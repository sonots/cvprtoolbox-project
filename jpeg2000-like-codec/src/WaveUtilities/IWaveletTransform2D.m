function [X] = IWaveletTransform2D(W,resolution,qmf)
% WAVELETTRANSFORM 2D inverse wavelet transform
% X = IWaveletTransform2D(W,resolution,qmf)
%  returns in X[n,T] the inverse wavelet transform
%  of W[n,T] along the second dimension.
%
% Inputs
% ------
%  resolution : resolution level,
%  qmf        : quadratic mirror filters.
%
% defaults: resolution = log2(T), qmf = {Symmlet,4}.
%
% See also: WaveletTransform2D, MakeONFilter, IFWT2_PO
%

	[m,T] = size(W);
	I = sqrt(T);
	Image = zeros(I,I);

	if nargin == 1
		resolution = log2(I);
		qmf = MakeONFilter('Symmlet',4);
	end

	scale = log2(I) - resolution;
	for i = 1:m
		Image = reshape(W(i,:),I,I);
		Image = IWT2_PO(Image,scale,qmf);
		X(i,:) = Image(:)';
	end
