function flag4
 SI = 5; SX = 4; r = 1; mNcut = 0.1;
 I = imread('image/France.png');
 NcutImageSegment(I, SI, SX, r, mNcut);
end
