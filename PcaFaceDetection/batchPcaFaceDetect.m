function batchPcaFaceDetect(pose)
if ~exist('pose','var') || isempty(pose)
    pose = 'frontal';
    wsize = [10; 10; 3; 3; 6];
end
if strcmp(pose, 'profile')
    wsize = [10; 3; 3; 3; 10];
end
NAME = cvuLs(['../../',pose,'-clips'], 'dir', '^0.*');
NAME{end+1} = 'foobar';
for i = 1:length(NAME)
    if exist([NAME{i},'/imageclipper'],'dir') && ...
            ~exist([NAME{i},'/pcafacedetect'],'dir')
        break;
    end
end

last = i - 1; % try to resume last existing process
for i = last:length(NAME)
    if ~exist([NAME{i},'/imageclipper'],'dir')
        continue;
    end
    runPca(NAME{i});
    runPcaFaceDetect(NAME{i}, [], wsize, []);
end
