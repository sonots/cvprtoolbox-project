function [g] = gaussian_filter( sigma, spread )
% gaussian_filter: Create 1D a gaussian filter
%
%  [g] = gaussian_filter( sigma, spread )
%
% Input arguments ([]s are optional):
%   sigma (scalar): The standard deviation of Gaussian. 
%     Large sigma blurs more.
%   [spread] (scalar): The spread of gaussian filter. 
%     Default is round(3.5 * sigma). The filter size is 2*spread+1
%
% Output arguments ([]s are optional):
%   g (matrix): the gaussian filter
%
% Author : Naotoshi Seo <sonots(at)umd.edu>
% Date   : Oct, 2006
% Revised: Apr, 2007
if nargin < 2, 
    spread = round(3.5 * sigma);
end

% Generate the x values.
x = -spread:spread;

% the gaussian filter
g = exp(-(x.^2)/(2*sigma^2)) ...
    / (sqrt(2*pi)*sigma); % Normalize
