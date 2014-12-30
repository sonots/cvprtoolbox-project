function cvuKltPlot(imgfile, W)
% cvuKltPlot - Plot KLT tracking points
%
% Synopsis
%  cvuKltPlot(imgfile, W)
%
% Inputs ([]s are optional)
%  (string) imgfile  image file to be shown
%  (matrix) W        2F x P measurement matrix containing points
%
% Outputs ([]s are optional)
%
% Examples
%  W = cvuKltRead('image/hotel/hotel.seq%d.feat.txt', 0, 100);
%  cvuKltPlot('image/hotel/hotel.seq1.pgm', W);
%
% Requirements
%  cvuKltRead.m
%
% Authors
%  Naotoshi Seo <sonots(at)sonots.com>
%
% License
%  The program is free to use for non-commercial academic purposes,
%  but for course works, you must understand what is going inside to use.
%  The program can be used, modified, or re-distributed for any purposes
%  if you or one of your group understand codes (the one must come to
%  court if court cases occur.) Please contact the authors if you are
%  interested in using the program without meeting the above conditions.

% Changes
%  11/01/2006  First Edition
I = imread(imgfile);
F = size(W, 1) / 2;
P = size(W, 2);
figure;
imshow(I);
hold on;
plot(W(1, :), W(F+1, :), '.y');
for j=1:P
    plot(W(2:F, j), W(F+(2:F), j), '-g');
end
set(gca,'Position', [0 0 1 1], 'Visible', 'off');
end