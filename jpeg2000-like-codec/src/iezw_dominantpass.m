function [Xn] = iezw_dominantpass(X, sigmap, T, scan);
% EZW Inverse dominantpass, decode significance map (1 pass)
%
%  X = iezw_dominantpass(X, sigmap, T, scan)
%
% Input arguments ([]s are optional):
%  X (matrix) of size NxN: wavelet coefficients matrix to be refined
%  sigmap (string or vector): significance symbol map ('p','n','z',and't')
%  T (scalar): treshold to use for this pass
%  scan (matrix) of size N^2x2: scan order
%         (currently only Morton scan order supported). 
%
% Output arguments ([]s are optional):
%  Xn (matrix) of size NxN: decoded wavelet coefficients matrix
%
% Author: Naotoshi Seo <sonots(at)umd.edu>
% Date  : April 2007

% Input Argument Check
[N, nCol] = size(X);
if N ~= nCol
    error('The # of rows and # of cols must be same');
end
if mod(log2(N), 1) ~= 0
    error('Size of Image must be power of 2');
end
if nargin < 4,
    scan = ezw_mortonorder(N);
end

Xn = X; % store original to undo bookkeeping actions
index = 1; % index in significance map
for k = 1:N*N;
    % get matrix index for k
    i = scan(k,1);
    j = scan(k,2);
    % realmax marks elements detected as in zerotree (only for this pass!)
    % elements dedected as significant in past passes have real values
    if (Xn(i, j) ~= 0)
        continue;
    end
    % determine type of k
    if(sigmap(index) == 'p'), % k is significant positive
        Xn(i, j) = T + T/2;
    elseif(sigmap(index) == 'n'), % k is significant negative
        Xn(i, j) = -T - T/2;
    elseif(sigmap(index) == 'z'), % k is isolated zero
        Xn(i, j) = 0;
    elseif(sigmap(index) == 't'), % k is zerotree root ('t')
        Xn(i, j) = 0;
        mask = ezw_childtree(i, j, N);
        Xn = Xn + (mask * realmax);
    end
    index = index + 1;
end
% realmax (zerotree mark) must be restored
index = find(Xn == realmax);
Xn(index) = X(index);
end
