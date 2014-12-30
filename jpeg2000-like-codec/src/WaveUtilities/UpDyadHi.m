function y = UpDyadHi(x,qmf)
% UpDyadHi -- Hi-Pass Upsampling operator; periodized
%  Usage
%    u = UpDyadHi(d,f)
%  Inputs
%    d    1-d signal at coarser scale
%    f    filter
%  Outputs
%    u    1-d signal at finer scale
%
%  See Also
%    DownDyadLo, DownDyadHi, UpDyadLo, IWT_PO, aconv
%
	
	y = aconv( MirrorFilt(qmf), rshift( UpSample(x) ) );
	
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
    
