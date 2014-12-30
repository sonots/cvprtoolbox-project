function demo_jpegcodec
    I = imread('../images/LenaC.bmp');
    jpegenc(I);
    O = jpegdec;
    imwrite(O, '../images/IIIJpegCodec.png');
    figure;
    imshow(O);
end