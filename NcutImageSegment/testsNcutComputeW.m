function testsNcutComputeW
 I = imread('image/test5.jpg'); %15x20
 [nRow, nCol, c] = size(I);
 V = reshape(I, nRow * nCol, c);
 SI = 5;
 SX = 4;
 r = 2;
 W = NcutComputeW(I, SI, SX, r);
 W(1,:)
 W(123,:)
end
