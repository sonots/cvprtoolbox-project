function demo_SIFT_descriptor(imfile)
if ~exist('imfile', 'var')
    imfile = '../images/einstein.pgm';
end
eval(sprintf('load ''%s.pyramid'' -mat', imfile));
eval(sprintf('load ''%s.keypoint'' loc -mat', imfile));
eval(sprintf('load ''%s.orient'' pos ori scale -mat', imfile));
%load '../images/einstein.truedesc' desc1 -mat
[desc] = SIFT_descriptor(gauss_pyr, subsample, pos, scale, ori);
eval(sprintf('save ''%s.descriptor'' desc -mat', imfile));

% Examine difference with truth
%diff_desc = desc-desc1