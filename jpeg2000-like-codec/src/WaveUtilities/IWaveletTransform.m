function [X] = IWaveletTransform(W,resolution,qmf)
% WAVELETTRANSFORM 1D inverse wavelet transform
% X = IWaveletTransform(W,resolution,qmf)
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
% See also: WaveletTransform, MakeONFilter, IFWT_PO
%

	[m,T] = size(W);

	if nargin == 1
		resolution = log2(T);
		qmf = MakeONFilter('Symmlet',4);
	end

	scale = log2(T) - resolution;
	for i = 1:m
		X(i,:) = IWT_PO(W(i,:),scale,qmf);
	end
