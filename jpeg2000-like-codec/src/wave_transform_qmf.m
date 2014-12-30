function [transformed] = wave_transform_qmf(picture, filter_length);
% Defining filter aspects
%filter_length = 9;
qmf_filter = ['qmf' num2str(filter_length)];
siz = size(picture,1); %size of image
low_siz = 2^(nextpow2(filter_length)-1); %size of highest decomposition (DC-coeff blok)
decomp_order = maxPyrHt(siz,filter_length); %maximum decomposition order

% performing the wavelet decomposition of order 'decomp_order'
% we use a qmf filter to make sure we get square decompositions
[C,S] = buildWpyr(picture,decomp_order,qmf_filter);

transformed(1:low_siz,1:low_siz) = reshape( C( (size(C,1)-(low_siz*low_siz)+1 ):size(C,1) ),low_siz,low_siz );
for i=1:decomp_order,
    transformed( 1 : (siz/2^i) , ((siz/2^i)+1) : (siz/2^(i-1))) = wpyrBand(C,S,i,1);
    transformed( ((siz/2^i)+1) : (siz/2^(i-1)) , 1 : (siz/2^i)) = wpyrBand(C,S,i,2);
    transformed( ((siz/2^i)+1) : (siz/2^(i-1)) , ((siz/2^i)+1) : (siz/2^(i-1)) ) = wpyrBand(C,S,i,3);
end