% [F12s,cond]=Fspace_from_pts(x1,x2,k)
% Estimate a `k-point', (9-k)-D subspace of the 9-D space of all 3x3
% matrices, likely to approximately contain the fundamental matrix F
% linking two sets X,Y of n homogeneous image points. This is used to
% obtain small subspaces of F-space on which to enforce nonlinear
% constraints, as in the `7-point' F-matrix and `6-point' essential
% matrix methods, or from which to project a valid F-matrix as in the
% `8-point + SVD' method.
%
% Method: each point pair gives a linear constraint on the 9 components
% of F, assemble the constraints into an nx9 matrix A, SVD to find the
% minimal residual error (9-k)-D subspace, and read off the F matrices.
% In applications, *any* (9-k)-D subspace containing the true F would
% usually do, but the minimum residual subspace contains the directions
% of greatest uncertainty, so is the subspace most likely to lie close
% to the true F, and on which nonlinear constraints are likely provide
% the most useful reduction of variability.
%
% Input: 3xn matrices x1,x2 of standardized homogeneous image points
% Output: estimated fundamental matrix basis F12(3,3*(9-k)) and
% condition numbers (normalized singular values), which
% should ideally be close to [ones(k),zeros(9-k)]

function [F12s,cond]=Fspace_from_pts(x1,x2,k)
   if (k<1 | k>8) error('bad subspace dimension: %d',k); end;
   [d,n] = size(x1); 
   [d2,n2] = size(x2);
   if (~(d==3) | ~(d2==3)) error('bad x1/x2 point dimension: %d/%d',d,d2); end
   if (~(n2==n)) error('#points in x1 and x2 differ: %d/%d',n,n2); end;
   if (n<k) error('too few points for solution: %d/%d',n,k); end;
   A = zeros(max(n,9),9);
   for p = 1:n
      A(p,:) = kron(x2(:,p)',x1(:,p)');
   end;
   [U,S,V] = svd(A);
   cond = diag(S)/S(1,1);
   F12s = sqrt(2)*reshape(V(:,k+1:9),3,3*(9-k));
%end;
