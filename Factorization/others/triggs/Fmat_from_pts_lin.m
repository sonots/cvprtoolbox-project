% [F12,cond] = Fmat_from_pts_lin(x1,x2)
% Linearly estimate the 3x3 fundamental matrix F linking two sets X,Y 
% of n homogeneous image points.
%
% Input: homogeneous image point matrices X(3,n),Y(3,n)
% Output: estimated fundamental matrix F12 and condition numbers
%	cond = [smallest/largest `non-zero' singular value,
%	        `zero'/smallest `non-zero' singular value]
%	(ideally these should be close to [1,0] )
%
% Method: the `8 point' method, followed by SVD to enforce the det(F)=0
% constraint.

function [F12,e12,e21,cond] = Fmat_from_pts_lin(x1,x2)
   [F12,cond] = Fspace_from_pts(x1,x2,8);
   [U,S,V] = svd(F12);
   S = S/S(1,1);
   cond = [S(2,2); S(3,3); cond];
   S(3,3) = 0;
   F12 = U*S*V';
   e12 = V(:,3);
   e21 = U(:,3);
%end;
