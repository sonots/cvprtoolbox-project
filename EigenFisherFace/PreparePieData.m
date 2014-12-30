% Create mat/Data%d.mat data from '../../../../imagedb/PIE'
function PreparePieData(Experiment)
nClass = 68; % PIE database
root = '../../../../imagedb/PIE';

if ~exist('Experiment', 'var')
    fprintf('1\n');PreparePieData(1);
    fprintf('2\n');PreparePieData(2);
    fprintf('3\n');PreparePieData(3);
    fprintf('4\n');PreparePieData(4);
    return;
elseif Experiment == 1
    Experiment = 1;
    TrainingSet = [8, 9]; % generation of pca space
    GallerySet = [11]; % database
    ProbeSet = [1, 4, 6, 8, 14, 20]; % query
elseif Experiment == 2
    TrainingSet = [2, 3];
    GallerySet = [1]; % right half is shaded
    ProbeSet = [11, 5, 6, 8, 14, 20];
elseif Experiment == 3
    % no gallery, gallery set is the training set
    TrainingSet = [2 5 8 9 10];
    ProbeSet = [4 7 9 11 12 13 15 18 19];
elseif Experiment == 4
    TrainingSet = [1 2 3 14 21];
    ProbeSet = [4 7 9 11 12 13 15 18 19];
end

%% Training Set
for c = 1:nClass
    I = [];
    for i = TrainingSet
        I(end+1, :, :) = imread(sprintf('%s/%02d/img%02d.bmp', root, i, c));
    end
    Xt{c} = double(reshape(I, size(I,1), []).');
end

% %% Gallery (Representative) Set
% if ~exist('GallerySet', 'var') || isempty(GallerySet)
%     Xg = Xt;
% else
% for i = GallerySet
%     I = [];
%     for c = 1:nClass
%         I(end+1, :, :) = imread(sprintf('PIE/%02d/img%02d.bmp', i, c));
%     end
%     Xg{c} = double(reshape(I, size(I,1), []).');
% end
% end

%% Probe (Query) Set
for c = 1:nClass
    I = [];
    for i = ProbeSet
        I(end+1, :, :) = imread(sprintf('%s/%02d/img%02d.bmp', root, i, c));
    end
    Xq{c} = double(reshape(I, size(I,1), []).');
end


eval(sprintf('save mat/Data%d.mat Xt Xq', Experiment));
