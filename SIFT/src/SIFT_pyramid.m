
function [gauss_pyr, DOG_pyr, subsample, filter_size, filter_sigma, absolute_sigma] = SIFT_pyramid( im, levels, s )
% Generate the gaussian and difference-of-gaussian (DOG) pyramids.  
%
%  [gauss_pyr, DOG_pyr, subsample, filter_size, filter_sigma, absolute_sigma]
%    = SIFT_pyramid( im, levels, s )
%
% These pyramids will be stored as two cell arrays,
% gauss_pyr{orient,interval} and DOG_pyr{orient,interval}, respectively.  In order
% to detect keypoints on s intervals per level, we must generate s+3 blurred
% images in the gaussian pyramid.  This is becuase s+3 blurred images generates
% s+2 DOG images, and two images are needed (one at the highest and one lowest scales 
% of the level) for extrema detection.
%
% Input arguments ([]s are optional):
%  im (matrix) of size NxN: the input image, with pixel values normalize 
%    to lie betwen [0,1].
%  levels (scalar): the number of pyramid levels (or octaves) 
%  s (scalar): the number of intervals (or scales) used to detect maxima 
%    and minima of the DoG images. [1]'s Figure 2 shows one interval, 
%    thus Figure 1 shows there are 2 intervals at each level (or octave). 
%
% Output arguments ([]s are optional):
%  gauss_pyr (cell matrix) of size levels by s+3:
%    Gaussian pyramids. gauss_pyr{level,interval}
%  DOG_pyr (cell matrix) of size levels by s+2: 
%    DOG pyramids. DOG_pyr{level}(:,:,interval)
%  subsample (vector) of size levels:
%    subsampling rates to recover into original image size at each level
%  filter_size (matrix) of size levels by s+3:
%    Filter sizes used to generate pyramids
%  filter_sigma (matrix) of size levels by s+3:
%    Standard deviations used to generate pyramids
%  absolute_sigma (matrix) of size levels by s+3:
%    Sigma scaled for original image size at each level
%
% Reference:
% [1] David G. Lowe, "Distinctive Image Features from Sacle-Invariant Keypoints",
%     accepted for publicatoin in the International Journal of Computer
%     Vision, 2004.
% [2] David G. Lowe, "Object Recognition from Local Scale-Invariant Features",
%     Proc. of the International Conference on Computer Vision, Corfu,
%     September 1999.
%
% Naotoshi Seo
% April 2007
interactive = 1; % print message

% Initialization of tracks
filter_size    = zeros(levels,s+3);
filter_sigma   = zeros(levels,s+3);
absolute_sigma = zeros(levels,s+3);
subsample      = [];

% Prior to building the pyramid
% [1] 3.3 We assume that the original image has a blur of at least 0.5
% (the minimum needed to prevsent siginificant aliasing)
% antialias_sigma = 0.5;
% g = gaussian_filter( antialias_sigma );
% im = conv2( g, g, im, 'same' );
% [1] 3.3 We double the size of input image using linear interpolation
% prior to building the pyramid
% [1] 3.3 This increases the number of stable keypoints by a factor of 4. 
[X Y] = meshgrid( 1:0.5:size(im,2), 1:0.5:size(im,1) );
im = interp2( im, X, Y, '*linear' ); 
subsample(1) = 0.5; % subsampling rate for doubled image is 1/2

% [1] 3.3 prior smoothing is applied to each image level before building
% the scale space representation for an octave. we have chosen 1.6. 
preblur_sigma = 1.6;
g = gaussian_filter( preblur_sigma );
gauss_pyr{1,1} = conv2( g, g, im, 'same' );

% [2] The input image is first convolved with the Gaussian using sigma = sqrt(2)
initial_sigma = sqrt(2); % [2]

if interactive >= 1
   fprintf( 2, 'Expanding the Gaussian and DOG pyramids...\n' );
end
tic;
for level = 1:levels
   sigma = initial_sigma;
   g = gaussian_filter( sigma );
   absolute_sigma( level, 1 ) = sigma * subsample(level);
   filter_size( level, 1 ) = length(g);
   filter_sigma( level, 1 ) = sigma;
   DOG_pyr{level} = zeros(size(gauss_pyr{level,1},1),size(gauss_pyr{level,1},2),s+2);
   % we have genearated gauss_pyr( level, 1 ); 
   if interactive >= 1
      fprintf( 2, '\tProcessing level %d: image size %d x %d subsample %.1f\n', level, size(gauss_pyr{level,1},2), size(gauss_pyr{level,1},1), subsample(level) );
      fprintf( 2, '\t\tInterval 1 sigma %f\n', absolute_sigma(level,1) );
   end   
   for interval = 2:(s+3)
      
      % Compute the standard deviation of the gaussian filter needed to produce the 
      % next level of the geometrically sampled pyramid.  Here, sigma_i+1 = k*sigma.
      % By definition of successive convolution, the required blurring sigma_f to
      % produce sigma_i+1 from sigma_i is:
      %
      %    sigma_i+1^2 = sigma_f,i^2 + sigma_i^2
      %  (k*sigma_i)^2 = sigma_f,i^2 + sigma_i^2
      %
      % therefore:
      %
      %      sigma_f,i = sqrt(k^2 - 1)sigma_i
      % 
      % where k = 2^(1/s) to span the level, so:
      %
      %  sigma_f,i = sqrt(2^(2/s) - 1)sigma_i
      sigma_f = sqrt(2^(2/s) - 1)*sigma;
      g = gaussian_filter( sigma_f );
      sigma = (2^(1/s))*sigma;  % sigma = sqrt(2) * sigma; [2]
      
      % Keep track of the absolute sigma
      absolute_sigma(level,interval) = sigma * subsample(level);
      
      % Store the size and standard deviation of the filter for later use
      filter_size(level,interval) = length(g);
      filter_sigma(level,interval) = sigma;
      
      gauss_pyr{level,interval} = conv2( g, g, gauss_pyr{level,interval-1}, 'same' );
      DOG_pyr{level}(:,:,interval-1) = gauss_pyr{level,interval} - gauss_pyr{level,interval-1};
      
      if interactive >= 1
         fprintf( 2, '\t\tInterval %d sigma %f\n', interval, absolute_sigma(level,interval) );
      end              
   end      
   if level < levels
      % Generate the first image for next level (pyramid level)
      % The gaussian image 2 images from the top of the stack for
      % this level have be blurred by 2*sigma.  Subsample this image by a 
      % factor of 2 to procuduce the first image of the next level.
      sz = size(gauss_pyr{level,s+1});
      [X Y] = meshgrid( 1:2:sz(2), 1:2:sz(1) ); % [1] resampling by taking every second pixel
      gauss_pyr{level+1,1} = interp2(gauss_pyr{level,s+1},X,Y,'*nearest'); 
      subsample = [subsample subsample(end)*2]; % [1] twice the initial value of sigma
   end      
end
pyr_time = toc;
if interactive >= 1
   fprintf( 2, 'Pryamid processing time %.2f seconds.\n', pyr_time );
end
