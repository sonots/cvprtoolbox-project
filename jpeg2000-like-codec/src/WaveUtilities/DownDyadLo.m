function d = DownDyadLo(x,qmf)
% DownDyadLo -- Lo-Pass Downsampling operator (periodized)
%  Usage
%    d = DownDyadLo(x,f)
%  Inputs
%    x    1-d signal at fine scale
%    f    filter
%  Outputs
%    y    1-d signal at coarse scale
%
%  See Also
%    DownDyadHi, UpDyadHi, UpDyadLo, FWT_PO, aconv
%
	d = aconv(qmf,x);
	n = length(d);
	d = d(1:2:(n-1));

%
% Copyright (c) 1993. Iain M. Johnstone
%     
    
    
%   
% Part of WaveLab Version 802
% Built Sunday, October 3, 1999 8:52:27 AM
% This is Copyrighted Material
% For Copying permissions see COPYING.m
% Comments? e-mail wavelab@stat.stanford.edu
%   
    
