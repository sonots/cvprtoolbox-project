function [state, frame, vidfile, id] = getFileinfo(filename)
% ../053524_w2b.ts/imageclipper/053524_w2b.ts_0004.png_0000_0641_0487_0034_0053.png
[dirname, basename, ext] = fileparts(filename);
parts  = strsplit('_', basename);
rotate = sscanf(parts{end-4}, '%d');
x      = sscanf(parts{end-3}, '%d');
y      = sscanf(parts{end-2}, '%d');
width  = sscanf(parts{end-1}, '%d');
height = sscanf(parts{end}, '%d');
state  = [x; y; width; height; rotate];
frame  = sscanf(parts{end-5}, '%4d');
if length(parts) > 6
    vidfile = [parts{end-7},'_',parts{end-6}];
    id = parts{end-7};
else
    vidfile = [];
    id = [];
end
end
