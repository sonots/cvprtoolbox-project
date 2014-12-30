function demo_SIFT_keypoint(imfile, usecache)
if ~exist('imfile', 'var')
    imfile = '../images/einstein.pgm';
end
if ~exist('usecache', 'var')
    usecache = 0;
end

if usecache & exist(sprintf('%s.keypoint', imfile), 'file')
    eval(sprintf('load ''%s.pyramid'' -mat', imfile));
    eval(sprintf('load ''%s.keypoint'' -mat', imfile));
else
    eval(sprintf('load ''%s.pyramid'' -mat', imfile));
    object_mask = ones(size(im));
    contrast_threshold = 0.02;
    curvature_threshold = 10.0;
    [loc, raw_keypoints, contrast_keypoints, curve_keypoints] = ...
        SIFT_keypoint( DOG_pyr, subsample, filter_size, filter_sigma, ...
        object_mask, contrast_threshold, curvature_threshold );
    eval(sprintf('save ''%s.keypoint'' loc raw_keypoints contrast_keypoints curve_keypoints -mat', imfile));
end
% Display results of extrema detection and keypoint filtering

% im = imresize(im, 2);
% raw_keypoints = raw_keypoints * 2;
% contrast_keypoints = contrast_keypoints * 2;
% curve_keypoints = curve_keypoints * 2;

fig = figure;
clf;
imshow(im);
hold on;
plot(raw_keypoints(:,1),raw_keypoints(:,2),'y+');
resizeImageFig( fig, size(im), 2 );
%saveas(fig, [imfile(1:end-4) 'KeypointExtrema.png']); % Assume 3 letter ext
fprintf( 2, 'DOG extrema (2x scale).\n');
fprintf( 2, '%d keypoints were found.\n', size(raw_keypoints, 1));

fig = figure;
clf;
imshow(im);
hold on;
plot(contrast_keypoints(:,1),contrast_keypoints(:,2),'y+');
resizeImageFig( fig, size(im), 2 );
%saveas(fig, [imfile(1:end-4) 'KeypointRemoveLowContrast.png']); % Assume 3 letter ext
fprintf( 2, 'Keypoints after removing low contrast extrema (2x scale).\n');
fprintf( 2, '%d keypoints were found.\n', size(contrast_keypoints, 1));

fig = figure;
clf;
imshow(im);
hold on;
plot(curve_keypoints(:,1),curve_keypoints(:,2),'y+');
resizeImageFig( fig, size(im), 2 );
%saveas(fig, [imfile(1:end-4) 'KeypointRemoveEdge.png']); % Assume 3 letter ext
fprintf( 2, 'Keypoints after removing edge points using principal curvature filtering (2x scale).\n');
fprintf( 2, '%d keypoints were found.\n', size(curve_keypoints, 1));
