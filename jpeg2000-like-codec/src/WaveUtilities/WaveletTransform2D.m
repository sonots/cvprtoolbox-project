function [W,resolution,qmf] = WaveletTransform2D(X,scale,wbase,mom)
% WAVELETTRANSFORM 2D wavelet transform
% [W,resolution,qmf] = WaveletTransform2D(X,scale,wbase,mom)
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
% See also: IWaveletTransform2D, MakeONFilter, FWT2_PO
%

	[m,T] = size(X);
	W = zeros(m,T);
	I = sqrt(T);
	Image = zeros(I,I);

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

	resolution = log2(I) - scale;

	for i = 1:m
		Image = reshape(X(i,:),I,I);
		Image = FWT2_PO(Image,scale,qmf);
		W(i,:) = Image(:)';
	end
