function demo4(write)
if ~exist('write', 'var'), write = false; end;
SI =5; SX = 6; r = 1.5; sNcut = 0.04; sArea = 1000;
I = imread('image/3.jpg');
tic
segI = NcutImageSegment(I, SI, SX, r, sNcut, sArea);
toc
% show
for i=1:length(segI)
    if ~write
        figure; imshow(segI{i});
    else
        imwrite(segI{i}, sprintf('result/3-%d.png', i));
    end
end
end
