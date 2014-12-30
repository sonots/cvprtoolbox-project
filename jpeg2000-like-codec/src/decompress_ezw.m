function decompress_ezw(file_ins, img_outs)
% EZW-Based Image Decompression
%
%  decompress_ezw(file_in, img_out)
%
% Input arguments ([]s are optional):
%  file_in (string): path to compressed file to be docompressed
%  img_out (string): path to decompressed image file
%
% Uses: iezw.m, ihuffman.m arith06.m, WaveUtilities/IWaveletTransform2D.m
%
% Author: Naotoshi Seo <sonots(at)umd.edu>
% Date  : April 2007
if nargin < 3,
    num_pass = Inf;
end

for bppid=1:length(file_ins)
    file_in = file_ins{bppid};
    % read file
    if exist(file_in)
        eval(sprintf('load ''%s'' -mat', file_in));
        % N, T0, dc, len_arighmetic, arithmetic
        % codewords_sigs codewords_refs pad_sigs pad_refs
        % huffman_sigs huffman_refs
        %whos
        num_pass(bppid) = length(codewords_sigs);
    end
end
% Initialization
X = zeros(N);
T = T0;
fname = sprintf('%s_%d.pass', file_ins{1}, 0);
if exist(fname)
    eval(sprintf('load ''%s'' scan -mat', fname));
else
    scan = ezw_mortonorder(N);
end
% decoding
bppid = 1;
for i=1:num_pass(end)
    tmpfile = sprintf('%s.%02d', file_in, i);
    if exist(tmpfile)
        eval(sprintf('load ''%s'' -mat', tmpfile));
        continue;
    end
    fprintf('pass %d ...\n', i);
    % Aritmetic decoding, Copyright (c) 1999-2001.  Karl Skretting.
    %     disp('Arithmetic decoding ...');
    %     tic;
    %     xc = cell(2, 1);
    %     xc = arith06(arithmetic{i});
    %     stream = xc{1}';
    %     huffman_sigs{i} = uint8(stream(1:len_arithmetic(i)));
    %     huffman_refs{i} = uint8(stream(len_arithmetic(i):end));
    %     toc;

    disp('Huffman decoding ...');
    tic;
    sigmaps{i} = ihuffman(huffman_sigs{i}, codewords_sigs{i}, pad_sigs{i});
    refmaps{i} = ihuffman(huffman_refs{i}, codewords_refs{i}, pad_refs{i});
    toc

    disp('ezw_decoding ...');
    tic
    X = iezw_dominantpass(X, sigmaps{i}, T, scan);
    X = iezw_subordinatepass(X, refmaps{i}, T, scan);
    toc

    T = T/2;

    while (i >= num_pass(bppid))
        img_out = img_outs{bppid};
        bppid = bppid + 1;
        % Inverse Wavelet
        addpath matlabPyrTools/
        addpath matlabPyrTools/MEX/
        I = invwave_transform_qmf(X,5); % qmf5
        % I = invwave_transform(X); % haar

        % add DC coponent
        I = I + dc;
        I = uint8(I);
        % restore size from power of 2, remove 0 padding
        I = I(1:orignRow, 1:orignCol);

        % Save
        imwrite(I, img_out);
        if bppid > length(num_pass)
            break;
        end
    end
    % for testing
    eval(sprintf('save ''%s'' -mat', tmpfile));
    if bppid > length(img_outs)
        break;
    end
end
end

