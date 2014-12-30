function [mask] = ezw_childtree(i, j, N);
% Generate EZW Child-tree mask for given coefficient poition
%  The mask has a 1 on positions on children nodes, 0 elsewhere
%
%  mask = ezw_childtree(i, j, N) 
%
% Input arguments ([]s are optional):
%  i (scalar) the row position of the coefficient matrix
%  j (scalar) the col position of the coefficient matrix
%  N (scalar) the # of rows (or # of cols) of the coefficient matrix
%  
% Output arguments ([]s are optional):
%  mask (matrix) of size NxN: is the mask matrix
%    selected = mask .* wavelet_matrix;
%
% Author: Naotoshi Seo <sonots(at)umd.edu>
% Date  : April 2007
mask = zeros(N);
i_min = 2*i-1;
i_max = 2*i;
j_min = 2*j-1;
j_max = 2*j;
while(i_max <= N & j_max <= N),
   mask(i_min:i_max, j_min:j_max) = 1;   
   % calculate new subset
   i_min = 2*i_min - 1;
   i_max = 2*i_max;
   j_min = 2*j_min - 1;
   j_max = 2*j_max;
end