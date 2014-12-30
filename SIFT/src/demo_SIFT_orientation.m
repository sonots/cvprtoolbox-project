function demo_SIFT_orientation(imfile, usecache)
if ~exist('imfile', 'var')
    imfile = '../images/einstein.pgm';
end
if ~exist('usecache', 'var')
    usecache = 0;
end

if usecache & exist([imfile '.orient'])
    eval(sprintf('load ''%s.pyramid'' -mat', imfile));
    eval(sprintf('load ''%s.keypoint'' loc -mat', imfile));
    eval(sprintf('load ''%s.orient'' -mat', imfile));
else
    eval(sprintf('load ''%s.pyramid'' -mat', imfile));
    eval(sprintf('load ''%s.keypoint'' loc -mat', imfile));
    [pos, ori, scale] = SIFT_orientation( loc, gauss_pyr, subsample, absolute_sigma );
    eval(sprintf('save ''%s.orient'' pos ori scale -mat', imfile));
end

% Display the keypoints with scale and orientation in interactive mode.
fig = figure;
clf;
imshow(im);
hold on;
display_keypoints( pos, scale(:,3), ori, 'y' );
resizeImageFig( fig, size(im), 1 );
%saveas(fig, [imfile(1:end-4) 'Orientation.png']); % Assume 3 letter ext
fprintf( 2, 'Final keypoints with scale and orientation (2x scale).\n' );

