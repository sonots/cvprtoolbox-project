function runPcaFaceDetect(dirname, frame, wsize, factors)
if ~exist('frame', 'var') || isempty(frame)
    frame = [];
end;
if ~exist('wsize', 'var') || isempty(wsize)
    wsize = [10; 10; 3; 3; 6];
end
if ~exist('factors', 'var') || isempty(factors)
    factors = [0.25 0.5 1]; % resize factor
end
%% Load
FILE = cvuLs(dirname, 'file', 'png$');
DAT = load([dirname, '/imageclipper/pca.mat'], '-mat');
X      = DAT.X;
PCA    = DAT.PCA;
imsize = DAT.imsize;
clear DAT;

% if incremental == 1 && exist([dirname, '_update.mat'], 'file')
%     DAT = load([dirname, '_update.mat'], '-mat');
%     X = DAT.X;
%     PCA = DAT.PCA;
%     imsize = DAT.imsize;
%     factors = DAT.factors;
%     region = DAT.region;
% end

%% Initial rectangle state
TRAIN = cvuLs([dirname, '/imageclipper'], 'file', 'png$');
RESULT = cvuLs([dirname, '/pcafacedetect'], 'file', 'png$');
if isempty(frame) % auto resume
    if isempty(RESULT)
        [state, frame, vidfile, id] = getFileinfo(TRAIN{end});
        frame = frame + 1;
    else
        [state, frame, vidfile, id] = getFileinfo(RESULT{end});
        frame = frame + 1;
    end
else
    if length(TRAIN) >= frame
        [state, tmp, vidfile, id] = getFileinfo(TRAIN{frame});
    elseif ~isempty(RESULT)
        [state, tmp, vidfile, id] = getFileinfo(RESULT{end});
    else
        [state, tmp, vidfile, id] = getFileinfo(TRAIN{end});
    end
end

while frame <= length(FILE)
    fprintf('%s %04d\n', dirname, frame);

    %% Tracking

    imfile = FILE{frame};
    I = cvuImgread(imfile);
    I = double(I);
    I = I ./ 255;
    [state logLikeli] = cvPcaFaceDetect(I, PCA, imsize, factors, state, wsize, true);
    state
    logLikeli

    %% Incremental Update
%     if incremental == 1
%         fprintf('Update PCA!\n');
%         I = I(state(2):state(2)+state(4),state(1):state(1)+state(3));
%         I = imresize(I, [24, 24]);
%         I = reshape(I, 24*24, 1);
%         X(:,5:end-1) = X(:,6:end); % keep original 4
%         X(:,end) = I;
%         [PCA.V, PCA.Me, PCA.Lambda] = cvPca(X, 10);
%     end

    %% Crop Image
    [dir, name, ext] = fileparts(imfile);
    dir = [dir, '/pcafacedetect'];
    if ~exist(dir, 'dir'), mkdir(dir); end
    outfile = sprintf('%s/%s%s_%04d_%04d_%04d_%04d_%04d.png', dir, name, ext, state(5), state(1), state(2), state(3), state(4));
    I = imread(imfile);
    I = cvuCropImageROI(I, state(1:4), state(5));
    imwrite(uint8(I), outfile);

    %% Save
    frame = frame + 1;
%     if incremental == 1
%         eval(sprintf('save %s_update X PCA imsize state factors', dirname));
%     end

    if logLikeli < 0.01
        %fprintf('Likelihood is low. Do you want to continue?');
        %pause
    end
end
