function [ pos, scale, orient, desc ] = SIFT( im, levels, s, search_mask, d, r )
% Scale Invariant Feature Transform (SIFT)
%
% [ pos, scale, orient, desc ] = SIFT( im, levels, s, search_mask, d, r )
%
% Apply David Lowe's Scale Invariant Feature Transform (SIFT) algorithm
% to a grayscale image.  This algorithm takes a grayscale image as input
% and returns a set of scale- and rotationally-invariant keypoints
% allong with their corresponding feature descriptors.
%
% Input arguments ([]s are optional):
%  im (matrix) of size NxM:
%    the input image, with pixel values normalized to lie betwen [0,1].
% [levels] (scalar):
%    the number of pyramid levels (or levels) (default = 4).
% [s] (scalar): the number of intervals (or scales) used to detect maxima
%    and minima of the DoG images. [1]'s Figure 2 shows one interval,
%    thus Figure 1 shows there are 2 intervals at each level (or octave).
%    (default = 2).
% [search_mask] (matrix) of size NxM:
%   a binary mask specifying the region or locations of the object in
%   the image to search for keypoints on.  If not specified, the whole
%   image is searched.
% [d] (scalar):
%   the threshold on the contrast of the DOG extrema
%   before classifying them as keypoints (default = 0.03).
% [r] (scalar):
%   the upper bound (threshold) on the ratio between the principal
%   curvatures of the DOG extrema before classifying it as a keypoint
%   (default = 10.0).
%
% Output arguments ([]s are optional):
%  pos (matrix) of size Kx2:
%   containing the (x,y) coordinates of the keypoints stored in rows.
%  scale (matrix) of size Kx3:
%   with rows describing the scale of each keypoint (i.e.,
%   first column specifies the octave, second column specifies the
%   interval, and third column specifies sigma).
%  orient (vector) of size Kx1:
%   containing the orientations of the keypoints [-pi,pi).
%  desc (matrix) of size Kx128:
%   with rows containing the feature descriptors corresponding to
%   the keypoints.
%
% Reference:
% [1] David G. Lowe, "Distinctive Image Features from Sacle-Invariant Keypoints",
%     accepted for publicatoin in the International Journal of Computer
%     Vision, 2004.
% [2] David G. Lowe, "Object Recognition from Local Scale-Invariant Features",
%     Proc. of the International Conference on Computer Vision, Corfu,
%     September 1999.
%
% Naotoshi Seo, David A. Schug
% April 2007
% assign default values to the input variables
if ~exist('levels')
    levels = 4;
end
if ~exist('s')
    s = 2; % [1]'s Figure 3 shows 2 or 3 are efficient.
end
if ~exist('search_mask')
    search_mask = ones(size(im));
end
if size(search_mask) ~= size(im)
    search_mask = ones(size(im));
end
if ~exist('d')
    d = 0.02; % [1] 4 less than 0.03, though
end
if ~exist('r')
    r = 10.0; % [1] 4.1 r = 10
end

% Check that the image is normalized to [0,1]
if( (min(im(:)) < 0) | (max(im(:)) > 1) )
    fprintf( 2, 'Warning: image not normalized to [0,1].\n' );
end

[gauss_pyr, DOG_pyr, subsample, filter_size, filter_sigma, absolute_sigma] = SIFT_pyramid( im, levels, s );
[loc] = SIFT_keypoint( DOG_pyr, subsample, filter_size, filter_sigma, search_mask, d, r );
[pos, orient, scale] = SIFT_orientation( loc, gauss_pyr, subsample,absolute_sigma );
[desc] = SIFT_descriptor( gauss_pyr, subsample, pos, scale, orient );
