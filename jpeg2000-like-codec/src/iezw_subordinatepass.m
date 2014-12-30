function [X] = iezw_subordinatepass(X, refmap, T, scan);
% EZW Inverse dominantpass, decode refinement map (1 pass)
%
%  X = iezw_subordinatepass(X, refmap, T, scan)
%
% Input arguments ([]s are optional):
%  X (matrix) of size NxN: wavelet coefficients matrix to be refined
%  refmap (vector): refinement symbol map (0 or 1)
%  T (scalar): treshold to use for this pass
%  scan (matrix) of size N^2x2: scan order
%         (currently only Morton scan order supported). 
%
% Output arguments ([]s are optional):
%  X (matrix) of size NxN: refined wavelet coefficients matrix
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

index = 1; % index in refinement map
for k = 1:N*N;
    % get matrix index for k
    i = scan(k,1);
    j = scan(k,2);
    % 0 of course marks elements detected as in zerotree or isolated zero
    if(X(i, j) == 0)
        continue;
    end
    % if refmap bit is 1, add T/4 to current value
    % if refmap bit is 0, subtract T/4 from current value
    if(refmap(index) == 1),
        if(X(i, j) > 0),
            X(i, j) = X(i, j) + T/4;
        else
            X(i, j) = X(i, j) - T/4;
        end
    else
        if(X(i, j) > 0),
            X(i, j) = X(i, j) - T/4;
        else
            X(i, j) = X(i, j) + T/4;
        end
    end
    index = index + 1;
end
end
