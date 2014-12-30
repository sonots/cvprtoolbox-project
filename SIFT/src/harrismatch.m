function num = harrismatch(image1, image2, wsize)
% num = harrismatch(image1, image2)
%
% This function reads two images, finds interest points using harris
% corner detector. Maching is performed by taking Sum of Squared Difference
% (SSD) in the neighboorhoods between each interest point in two images.
%
% Input Arguments([]s are optional)
%   image1 (matrix): input image
%   image2 (matrix): input image
%   wsize  (scalar): windows size taking SSD
%   dist   (scalar): manimum distortion to allow
%
% Example: harrismatch('../images/Lena.png','../images/LenaS.png');
%
% Date: May 2006
% Author: Naotoshi Seo <sonots(at)umd.edu>
if ~exist('wsize', 'var')
    wsize = 3;
end
im1 = imread(image1);
im2 = imread(image2);

% Find Corners
[ x1 y1 ] = harris( im1 );
[ x2 y2 ] = harris( im2 );

% fill in boundaries
[ ny1, nx1 ] = size( im1 );
[ ny2, nx2 ] = size( im2 );
rim1 = zeros( ny1 + wsize*2, nx1 + wsize*2);
rim1(wsize+1:end-wsize, wsize+1:end-wsize) = im1;
rim2 = zeros( ny2 + wsize*2, nx2 + wsize*2);
rim2(wsize+1:end-wsize, wsize+1:end-wsize) = im2;

w = 0:(2*wsize);
for i=1:size(y1, 1)
    subimage1 = rim1(y1(i)+w, x1(i)+w);
    MSSD = Inf;
    for j=1:size(y2, 1);
        subimage2 = rim2(y2(j)+w, x2(j)+w);
        SSD = sum(sum( (subimage1 - subimage2).^2 ));
        if SSD < MSSD
            MSSD = SSD;
            match(i) = j;
        end
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
for i = 1: size(y1,1)
    if (match(i) > 0)
        line([x1(i) x2(match(i))+cols1], ...
            [y1(i) y2(match(i))], 'Color', 'c');
    end
end
hold off;
set(gca,'Position', [0 0 1 1], 'Visible', 'off');
num = sum(match > 0);
fprintf('Found %d matches.\n', num);
