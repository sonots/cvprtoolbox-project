function flag1
 SI =5; SX = 4; r = 2; mNcut = 0.08;
 I = imread('image/Japan.png');
 NcutImageSegment(I, SI, SX, r, mNcut);
end
