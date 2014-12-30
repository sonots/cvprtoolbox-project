function [sigmap, sublist, Xn] = ezw_dominantpass(X, T, sublist, scan);
% EZW dominantpass function
%
%  [sigmap, sublist, Xn] = ezw_dominantpass(X, T, sublist, scan)
%
% Input arguments ([]s are optional):
%  X (matrix) of size NxN: wavelet coefficients matrix
%  T (scalar): treshold to use for this step, initial treshold should be
%            pow2(floor(log2(max(max(abs(wavedata))))))
%  sublist (matrix) of size ?x3: Subordinate list to be used in
%         subordinate pass which is containing the coefficients that
%         are detected significant in past passes
%            The 1st col is the original coefficient
%            The 2nd col is first reconstruction value of this coefficient
%            The 3rd col is the index at the scanning order
%  scan (matrix) of size N^2x2: scan order
%         (currently only Morton scan order supported).
%
% Output arguments ([]s are optional):
%  sigmap (string): Significant symbol map
%            'p' significant positive
%            'n' significant negative
%            'z' isolated zero
%            't' zerotree root
%  sublist (matrix) of size ?x3: Subordinate list to be used in
%         subordinate pass which is containing the coefficients that
%         are detected significant in past and current passes
%            The 1st col is the original coefficient
%            The 2nd col is first reconstruction value of this coefficient
%            The 3rd col is the index at the scanning order
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
    error('Size of Image must be power of 2');
end
if nargin < 4,
    scan = ezw_mortonorder(N);
end

% Initialization
Xn = X; % store originals to undo bookkeeping actions
sigmap  = [];

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
            % push new siginificant coef to subordinate list
            sublist = [sublist; [X(i,j), T + T/2, k]];
        else % negative significant
            sigmap = [sigmap 'n'];
            sublist = [sublist; [X(i,j), -T - T/2, k]];
        end
        Xn(i,j) = NaN; % ignore in the next pass
    else % zerotree or isolated zero
        if i > N/2 | j > N/2 % no children (either of 't' or 'z')
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
% sort sublist in scanning (morton) order
sublist = sortrows(sublist, 3);
end
