function [rowN,colN,dct_block_size,iQ,iZZDCTQIm]=JPEG_entropy_decode(decoder_path)

% function [rowN,colN,dct_block_size,iQ,iZZDCTQIm]=JPEG_entropy_decode(decoder_path)
% JPEG Entropy Decoder
% Input:
%      decoder_path: string: the absolute path which put this .m and jpeg_entropy_encode.exe
%             ## remember to set "current directory window" under Matlab to this path, thus this .exe file can run
% Output:
%      rowN: 1x1 : number of row
%      colN: 1x1 : number of column
%      dct_block_size: 1x1: the dimension of DCT
%      iQ: dct_block_sizexdct_block_size : quantization table
%      iZZDCTQIm: (rowN*colN/dct_block_size^2)x(dct_block_size^2) : the zigzaged image matrix which is already DCT/Q. 
%
% Author: Guan-Ming Su
% Date: 8/1/02

% execute the jpeg entropy program
!jpeg_entropy_decode

% open decoded file by jpeg_entropy_decode
[fid_in,message]=fopen(strcat(decoder_path,'JPEG_iDCTQ_ZZ.txt'),'r');
temp=fgets(fid_in);  % read comment
temp=fgetl(fid_in);  % read filename
temp=fgetl(fid_in);  % read DisplauProcess_Flag
temp=fgetl(fid_in);   next_index=findstr(temp,':')+1; rowN=str2num(temp(next_index:end));   % read number of row
temp=fgetl(fid_in);   next_index=findstr(temp,':')+1; colN=str2num(temp(next_index:end));   % read number of col
temp=fgetl(fid_in);   next_index=findstr(temp,':')+1; dct_block_size=str2num(temp(next_index:end));  % read dct block size
rowblkN=rowN/dct_block_size; colblkN=colN/dct_block_size;

temp=fgetl(fid_in);   % read DQT
iQ=zeros(dct_block_size,dct_block_size);  % read table
for i=1:1:dct_block_size
    temp=fgetl(fid_in);
    iQ(i,:)=str2num(temp);
end

temp=fgetl(fid_in);   % read Y:
% read data
iZZDCTQIm=zeros(rowblkN*colblkN,dct_block_size*dct_block_size);
for i=1:1:rowblkN*colblkN
   temp=fgetl(fid_in);
   iZZDCTQIm(i,:)=str2num(temp);
end     
fclose(fid_in);
