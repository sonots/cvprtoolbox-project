function O = jpegdec(zigzag)
% JPEG-like  decoder
%
%  [O] = jpegenc
%
% Input arguments ([]s are optional):
%  zigzag (0 or 1): flag to use zigzag scannning. Default is 1 (use). 
%
% Output arguments ([]s are optional):
%  O   (matrix) of size NxN. Decoded Image
%
% Future Work: 
%  Support NxM image
%
% Author: Naotoshi Seo <sonots(at)umd.edu>
% Date  : March 2007
if nargin < 1,
    zigzag = 1;
end
%% entropy decoding and load propeties
contentfile = 'JPEG.jpg'; headerfile = 'JPEG_DCTQ_ZZ.txt';
copyfile(['Cr_' contentfile], contentfile);
copyfile(['Cr_' headerfile ], headerfile);
[nr, nc, m, chrtable, CrVec] = JPEG_entropy_decode('');
copyfile(['Cb_' contentfile], contentfile);
copyfile(['Cb_' headerfile ], headerfile);
[nc, nr, m, chrtable, CbVec] = JPEG_entropy_decode('');
copyfile(['Y_'  contentfile], contentfile);
copyfile(['Y_'  headerfile ], headerfile);
[nRow, nCol, m, lumtable, YVec] = JPEG_entropy_decode('');
% m block size
s = nRow / nc; % down-up sampling factor;

%%% izigzag scanning for each block
ind = gen_zigzagind(m);
nBlock = size(YVec, 1);
nBlockInRow = floor(nRow / m);
for k=0:(nBlock-1)
    i = mod(k, nBlockInRow);
    j = floor(k / nBlockInRow);
    si = i*m+1;
    sj = j*m+1;
    if zigzag
        Y(si:(si+m-1), sj:(sj+m-1)) = Vector2ZigzagMtx(YVec(k+1, :), ind);
    else
        Y(si:(si+m-1), sj:(sj+m-1)) = reshape(YVec(k+1, :), m, m);
    end
end
nBlock = size(CbVec, 1);
nBlockInRow = floor(floor(nRow / s) / m);
for k=0:(nBlock-1)
    i = mod(k, nBlockInRow);
    j = floor(k / nBlockInRow);
    si = i*m+1;
    sj = j*m+1;
    if zigzag
        Cb(si:(si+m-1), sj:(sj+m-1)) = Vector2ZigzagMtx(CbVec(k+1, :), ind);
        Cr(si:(si+m-1), sj:(sj+m-1)) = Vector2ZigzagMtx(CrVec(k+1, :), ind);
    else
        Cb(si:(si+m-1), sj:(sj+m-1)) = reshape(CbVec(k+1, :), m, m);
        Cr(si:(si+m-1), sj:(sj+m-1)) = reshape(CrVec(k+1, :), m, m);
    end
end

%%% inverse quantization table
Y  = blkproc(Y,[m m],'x.*P1', lumtable);
Cb = blkproc(Cb,[m m],'x.*P1', chrtable);
Cr = blkproc(Cr,[m m],'x.*P1', chrtable);

%%% inverse DCT
dctmat = dctmtx(m); % matlab builtin
Y =  blkproc(Y, [m m], 'P1''*x*P1', dctmat); % or 'idct2(x)'
Cb = blkproc(Cb, [m m], 'P1''*x*P1', dctmat);
Cr = blkproc(Cr, [m m], 'P1''*x*P1', dctmat);

%%% upsampling
Cb = imresize(Cb, s);
Cr = imresize(Cr, s);
%%% Level shift
Y  = Y  + 128;
Cb = Cb + 128;
Cr = Cr + 128;
%%% RGB to YCbCr
YCbCr = cat(3, Y, Cb, Cr);
O = ycbcr2rgb(uint8(YCbCr));
