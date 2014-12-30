function V = ZigzagMtx2Vector(A, ind)
% JPEG like zigzag scanning of matrix of size NxN into a vector
%
%  V = ZigzagMtx2Vector(A)
%
% Input arguments ([]s are optional):
%  A     (matrix) of size NxN.
%  [ind] (matrix) of size N^2x1. Zigzag indicies matrix if available
%
% Output arguments ([]s are optional):
%  V   (vector) of size 1xN^2
%
% see also: gen_zigzagind.m
%
% Author: Naotoshi Seo <sonots(at)umd.edu>
% Date  : March 2007
[nRow,nCol]=size(A);
if nRow ~= nCol
    error('input array should have equal number of rows and columns')
end
if nargin < 2,
    ind = gen_zigzagind(nRow); 
end
V = [];
for k=1:size(ind,1)
    V = horzcat(V, A(ind(k,1),ind(k,2)) ) ;
end