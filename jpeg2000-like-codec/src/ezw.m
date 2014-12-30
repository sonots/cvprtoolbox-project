function [N, T0, sigmaps, refmaps] = ezw(X, Tmin);
% EZW encoding
%
%  [N T0 sigmaps refmaps] = ezw(X, Tmin)
%
% Input arguments ([]s are optional):
%  X (matrix) of size NxN: wavelet coefficients
%  [Tmin] (scalar): minimum threshold of iterations. 
%        Default is 1 (perfect reconstruction for interger coefficients)
%
% Output arguments ([]s are optional):
%  N  (scalar): size of wavelet coefficients matrix
%  T0 (scalar): initial threshold used while encoding
%  sigmaps (cell of strings):
%   Significant map containing significance data ('p','n','z','t') for
%   each pass. Each string contains data for a different pass.
%  refmaps (cell of row vectors):
%   Refinement map containing refinement data (0 or 1) for each
%   pass. Each vector contains data for a different pass.
%
% Uses: ezw_childtree.m, ezw_mortonorder.m
% See also: iezw.m
%
% Author: Naotoshi Seo <sonots(at)umd.edu>
% Date  : April 2007

% Input Argument Check
if nargin < 2, Tmin = 1; end
[N, nCol] = size(X);
if N ~= nCol
    error('The # of rows and # of cols must be same');
end
if mod(log2(N), 1) ~= 0
    error('Size of Image must be power of 2');
end

% Initial threshold
T0 = 2^floor(log2(max(max(abs(X)))));
T  = T0;
% Generate Morton scan order
scan = ezw_mortonorder(N);

% Encoding, Iterate dominant pass and subordinate pass
i = 1;
sublist = [];
while T >= Tmin
    fprintf('pass %d ...\n', i);
    tic
    [sigmaps{i} sublist X] = ezw_dominantpass(X, T, sublist, scan);
    [refmaps{i}] = ezw_subordinatepass(sublist, T, T0);
    toc
    i = i + 1;
    T = T / 2;
end
end


