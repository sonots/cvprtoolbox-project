function flag2
 SI =5; SX = 4; r = 1; mNcut = 0.09;
 I = imread('image/SouthAfrica.png');
 NcutImageSegment(I, SI, SX, r, mNcut);
end
