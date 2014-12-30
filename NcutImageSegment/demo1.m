function demo1(write)
if ~exist('write', 'var'), write = false; end;
SI =500; SX = 4; r = 1.1; sNcut = 0.21; sArea = 15;
I = imread('image/test5.jpg');
segI = NcutImageSegment(I, SI, SX, r, sNcut, sArea);
% show
%figure; imshow(imresize(I, [45 60]));
for i=1:length(segI)
    if ~write
        figure; imshow(imresize(segI{i}, [45 60]));
    else
        imwrite(imresize(segI{i}, [45 60]), sprintf('result/test5-%d.png', i));
    end
end
end
