S = 4*rand(3,80);
S(1,:) = S(1,:) - mean(S(1,:));
S(2,:) = S(2,:) - mean(S(2,:));
S(3,:) = S(3,:) - mean(S(3,:));


i=1;
for x=-8:0.1:8.1;
  y(i)=sqrt(36 - 9*x^2/16);
  i=i+1;
end

x=-8:0.1:8.1;
figure; 
hold on
plot(T(1,1:length(T)/2),T(3,1:length(T)/2),'.');
hold on
plot(T(1,50:length(T)),T(3,50:length(T)),'.r');
figure;
len = length(x);
half = length(x)/2;
T = [x(half+1:len) fliplr(x(half+1:len)) ; ...
      zeros(1,len); ...
      y(half+1:len) -fliplr(y(half+1:len)) ];


k = zeros(size(T,1), size(T,2)) - T;

J = [0;1;0];

for n=1:size(k,2);
  I(:,n) = -cross(k(:,n),J);
end

var = 0.2;
R = [I [zeros(1,size(k,2)); ones(1,size(k,2)); zeros(1,size(k,2))]]';
U = R*S + rand(size(R,1), size(S,2)) / 100; %+ gaussnoise(size(R,1), size(S,2), var);

[M, A, t] = orthofactor(U);
[Ms,As] = projfactor(U);
[Mp,Ap,tp] = parapersfactor(U);


%% recover camera motion

for n=1:size(R,1)/2
  % yaw
  
  num = R(n,1);
  if (num ~= 0)  yaw(n) = atan(-R(n,2)/num) * 180 /  pi;  % atan(y/x)
  else yaw(n) = 90;
  end
    
  % atan(z/x) pitch
  if (num ~= 0) pitch(n) = atan(R(n,3)/R(n,1)) * 180 / pi;  
  else pitch(n) = 90;
  end
    
  %atan(z/y) roll  
  num = R(n,2);
  if (num ~= 0) roll(n) = atan(R(n,3)/R(n,2)) * 180 / pi;  
  else roll(n) = 90;
  end

%   % scaled ortho
%   num = Ms(n,1);
%   if (num ~= 0) yaw1(n) = atan(-Ms(n,2)/Ms(n,1)) * 180 / pi;  
%   else yaw1(n) = 90;
%   end
% 
%   if (num ~= 0) pitch1(n) = atan(-Ms(n,3)/Ms(n,1)) * 180 / pi;  
%   else pitch1(n) = 90;
%   end
%   
%   num = Ms(n,2);
%   if (num ~= 0) 
%     roll1(n) = atan(Ms(n,3)/Ms(n,2)) * 180 / pi;  
%     if (roll1(n) <0) roll1(n) = -roll1(n); end
%   else roll1(n) = 90;
%   end

  % factorization
  num = M(n,1);
  if (num ~= 0) yaw2(n) = atan(-M(n,2)/M(n,1)) * 180 / pi;  
  else yaw1(n) = 90;
  end

  if (num ~= 0) pitch2(n) = atan(-M(n,3)/M(n,1)) * 180 / pi;  
  else pitch2(n) = 90;
  end
  
  num = M(n,2);
  if (num ~= 0) 
    roll2(n) = atan(M(n,3)/M(n,2)) * 180 / pi;  
    if (roll2(n) <0) roll2(n) = -roll2(n); end
  else roll2(n) = 90;
  end

  % factorization
  num = Mp(n,1);
  if (num ~= 0) yaw3(n) = atan(-Mp(n,2)/Mp(n,1)) * 180 / pi;  
  else yaw3(n) = 90;
  end

  if (num ~= 0) pitch3(n) = atan(-Mp(n,3)/Mp(n,1)) * 180 / pi;  
  else pitch3(n) = 90;
  end
  
  num = Mp(n,2);
  if (num ~= 0) 
    roll3(n) = atan(Mp(n,3)/Mp(n,2)) * 180 / pi;  
    if (roll3(n) <0) roll3(n) = -roll3(n); end
  else roll3(n) = 90;
  end

end


figure(1)
subplot(311)
hold off
plot(1:length(yaw), yaw, 'r');
hold on

plot(1:length(yaw2), yaw2, 'g');
plot(1:length(yaw3), yaw3, 'b');
% plot(1:length(yaw1), yaw1, 'y');
subplot(312)

hold off
plot(1:length(pitch), pitch, 'r');
hold on 


plot(1:length(pitch2), pitch2, 'g');
plot(1:length(pitch3), pitch3, 'b');
% plot(1:length(pitch1), pitch1, 'y');
subplot(313)

hold off
plot(1:length(roll), roll, 'r');
hold on 
plot(1:length(roll2), roll2, 'g');
plot(1:length(roll3), roll3, 'b');
% plot(1:length(roll1), roll1, 'y');

xlabel('frame number')
ylabel('roll (degree)')
legend('ground truth','orthographic','paraperspective');
subplot(312)
ylabel('pitch (degree)')
subplot(311)
ylabel('yaw (degree)')  
title('Factorized camera motion vs. true camera motion');


%% recover object shape

sc = norm(S(:,1));
for i=1:size(S,2)
  SS(:,i) = S(:,i)/sc;
end

sc = norm(A(:,1));
for i=1:size(A,2)
  AA(:,i) = A(:,i)/sc;
end

% sc = norm(As(:,1));
% for i=1:size(As,2)
%   AAs(:,i) = As(:,i)/sc;
% end

sc = norm(Ap(:,1));
for i=1:size(Ap,2)
  AAp(:,i) = Ap(:,i)/sc;
end

figure(2)
hold off
plot3(SS(1,:), SS(2,:), SS(3,:), '.');
hold on
% plot3(AAs(1,:), AAs(2,:), -AAs(3,:), '.r');
plot3(AA(1,:), AA(2,:), -AA(3,:), '.g');
plot3(AAp(1,:), AAp(2,:), -AAp(3,:), '.y');


figure(3)
hold off
plot(SS(1,:), SS(2,:), '.');
hold on
% plot(AAs(1,:), -AAs(2,:), '.r');
plot(AA(1,:), -AA(3,:), '.g');
plot(AAp(1,:), -AAp(3,:), '.y');


%% recover depth

for i=1:size(M,1)/2,
  zf(i) = sqrt(norm(k(:,i)));
%   zfs(i) = sqrt(1/norm(Ms(i,:)));
  zfp(i) = sqrt((1+tp(i)^2)/norm(Mp(i,:)));
end

% sc = (max(zfs) - min(zfs))/(max(zf)-min(zf));
% zzf = (zf - min(zf)) * (sc-0.04) + 1.3;

figure(4)
hold off
% plot(1:size(zf,2), zzf);
hold on
% plot(1:size(zf,2), zfs, 'r');
plot(1:size(zf,2), zfp, 'g');

%nframe = size(U,1)/2;
%nfeat = size(U,2);

%for n=1:nframe,
%  hold off
%  plot(U(n,:),U(n+nframe,:), '.');
%  hold on
%  plot(-3, 1, '.');
%  plot(3, -1, '.');
%  M(:,n) = getframe;
%end

% movie(M);
