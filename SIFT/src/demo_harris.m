function demo_harris(imfile)
if ~exist('imfile', 'var')
    imfile = '../images/Lena.png';
end
im = imgread(imfile);
%im = imgread('../images/einstein.pgm');
width = 5;
sigma = 1;
[x y] = harris(im, width, sigma);
% plot
fig = figure;
imshow(im);
hold on;
plot(x,y,'y*');
%set(gca,'Position', [0 0 1 1], 'Visible', 'off');
%saveas(fig, '../images/LenaHarris.png');

% im = imresize(im, 0.25);
% width = 5;
% sigma = 1;
% [x y] = harris(im, width, sigma);
% % plot
% fig = figure;
% imshow(im);
% hold on;
% plot(x,y,'y*');
% set(gca,'Position', [0 0 1 1], 'Visible', 'off');
%saveas(fig, '../images/LenaHarris.png');
end
