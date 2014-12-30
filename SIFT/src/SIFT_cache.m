function [ im, pos, scale, ori, desc ] = SIFT_cache( imfile, levels, s, search_mask, d, r )
% global cache (scalar) [0-3]:
%    0: Do not use cache.
%    1: use cache file
%    2: Do not use cache. Use Lowe's software
%    3: use cache file created by Lowe's software
global cache;
if ~exist('cache', 'var')
    cache = 1;
end
im = im2double(imread(imfile));
if cache <= 1
    if cache == 1 & exist([imfile '.sift'])
        eval(sprintf('load ''%s.sift'' pos scale ori desc -mat', imfile));
    else
        if ~exist('levels')
            levels = 4;
        end
        if ~exist('s')
            s = 2; % [1]'s Figure 3 shows 2 or 3 are efficient.
        end
        if ~exist('search_mask')
            search_mask = ones(size(im));
        end
        if size(search_mask) ~= size(im)
            search_mask = ones(size(im));
        end
        if ~exist('d')
            d = 0.02; % [1] 4 less than 0.03, though
        end
        if ~exist('r')
            r = 10.0; % [1] 4.1 r = 10
        end

        [pos scale ori desc] = SIFT( im, levels, s, search_mask, d, r );
        eval(sprintf('save ''%s.sift'' pos scale ori desc -mat', imfile));
    end
else
    if cache == 3 & exist([imfile '.lowe'])
        eval(sprintf('load ''%s.lowe'' pos scale ori desc -mat', imfile));
    else
        cd 'siftDemoV4';
        [tmp, desc, loc] = sift(['../' imfile]);
        pos(:,1) = loc(:,2); pos(:,2) = loc(:,1);
        scale(:, 1) = loc(:, 3);
        ori(:, 1) = loc(:, 4);
        cd '..';
        eval(sprintf('save ''%s.lowe'' pos scale ori desc -mat', imfile));
    end
end
