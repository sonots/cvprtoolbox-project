function demo_wavelet
addpath matlabPyrTools/
addpath matlabPyrTools/MEX/
image = imgread('../images/Lena.bmp');
figure;imshow(image);title('original');
% remove DC component
dc = mean(mean(image));
image = image - dc;
% decompose image using wavelet transform
% for the decomposition filter you can select: db1, qmf5, qmf8, qmf9, qmf12, qmf13, qmf16
% => in decompress.m the same filter should be used! <=
%decomposed = wave_transform(image); % db1 (Haar)
wave_coeff = wave_transform_qmf(image,5); % qmf5
figure;imshow(wave_coeff);title('wavelet');

%wave_coeff = wave_transform_qmf(image,9); % qmf9
% Inverse wavelet transformation
% for the decomposition filter you can select: db1, qmf5, qmf8, qmf9, qmf12, qmf13, qmf16
% => the same filter as in compress.m should be used! <=
%image = invwave_transform(wave_coeff); % db1 (Haar)
image = invwave_transform_qmf(wave_coeff,5); % qmf5
%image = invwave_transform_qmf(wave_coeff,9); % qmf9
% add DC coponent
image = image + dc;
figure;
imshow(image);title('iwavelet');

% addpath('WaveUtilities');
% warning('off','MATLAB:dispatcher:InexactMatch');
% [m,T] = size(I);
% coarse = 0;
% wname = 'Haar';
% number = 4;
% [X,resolution,qmf] = WaveletTransform2D(double(I), coarse, wname, number);
% figure;imshow(X);
% [m,T] = size(X); resolution = log2(sqrt(T)) - coarse;
% qmf = MakeONFilter(wname, number);
% [I] = IWaveletTransform2D(X,resolution,qmf);
% figure;imshow(uint8(I));
end

