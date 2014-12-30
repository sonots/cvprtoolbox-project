function [invwave_transformed] = invwave_transform_qmf(wavedata, filter_length);

% Defining filter aspects
qmf_filter = ['qmf' num2str(filter_length)];
siz = size(wavedata,1);
order = maxPyrHt(siz,filter_length);

% Constructing S-matrix
entry = siz;
S = [];
for i = 1:order,
    entry = entry/2;
    S = [S; [entry entry]; [entry entry]; [entry entry]];
end
S = [S; [entry entry]];
%disp(S);

nbands = 3;
pind = S;

for i=order:-1:1,
    
    temp = wavedata( 1 : (siz/2^i) , ((siz/2^i)+1) : (siz/2^(i-1)))  ;
    index = pyrBandIndices(pind,1 + nbands*(i-1));
    ret(index) = reshape(temp,1,(siz/2^i)*(siz/2^i)); 

    temp = wavedata( ((siz/2^i)+1) : (siz/2^(i-1))  , 1 : (siz/2^i)) ;
    index = pyrBandIndices(pind,2 + nbands*(i-1));
    ret(index) = reshape(temp,1,(siz/2^i)*(siz/2^i)); 

    temp = wavedata( ((siz/2^i)+1) : (siz/2^(i-1))  , ((siz/2^i)+1) : (siz/2^(i-1)));
    index = pyrBandIndices(pind,3 + nbands*(i-1));
    ret(index) = reshape(temp,1,(siz/2^i)*(siz/2^i)); 
end

ret = [ret reshape(wavedata(1:4,1:4),1,16)];

invwave_transformed = reconWpyr(ret',S,qmf_filter);