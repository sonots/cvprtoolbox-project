function demo_sifttracker(disto, usecache)
if ~exist('disto', 'var')
    disto = 0.6;
end
if ~exist('usecache', 'var')
    usecache = 0;
end

savefile = '../images/castle/castle.tracker';
if usecache & exist(savefile)
    eval(sprintf('load ''%s'' U V -mat', savefile));
else
    for i=1:13
        im_names{i} = sprintf('../images/castle/castle.%03d.pgm', i);
    end
    global cache; cache = 3;
    [U, V] = sifttracker(im_names, disto);

    % Delete errored tracking points (one more -1)
    U = U(:, sum(U < 0, 1) == 0);
    V = V(:, sum(V < 0, 1) == 0);
    
    eval(sprintf('save ''%s'' U V -mat', savefile));
end

% plot
I = imread('../images/castle/castle.001.pgm');
[F, P] = size(U);
figure;
imshow(I);
hold on;
plot(U(1, :), V(1, :), '.y');
for j=1:P
    plot(U(2:F, j), V(2:F, j), '-g');
end
set(gca,'Position', [0 0 1 1], 'Visible', 'off');