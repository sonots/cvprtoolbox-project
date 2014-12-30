function [Ylen Cblen Crlen] = jpegenc(I, m, s, CF, zigzag)
% JPEG-like encoder
%
%  jpegenc(I)
%
% Input arguments ([]s are optional):
%  I   (matrix) of size NxN. Input Image.
%  m   (scalar) block size of block based DCT. Default is 8.
%  s   (scalar) downsampling factor for Cb, Cr. Default is 2.
%  CF  (scalar) Compression factor (correlated to the quantization scale
%  factor)
%  zigzag (0 or 1): flag to use zigzag scannning. Default is 1 (use). 
%
% Output arguments ([]s are optional):
%  Ylen, Cblen, Crlen (scalar) compressed file length for Y, Cb, Cr components
%  respectively
%
% Future Work: 
%  Support NxM image
%
% Author: Naotoshi Seo <sonots(at)umd.edu>
% Date  : March 2007
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
%%% RGB to YCbCr
YCbCr = double(rgb2ycbcr(I)); % I uint8 [0, 255]
Y  = YCbCr(:, :, 1);
Cb = YCbCr(:, :, 2);
Cr = YCbCr(:, :, 3);
% Level shift input
Y  = Y  - 128;
Cb = Cb - 128;
Cr = Cr - 128;
% downsample Cb, Cr
Cb = imresize(Cb, 1/s);
Cr = imresize(Cr, 1/s);

%%% block based DCT
dctmat = dctmtx(m); % gen_dctbasis(m)
% block_dct2
Y  = blkproc(Y, [m m], 'P1*x*P1''', dctmat); % or 'dct2(x)'
Cb = blkproc(Cb, [m m], 'P1*x*P1''', dctmat);
Cr = blkproc(Cr, [m m], 'P1*x*P1''', dctmat);
fprintf('DCT done\n');

%%% quantization table
lumtable = JpegLumQuanTable*CF;
chrtable = JpegChrQuanTable*CF;
Y  = blkproc(Y,[m m],'round(x./P1)', lumtable);
Cb = blkproc(Cb,[m m],'round(x./P1)', chrtable);
Cr = blkproc(Cr,[m m],'round(x./P1)', chrtable);
fprintf('quantization done\n');

%%% zigzag scanning for each block
ind = gen_zigzagind(m);
YVec = [];
for j=0:(floor(nCol/m)-1)
    sj = j*m+1;
    for i=0:(floor(nRow/m)-1)
        si = i*m+1;
        if zigzag
            YVec = [YVec; ZigzagMtx2Vector(Y(si:(si+m-1), sj:(sj+m-1)), ind)];
        else
            YVec = [YVec; reshape(Y(si:(si+m-1), sj:(sj+m-1)), 1, m*m)];
        end
    end
end
CbVec = [];
CrVec = [];
for j=0:(floor(nCol/s/m)-1)
    sj = j*m+1;
    for i=0:(floor(nRow/s/m)-1)
        si = i*m+1;
        if zigzag
            CbVec = [CbVec; ZigzagMtx2Vector(Cb(si:(si+m-1), sj:(sj+m-1)), ind)];
            CrVec = [CrVec; ZigzagMtx2Vector(Cr(si:(si+m-1), sj:(sj+m-1)), ind)];
        else
            CbVec = [CbVec; reshape(Cb(si:(si+m-1), sj:(sj+m-1)), 1, m*m)];
            CrVec = [CrVec; reshape(Cr(si:(si+m-1), sj:(sj+m-1)), 1, m*m)];
        end
    end
end
fprintf('zigzag done\n');

%%% entropy encoding
contentfile = 'JPEG.jpg'; headerfile = 'JPEG_DCTQ_ZZ.txt';
JPEG_entropy_encode(nRow, nCol, m, lumtable, YVec, '', 1);
movefile(contentfile, ['Y_' contentfile]);
movefile(headerfile,  ['Y_' headerfile ]);
JPEG_entropy_encode(nRow/s, nCol/s, m, chrtable, CbVec, '', 1);
movefile(contentfile, ['Cb_' contentfile]);
movefile(headerfile,  ['Cb_' headerfile ]);
JPEG_entropy_encode(nRow/s, nCol/s, m, chrtable, CrVec, '', 1);
movefile(contentfile, ['Cr_' contentfile]);
movefile(headerfile,  ['Cr_' headerfile ]);
fprintf('entropy encoding done\n');