function runPca(dirname)
filename = [dirname,'/imageclipper/pca.mat'];
if exist(filename,'file'), return; end;
FILE = cvuLs([dirname, '/imageclipper/'], 'file', 'png$');
imsize = [24, 24];
for i = 1:length(FILE)
    I = cvuImgread(FILE{i});
    I = double(I);
    I = imresize(I, imsize);
    X(:,i) = reshape(I, prod(imsize), 1);
    X(:,i) = cvGaussNorm(X(:,i).').';
    % X(:,i) = X(:,i) ./ 255;
end
[V, Me Lambda] = cvPca(X, 5);
PCA.V = V; PCA.Me = Me; PCA.Lambda = Lambda;
eval(sprintf('save %s X PCA imsize', filename));
