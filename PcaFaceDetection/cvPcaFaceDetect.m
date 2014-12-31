% cvPcaFaceDetect - Probabilistic PCA Model-based Face Detector
%
% Synopsis
%   [state, likeli] = cvPcaFaceDetect(I, PCA, imsize, factors, init_state, wsize, verbose)
%
% Description
%   Probabilistic PCA Model-based Face Detector
%
% Inputs ([]s are optional)
%   (matrix) I        nRow x nCol matrix representing input image
%   (struct) PCA      PCA subspace
%      PCA.V          PCA eigen vectors
%      PCA.Me         PCA mean vectors
%      PCA.Lambda     PCA eigen values
%   (vector) imsize   2 x 1 vector where [width height] representing
%                     resizing width and height of image patch.
%                     This is the size used when training PCA subspace
%   (vector) [init_state]
%                     The initial state
%                     [x; y; width; height; rotate]
%   (vector) [wsize]
%                     Searching range. -wsize to wsize
%                     [x; y; width; height; rotate]
%   (vector) [factors  = [0.1 0.25 0.5 1]
%                     A variable sized vector representing resizing factor
%                     of the entire image.
%                     The first iteration searches entire image roughly by
%                     making small the entire image.
%   (bool)   [verbose = 0]
%                     print intermediate results verbosely
%
% Outputs ([]s are optional)
%   (vector) state     [x y width height rotate]
%                     The detected face position
%   (scalar) [likeli] The likelihood probability of the detected face

% Authors
%   Naotoshi Seo <sonots(at)sonots.com>
%
% License
%   The program is free to use for non-commercial academic purposes,
%   but for course works, you must understand what is going inside to use.
%   The program can be used, modified, or re-distributed for any purposes
%   if you or one of your group understand codes (the one must come to
%   court if court cases occur.) Please contact the authors if you are
%   interested in using the program without meeting the above conditions.
%
% Changes
%   11/05/2008  First Edition
function [state likeli] = cvPcaFaceDetect(I, PCA, imsize, factors, init_state, wsize, verbose)
%% Initialization
if ~exist('init_state', 'var') || isempty(init_state)
    init_state = fix([
        size(I,2)/2 % x
        size(I,1)/2 % y
        imsize(2) % width
        imsize(1) % height
        0 % rotation
        ]);
end
if ~exist('wsize', 'var') || isempty(wsize)
    wsize = [10; 10; 3; 3; 5];
end
if ~exist('factors', 'var') || isempty(factors)
    factors = [0.1 0.2 0.5 1]; % resize factor
end
if ~exist('verbose', 'var') || isempty(verbose)
    verbose = 1;
end
state      = init_state;
region     = [state - wsize state + wsize];
entiregion = region;
%% Progressive Grid-based Search
% First, roughly search in entire region
% Then, finer searching in smaller region
for factor = factors
    if verbose, fprintf('factor:%f\n', factor); end;
    % make searching range smaller as iteration proceeds
    region(:,1) = state - wsize ./ (factor / factors(1));
    region(:,2) = state + wsize ./ (factor / factors(1));
    region = round(region);
    % make sure searching range to be inside entiregion
    region(:,1) = max(entiregion(:,1),region(:,1));
    region(:,2) = max(entiregion(:,1),region(:,2));
    region(:,1) = min(entiregion(:,2),region(:,1));
    region(:,2) = min(entiregion(:,2),region(:,2));
    if verbose, fprintf('region =\n');disp(region); end;
    % Grid search
    [state likeli] = GridSearch_(I, PCA, imsize, factor, region, verbose);
end
if state(5) < 0
    state(5) = state(5) + 360;
elseif state(5) >= 360
    state(5) = state(5) - 360;
end
end

%% GridSearch_ subfunction
function [state likeli] = GridSearch_(I, PCA, imsize, factor, region, verbose)
%% Initialization
nState = size(region,1);
possibleregion = [
    1 size(I,2); % x
    1 size(I,1); % y
    1 size(I,2); % width
    1 size(I,1); %height
    -360 720; % rotate
    ];
% nSkip = round(1 / factor)
fregion = round(region .* factor); % nSkip == 1

fpossibleregion(:,1) = ceil(possibleregion(:,1) .* factor);
fpossibleregion(:,2) = floor(possibleregion(:,2) .* factor);
fregion(:,1) = max(fpossibleregion(:,1),fregion(:,1));
fregion(:,2) = max(fpossibleregion(:,1),fregion(:,2));
fregion(:,1) = min(fpossibleregion(:,2),fregion(:,1));
fregion(:,2) = min(fpossibleregion(:,2),fregion(:,2));

P = -Inf * ones((fregion(:,2)-fregion(:,1)+1).');
for frotate = fregion(5,1):fregion(5,2)
    rotate = round(frotate / factor);
    for fheight = fregion(4,1):fregion(4,2)
        height = round(fheight / factor);
        for fwidth = fregion(3,1):fregion(3,2)
            width = round(fwidth / factor);
            for fy = fregion(2,1):fregion(2,2)
                y = round(fy / factor);
                Data = zeros(prod(imsize), fregion(1,2)-fregion(1,1)+1);
                for fx = fregion(1,1):fregion(1,2)
                    x = round(fx / factor);
                    Patch = cvuCropImageROI(I,[x,y,width,height],rotate);
                    if isempty(Patch), continue; end;
                    Patch = imresize(Patch, imsize);
                    Patch = reshape(Patch, prod(imsize), 1);
                    Patch = cvGaussNorm(Patch.').';
                    Data(:,fx-fregion(1,1)+1) = Patch;
                end
                [d p] = cvPcaDiffs(Data, PCA.V, PCA.Me, PCA.Lambda, 0);
                p(end+1:fregion(1,2)-fregion(1,1)+1) = 0;
                P(:,fy-fregion(2,1)+1,fwidth-fregion(3,1)+1,fheight-fregion(4,1)+1,frotate-fregion(5,1)+1) = p;
                if verbose >= 2, fprintf(' y:%d width:%d height:%d rotate:%d\n', y, width, height, rotate); end
            end
        end
    end
end

%% argmax
fstate = ones(nState,1); % index
[maxp argmax] = max(reshape(P, 1, []));
% [state(1) state(2) state(3) state(4) state(5)] = ind2sub(size(P), argmax);
siz = size(P);
for i = 1:ndims(P)-1
    [fstate(i) argmax] = ind2sub(siz(i:end), argmax);
end
fstate(ndims(P)) = argmax;

%% value
fstate = fstate + fregion(:,1) - 1;
state = round(fstate ./ factor);
likeli = maxp;
end
