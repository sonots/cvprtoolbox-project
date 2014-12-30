% cvGaborTextureSegmentRun - Run cvGaborTextureSegment
%
% Examples
%  cvGaborTextureSegmentRun('image/data.20.png', 5);
%  cvGaborTextureSegmentRun('image/data.20.png', 5, 'data.20.seg.png');
function cvGaborTextureSegmentRun(imfile, K, outfile)
I = cvuImgread(imfile);
[N, M] = size(I);
%% parameter settings
gamma = 1; b = 1; Theta = 0:pi/6:pi-pi/6; phi = 0; shape = 'valid';
%% Lambda settings
% (1) Jain's paper %[4 8 16 ...] sqrt(2) 
% Lambda = M./((2.^(2:log2(M/4))).*sqrt(2));
% (2) J. Zhang's paper
J = (2.^(0:log2(M/8)) - .5) ./ M;
F = [ (.25 - J) (.25 + J) ];
F = sort(F); 
Lambda = 1 ./ F;
%% Run
seg = cvGaborTextureSegment(I, K, gamma, Lambda, b, Theta, phi, shape);
%% Display (Upto 5 colors just for now)
%imseg = uint8(seg) * floor(255 / K); % cluster id to gray scale (max 255)
[N, M] = size(seg);
color = [0 0 0; 255 255 255; 255 0 0; 0 255 0; 0 0 255]; % 5 colors reserved
imseg = zeros(N*M, 3);
for i=1:K
    idx = find(seg == i);
    imseg(idx, :) = repmat(color(i, :), [], length(idx));
end
imseg = reshape(imseg, N, M, 3);
if exist('outfile', 'var')
    imwrite(uint8(imseg), outfile);
else
    fig = figure; imshow(imseg);
    cvuResizeImageFig(fig, [N, M]);
end
end