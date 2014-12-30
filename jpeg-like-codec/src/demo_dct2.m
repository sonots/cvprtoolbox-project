function demo_dct2
% (2) 2-D DCT Transform of images:
%
%  demo_dct2
%
% Author: Naotoshi Seo <sonots(at)umd.edu>
% Date  : March 2007

% Apply DCT to mysq.tif
mysq = double(imread('../images/mysq.tif'));
dctimg0 = doDct2(mysq);
figure;
imshow(log(abs(dctimg0)), [-1 12], 'InitialMagnification', 1500);
colormap(gray);
colorbar;
title('2-D DCT of mysq.tif');

% IDCT, Data Compression (Approximation) Test
N = size(mysq, 1);
for m = [1 2 4 8]
    reduced = zeros(N,N);
    reduced(1:m,1:m) = dctimg0(1:m,1:m);
    im = doIDct2(reduced);
    figure;
    imshow(im, [min(min(im)) max(max(im))], 'InitialMagnification', 1500);
    title(['DCT Data Compression Test m=',num2str(m),' ' ...
            num2str(floor(100*(m*m)/(N*N))), '%']);
end

% 2-D DCT for saturn image using built-in dct2 function
saturn = imread('../images/saturn.tif');
dctimg = dct2(saturn);
figure;
imshow(log(abs(dctimg)),[-1 12])
colormap(jet);
colorbar;
title('2-D DCT of saturn.tif');
