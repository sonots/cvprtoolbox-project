function demo_SIFT_pyramid(imfile, usecache)
if ~exist('imfile', 'var')
    imfile = '../images/einstein.pgm';
end
if ~exist('usecache', 'var')
    usecache = 0;
end

if usecahe
    eval(sprintf('load ''%s.pyramid'' -mat', imfile));
else
    im = double(imread(imfile))./255;
    levels = 4;
    s = 2;
    [gauss_pyr, DOG_pyr, subsample, filter_size, filter_sigma, absolute_sigma]...
        = SIFT_pyramid( im, levels, s );
    eval(sprintf('save ''%s.pyramid'' im gauss_pyr DOG_pyr subsample filter_size filter_sigma absolute_sigma -mat', imfile));
end

% Display the gaussian pyramid
sz = zeros(1,2);
sz(2) = (s+3)*size(gauss_pyr{1,1},2);
for level = 1:levels
    sz(1) = sz(1) + size(gauss_pyr{level,1},1);
end
pic = zeros(sz);
y = 1;
for level = 1:levels
    x = 1;
    sz = size(gauss_pyr{level,1});
    for interval = 1:(s + 3)
        pic(y:(y+sz(1)-1),x:(x+sz(2)-1)) = gauss_pyr{level,interval};
        x = x + sz(2);
    end
    y = y + sz(1);
end
fig = figure;
clf;
imshow(pic);
resizeImageFig(fig, size(pic), 0.25);
saveas(fig, [imfile(1:end-4) 'GaussianPyramid.png']); % Assume 3 letter ext
fprintf( 2, 'The gaussian pyramid (0.25 scale).\n');

% Display the DOG pyramid
sz = zeros(1,2);
sz(2) = (s+2)*size(DOG_pyr{1}(:,:,1),2);
for level = 1:levels
    sz(1) = sz(1) + size(DOG_pyr{level}(:,:,1),1);
end
pic = zeros(sz);
y = 1;
for level = 1:levels
    x = 1;
    sz = size(DOG_pyr{level}(:,:,1));
    for interval = 1:(s + 2)
        pic(y:(y+sz(1)-1),x:(x+sz(2)-1)) = DOG_pyr{level}(:,:,interval);
        x = x + sz(2);
    end
    y = y + sz(1);
end
fig = figure;
clf;
imshow(pic, [min(min(pic)) max(max(pic))]);
resizeImageFig(fig, size(pic), 0.25);
saveas(fig, [imfile(1:end-4) 'DoGPyramid.png']); % Assume 3 letter ext
fprintf( 2, 'The DOG pyramid (0.25 scale).\n');

end
