function [pos, orient, scale] = SIFT_orientation( loc, gauss_pyr, subsample,absolute_sigma )
% Assign orientations to the keypoints
%
%  [pos, orient, scale] = SIFT_orientation( loc, gauss_pyr, subsample )
%
% This is done by looking for peaks in histograms of gradient orientations 
% in regions surrounding each keypoint.  A keypoint may be assigned more 
% than one orientation.  If it is, then two identical descriptors 
% are added to the database with different orientations.
%
% Input arguments ([]s are optional):
%  loc (cell) of size levels by s+1: 
%    boolean maps of keypoints
%  gauss_pyr (cell matrix) of size levels by s+1: 
%    Gaussian pyramids
%  subsample (vector) of size:
%    subsampling rates used to generate pyramids
%
% Output arguments ([]s are optional):
%  pos (matrix) of size Nx2: 
%   containing the (x,y) coordinates of the keypoints stored in rows.
%  scale (matrix) of size Nx3: 
%   with rows describing the scale of each keypoint (i.e.,
%   first column specifies the level, second column specifies the
%   interval, and third column specifies sigma).
%  orient (vector) of size Nx1: 
%   containing the orientations of the keypoints [-pi,pi).
%
% David A. Schug
% April 2007
interactive = 1; % print message

% The next step of the algorithm is to assign orientations to the keypoints.  For this,
% we histogram the gradient orientation over a region about each keypoint.
levels = 4; % levels
s = 2; % s

% absolute_sigma = zeros(levels,s+3);


g = gaussian_filter( 1.5 * absolute_sigma(1,s+3) / subsample(1) );
zero_pad = ceil( length(g) / 2 );

% Compute the gradient direction and magnitude of the gaussian pyramid images
if interactive >= 1
   fprintf( 2, 'Computing gradient magnitude and orientation...\n' );
end
tic;
mag_thresh = zeros(size(gauss_pyr));
mag_pyr = cell(size(gauss_pyr));
grad_pyr = cell(size(gauss_pyr));
for level = 1:levels
   for interval = 2:(s+1)      
      % Compute x and y derivatives using pixel differences
      diff_x = 0.5*(gauss_pyr{level,interval}(2:(end-1),3:(end))-gauss_pyr{level,interval}(2:(end-1),1:(end-2)));
      diff_y = 0.5*(gauss_pyr{level,interval}(3:(end),2:(end-1))-gauss_pyr{level,interval}(1:(end-2),2:(end-1)));
      
      % Compute the magnitude of the gradient
      mag = zeros(size(gauss_pyr{level,interval}));      
      mag(2:(end-1),2:(end-1)) = sqrt( diff_x .^ 2 + diff_y .^ 2 );
      
      % Store the magnitude of the gradient in the pyramid with zero padding
      mag_pyr{level,interval} = zeros(size(mag)+2*zero_pad);
      mag_pyr{level,interval}((zero_pad+1):(end-zero_pad),(zero_pad+1):(end-zero_pad)) = mag;      
      
      % Compute the orientation of the gradient
      grad = zeros(size(gauss_pyr{level,interval}));
      grad(2:(end-1),2:(end-1)) = atan2( diff_y, diff_x );
      grad(find(grad == pi)) = -pi;
      
      % Store the orientation of the gradient in the pyramid with zero padding
      grad_pyr{level,interval} = zeros(size(grad)+2*zero_pad);
      grad_pyr{level,interval}((zero_pad+1):(end-zero_pad),(zero_pad+1):(end-zero_pad)) = grad;
   end
end
clear mag grad
grad_time = toc;
if interactive >= 1
   fprintf( 2, 'Gradient calculation time %.2f seconds.\n', grad_time );
end

% The next step of the algorithm is to assign orientations to the keypoints
% that have been located.  This is done by looking for peaks in histograms of
% gradient orientations in regions surrounding each keypoint.  A keypoint may be 
% assigned more than one orientation.  If it is, then two identical descriptors 
% are added to the database with different orientations.

% Set up the histogram bin centers for a 36 bin histogram.
num_bins = 36;
hist_step = 2*pi/num_bins;
hist_orient = [-pi:hist_step:(pi-hist_step)];

% Initialize the positions, orientations, and scale information
% of the keypoints to emtpy matrices.
pos = [];
orient = [];
scale = [];

