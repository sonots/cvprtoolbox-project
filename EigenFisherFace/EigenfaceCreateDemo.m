% A small demo to create eigenface pictures
function EigenfaceCreateDemo
% training data
for i=1:5 
    It(:,:,i) = imread(sprintf('image/face%02d.gif', i));
end
[nRow, nCol, N] = size(It);
Xt = reshape(double(It), [], 5);
Ct = [1 2 3 4 5];

% PCA
[U, Me] = cvPca(Xt);
[D, M] = size(U);

% imshow meanface
Y = reshape(uint8(Me), nRow, nCol);
figure(M+1); imshow(Y);
imwrite(Y, sprintf('result/meanface.png'), 'PNG');

% imshow eigenfaces
for i=1:M
    Y = reshape(U(:,i), nRow, nCol);
    Y = uint8(cvuNormalize(Y, [0, 255])); % normalize to plot
    figure(i); imshow(Y);
    imwrite(Y, sprintf('result/eigenface%02d.png', i), 'PNG');
end

% composed by component j
[Y, TX, Ratio] = cvPcaProj(Xt, U, Me);
[M N] = size(Ratio);
for i = 1:N, fprintf('face%02d: \r', i);
    for j = 1:M, fprintf('%02d%% is composed by eigenface%d. \r', ...
        round(Ratio(j,i)*100), j);
    end
end
