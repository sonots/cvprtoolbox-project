function [X] = iezw(N, T0, sigmaps, refmaps)
% EZW decoding
%
%  [X] = iezw(N, T, sigmaps, refmaps)
%
% Input arguments ([]s are optional):
%  N  (scalar): The size of reconstructed matrix (NxN)
%  T0 (scalar): initial threshold used while encoding
%  sigmaps (cell of strings): 
%   Significant map containing significance data ('p','n','z','t') for 
%   each pass. Each string contains data for a different pass. 
%  refmaps (cell of row vectors:
%   Refinement map containing refinement data (0 or 1) for each
%   pass. Each vector contains data for a different pass. 
%  
% Output arguments ([]s are optional):
%  X (matrix) of size NxN: reconstructed wavelet coefficients
%
% Uses: ezw_childtree.m, ezw_mortonorder.m
%
% Author: Naotoshi Seo <sonots(at)umd.edu>
% Date  : April 2007

% Initialization
X = zeros(N);
T = T0;
% Generate Morton scan order
scan = ezw_mortonorder(N);

% Decoding
for i = 1:length(sigmaps)
    fprintf('pass %d ...\n', i);
    tic
    X = iezw_dominantpass(X, sigmaps{i}, T, scan);
    X = iezw_subordinatepass(X, refmaps{i}, T, scan);
    toc
    T = T / 2;
end
end
