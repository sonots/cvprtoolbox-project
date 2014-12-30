function psnr = getPsnr(A,B);

% Function to compute PSNR between two images A and B of identical size
% Inputs A and B can be strings to the filename or the actual image arrays
% themselves.
% Assumes pixel values are in the range [0 255]
%
% Author: Avinash L. Varna
% Date: 04/25/07

if ischar(A)
    A = imread(A);
end
if ischar(B)
    B = imread(B);
end

sizeA = size(A);
sizeB = size(B);

if ~all(sizeA == sizeB)
    error('Images A and B should be of the same size');
end

err = double(A) - double(B);

mse = sum(err(:).^2)/prod(sizeA);

psnr = 10 * log10(255^2/mse);