function ind = gen_zigzagind(N)
% Generate zigzag association indices between matrix and to be generate
% vector for JPEG like zigzag scanning
%
%  ind = gen_zigzagind(N)
%
% Input arguments ([]s are optional):
%  N   (scalar) size of NxN matrix to be zigzag scanned
%
% Output arguments ([]s are optional):
%  ind (matrix) of size N^2x2. First column contains the appropriate row
%   indices and the second column contains the column indices of scanned matrix 
%
% Reference: 
%  JPEGtool collection of scripts for Octave and Matlab; 
%  http://www.dms.auburn.edu/compression
%
% Author: Naotoshi Seo <sonots(at)umd.edu>
% Date  : March 2007
ind = zeros(N,2);
c = 0;
r = 2;
increment = 1;
for n = 1:N*N
  r = r - increment; c = c + increment;
  if (c > N)
    r = r + 2; c = N; increment = -1;
  elseif (r < 1)
    r = 1; increment = -1;
  elseif (r > N)
    c = c + 2; r = N; increment = 1;
  elseif (c < 1)
    c = 1; increment = 1;
  end
  ind(n,:) = [r c];
end
