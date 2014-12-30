function [transformed] = wave_transform(picture);
siz = size(picture,1);

% order of decomposition
decomp_order = log2(siz);

% performing the wavelet decomposition of order 'decomp_order'
% we use a db1 filter to make sure we get square decompositions
[C,S] = wavedec2(picture,decomp_order,'db1');

% convert wavelet coefficient to matrix format
transformed( 1:(siz/(2^decomp_order)) , 1:(siz/(2^decomp_order)) ) = appcoef2(C,S,'db1',decomp_order);
for i=1:decomp_order,
    transformed( 1 : (siz/2^i) , ((siz/2^i)+1) : (siz/2^(i-1))) = detcoef2('h',C,S,i);
    transformed( ((siz/2^i)+1) : (siz/2^(i-1)) , 1 : (siz/2^i)) = detcoef2('v',C,S,i);
    transformed( ((siz/2^i)+1) : (siz/2^(i-1)) , ((siz/2^i)+1) : (siz/2^(i-1)) ) = detcoef2('d',C,S,i);
end
