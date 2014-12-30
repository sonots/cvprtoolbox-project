function demo_compress_spiht
postfix = '';
img_in = '../images/Lena.bmp';
A = double(imgread(img_in));
[nRow, nCol] = size(A);

for i=1:5
    bpp_target = 0.2 * 2^i;
    bitbudget = bpp_target * (nRow * nCol);
    file_out = sprintf('../images/LenaSPIHT%02d%s.dat', i, postfix);
    file_in = file_out;
    img_out = sprintf('../images/LenaSPIHT%02d%s.png', i, postfix);
    if exist(file_out) == 0,
        compress_spiht(img_in, bpp_target, file_out);
    end
    if exist(img_out) == 0,
        decompress_spiht(file_in, img_out);
    end

    % plot bpp vs psnr
    eval(sprintf('load %s -mat', file_in));
    bpps(i) = bits / (nRow * nCol);
    I = imgread(img_out);
    psnrs(i) = psnr(double(A), double(I));
end

bpps
psnrs
%figure;
hold on;
plot(bpps, psnrs, '-k');
% title('BPP vs PSNR for SPIHT-Based Encoding');
xlabel('bpp (bits per pixel)');
ylabel('PSNR in dB');
    