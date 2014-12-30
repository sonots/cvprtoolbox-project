function i = dyad(j)
% dyad -- Index entire j-th dyad of 1-d wavelet xform
%  Usage
%    ix = dyad(j);
%  Inputs
%    j     integer
%  Outputs
%    ix    list of all indices of wavelet coeffts at j-th level
%
    i = (2^(j)+1):(2^(j+1)) ;

%
% Copyright (c) 1993. David L. Donoho
%     
    
    
%   
% Part of WaveLab Version 802
% Built Sunday, October 3, 1999 8:52:27 AM
% This is Copyrighted Material
% For Copying permissions see COPYING.m
% Comments? e-mail wavelab@stat.stanford.edu
%   
    
