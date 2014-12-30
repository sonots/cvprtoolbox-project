function [O] = histnorm(I, L)
% Histogram Normalization or Streching
%
%  [O] = histnorm(I)
%
% Input arguments ([]s are optional):
%  I   (matrix) of size MxN. Input.
%  [L] (scalar) dynamic range. Default is 256.
%
% Output arguments ([]s are optional):
%  O   (matrix) of size MxN. Output
%
% Author: Naotoshi Seo <sonots(at)umd.edu>
% Date  : Feb 2007
if nargin < 2, L = 256;, end;
mini = min(min(I));
O = I - mini;
maxi = max(max(O));
O = O * (L-1) / maxi;
O = uint8(O);
end
