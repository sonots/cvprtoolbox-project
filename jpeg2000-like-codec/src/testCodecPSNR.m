function testCodecPSNR
imNum = 7;
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
for i = 1 : imNum
    fprintf('|%d.tif|',i);
    img_in = [imInDir num2str(i) '.tif'];
    im = imgread(img_in);
    for j = 1 : length(bitrate)
        img_out = [imOutDir 'decomp' num2str(i) '_' num2str(j) '.tif'];
        if exist(img_out)
            im_out = imgread(img_out);
            psnr_vals(i,j) = getPsnr(im, im_out);
            fprintf('%f|', psnr_vals(i,j));
        end
    end
    fprintf('\n');
end
