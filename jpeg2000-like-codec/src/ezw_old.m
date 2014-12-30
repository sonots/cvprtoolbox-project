function [N, T0, sigmaps, refmaps] = ezw(X, Tmin);
% EZW encoding
%
%  [N T0 sigmaps refmaps] = ezw(X, Tmin)
%
% Input arguments ([]s are optional):
%  X (matrix) of size NxN: wavelet coefficients
%  [Tmin] (scalar): minimum threshold of iterations. Default is 2
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
%
% Author: Naotoshi Seo <sonots(at)umd.edu>
% Date  : April 2007

% Input Argument Check
if nargin < 2, Tmin = 2; end
[N, nCol] = size(X);
if N ~= nCol
    error('The # of rows and # of cols must be same');
end
if mod(log2(N), 1) ~= 0
    error('Size of Image must be multiples of 2');
end

% Initial threshold
T0 = 2^floor(log2(max(max(abs(X)))));
T  = T0;
% Generate Morton scan order
scan = ezw_mortonorder(N);

% Encoding, Iterate dominant pass and subordinate pass
i = 1;
while T >= Tmin
    [sigmaps{i} sublist X] = ezw_dominantpass(X, T, scan);
    [refmaps{i} sublist] = ezw_subordinatepass(sublist, T);
    i = i + 1;
    T = T / 2;
end
end

function [sigmap, sublist, Xn] = ezw_dominantpass(X, T, scan);
% EZW dominantpass function
%
%  [sigmap, sublist, Xn] = ezw_dominantpass(X, T)
%
% Input arguments ([]s are optional):
%  X (matrix) of size NxN: wavelet coefficients matrix
%  T (scalar): treshold to use for this step, initial treshold should be
%            pow2(floor(log2(max(max(abs(wavedata))))))
%  scan (matrix) of size N^2x2: scan order
%         (currently only Morton scan order supported).
%
% Output arguments ([]s are optional):
%  sigmap (string): Significant symbol map
%            'p' significant positive
%            'n' significant negative
%            'z' isolated zero
%            't' zerotree root
%  sublist (matrix) of size 2x?: Subordinate list to be used in
%         subordinate pass which is containing the coefficients that
%         are detected significant in _this_ pass
%            The 1st row is the original coefficient
%            The 2nd row is first reconstruction value of this coefficient
%  Xn (matrix) of size NxN:
%         new wavelet coefficients to be used in the next pass
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
if nargin < 3,
    scan = ezw_mortonorder(N);
end

% Initialization
Xn = X; % store original to undo bookkeeping actions
sigmap  = [];
sublist = [];

for k = 1:N*N
    % get matrix index for k
    i = scan(k,1);
    j = scan(k,2);
    % NaN marks elements already dedected as significant in previous pass
    % realmax marks elements detected as in zerotree (only for this pass!)
    if(isnan(Xn(i,j)) | Xn(i,j) == realmax)
        continue;
    end
    if (abs(Xn(i,j)) >= T) % significant
        if (Xn(i,j) >= 0) % positive significant
            sigmap = [sigmap 'p'];
            % original data and reconstructed value
            sublist = [sublist [X(i,j); T + T/2]];
        else % negative significant
            sigmap = [sigmap 'n'];
            sublist = [sublist [X(i,j); -T - T/2]];
        end
        Xn(i,j) = NaN; % ignore in the next pass
    else % zerotree or isolated zero
        if i > N/2 | j > N/2 % definitely isolated zero if no children
            sigmap = [sigmap 'z'];
        else
            mask = ezw_childtree(i,j,N);
            children = Xn .* mask;
            if(isempty(find(abs(children) >= T)))
                % zerotree root
                sigmap = [sigmap 't'];
                % mark elements as zerotree nodes (only for this pass!)
                Xn = Xn + (mask * realmax);
            else % isolated zero
                sigmap = [sigmap 'z'];
            end
        end
    end
end
% realmax (zerotree mark) must be restored to original value, but keep NaN
index = find(Xn == realmax);
Xn(index) = X(index);
end

function [refmap, sublist] = ezw_subordinatepass(sublist, T);
% EZW subordinatepass function
%
%  [refmap sublist] = ezw_dominantpass(X, T)
%
% Input arguments ([]s are optional):
%  sublist (matrix) of size 2x?: Subordinate list to be used in
%         subordinate pass which is containing the coefficients that
%         are detected significant in _this_ pass
%            The 1st row is the original coefficient
%            The 2nd row is first reconstruction value of this coefficient
%  T (scalar): treshold
%
% Output arguments ([]s are optional):
%  refmap: matrix containing 0's and 1's for refinement of the suborinate list
%  [sublist]: new subordinate list (reconstruction values are refined)
%
% Author: Naotoshi Seo <sonots(at)umd.edu>
% Date  : April 2007
refmap = zeros(1, size(sublist, 2));
refmap(find(abs(sublist(1, :)) > T + T/2)) = 1;
if nargout < 2,
    return;
end
% update sublist(2,:) (reconstructed values) if wantted
for i = 1:length(refmap),
    if(refmap(i) == 1),
        if(sublist(1,i) > 0),
            sublist(2,i) = sublist(2,i) + T/4;
        else
            sublist(2,i) = sublist(2,i) - T/4;
        end
    else
        if(sublist(1,i) > 0),
            sublist(2,i) = sublist(2,i) - T/4;
        else
            sublist(2,i) = sublist(2,i) + T/4;
        end
    end
end
end
