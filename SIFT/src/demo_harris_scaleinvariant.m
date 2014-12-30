function demo_harris_scaleinvariant(imfile)
if ~exist('imfile', 'var')
    imfile = '../images/wadham001.png';
end
im = imread(imfile);
[x y] = harris(im);

factor = 0.25;
im2 = imresize(im, factor);
[x2 y2] = harris(im2);

%4.6916 Lena
%20.7919 wadham001

% plot
fig = figure;
imshow(im);
hold on;
plot(x,y,'y*');
resizeImageFig(fig, size(im), 0.8);

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

