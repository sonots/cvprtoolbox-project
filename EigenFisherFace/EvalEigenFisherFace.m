% Experimental comparison of Eigenface and Fisherface
% requires mat/Data%d.mat, see PreparePieData
function EvalEigenFisherFace(Experiment,M)
if ~exist('Experiment', 'var'), Experiment = 1; end;
if ~exist('M', 'var'), M = 1:20; end;
eval(sprintf('load mat/Data%d.mat Xt Xq', Experiment));

figure; hold on;
[Classified, Rate, Rank] = Eigenface(Xt, Xq, M);
eval(sprintf('save mat/Data%dEigen.mat M Classified Rate Rank', Experiment));
set(findobj(gca,'Type','line','Color',[0 0 1]),'Color','red','Marker','o');

[Classified, Rate, Rank] = Fisherface(Xt, Xq, M);
eval(sprintf('save mat/Data%dFisher.mat M Classified Rate Rank', Experiment));
set(findobj(gca,'Type','line','Color',[0 0 1]),'Color','red','Marker','+');

legend('Eigenface','Fisherface');
