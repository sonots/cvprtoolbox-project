function compress_spiht(img_in, bpp_target, file_out)
% SPIHT Based Image Compression
%
%  compress_spiht(img_in, bpp_target, file_out)
%
% Input arguments ([]s are optional):
%  img_in (string): path to input image to be compressed
%  bpp_target (scalar): target bitrate in bits per pixel e.g - 0.125
%  file_out (string): path to output file
%
% Output arguments ([]s are optional):
%  [bpp] (scalar): bits per pixel value of compressed data
%
% Uses: ezw.m, huffman.m, arith06.m, WaveUtilities/WaveletTransform2D.m
%
% Author: Naotoshi Seo <sonots(at)umd.edu>
% Date  : April 2007
if nargin < 4,
    num_pass = Inf;
end

% read image as grayscale image
I = imgread(img_in);
% figure;imshow(I);title('original');
[nRow, nCol] = size(I);
disp(sprintf('Original size is %d bits (%d bytes)', nRow*nCol*8, nRow*nCol));
disp(sprintf('bbp_target is %f', bpp_target));

% remove DC component
I = double(I);
dc = mean(mean(I));
I = I - dc;

% wavelet transform
display('Wavelet transform ....');
tic
addpath matlabPyrTools/
addpath matlabPyrTools/MEX/
X = wave_transform_qmf(I, 5); % qmf5
% X = wave_transform(I); % haar
% figure;imshow(X);title('wavelet');
toc

[N, nCol] = size(X);
display('SPIHT ...');
tic
bitbudget = bpp_target * nRow * nCol;
[encoded bits] = cSPIHT(X, 1, bitbudget);
bpp = bits / (nRow * nCol)
toc

eval(sprintf(['save %s dc encoded bits -mat'], file_out));
end
