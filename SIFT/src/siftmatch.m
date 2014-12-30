% num = siftmatch(image1, image2)
%
% This function reads two images, finds their SIFT features, and
%   displays lines connecting the matched keypoints.  A match is accepted
%   only if its distance is less than distRatio times the distance to the
%   second closest match.
% It returns the number of matches displayed.
%
% Example: siftmatch('../images/scene.pgm','../images/box.pgm');

function num = siftmatch(image1, image2)

% Find SIFT keypoints for each image
[ im1 pos1, scale1, ori1, des1 ] = SIFT_cache( image1 );
[ im2 pos2, scale2, ori2, des2 ] = SIFT_cache( image2 );

% For efficiency in Matlab, it is cheaper to compute dot products between
%  unit vectors rather than Euclidean distances.  Note that the ratio of 
%  angles (acos of dot products of unit vectors) is a close approximation
%  to the ratio of Euclidean distances for small angles.
%
% distRatio: Only keep matches in which the ratio of vector angles from the
%   nearest to second nearest neighbor is less than distRatio.
distRatio = 0.6;   

% For each descriptor in the first image, select its match to second image.
des2t = des2';                          % Precompute matrix transpose
for i = 1 : size(des1,1)
   dotprods = des1(i,:) * des2t;        % Computes vector of dot products
   [vals,indx] = sort(acos(dotprods));  % Take inverse cosine and sort results

   % Check if nearest neighbor has angle less than distRatio times 2nd.
   if (vals(1) < distRatio * vals(2))
      match(i) = indx(1);
   else
      match(i) = 0;
   end
end

% Create a new image showing the two images side by side.
im3 = appendimages(im1,im2);

% Show a figure with lines joining the accepted matches.
figure('Position', [100 100 size(im3,2) size(im3,1)]);
colormap('gray');
imagesc(im3);
hold on;
cols1 = size(im1,2);
for i = 1: size(des1,1)
  if (match(i) > 0)
    line([pos1(i,1) pos2(match(i),1)+cols1], ...
         [pos1(i,2) pos2(match(i),2)], 'Color', 'c');
  end
end
hold off;
set(gca,'Position', [0 0 1 1], 'Visible', 'off');
num = sum(match > 0);
fprintf('Found %d matches.\n', num);
