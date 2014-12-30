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
    % mark significant coeff at previous pass as NaN to skip in current pass
    Xn = X; Xn(find(Xn ~= 0)) = NaN; 
    Xn = iezw_dominantpass(Xn, sigmaps{i}, T, scan);
    Xn = iezw_subordinatepass(Xn, refmaps{i}, T, scan);
    % update not NaN parts
    index = ~isnan(Xn); X(index) = Xn(index);
    T = T / 2;
end
end

function [X] = iezw_dominantpass(X, sigmap, T, scan);
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
%  X (matrix) of size NxN: decoded wavelet coefficients matrix
%
% Author: Naotoshi Seo <sonots(at)umd.edu>
% Date  : April 2007

% Input Argument Check
[N, nCol] = size(X);
if N ~= nCol
    error('The # of rows and # of cols must be same');
end
if mod(log2(N), 1) ~= 0
    error('Size of Image must be multiples of 2');
end
if nargin < 4,
    scan = ezw_mortonorder(N);
end


index = 1; % index in significance map
for k = 1:N*N;
    % get matrix index for k
    i = scan(k,1);
    j = scan(k,2);
    % NaN marks elements already dedected as significant in previous pass
    % realmax marks elements detected as in zerotree (only for this pass!)
    %if(isnan(X(i,j)) | X(i,j) == realmax)
    if (X(i, j) ~= 0)
        continue;
    end
    % determine type of k
    if(sigmap(index) == 'p'), % k is significant positive
        X(i, j) = T + T/2;
    elseif(sigmap(index) == 'n'), % k is significant negative
        X(i, j) = -T - T/2;
    elseif(sigmap(index) == 'z'), % k is isolated zero
        X(i, j) = 0;
    else
        % k is zerotree root ('t')
        X(i, j) = 0;
        mask = ezw_childtree(i, j, N);
        X = X + (mask * realmax);
    end
    index = index + 1;
end
% realmax (zerotree mark) must be restored to 0
X(find(X == realmax)) = 0;
end

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
    error('Size of Image must be multiples of 2');
end
if nargin < 4,
    scan = ezw_mortonorder(N);
end

index = 1; % index in refinement map
for k = 1:N*N;
    % get matrix index for k
    i = scan(k,1);
    j = scan(k,2);
    % NaN marks elements dedected as significant in previous pass
    % 0 of course marks elements detected as in zerotree or isolated zero
    if(isnan(X(i, j)) | X(i, j) == 0)
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
