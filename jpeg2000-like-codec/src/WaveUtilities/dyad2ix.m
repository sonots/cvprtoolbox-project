function ix = dyad2ix(j,k)
% dyad2ix -- Convert wavelet indexing into linear indexing
%  Usage
%    ix = dyad2ix(j,k)
%  Inputs
%     j    Resolution Level. j >= 0.
%     k    Spatial Position. 0 <= k < 2^j
%  Outputs
%     ix   index in linear 1-d wavelet transform array where
%          the (j,k) wavelet coefficient is stored
%
   ix = 2^j + k + 1;

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
    
