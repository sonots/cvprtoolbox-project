function decompress_spiht(file_in, img_out)
% SPIHT-Based Image Decompression
%
%  decompress_spiht(file_in, img_out)
%
% Input arguments ([]s are optional):
%  file_in (string): path to compressed file to be docompressed
%  img_out (string): path to decompressed image file
%
% Uses: iezw.m, ihuffman.m arith06.m, WaveUtilities/IWaveletTransform2D.m
%
% Author: Naotoshi Seo <sonots(at)umd.edu>
% Date  : April 2007

% read file
eval(sprintf('load %s -mat', file_in));
%whos

display('Inverse SPIHT ....');
[X level] = dSPIHT(encoded, bits);

% Inverse Wavelet
addpath matlabPyrTools/
addpath matlabPyrTools/MEX/
I = invwave_transform_qmf(X,5); % qmf5
% I = invwave_transform(X); % haar

% add DC coponent
I = I + dc;
I = uint8(I);

% Save
imwrite(I, img_out);
end

