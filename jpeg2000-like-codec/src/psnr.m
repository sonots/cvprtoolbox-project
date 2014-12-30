function  [psnr,mse] = psnr(A, B)
% Peak Signal-to-Noise Ratio
%
%  [psnr,mse] = psnr(A, B)
%
% Input arguments ([]s are optional):
%  A: Data A
%  B: Data B
%
% Output arguments ([]s are optional):
%  psnr   (scalar) Peak Signal-to-Noise Ratio
%  [mse]  (scalar) Mean Squared Error
%
% Author: Naotoshi Seo <sonots(at)umd.edu>
% Date  : April 2007
diff = A - B;
diff_sq = diff .^ 2;		% difference squared
mse = mean(mean(diff_sq));	% means squared error
if (mse == 0)
    psnr=Inf;
else
    psnr = 10*log10(255^2/mse);          % PSNR
end