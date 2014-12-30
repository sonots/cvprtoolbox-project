function [W,resolution,qmf] = WaveletTransform(X,scale,wbase,mom)
% WAVELETTRANSFORM 1D wavelet transform
% [W,resolution,qmf] = WaveletTransform(X,scale,wbase,mom)
%  returns in W[n,T] the wavelet transform of X[n,T]
%  along the second dimension.
%
% Inputs
% ------
%  wbase : wavelet basis
%  scale : scale paramter
%  mom   : number of moments
%
% defaults: wbase = 'Symmlet', mom = 4, scale = 0.
%
% Outputs
% -------
%  resolution : resolution level,
%  qmf        : quadratic mirror filters.
%
% See also: IWaveletTransform, MakeONFilter, FWT_PO
%

	[m,T] = size(X);
	W = zeros(m,T);

	if nargin == 1
		wbase = 'Symmlet';
		mom = 4;
		scale = 0;
	end

	if nargin == 3 
		qmf = MakeONFilter(wbase);
	else
		qmf = MakeONFilter(wbase,mom);
	end

	resolution = log2(T) - scale;

	for i = 1:m
		W(i,:) = FWT_PO(X(i,:),scale,qmf);
	end
