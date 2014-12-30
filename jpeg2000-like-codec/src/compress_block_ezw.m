function compress_block_ezw(img_in, bpp_target, file_out, num_pass, M)
% Block-EZW Based Image Compression
%
%  compress_block_ezw(img_in, bpp_target, file_out)
%
% Input arguments ([]s are optional):
%  img_in (string): path to input image to be compressed
%  bpp_target (scalar): target bitrate in bits per pixel e.g - 0.125
%  file_out (string): path to output file
%  [num_pass] (scalar): number of pass (for testing)
%  [M] (scalar): block size. Default is 8. (for testing)
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
if nargin < 5,
    M = 8;
end

% read image as grayscale image
I = imgread(img_in);
% figure;imshow(I);title('original');
[nRow, nCol] = size(I);
disp(sprintf('Original size is %d bits (%d bytes)', nRow*nCol*8, nRow*nCol));

% remove DC component
I = double(I);
for j=0:(floor(nCol/M)-1)
    sj = j*M+1;
    for k=0:(floor(nRow/M)-1)
        sk = k*M+1;
        dc{k+1}{j+1} = mean(mean(I(sk:(sk+M-1), sj:(sj+M-1))));
        I(sk:(sk+M-1), sj:(sj+M-1)) = I(sk:(sk+M-1), sj:(sj+M-1)) - dc{k+1}{j+1};
    end
end

% wavelet transform
display('Wavelet transform ....');
tic
addpath matlabPyrTools/
addpath matlabPyrTools/MEX/
X = blkproc(I, [M M], 'wave_transform_qmf(x,P1)', 5);
%figure;imshow(X);title('wavelet');
toc

% Progressive (Embedded) Compression
% Initialization
[N, nCol] = size(X);
scan = ezw_mortonorder(M);
for j=0:(floor(nCol/M)-1)
    sj = j*M+1;
    for k=0:(floor(nRow/M)-1)
        sk = k*M+1;
        T0{k+1}{j+1} = 2^floor(log2(max(max(abs(X(sk:(sk+M-1), sj:(sj+M-1)))))));
        sublist{k+1}{j+1} = [];
    end
end
T = T0;
total_bits = 0;
% Encoding, EZW, huffman, arithmetic coding
for i=1:num_pass
    fprintf('EZW encoding %d pass ...\n', i);
    tic
    sigmapss{i} = '';
    refmapss{i} = '';
    for j=0:(floor(nCol/M)-1)
        sj = j*M+1;
        for k=0:(floor(nRow/M)-1)
            sk = k*M+1;
            [sigmaps{i}{k+1}{j+1} sublist{k+1}{j+1} X(sk:(sk+M-1), sj:(sj+M-1))] = ...
                ezw_dominantpass(X(sk:(sk+M-1), sj:(sj+M-1)), T{k+1}{j+1}, sublist{k+1}{j+1}, scan);
            [refmaps{i}{k+1}{j+1}] = ezw_subordinatepass(...
                sublist{k+1}{j+1}, T{k+1}{j+1}, T0{k+1}{j+1});
        end
    end
    toc

    disp('Huffman encoding ...');
    tic
%     bits = 0;
%     for j=0:(floor(nCol/M)-1)
%         sj = j*M+1;
%         for k=0:(floor(nRow/M)-1)
%             sk = k*M+1;
%             [huffman_sigs{i}{k+1}{j+1}, codewords_sigs{i}{k+1}{j+1}, pad_sigs{i}{k+1}{j+1}] = ...
%                 huffman(uint8(sigmaps{i}{k+1}{j+1}), uint8('nptz'));
%             [huffman_refs{i}{k+1}{j+1}, codewords_refs{i}{k+1}{j+1}, pad_refs{i}{k+1}{j+1}] = ...
%                 huffman(uint8(refmaps{i}{k+1}{j+1}), [0 1]);
%             bits = bits + (length(huffman_sigs{i}{k+1}{j+1}) + length(huffman_refs{i}{k+1}{j+1}));
%         end
%     end
    % concat  
    sigmapss{i} = '';
    refmapss{i} = '';
    for j=0:(floor(nCol/M)-1)
        for k=0:(floor(nRow/M)-1)
            sigmapss{i} = [sigmapss{i} 'd' sigmaps{i}{k+1}{j+1}]; % delimiter 'd'
            refmapss{i} = [refmapss{i} 2 refmaps{i}{k+1}{j+1}]; % delimiter 2
        end
    end
    [huffman_sigs{i}, codewords_sigs{i}, pad_sigs{i}] = huffman(uint8(sigmapss{i}), uint8('nptzd'));
    [huffman_refs{i}, codewords_refs{i}, pad_refs{i}] = huffman(uint8(refmapss{i}), [0 1 2]);
    bits = (length(huffman_sigs{i}) + length(huffman_refs{i}));    
    bits = bits * 8;
    toc
    fprintf('%d bits\n', bits);
    
    % bpp (bits per pixel)
    total_bits = total_bits + bits;
    bpp = total_bits / (nRow * nCol);
    disp('total bpp =');
    disp(bpp);
    if bpp >= bpp_target
        fprintf('bpp_target %f reached\n', bpp_target);
        break;
    end
    
    for j=0:(floor(nCol/M)-1)
        for k=0:(floor(nRow/M)-1)
            T{k+1}{j+1} = T{k+1}{j+1} / 2;
        end
    end
end
% When we want to compress best, we should not use built-in
% function 'save', though
eval(sprintf(['save %s N T0 dc huffman_sigs huffman_refs ' ....
    'codewords_sigs codewords_refs pad_sigs pad_refs M -mat'], file_out));
end
