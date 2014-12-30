function resizeImageFig(h, sz, frac)
% function resizeImageFig(h, sz, frac)
% Resize figure with handle h to have pixels of size frac. 
%  sz = image size.
%  frac (default = 1, provides truesize when sz = size of displayed image).

if (nargin <3)
 frac = 1;
end

pos = get(h, 'Position');
set(h, 'Units', 'pixels', 'Position', ...
       [pos(1), pos(2)+pos(4)-frac*sz(1), ... %% Keep top left corner fixed
        frac*sz(2), frac*sz(1)]);
set(gca,'Position', [0 0 1 1], 'Visible', 'off');
