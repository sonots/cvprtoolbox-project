function demo_compress
 file_in = '../images/Lena.bmp';
 I = imread(file_in);
 addpath('WaveUtilities');
 [X,resolution,qmf] = WaveletTransform2D(double(I),1,'Daubechies',20);
 [I] = IWaveletTransform2D(X,resolution,qmf);
 imshow(uint8(I));
end
