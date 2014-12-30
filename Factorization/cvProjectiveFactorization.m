function [P, X, T] = cvProjectiveFactorization(W)
% cvProjectiveFactorization - The projective factorization method
%
% Synopsis
%  [P, X, T] = cvProjectiveFactorization(W)
%
% Inputs ([]s are optional)
%  (matrix) W        2F x P matrix of image points where F is the
%                    number of frames and P is the number of points
%                    in one frame. 2 is for x coordinate and y coordinate.
%
% Outputs ([]s are optional)
%  (matrix) P        3F x 4 matrix representing F reconstructed
%                    3 x 4 image projection matricies
%  (matrix) X        4 x P reconstructed image points
%  (matrix) T        3 x 3 transformation matrix
%
% References
%  [1] Bill Triggs, Factorization methods for projective structure and
%  motion. In Proceeding of 1996 Computer Society Conference on Computer
%  Vision and Pattern Recognition, pages 845--51, San Francisco,
%  CA, USA, 1996. IEEE Comput. Soc. Press.
%  http://citeseer.ist.psu.edu/article/triggs96factorization.html
%
% Authors
%  Naotoshi Seo <sonots(at)sonots.com>
%
% Requirements
%  proj_recons_fsvd.m (Triggs factorization toolbox), normalise2dpts.m
%  >> addpath('others');
%  >> addpath('others/triggs');
%
% License
%  The program is free to use.

% Changes
%  11/01/2006  First Edition
m = size(W, 1) / 2;
n = size(W, 2);

%  t = mean(W, 2);
%  W = W - repmat(t, 1, size(W, 2));
%  mean(W, 2)
%  s = W.^2;
%  s = s(1:m, :) + s(m+1:2*m, :);
%  s = mean(s, 2);
%  s = sqrt(s) / sqrt(2);
%  W = W ./ repmat(s, 2, size(W, 2));

U = W(1:m, :);
V = W(m+1:2*m, :);
for j=1:n
    for i=1:m
        x(i*3-2, j) = U(i, j);
        x(i*3-1, j) = V(i, j);
        x(i*3  , j) = 1;
    end
end
for i=1:m
    [xt(i*3-2:i*3, :) T{i}] = normalise2dpts(x(i*3-2:i*3, :));
end
[P, X, cond] = proj_recons_fsvd(x,1,0);
end