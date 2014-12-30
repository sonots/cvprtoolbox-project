function demo_block_dct2
% (3) Block-based DCT transform
%
%  demo_block_dct2
%
% Author: Naotoshi Seo <sonots(at)umd.edu>
% Date  : March 2007
saturn = imread('../images/saturn.tif');
blkdctimg = block_dct2(saturn);
figure;
imshow(log(abs(blkdctimg)),[-1 12])
colormap(jet);
colorbar;
title('Block-based 2-D DCT of saturn.tif');