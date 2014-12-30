% A small demo to create reconstructed facial images
function EigenfaceReconstructDemo
% training data
for i=1:5 
    It(:,:,i) = imread(sprintf('image/face%02d.gif', i));
end
Xt = reshape(double(It), [], 5);
Ct = [1 2 3 4 5];

% test data
Iq(:,:,1) = imread('image/face01.gif');
Iq(:,:,2) = imread('image/face06.gif');
Iq(:,:,3) = imread('image/occludedface06.gif');
[nRow, nCol, N] = size(Iq);
Xq = reshape(double(Iq), [], 3);

% training
[U, Me] = cvPca(Xt);

% projection
[Yq] = cvPcaProj(Xq, U, Me);
% reconstruction
[Zq] = cvPcaInvProj(Yq, U, Me);

Rq = reshape(uint8(Zq), nRow, nCol, N);
imwrite(Rq(:, :, 1), 're_face01.gif', 'GIF');
imwrite(Rq(:, :, 2), 're_face06.gif', 'GIF');
imwrite(Rq(:, :, 3), 're_occludedface06.gif', 'GIF');
end