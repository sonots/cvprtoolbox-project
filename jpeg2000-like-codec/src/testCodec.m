% Script to test programs of Project 1 for ENEE 631 S'07
warning off;
clear all;
imNum = 6;
bitrate = [0.5 0.75 1 2 4];
% Directory with input images
imInDir = '.\';
% Directory where output images should be stored
imOutDir = '.\';

studentName = 'seo';

enc_t = zeros(imNum,length(bitrate));
dec_t = zeros(imNum,length(bitrate));
psnr_vals = zeros(imNum,length(bitrate));
file_size = zeros(imNum,length(bitrate));
for i = 1
    img_in = [imInDir num2str(i) '.tif'];
    for j = 1 : length(bitrate)
        file_out = [imOutDir studentName num2str(i) '_' num2str(j) '.dat'];
        file_outs{j} = file_out;
        img_out = [imOutDir 'decomp' num2str(i) '_' num2str(j) '.tif'];
        img_outs{j} = img_out;
    end
    tic;
    compress_ezw(img_in, bitrate, file_outs);
    enc_t(i,j) = toc;
    d = dir(file_out);
    file_size(i,j) = d.bytes;
    tic;

    decompress_ezw(file_outs,img_outs);
    dec_t(i,j) = toc;
end
% str = ['save ' imOutDir studentName '.mat enc_t dec_t psnr_vals file_size'];
% eval(str);
