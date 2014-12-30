function O = doDct(I)
% Discrete cosine transform (DCT).
%
%  [O] = doDct(I)
%
% Input arguments ([]s are optional):
%  I  (vector) of size Nx1. Input
%
% Output arguments ([]s are optional):
%  O  (vector) of size Nx1. Output
%
% see also: dct
%
% Author: Naotoshi Seo <sonots(at)umd.edu>
% Date  : March 2007
N = size(I, 1);
C = gen_dctbasis(N);
O = C*I;