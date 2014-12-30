% [P,cond]=proj_from_pts_lin(Y,X)
% Linearly estimate the projectivity (k*d projective transformation) P
% mapping a set of n d-D homogeneous projective points X to a set of n
% k-D ones Y: i.e. Y ~ P.X, where n>=ceil((k*d-1)/(k-1))
%
% Input: homogeneous point matrices X(d,n),Y(k,n)
% Output: estimated homography matrix P(k,d) and condition numbers
%	cond = [smallest/largest `non-zero' singular value,
%	        `zero'/smallest `non-zero' singular value]
%	(ideally these should be close to [1,0] )
%
% Method: for each point p, P.xp is approximately parallel to yp,
% so applying the orthogonal projector O(yp) = I-yp*yp'/(yp'*yp) gives
% O(yp).P.xp ~= 0, i.e. k linear constraints on the k*d elements of P
% (k-1 linearly independent). We assemble the constraints, and solve
% for P by minimum SVD.

function [P,cond]=proj_from_pts_lin(Y,X)
   [d,n] = size(X); 
   [k,ny] = size(Y);
   kd = k*d;
   if (~(ny==n)) error('#points in X and Y differ: %d/%d',n,ny); end;
   c = ceil((kd-1)/(k-1));
   if (n<c) error('too few points for solution: %d/%d',n,c); end;
   A = zeros(n*k,kd);
   for p = 1:n
      yp = Y(:,p);
      A((p-1)*k+1:p*k,:) = kron(X(:,p)',eye(k)-yp*yp'/(yp'*yp));
   end;
   [U,S,V] = svd(A);
   cond = [S(kd-1,kd-1)/S(1,1), S(kd,kd)/S(kd-1,kd-1)];
   P = sqrt(k)*reshape(V(:,kd),k,d);

   % optional sign hack
   ok = 0;
   for p = 1:n
      ok = ok + (Y(:,p)'*P*X(:,p)>=0);
   end;
   if (ok<n/2) P = -P; end;
%end;
