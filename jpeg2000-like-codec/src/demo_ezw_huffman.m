function demo_ezw_huffman
% Demonstrate EZW coding, and then huffman coding
%
% Author: Naotoshi Seo <sonots(at)umd.edu>
% Date  : April 2007
% Example of wavelet transform of an 8x8 image
% given by Usevitch's JPEG2000 paper
X=[ 53   -22    21    -9    -1     8    -7     6
    14   -12    13   -11    -1     0     2    -3
    15    -8     9     7     2    -3     1    -2
    34    -2    -6    10     6    -4     4    -5
    -6     5    -1     1     1     3    -1     5
     6     1     3     0    -2     2     6     0
     4     2     1    -4    -1     0    -1     4
     0    -2     7     5    -3     2    -2     3];
% EZW encoding
[N, T0, sigmaps, refmaps] = ezw(X, 1);
% display
display(bytes(sigmaps));
display(bytes(refmaps));
for i=1:length(sigmaps)
    [sigmaps{i}, codewords{i}, pad] = huffman(uint8(sigmaps{i}));
end
sum = 0;
for i=1:length(refmaps)
    refmaps{i} = huffman(uint8(refmaps{i}));
    sum = sum + bytes(refmaps{i});
end
display(bytes(sigmaps));
display(bytes(refmaps));
sum