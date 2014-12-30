function demo_plotpsnr
% Plot Peak Signal-to-Noise Ratio of luminance components in y-axis vs.
% Compression Ration (CR) in x-axis.
%  
%  demo_plotpsnr
%
% Input arguments ([]s are optional):
%  I   (matrix) of size NxN. Original Image
%  O   (matrix) of size NxN. Code-decoded Image
%
% Output arguments ([]s are optional):
%  psnr (scalar) Peak Signal-to-Noise Ratio
%
% Author: Naotoshi Seo <sonots(at)umd.edu>
% Date  : March 2007

load test.dat -mat
A = double(imgread('../images/LenaC.bmp'));
for i=1:5
    B = imgread(sprintf('LenaY%d.png', i));
    figure;imshow(B);
    psnrs(i) = psnr(A, double(B));
end
figure;plot(bpp, psnrs);

% % with zigzag scanning
% [nRow nCol nColor] = size(I);
% for i=1:5
%     [Ylen Cblen Crlen] = jpegenc(I, 8, 2, i);
%     O = jpegdec;
%     imwrite(O, sprintf('LenaY%d.png', i));
%     PSNR(i) = psnr(I, O);
%     CR(i) = (nRow * nCol) / Ylen;
%     bpp(i) = Ylen / (nRow * nCol);
% end
% save test.dat PSNR CR bpp -mat;
% figure;
% plot(bpp, PSNR);

% without zigzag scanning
% for i=1:5
%     [Ylen Cblen Crlen] = jpegenc(I, 8, 2, i, 0);
%     O = jpegdec;
%     PSNR(i) = psnr(I, O);
%     CR(i) = (nRow * nCol) / Ylen;
% end
% figure;
% plot(CR, PSNR);
end
