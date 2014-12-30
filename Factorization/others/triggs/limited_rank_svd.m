% [U,S,V] = limited_rank_svd(A,k)
% Find a rank k approximation to the SVD of A by block power iteration:
% A(m,n) ~= U(m,k)*S(k,k)*V(n,k)' where U,V are orthonormal and S is
% decreasing diagonal. For rank(A)>k, U,S,V should closely approximate
% the first k columns of the full SVD of A provided the relative gap
% between the k^th and (k+1)^st S.V. of A is sufficiently large.
% Convergence is linear at rate |S(k+1,k+1)/S(k,k)|^2, and is fast if
% this is <<1, but slow and eventually unreliable if not. If rank(A)<k
% the non-zero singular vectors of A should be correct, and the
% remaining ones will be somewhere arbitrary in the null space.

function [U,S,V] = limited_rank_svd(A,k)
   [m,n] = size(A);
   if (k>min(m,n)) k = min(m,n); end;
   U = zeros(m,k); S = zeros(k,k); V = zeros(k,n);

   % Pull out k strong, orthogonal column-space vectors by k steps of
   % modified Gram-Schmidt QR with column pivoting, i.e. choose k
   % columns, at each stage projecting the remaining columns orthogonal
   % to the chosen one, and choosing the strongest remaining one.
   B = A;
   for i = 1:k
      nmax=-1; c=0;
      for j = 1:n-i+1
	 nj = norm(B(:,j));
	 if (nj>nmax) nmax = nj; c = j; end;
      b = B(:,c)/nmax;
      U(:,i) = b;
      B = B(:,[1:c-1,c+1:n-i+1]);
      B = B - b*(b'*B);
   end;

   % `Simultaneous iteration' (block power method): keep multiplying U
   % by A*A' to select largest modulus singular values, but at each
   % stage do a QR decomposition to keep columns of U orthogonal. The
   % convergence test is based on A*A'*U rather than U as if rank(A)<k
   % the extra directions in U are very unstable but don't affect the
   % final SVD much in norm (they have small S.V.s and entries in
   % R). But we also don't want to wait for U to stabilize to the exact
   % S.V. basis (i.e. R -> diagonal S): it is enough for U to span the
   % nonzero s.v. column space as we find the actual S.V.s by an n*k
   % SVD. So we project A*A'*U orthogonally to Uprev to test whether
   % the (A*A')-weighted span(U) has stabilized.

   % FIXME: power iteration is painfully slow if the relative gap
   % between the k^th and k+1^st S.V. is small. The heuristic shifting
   % strategy below helps a bit, but an adaptive estimate of the biggest
   % residual S.V. would help. The fixed shift has to be large to have
   % much effect on the small gap case, but must be less than half of
   % S.V. #k (~=R(k,k)) to stop shifts of near-zero SV's exploding.
   % 0.3--0.4 seems about right, and often about halves the number of
   % iterations.
   shift=0;
   for it = 1:100
      Uprev = U;
      AAU = A*(A'*U)-shift*U;
      [U,R] = qr(AAU,0);
      na = norm(AAU-Uprev*(Uprev'*AAU),1);
      if (na<1e-10) break; end;
      shift=0.4*R(k,k);
   end;
   
   % Find V by SVD of A'*U, and straighten U to a corresponding
   % S.V. basis.
   [V,S,U1] = svd(A'*U,0);
   U = U*U1;
%   na,it,norm(A-U*S*V',1)
end;