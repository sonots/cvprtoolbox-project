% A small demo of the eigenface recognition
function EigenfaceRecognitionDemo
% training data
for i=1:5 
    It(:,:,i) = imread(sprintf('image/face%02d.gif', i));
end
Xt = reshape(double(It), [], 5);
Ct = [1 2 3 4 5];

% test data
Iq(:,:,1) = imread('image/face06.gif');
Iq(:,:,2) = imread('image/occludedface06.gif');
Iq(:,:,3) = imread('image/face07.gif');
Iq(:,:,4) = imread('image/face08.gif');
Xq = reshape(double(Iq), [], 4);
Cq = [1 1 2 3];

Xt = cvuMat2Cell(Xt, Ct);
Xq = cvuMat2Cell(Xq, Cq);
[Classified, Rate, Rank] = Eigenface(Xt, Xq, []);
Classified
Rate
Rank
end