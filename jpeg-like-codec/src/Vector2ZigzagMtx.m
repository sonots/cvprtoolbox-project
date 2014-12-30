function A = Vector2ZigzagMtx(V, ind)
% JPEG like inverse zigzag scanning
%
%  A = Vector2ZigzagMtx(V)
%
% Input arguments ([]s are optional):
%  V     (vector) of size 1xN^2
%  [ind] (matrix) of size N^2x1. Zigzag indicies matrix if available
%
% Output arguments ([]s are optional):
%  A   (matrix) of size NxN. Restored matrix
%
% see also: gen_zigzagind.m
%
% Author: Naotoshi Seo <sonots(at)umd.edu>
% Date  : March 2007
if nargin < 2,
    ind = gen_zigzagind(sqrt(length(V))); 
end
A=[];
for k=1:length(V)
    A( ind(k,1),ind(k,2) )=V(k);
end    
