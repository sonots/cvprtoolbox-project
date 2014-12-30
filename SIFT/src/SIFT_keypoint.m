function [loc, raw_keypoints, contrast_keypoints, curve_keypoints] = SIFT_keypoint( DOG_pyr, subsample, filter_size, filter_sigma, search_mask, d, r )
% Detect local maxima (keypoint) in the DOG pyramid
%
%  [loc, raw_keypoints, contrast_keypoints, curve_keypoints]
%    = SIFT_keypoint( DOG_pyr, filter_size, filter_sigma, object_mask, contrast_threshold, r )
%
% When a maxima is found, two tests are applied before labeling it as a
% keypoint.  First, it must have sufficient contrast.  Second, it should
% not be and edge point (i.e., the ratio of principal curvatures at the
% extremum should be below a threshold).
%
% Input arguments ([]s are optional):
%  DOG_pyr (cell matrix) of size levels by s+2 where s is the number of intervals:
%    DOG pyramids. DOG_pyr{level}(:,:,interval)
%  subsample (vector) of size levels:
%    subsampling rates to recover into original image size at each level
%  filter_size (matrix) of size levels by s+3:
%    Filter sizes used to generate pyramids
%  filter_sigma (matrix) of size levels by s+3:
%    Standard deviations used to generate pyramids
%  search_mask (matrix) of size NxM (the size of input image): 
%   a binary mask specifying the region or locations of the object in
%   the image to search for keypoints on.
%  d (scalar): 
%   the threshold on the contrast of the DOG extrema
%   before classifying them as keypoints
%  r (scalar): 
%   the upper bound on the ratio between the principal
%   curvatures of the DOG extrema before classifying it as a keypoint
%
% Output arguments ([]s are optional):
%  loc (cell) of size levels by s+3: boolean maps of keypoints
% [raw_keypoints]
% [contrast_keypoints]
% [curve_keypoints]
%
% Reference:
% [1] David G. Lowe, "Distinctive Image Features from Sacle-Invariant Keypoints",
%     accepted for publicatoin in the International Journal of Computer
%     Vision, 2004.
%
% Naotoshi Seo
% April 2007
interactive = 1; % print message

%% Initialization
levels = length(DOG_pyr); % the number of pyramid levels
s = size(DOG_pyr{1}, 3) - 2; % the number of intervals
loc = cell(levels); % boolean maps of keypoints
% Coordinates of keypoints after each stage of processing for display
raw_keypoints = [];
contrast_keypoints = [];
curve_keypoints = [];

% [1] 4.1 Compute threshold for the ratio of principle curvature test 
% applied to the DOG extrema before classifying them as keypoints.
r = ((r + 1)^2)/r;

% 2nd derivative kernels
xx = [ 1 -2  1 ];
yy = xx';
xy = [ 1 0 -1; 0 0 0; -1 0 1 ]/4;

% Detect local maxima in the DOG pyramid
if interactive >= 1
    fprintf( 2, 'Locating keypoints...\n' );
end
tic;
for level = 1:levels
    if interactive >= 1
        fprintf( 2, '\tProcessing level %d\n', level );
    end
    for interval = 2:(s+1)
        keypoint_count = 0;
        contrast_mask = abs(DOG_pyr{level}(:,:,interval)) >= d;
        loc{level,interval} = zeros(size(DOG_pyr{level}(:,:,interval)));
        edge = ceil(filter_size(level,interval)/2);
        for y=(1+edge):(size(DOG_pyr{level}(:,:,interval),1)-edge)
            for x=(1+edge):(size(DOG_pyr{level}(:,:,interval),2)-edge)
                % Only check for extrema where the search mask is 1
                if search_mask(round(y*subsample(level)),round(x*subsample(level))) == 1

                    % When not displaying intermediate results, perform the check that the current location
                    % in the DOG pyramid is above the contrast threshold before checking
                    % for an extrema for efficiency reasons.  Note: we could not make this
                    % change of order if we were interpolating the locations of the extrema.
                    if( (interactive >= 2) | (contrast_mask(y,x) == 1) )

                        % Check for a max or a min across space and scale
                        tmp = DOG_pyr{level}((y-1):(y+1),(x-1):(x+1),(interval-1):(interval+1));
                        pt_val = tmp(2,2,2);
                        if( (pt_val == min(tmp(:))) | (pt_val == max(tmp(:))) )
                            % The point is a local extrema of the DOG image.  Store its coordinates for
                            % displaying keypoint location in interactive mode.
                            raw_keypoints = [raw_keypoints; x*subsample(level) y*subsample(level)];

                            if abs(DOG_pyr{level}(y,x,interval)) >= d
                                % The DOG image at the extrema is above the contrast threshold.  Store
                                % its coordinates for displaying keypoint locations in interactive mode.
                                contrast_keypoints = [contrast_keypoints; raw_keypoints(end,:)];

                                % [1] 4.1 principle curvatures
                                % Compute the entries of the Hessian matrix at the extrema location.
                                Dxx = sum(DOG_pyr{level}(y,x-1:x+1,interval) .* xx);
                                Dyy = sum(DOG_pyr{level}(y-1:y+1,x,interval) .* yy);
                                Dxy = sum(sum(DOG_pyr{level}(y-1:y+1,x-1:x+1,interval) .* xy));

                                % Compute the trace and the determinant of the Hessian.
                                Tr_H = Dxx + Dyy;
                                Det_H = Dxx*Dyy - Dxy^2;

                                % Compute the ratio of the principal curvatures.
                                curvature_ratio = (Tr_H^2)/Det_H;

                                if ((Det_H >= 0) & (curvature_ratio < r))
                                    % The ratio of principal curvatures is below the threshold (i.e.,
                                    % it is not an edge point).  Store its coordianates for displaying
                                    % keypoint locations in interactive mode.
                                    curve_keypoints = [curve_keypoints; raw_keypoints(end,:)];

                                    % Set the loc map to 1 to at this point to indicate a keypoint.
                                    loc{level,interval}(y,x) = 1;
                                    keypoint_count = keypoint_count + 1;
                                end
                            end
                        end
                    end
                end
            end
        end
        if interactive >= 1
            fprintf( 2, '\t\t%d keypoints found on interval %d\n', keypoint_count, interval );
        end
    end
end
keypoint_time = toc;
if interactive >= 1
    fprintf( 2, 'Keypoint location time %.2f seconds.\n', keypoint_time );
end
