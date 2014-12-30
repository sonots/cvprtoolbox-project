function demo_SIFT(imfile)
if ~exist('imfile', 'var')
    imfile = '../images/einstein.pgm';
end
im = double(imread(imfile))./255;
levels = 4;
s = 2;
search_mask = ones(size(im));
d = 0.02;
r = 10.0;
[pos scale ori desc] = SIFT( im, levels, s, search_mask, d, r );
eval(sprintf('save ''%s.sift'' pos scale ori desc -mat', imfile));
% demo_SIFT_pyramid(imfile)
% fprintf('Press any key to continue...\n'); pause;
% demo_SIFT_keypoint(imfile)
% fprintf('Press any key to continue...\n'); pause;
% demo_SIFT_orientation(imfile)
% fprintf('Press any key to continue...\n'); pause;
% demo_SIFT_descriptor(imfile)
% eval(sprintf('load ''%s.pyramid'' -mat', imfile));
% eval(sprintf('load ''%s.keypoint'' loc -mat', imfile));
% eval(sprintf('load ''%s.orient'' pos ori scale -mat', imfile));
% eval(sprintf('load ''%s.descriptor'' desc -mat', imfile));
% eval(sprintf('save ''%s.sift'' pos scale ori desc -mat', imfile));
end