% Assign orientations to the keypoints.
if interactive >= 1
   fprintf( 2, 'Assigining keypoint orientations...\n' );
end
tic;
for level = 1:levels
   if interactive >= 1
      fprintf( 2, '\tProcessing level %d\n', level );
   end
   for interval = 2:(s + 1)
      if interactive >= 1
         fprintf( 2, '\t\tProcessing interval %d ', interval );
      end            
      keypoint_count = 0;
      
      % Create a gaussian weighting mask with a standard deviation of 1/2 of
      % the filter size used to generate this level of the pyramid.
      g = gaussian_filter( 1.5 * absolute_sigma(level,interval)/subsample(level) );
      hf_sz = floor(length(g)/2);
      g = g'*g;      
      
      % Zero pad the keypoint location map.
      loc_pad = zeros(size(loc{level,interval})+2*zero_pad);
      loc_pad((zero_pad+1):(end-zero_pad),(zero_pad+1):(end-zero_pad)) = loc{level,interval};
      
      % Iterate over all the keypoints at this level and orientation.
      [iy ix]=find(loc_pad==1);
      for k = 1:length(iy)
         % Histogram the gradient orientations for this keypoint weighted by the
         % gradient magnitude and the gaussian weighting mask.
         x = ix(k);
         y = iy(k);
         wght = g.*mag_pyr{level,interval}((y-hf_sz):(y+hf_sz),(x-hf_sz):(x+hf_sz));
         grad_window = grad_pyr{level,interval}((y-hf_sz):(y+hf_sz),(x-hf_sz):(x+hf_sz));
         orient_hist=zeros(length(hist_orient),1);
         for bin=1:length(hist_orient)
            % Compute the diference of the orientations mod pi
            diff = mod( grad_window - hist_orient(bin) + pi, 2*pi ) - pi;
            
            % Accumulate the histogram bins
            orient_hist(bin)=orient_hist(bin)+sum(sum(wght.*max(1 - abs(diff)/hist_step,0)));
            %orient_hist(bin)=orient_hist(bin)+sum(sum(wght.*(abs(diff) <= hist_step)));
         end
         
         % Find peaks in the orientation histogram using nonmax suppression.
         peaks = orient_hist;        
         rot_right = [ peaks(end); peaks(1:end-1) ];
         rot_left = [ peaks(2:end); peaks(1) ];         
         peaks( find(peaks < rot_right) ) = 0;
         peaks( find(peaks < rot_left) ) = 0;
         
         % Extract the value and index of the largest peak. 
         [max_peak_val ipeak] = max(peaks);
         
         % Iterate over all peaks within 80% of the largest peak and add keypoints with
         % the orientation corresponding to those peaks to the keypoint list.
         peak_val = max_peak_val;
         while( peak_val > 0.8*max_peak_val )
            % Interpolate the peak by fitting a parabola to the three histogram values
            % closest to each peak.				            
            A = [];
            b = [];
            for j = -1:1
               A = [A; (hist_orient(ipeak)+hist_step*j).^2 (hist_orient(ipeak)+hist_step*j) 1];
	            bin = mod( ipeak + j + num_bins - 1, num_bins ) + 1;
               b = [b; orient_hist(bin)];
            end
            c = pinv(A)*b;
            max_orient = -c(2)/(2*c(1));
            while( max_orient < -pi )
               max_orient = max_orient + 2*pi;
            end
            while( max_orient >= pi )
               max_orient = max_orient - 2*pi;
            end            
            
            % Store the keypoint position, orientation, and scale information
            pos = [pos; [(x-zero_pad) (y-zero_pad)]*subsample(level) ];
            orient = [orient; max_orient];
            scale = [scale; level interval absolute_sigma(level,interval)];
            keypoint_count = keypoint_count + 1;
            
            % Get the next peak
            peaks(ipeak) = 0;
            [peak_val ipeak] = max(peaks);
         end         
      end
      if interactive >= 1
         fprintf( 2, '(%d keypoints)\n', keypoint_count );
      end            
   end
end
clear loc loc_pad 
orient_time = toc;
if interactive >= 1
   fprintf( 2, 'Orientation assignment time %.2f seconds.\n', orient_time );
end

