% [Ps,Xs,cond] = proj_recons_ppsvd(xs,serial,xxx)
%
% Projective reconstruction of m images of n points by SVD, assuming
% prior plane+parallax alignment. Epipolar depth estimation. 
%
% Inputs: xs(3*m,n) = matrix of homogeneous image points, standardized
% so that all coordinates are of O(1), and p+p aligned to a common plane.
% Flag rem(serial,2)==1 for serial chain, 0 for parallel chain depth 
% recovery.
% Flag fixed_rank==1: use an iterative method based on the rank-4-ness
% of the exact solution, rather than conventional SVD. This is O(m*n)
% rather than O(m*n*min(m,n)), i.e. much faster if both #images and
% #points are large, but not as stable and perhaps slightly less
% accurate than true SVD. For fixed_rank>1, try to guess the best method.
%
% Outputs: Ps(3*m,4) = matrix of m reconstructed 3x4 image projection
% matrices. Xs(4,n) = n reconstructed homogeneous image points. 
% Condition numbers cond = [range of first 4 singular values, step down
% to 5th singular value]. (Ideally, cond ~ [near 1, near 0]).
%
% The standard projective output frame with the alignment plane at
% infinity is used -- this may be far from any Euclidean frame.
%
% Method: see [Triggs XXX'99]

function [Ps,Xs,cond,xs] = proj_recons_ppsvd(xs,nplanar,serial,xxx)
   m = size(xs,1)/3;
   n = size(xs,2);
   
   % calculate homographies and align points if required
   % nplanar=0 for already aligned, >=4 for align
   if nplanar>0
      if nplanar<4, error('Not enough points for alignment',nplanar); end;
      xps = xs(:,1:nplanar);
      Hs = zeros(3,3*m);
      Hs(:,1:3) = eye(3);
      for i=2:m
	 [H,cond] = proj_from_pts_lin(xps(1:3,:),xps(3*i-2:3*i,:));
	 H = H/H(3,3);
	 Hs(:,3*i-2:3*i) = H;
	 xs(3*i-2:3*i,:) = H * xs(3*i-2:3*i,:);
      end;
      % Hs
      %crosses = zeros(m-1,n);
      %      for p=1:n
      %	 for i=2:m
      %	    crosses(i-1,p) = norm(cross(xs(3*i-2:3*i,p),xs(1:3,p)),2);
      %	 end;
      %      end;
      %  crosses
   end;

   % work out projective depths by Epipolar depth propagation
   % (serial==1) ==> use serial image 1->2->3...->m chain, otherwise
   % use parallel 1->2, 1->3,... 1->m chain

   lambda = ones(m,n);
   iref = 1;
   for i = 2:m
      xref = xs(3*iref-2:3*iref,:);
      xi = xs(3*i-2:3*i,:);
      % estimate epipole for depth recovery
      xir = zeros(3,n);
      for p = 1:n
	 xir(:,p) = cross(xref(:,p),xi(:,p));
      end;
      [U,S,V] = svd(xir');
      eri = V(:,3);
      for p = 1:n
	 xe = cross(xi(:,p),eri);
	 lambda(i,p) = lambda(iref,p)*abs((xe'*cross(xref(:,p),eri))/(xe'*xe));
      end;
      if (rem(serial,2)) iref = i; end;	% else iref = 1
   end;

   % Balance depth matrix by rescaling each point (column)
   % we can't rescale the images (triples of rows) as the 
   % scale of each projection P(i) = (I; -cop(i)) is fixed.
   for p = 1:n
      lp = lambda(:,p);
      lambda(:,p) = lp/norm(lp);
   end;

   % rescale the image points
   for i = 1:m
      for p = 1:n
	 xs(3*i-2:3*i,p) = lambda(i,p)*xs(3*i-2:3*i,p);
      end;
   end;

   % find and subtract off the means
   xmeans = zeros(3,n);
   ys = xs;
   for p = 1:n
      xmeans(:,p) = sum(reshape(xs(:,p),3,m)')'/m;
      xs(:,p) = xs(:,p) - kron(ones(m,1),xmeans(:,p));
   end;

   % if (xxx)
   %   [Q,R] = qr(xmeans');
   %   C = xs * Q';
   %   xs = xs - C * Q;
   %  ...
   % else

   % Rank 1 SVD gives the cop's and weights
   [U,S,V] = svd(xs);
   cops = S(1,1)*U(:,1);
   heights = V(:,1)';
   S = S/S(1,1);
   cond = [S(2,2)];
   % sing_vals = diag(S)'
   Xs = [xmeans; heights];
   Ps = [kron(ones(m,1),eye(3)), cops];
   % [reshape(ys,3,m*n); reshape(Ps*Xs,3,m*n)]
   if nplanar>0
      for i = 2:m
	 Ps(3*i-2:3*i,:) = Hs(:,3*i-2:3*i) \ Ps(3*i-2:3*i,:);
      end;
   end;
   
%end;
