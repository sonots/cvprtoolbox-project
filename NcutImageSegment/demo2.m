function demo2(write)
if ~exist('write', 'var'), write = false; end;
SI =5; SX =6; r = 1.5; sNcut = 0.14; sArea = 220;
I = imread('image/s42049.jpg');
segI = NcutImageSegment(I, SI, SX, r, sNcut, sArea);
% show
for i=1:length(segI)
    if ~write
        figure; imshow(segI{i});
    else
        imwrite(segI{i}, sprintf('result/s42049-%d.png', i));
    end
end
end
