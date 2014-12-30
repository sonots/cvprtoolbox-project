% r = epipolar_err_proj(F12,x1,x2)
% Rough projective measure of residual error for estimated epipolar
% constraint. (Proportional to the true statistical error iff point
% measurement errors are equal and uniform on the homogeneous coordinate
% sphere).

function r = epipolar_err_proj(F12,x1,x2)
   n = size(x1,2);
   r = 0;
   for p = 1:n
      xp = x1(:,p); yp = x2(:,p);
      xf = xp'*F12; fy = F12*yp;
      r = r + (xf*yp)^2/((xf*xf')*(yp'*yp)+(xp'*xp)*(fy'*fy));
   end;
%end;
