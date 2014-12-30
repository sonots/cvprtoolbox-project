function demo_sift_scaleinvariant(imfile)
if ~exist('imfile', 'var')
    imfile = '../images/wadham001.png';
end
im = double(imread(imfile))./255;
levels = 4;
s = 2;
search_mask = ones(size(im));
d = 0.02;
r = 10.0;
[im pos scale ori desc] = SIFT_cache( imfile, levels, s, search_mask, d, r );
x = pos(:, 1); y = pos(:, 2);

factor = 0.25;
im2 = imresize(im, factor);
[pos2 scale2 ori2 desc2] = SIFT( im2, levels, s, search_mask, d, r );
x2 = pos2(:, 1); y2 = pos2(:, 2);

%4.2944 Lena
%4.4997 wadham001

% plot
fig = figure;
imshow(im);
hold on;
plot(x,y,'y*');
resizeImageFig(fig, size(im), 1);

% plot
fig = figure;
imshow(im2);
hold on;
plot(x2,y2,'y*');
resizeImageFig(fig, size(im2), 1/factor);

% d
x2 = x2 .* (1/factor);
y2 = y2 .* (1/factor);
cmind = 0;
for i = 1:size(x2, 1)
    mind = Inf;
    for j = 1:size(x, 1)
        d = sqrt((x(j)-x2(i))^2 + (y(j)-y2(i))^2);
        if d < mind
            mind = d;
        end
    end
    cmind = cmind + mind;
end
cmind = cmind / size(x2, 1);
cmind

