function [invwave_transformed] = invwave_transform(wavedata);



siz = size(wavedata,1);
order = log2(siz);

% converting wavelet coefficients to 'waverec2' C format
ret = [wavedata(1,1),wavedata(1,2),wavedata(2,1),wavedata(2,2)];
for i=order-1:-1:1,
    temp = wavedata( 1 : (siz/2^i) , ((siz/2^i)+1) : (siz/2^(i-1))) ;
    for j=1:size(temp,1),
        ret=[ret temp(:,j)'];
    end
    
    temp = wavedata( ((siz/2^i)+1) : (siz/2^(i-1))  , 1 : (siz/2^i)) ;
    for j=1:size(temp,1),
        ret=[ret temp(:,j)'];
    end

    temp = wavedata( ((siz/2^i)+1) : (siz/2^(i-1))  , ((siz/2^i)+1) : (siz/2^(i-1)));
    for j=1:size(temp,1),
        ret=[ret temp(:,j)'];
    end
end

% generate S matrix
S = [[1, 1]; [1, 1]];
s = 1;
while(s < siz),
    s = s*2;
    S = [S; [s, s]];
end

invwave_transformed = waverec2(ret,S,'db1');