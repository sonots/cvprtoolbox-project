function compress_ezw(img_in, bpp_targets, file_outs, num_pass)
% EZW Based Image Compression
%
%  ezw_compress(img_in, bpp_target, file_out)
%
% Input arguments ([]s are optional):
%  img_in (string): path to input image to be compressed
%  bpp_target (scalar): target bitrate in bits per pixel e.g - 0.125
%  file_out (string): path to output file
%  [num_pass] (scalar): number of pass (for testing)
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
[orignRow, orignCol] = size(I);
% convert size into power of 2, 0 padding
nRow = 2^ceil(log2(orignRow));
nCol = 2^ceil(log2(orignCol));
I(orignRow+1:nRow,orignCol+1:nCol) = 0;
disp(sprintf('Original size is %d bits (%d bytes)', nRow*nCol*8, nRow*nCol));

% remove DC component
I = double(I);
dc = mean(mean(I));
I = I - dc;

% wavelet transform
fname = sprintf('%s_%d.pass', file_outs{1}, 0);
if exist(fname)
    eval(sprintf('load ''%s'' -mat', fname));
else
    display('Wavelet transform ....');
    tic
    addpath matlabPyrTools/
    addpath matlabPyrTools/MEX/
    X = wave_transform_qmf(I, 5); % qmf5
    % X = wave_transform(I); % haar
    % figure;imshow(X);title('wavelet');
    toc

    % Progressive (Embedded) Compression
    % Initialization
    [N, nCol] = size(X);
    scan = ezw_mortonorder(N);
    T0 = 2^floor(log2(max(max(abs(X)))));
    T = T0;
    sublist = [];
    total_bits = 0;
    % Encoding, EZW, huffman, arithmetic
    bppid = 1;
    bpp_target = bpp_targets(bppid);
    file_out = file_outs{bppid};
    
    eval(sprintf('save ''%s'' -mat', fname));
end

for i=1:num_pass
    fname = sprintf('%s_%d.pass', img_in, i);
    if exist(fname)
        eval(sprintf('load ''%s'' -mat', fname));
        continue;
    end
    fprintf('EZW encoding %d pass ...\n', i);
    tic
    [sigmaps{i} sublist X] = ezw_dominantpass(X, T, sublist, scan);
    [refmaps{i}] = ezw_subordinatepass(sublist, T, T0);
    toc

    disp('Huffman encoding ...');
    tic
    [huffman_sigs{i}, codewords_sigs{i}, pad_sigs{i}] = ...
        huffman(uint8(sigmaps{i}), uint8('nptz'));
    [huffman_refs{i}, codewords_refs{i}, pad_refs{i}] = ...
        huffman(uint8(refmaps{i}), [0 1]);
    toc
    bits = 8 * (length(huffman_sigs{i}) + length(huffman_refs{i}));
    fprintf('%d bits\n', bits);

    % Arithmetic encoding, Copyright (c) 1999-2001.  Karl Skretting.
    % This gives extra compression ratio hopefully
    % did not well ....
    %     display('Arithmetic encoding ...')
    %     tic;
    %     xc = cell(2,1);
    %     xc{1} = double([huffman_sigs{i}'; huffman_refs{i}']);
    %     [arithmetic{i} res] = arith06(xc);
    %     len_arithmetic(i) = length(huffman_sigs{i});
    %     toc
    %     bits = 8 * length(arithmetic{i});
    %     fprintf('%d bits\n', bits);
    % uint8, one element 1 byte (8 bits).

    % bpp (bits per pixel)
    total_bits = total_bits + bits;
    bpp = total_bits / (nRow * nCol);
    disp('total bpp =');
    disp(bpp);
    while bpp >= bpp_target
        fprintf('bpp_target %f reached\n', bpp_target);
        % When we want to compress best, we should not use built-in
        % function 'save'. We store length of each vector into a header,
        % and store everything in the sense of bits.
        % But, to measure bpp, they actually do not have big impacts compared with
        % the main data, so measuring length for only main data is enough now.
        % Let me use 'save' function.
        eval(sprintf(['save ''%s'' N T0 dc huffman_sigs huffman_refs ' ....
            'codewords_sigs codewords_refs pad_sigs pad_refs orignRow orignCol -mat'], file_out));
        bppid = bppid + 1;
        if bppid > length(bpp_targets)
            break;
        end
        bpp_target = bpp_targets(bppid);
        file_out = file_outs{bppid};
    end
    if bppid > length(bpp_targets)
        break;
    end

    T = T / 2;
    eval(sprintf('save ''%s'' -mat', fname));
end
end
