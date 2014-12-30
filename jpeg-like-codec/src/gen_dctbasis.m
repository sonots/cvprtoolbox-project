function C = gen_dctbasis(N)
% Generate Basis Vectors for Unitary DCT
%
%  [C] = gen_dctbasis(N)
%
% Input arguments ([]s are optional):
%  N  (scalar) size N. 
%
% Output arguments ([]s are optional):
%  C  (matrix) of size NxN. Basis Vectors. Rows of C form orthonormal
%  basis.
%
% see also: dctmtx
%
% Author: Naotoshi Seo <sonots(at)umd.edu>
% Date  : March 2007
k = 0;
for n = 0:N-1
    C(k+1, n+1) = sqrt(1/N) * cos( pi*k*(2*n+1) / (2*N) );
end
for k = 1:N-1
    for n = 0:N-1
        C(k+1, n+1) = sqrt(2/N) * cos( pi*k*(2*n+1) / (2*N) );
    end
end
