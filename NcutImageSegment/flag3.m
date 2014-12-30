function flag3
 SI = 5; SX = 4; r = 2; mNcut = 0.35;
 I = imread('image/CzechRepublic.png');
 NcutImageSegment(I, SI, SX, r, mNcut);
end
