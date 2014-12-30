function demo5(write)
if ~exist('write', 'var'), write = false; end;
SI =5; SX =6; r = 1.5; sNcut = 0.14; sArea = 220;
I = imread('image/42049.jpg');
tic
segI = NcutImageSegment(I, SI, SX, r, sNcut, sArea);
toc
% show
for i=1:length(segI)
    if ~write
        figure; imshow(segI{i});
    else
        imwrite(segI{i}, sprintf('result/42049-%d.png', i));
    end
end
end
