% Paul Heideman
% Rhodes University
% 4 April 2004
%
% Script to test cSPIHT and dSPIHT for level 1 wavelet transform
%

fprintf('\nTest script for cSPIHT and dSPIHT on level 1 wavelet coefficients');
fprintf('\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n');

clear
close all

% parameters
bitbudget = 1000000;

% load picture of woman into X and map
load woman;

sX = size(X);

% set wavelet filter to haar as it is the simplest
filter = 'haar';

% record start time
tic;

% perform single-level decomposition of X. 
[cA1,cH1,cV1,cD1] = dwt2(X, filter);

% record wavelet transform time and output
dwttime = toc;
fprintf('\nDWT time:    %6.3f seconds\n', dwttime);

% put it into the tree structure
dec2d = [... 
        cA1,     cH1;     ... 
        cV1,     cD1      ... 
        ];
        
% round all coefficients
dec2d = fix(dec2d);        

% reset start time
tic;

% perform SPIHT compression where encoded contains output and bits contains
% the amount of bits used.
[encoded bits] = cSPIHT(dec2d, 1, bitbudget);

% record cSPIHT time and output
cspihttime = toc;
fprintf('cSPIHT time: %6.3f seconds\n', cspihttime);

% reset start time
tic;

% perform inverse
[decoded level] = dSPIHT(encoded, bits);

% record cSPIHT time and output
dspihttime = toc;
fprintf('dSPIHT time: %6.3f seconds\n', dspihttime);

% put it back into the form wanted by idwt2
cA1 = decoded(1:(sX(1)/2), 1:(sX(1)/2));
cH1 = decoded(1:(sX(1)/2), (sX(1)/2 + 1):sX(1));
cV1 = decoded((sX(1)/2 + 1):sX(1), 1:(sX(1)/2));
cD1 = decoded((sX(1)/2 + 1):sX(1), (sX(1)/2 + 1):sX(1));

% reset start time
tic;

% reconstruct image from wavelet coefficients
dec = idwt2(cA1,cH1,cV1,cD1,filter,sX);

% record IDWT time and output
idwttime = toc;
fprintf('IDWT time:   %6.3f seconds\n', idwttime);

% output total times
fprintf('\nTotal coding time:   %6.3f seconds\n', dwttime + cspihttime);
fprintf('\nTotal decoding time: %6.3f seconds\n', idwttime + dspihttime);

% calculate Mean Square Error and PSNR
MSE = sum(sum((X-dec).^2))/(size(X,1))/(size(X,2));
PSNR = 10*log10(255*255/MSE);
fprintf('\nMSE: %7.2f \nPSNR: %9.7f dB', MSE, PSNR);

% output resultant images
figure
image(X);
title('Original');
colormap(map);
figure
image(dec);
title('Regenerated');
colormap(map);
figure
subplot(2,2,2);
image(abs(decoded));
title('Decoded wavelets');
colormap(map);
subplot(2,2,1);
image(abs(dec2d));
title('Wavelets');
colormap(map);
subplot(2,2,4);
image(abs(dec2d-decoded));
title('Difference wavelets');
colormap(map);
subplot(2,2,3);
image(abs(X-dec));
title('Difference');
colormap(map);
