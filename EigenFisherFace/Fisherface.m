% An experiment on the fisherface recognition
% You may separate training and classification processes. 
%
% Input
%   (cell)   Xt   c cell of D x Ni matrix which contains a training data
%                 where c is the number of classes and D is the number 
%                 of dimensions of the feature vector and Ni is the number
%                 of samples (feature vectors) for class i, 1 <= i < = c.
%   (cell)   Xq   c cell of D x Nj matrix which contains a query/test data
%                 where the total number of vectors is N. 
%   (scalar) [M]  The number of feature dimension reduced. 
%                 When this is a vector, an experiment to see effects
%                 of the number of reduced dimension is performed. 
% Output
%   (vector) Classified 1 x N
%   (scalar) Rate       1
%   (vector) Rank       c x 1
function [Classified, Rate, Rank] = Fisherface(Xt, Xq, M)
%% Load
[Xt Ct] = cvuCell2Mat(Xt);
[Xq Cq] = cvuCell2Mat(Xq);
[D, Nt] = size(Xt);
if ~exist('M', 'var') || isempty(M), 
    M = min(D, Nt-1);
end

%% Training
[W] = cvLda(Xt, Ct, M(end));

%% Classification
for m = length(M):-1:1
    W = W(:,1:M(m));
    Yt = cvLdaProj(Xt, W);
    Yq = cvLdaProj(Xq, W);
    [Classified{m}, Rank{m}] = cvKnn(Yq, Yt, Ct, 1);
    Rate(m) = sum(Classified{m} == Cq) / size(Cq,2);
end

%% Plot
if isscalar(M)
    Classified = Classified{1};
    Rank = Rank{1};
    Rate = Rate{1};
else
    plot(M, Rate);
    xlabel('Feature Dimension');
    ylabel('Recognition Rate');
    axis([M(1) M(end) 0 1.0]);
end