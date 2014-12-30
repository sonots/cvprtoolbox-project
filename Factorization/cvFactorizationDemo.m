% cvFactorizationDemo - Demo of cvFactorization
function cvFactorizationDemo(Experiment)
if ~exist('Experiment', 'var') || isempty(Experiment)
    Experiment = 1;
end
switch (Experiment)
    case 1
        W = cvuKltRead('image/hotel/hotel.seq%d.feat.txt', 0, 100);
        [R, S, t] = cvFactorization(W, 'orthographic');
    case 2
        W = cvuKltRead('image/medusa/medusa%03dfeat.txt', 110, 179);
        [R, S, t] = cvFactorization(W, 'orthographic');
    case 3
        W = cvuKltRead('image/hotel/hotel.seq%d.feat.txt', 0, 100);
        [R, S, t] = cvFactorization(W, 'paraperspective');
    case 4
        W = cvuKltRead('image/medusa/medusa%03dfeat.txt', 110, 179);
        [R, S, t] = cvFactorization(W, 'paraperspective');
%     case 5
%         W = cvuKltRead('image/castle/castle.%d.feat.txt', 0, 27);
end
F = size(W, 1) / 2;
P = size(W, 2);

% reconstruct approximated W
%  W = R*S + repmat(t, 1, P);
%  W = round(W);
%  I = imread('medusa/medusa110.pgm');
%  figure;
%  imshow(I);
%  hold on;
%  for j=1:P
%      plot(W(1:F, j), W(F+(1:F), j), '-g');
%  end
%  plot(W(1, :), W(F+1, :), '.y');

% Motion
% atan(y/x) yaw
figure; plot(1:F, atan(R(1:F,2)./R(1:F,1)) * 180/pi);
title('yaw'); xlabel('Frame number'); ylabel('degree');
% atan(z/y) roll
figure; plot(1:F, atan(R(1:F,3)./R(1:F,2)) * 180/pi);
title('roll'); xlabel('Frame number'); ylabel('degree');
% atan(z/x) pitch
figure; plot(1:F, atan(R(1:F,3)./R(1:F,1)) * 180/pi);
title('pitch'); xlabel('Frame number'); ylabel('degree');

% Shape, use rotate3 button
figure; plot3(S(1, :), S(2, :), S(3, :), '.');
figure; plot3(S(1, :), S(3, :), S(2, :), '.');
figure; plot3(S(2, :), S(1, :), S(3, :), '.');
figure; plot3(S(2, :), S(3, :), S(2, :), '.');
figure; plot3(S(3, :), S(1, :), S(2, :), '.');
figure; plot3(S(3, :), S(2, :), S(1, :), '.');
% x = S(1, :);
% y = S(2, :);
% z = S(3, :);
% tri = delaunay(x,y);
% h = trisurf(tri, x, y, z);
end
