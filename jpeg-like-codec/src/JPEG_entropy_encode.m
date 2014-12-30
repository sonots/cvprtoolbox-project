function [Len]=JPEG_entropy_encode(rowN,colN,dct_block_size,Q,ZZDCTQIm,encoder_path,DisplayProcess_Flag)

% function [Len]=JPEG_entropy_encode(rowN,colN,dct_block_size,Q,ZZDCTQIm,encoder_path,DisplayProcess_Flag)
% JPEG Entropy Encoder
% Input:
%      rowN: 1x1 : number of row
%      colN: 1x1 : number of column
%      dct_block_size: 1x1: the dimension of DCT
%      Q: dct_block_sizexdct_block_size : quantization table
%      ZZDCTQIm: (rowN*colN/dct_block_size^2)x(dct_block_size^2) : the zigzagged image matrix which is already DCT/Q. 
%      encoder_path: string: the absolute path which put this .m and jpeg_entropy_encode.exe
%                   ## remember to set "current directory window" under Matlab to this path, thus this .exe file can run
%      DisplayProcess_Flag: 1x1: flag for displaying the zero run pair and huffman table (in JPEG_entropy_encode.html)
% Output:
%      Len: 1x1 compressed file length
%
% Author: Guan-Ming Su
% Date: 8/1/02

% initial checking for input arguments
rowblkN=rowN/dct_block_size;
colblkN=colN/dct_block_size;
if (rowblkN~=round(rowN/dct_block_size)) | (colblkN~=round(colN/dct_block_size))
    error('number of row/column must be multiple of dct_block_size');
end    
[d1,d2]=size(Q);
if (d1~=dct_block_size) | (d2~=dct_block_size)
    error('Dimention of Quantization Talbe should be dct_block_size x dct_block_size ');
end
[d1,d2]=size(ZZDCTQIm);
if (d1~=rowblkN*colblkN) |(d2~=dct_block_size*dct_block_size)
    error('Dimension of ZZDCTQIm should be (rowN*colN/dct_block_size^2)x(dct_block_size^2)');
end    
if isempty(DisplayProcess_Flag); DisplayProcess_Flag=0; end;
    
% open file
[fid_out,message]=fopen(strcat(encoder_path,'JPEG_DCTQ_ZZ.txt'),'w');
% write comment
fprintf(fid_out,'%s\n','# For parsing zigzag YCbCr file used by jpeg_entropy_encode.cpp.  Author: Guan-Ming Su Date:8/1/02');
% write information for encoding
fprintf(fid_out,'%s\n','JPEG_Filename: JPEG.jpg'); 
fprintf(fid_out,'%s','DisplayProcess: ');   fprintf(fid_out,'%s\n',num2str(DisplayProcess_Flag));
fprintf(fid_out,'%s','rowN: ');             fprintf(fid_out,'%s\n',num2str(rowN));
fprintf(fid_out,'%s','colN: ');             fprintf(fid_out,'%s\n',num2str(colN));
fprintf(fid_out,'%s','dct_block_size: ');   fprintf(fid_out,'%s\n',num2str(dct_block_size));
% write DQT: Define Quantization Table
fprintf(fid_out,'%s\n','DQT:');
for i=1:1:dct_block_size
   for j=1:1:dct_block_size
      fprintf(fid_out,'%s ',num2str(Q(i,j)));
   end
     fprintf(fid_out,'\n');
end     
% write zigzag data
fprintf(fid_out,'%s\n','Y:');
for i=1:1:rowblkN*colblkN
   for j=1:1:dct_block_size*dct_block_size
      fprintf(fid_out,'%s ',num2str(ZZDCTQIm(i,j)));
   end
     fprintf(fid_out,'\n');
end     
status=fclose(fid_out);

% execute the jpeg entropy program
!jpeg_entropy_encode
[fid,message]=fopen(strcat(encoder_path,'JPEG.jpg'),'r');
status = fseek(fid,0,'eof');
Len=ftell(fid);
fclose(fid);
