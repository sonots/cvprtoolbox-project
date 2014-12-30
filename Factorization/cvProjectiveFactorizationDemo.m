% cvProjectiveFactorizationDemo - Demo of cvProjectiveFactorization
function cvProjectiveFactorizationDemo(Experiment)
if ~exist('Experiment', 'var') || isempty(Experiment)
    Experiment = 1;
end
switch (Experiment)
    case 1
        W = cvuKltRead('image/hotel/hotel.seq%d.feat.txt', 0, 100);
        [P, X, T] = cvProjectiveFactorization(W);
end
m = size(P, 1) / 3;
n = size(X, 2);

% Projection recovery
for i=1:m
    P(3*i-2:3*i, :) = inv(T{i}) * P(3*i-2:3*i, :);
end

% plot projection motion
for i=1:m
    R(i, :) = P(i*3-2, :);
    R(i+m, :) = P(i*3-1, :);
    R(i+2*m, :) = P(i*3, :);
end
% atan(y/x) yaw
figure; plot(1:m, atan(R(1:m,2)./R(1:m,1)) * 180/pi);
title('yaw'); xlabel('Frame number'); ylabel('degree');
% atan(z/y) roll
figure; plot(1:m, atan(R(1:m,3)./R(1:m,2)) * 180/pi);
title('roll'); xlabel('Frame number'); ylabel('degree');
% atan(z/x) pitch
figure; plot(1:m, atan(R(1:m,3)./R(1:m,1)) * 180/pi);
title('pitch'); xlabel('Frame number'); ylabel('degree');

% Shape, use rotate3 button
figure; plot3(X(1, :), X(2, :), X(3, :), '.');
end
