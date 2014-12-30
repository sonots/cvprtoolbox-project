function [refmap, sublist] = ezw_subordinatepass(sublist, T, T0);
% EZW subordinatepass function
%
%  [refmap sublist] = ezw_dominantpass(X, T)
%
% Input arguments ([]s are optional):
%  sublist (matrix) of size ?x(over 1): Subordinate list to be used in
%         subordinate pass which is containing the coefficients that
%         are detected significant in past and current passes
%            The 1st col is the original coefficient
%  T (scalar): treshold
%  T0 (scalar): initial treshold
%
% Output arguments ([]s are optional):
%  refmap: matrix containing 0's and 1's for refinement of the suborinate list
%  [sublist]: new subordinate list (reconstruction values are refined)
%
% Author: Naotoshi Seo <sonots(at)umd.edu>
% Date  : April 2007

% T0 (initial) = 32, T = 16 (2nd pass)
% [16, 24) => 0, [24, 32) => 1
% [32, 40) => 0, [40, 48) => 1
% [48, 56) => 0, [56, 64) => 1
if T/2 >= 1,
    % smart shortcut
    refmap = zeros(1, size(sublist, 1));
    refmap(find(bitand(abs(round(sublist(:,1))),T/2) == T/2)) = 1; 
else
    % ordinal way
    for i = 1:size(sublist, 1)
        for t = T:T:T0*2
            if abs(sublist(i, 1)) > t + t/2
                refmap(i) = 1;
            elseif abs(sublist(i, 1)) > t
                refmap(i) = 0;
            else
                break;
            end
        end
    end
end

% refine reconstructed values if wants
if nargout < 2,
    return;
end
for i = 1:length(refmap),
    if(refmap(i) == 1),
        if(sublist(i,1) > 0),
            sublist(i,2) = sublist(i,2) + T/4;
        else
            sublist(i,2) = sublist(i,2) - T/4;
        end
    else
        if(sublist(i,1) > 0),
            sublist(i,2) = sublist(i,2) - T/4;
        else
            sublist(i,2) = sublist(i,2) + T/4;
        end
    end
end
end