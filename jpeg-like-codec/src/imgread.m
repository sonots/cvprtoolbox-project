function [grayimg] = imgread(file);

%IMGREAD Read an image from file and convert to grayscale
%  IMGREAD reads an imagefile and returns a matrix containing
%  the grayscale coefficients
%
%  grayscale = imgread(imagefile);
%
%  imagefile should be the complete name of the file to read,
%  including the extention; the file should be located in the
%  current directory or somewhere in the Matlab path
%
%  grayscale is a 'double' matrix containing intensity coefficients
%  in the range of [0,1]
%
%  Copyright 2002  Paschalis Tsiaflakis, Jan Vangorp
%  Revision 1.1  4/11/2002 12.50u

info = imfinfo(file);

[image,map] = imread(file);

if(strcmp(info.ColorType,'indexed') == 1)
    grayimg = ind2gray(image,map);
    disp('Loading indexed image...');
elseif(strcmp(info.ColorType,'truecolor') == 1)
    grayimg = rgb2gray(image);
    disp('Loading truecolor image...');
else
    grayimg = image;
    disp('Loading grayscale image...');
end

% convert image data to [0,1] range
% grayimg = im2double(grayimg);