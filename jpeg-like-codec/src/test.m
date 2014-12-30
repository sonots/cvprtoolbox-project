function test

I = imread('../images/LenaC.bmp');
if nargin < 5,
    zigzag = 1;
end
if nargin < 4,
    CF = 1;
end
if nargin < 3,
    s = 2;
end
if nargin < 2,
    m = 8;
end

[nRow, nCol, z] = size(I);
I = double(I);
% RGB to YCbCr
YCbCr = rgb2ycbcr(I);
Y = YCbCr(:, :, 1);
Cb = YCbCr(:, :, 2);
Cr = YCbCr(:, :, 3);
% % Level shift input
% Y = double(Y) - 128;
% Cb = double(Cb) - 128;
% Cr = double(Cr) - 128;
% downsample Cb, Cr
% dCb = imresize(Cb, 1/s);
% dCr = imresize(Cr, 1/s);
% block based DCT
dctmat = dctmtx(m);
YDCT = blkproc(Y, [m m], 'P1*x*P1''', dctmat); % or 'dct2(x)'
% dCbDCT = blkproc(dCb, [m m], 'P1*x*P1''', dctmat);
% dCrDCT = blkproc(dCr, [m m], 'P1*x*P1''', dctmat);
fprintf('DCT done\n');

