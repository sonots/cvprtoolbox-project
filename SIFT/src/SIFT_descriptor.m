function [desc] = SIFT_descriptor( gauss_pyr, subsample, pos, scale, orient )
% Extract feature descriptors for the keypoints.
%
%  [desc] = SIFT_descriptor( gauss_pyr, subsample, pos, scale, orient )
%
% The descriptors are a grid of gradient orientation histograms, where the sampling
% grid for the histograms is rotated to the main orientation of each keypoint.  The
% grid is a 4x4 array of 4x4 sample cells of 8 bin orientation histograms.  This 
% procduces 128 dimensional feature vectors.
%
% Input arguments ([]s are optional):
%  gauss_pyr (cell matrix) of size octaves by intervals+1: 
%    Gaussian pyramids
%  subsample (vector) of size:
%    subsampling rates used to generate pyramids
%  pos (matrix) of size Nx2: 
%   containing the (x,y) coordinates of the keypoints stored in rows.
%  scale (matrix) of size Nx3: 
%   with rows describing the scale of each keypoint (i.e.,
%   first column specifies the octave, second column specifies the
%   interval, and third column specifies sigma).
%  orient (vector) of size Nx1: 
%   containing the orientations of the keypoints [-pi,pi).
%
% Output arguments ([]s are optional):
%  desc (matrix) of size Nx128: 
%   with rows containing the feature descriptors corresponding to the keypoints.
%
% David A. Schug
% April 2007
interactive = 1; % print message

% The orientation histograms have 8 bins
orient_bin_spacing = pi/4;
orient_angles = [-pi:orient_bin_spacing:(pi-orient_bin_spacing)];

% The feature grid is has 4x4 cells - feat_grid describes the cell center positions
grid_spacing = 4;
[x_coords y_coords] = meshgrid( [-6:grid_spacing:6] );
feat_grid = [x_coords(:) y_coords(:)]';
[x_coords y_coords] = meshgrid( [-(2*grid_spacing-0.5):(2*grid_spacing-0.5)] );
feat_samples = [x_coords(:) y_coords(:)]';
feat_window = 2*grid_spacing;

% Initialize the descriptor list to the empty matrix.
desc = [];

% Loop over all of the keypoints.
if interactive >= 1
   fprintf( 2, 'Computing keypoint feature descriptors for %d keypoints\n', size(pos,1) );
end
for k = 1:size(pos,1)
   x = pos(k,1)/subsample(scale(k,1));
   y = pos(k,2)/subsample(scale(k,1));   
   
   % Rotate the grid coordinates.
   M = [cos(orient(k)) -sin(orient(k)); sin(orient(k)) cos(orient(k))];
   feat_rot_grid = M*feat_grid + repmat([x; y],1,size(feat_grid,2));
   feat_rot_samples = M*feat_samples + repmat([x; y],1,size(feat_samples,2));
   
   % Initialize the feature descriptor.
   feat_desc = zeros(1,128);
   
   % Histogram the gradient orientation samples weighted by the gradient magnitude and
   % a gaussian with a standard deviation of 1/2 the feature window.  To avoid boundary
   % effects, each sample is accumulated into neighbouring bins weighted by 1-d in
   % all dimensions, where d is the distance from the center of the bin measured in
   % units of bin spacing.
   for s = 1:size(feat_rot_samples,2)
      x_sample = feat_rot_samples(1,s);
      y_sample = feat_rot_samples(2,s);
      
      % Interpolate the gradient at the sample position
      [X Y] = meshgrid( (x_sample-1):(x_sample+1), (y_sample-1):(y_sample+1) );
      G = interp2( gauss_pyr{scale(k,1),scale(k,2)}, X, Y, '*linear' );
      G(find(isnan(G))) = 0;
      diff_x = 0.5*(G(2,3) - G(2,1));
      diff_y = 0.5*(G(3,2) - G(1,2));
      mag_sample = sqrt( diff_x^2 + diff_y^2 );
      grad_sample = atan2( diff_y, diff_x );
      if grad_sample == pi
         grad_sample = -pi;
      end      
      
      % Compute the weighting for the x and y dimensions.
      x_wght = max(1 - (abs(feat_rot_grid(1,:) - x_sample)/grid_spacing), 0);
      y_wght = max(1 - (abs(feat_rot_grid(2,:) - y_sample)/grid_spacing), 0); 
      pos_wght = reshape(repmat(x_wght.*y_wght,8,1),1,128);
      
      % Compute the weighting for the orientation, rotating the gradient to the
      % main orientation to of the keypoint first, and then computing the difference
      % in angle to the histogram bin mod pi.
      diff = mod( grad_sample - orient(k) - orient_angles + pi, 2*pi ) - pi;
      orient_wght = max(1 - abs(diff)/orient_bin_spacing,0);
      orient_wght = repmat(orient_wght,1,16);         
      
      % Compute the gaussian weighting.
      g = exp(-((x_sample-x)^2+(y_sample-y)^2)/(2*feat_window^2))/(2*pi*feat_window^2);
      
      % Accumulate the histogram bins.
      feat_desc = feat_desc + pos_wght.*orient_wght*g*mag_sample;
   end
   
   % Normalize the feature descriptor to a unit vector to make the descriptor invariant
   % to affine changes in illumination.
   feat_desc = feat_desc / norm(feat_desc);
   
   % Threshold the large components in the descriptor to 0.2 and then renormalize
   % to reduce the influence of large gradient magnitudes on the descriptor.
   feat_desc( find(feat_desc > 0.2) ) = 0.2;
   feat_desc = feat_desc / norm(feat_desc);
   
   % Store the descriptor.
   desc = [desc; feat_desc];
   if (interactive >= 1) & (mod(k,25) == 0)
      fprintf( 2, '.' );
   end
end
if (interactive >= 1)
    fprintf( 2, '\n' );
end
desc_time = toc;

% Adjust for the sample offset
sample_offset = -(subsample - 1);
for k = 1:size(pos,1)
   pos(k,:) = pos(k,:) + sample_offset(scale(k,1));
end

% Return only the absolute scale
if size(pos,1) > 0
	scale = scale(:,3);
end