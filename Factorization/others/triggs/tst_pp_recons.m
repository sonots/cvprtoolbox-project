% tst_pp_recons(m,n,nplanar,noise,flatness,serial,bundle) 
%
% Test driver for plane+parallax factorization based projective reconstruction.
% Generates a random scene and runs SVD, limited rank, or incremental
% factorization based projective reconstruction on it. The scene is n
% points uniformly distributed in a unit sphere at the origin. There are
% m cameras in a uniform arc around the sphere and looking straight at
% it. Noise is isotropic Gaussian in pixels.
% Inputs:
%   Generates m images of n points with noise pixels noise.
%   rem(serial,2)=1 for serial chain, 0 for parallel chain depth estimation
%   (parallel is stablest). 
%   For serial>1 use differential instead of standard epipolar
%   constraint for depth recovery.
%   fixed_rank==1 - use limited rank SVD method (faster than normal SVD
%   if both m & n are large)
%   incremental==m1 - run batch econstruction up to image m1, then fold
%   in following ones incrementally

function e = tst_pp_recons(m,n,nplanar,noise,flatness,serial,bundle);
   % parameters
   f = 1000;			% focal length in pixels
   w = 512; h = 512;		% image width, height
   d = 5;			% camera distance from scene centre
   a = pi/4;			% angle from first to last camera
   % a = 0; 
   cam_t = [0; 0; d];
   cam_dt = [0;0;0];
   % cam_dt = [0.2*d/m;0;0];
   cam_R = [cos(a/m),0,sin(a/m); 0,1,0; -sin(a/m),0,cos(a/m)];
   K = [f,0,w/2; 0,f,h/2; 0,0,1];
   
   % generate scene, projections, images

   Xs = zeros(4,n);
   Ps = zeros(3*m,4);
   pxs = zeros(2*m,n);
   for p = 1:n
      X = randn(3,1);
      Xs(:,p) = [X/norm(X)*rand(1)^0.3333; 1];   % uniform unit sphere of points
%      Xs(:,p) = [X; 1];			  % spherical gaussian point distrib.
   end;
   Xs(3,:) = flatness * Xs(3,:);
   if (nplanar>0) 
      Xs(3,1:nplanar) = zeros(1,nplanar);
   end;
   for i = 1:m
      P = K*[cam_R^i,cam_t+cam_dt*i];
      Ps(3*i-2:3*i,:) = P;
      xis = P*Xs;
      for p = 1:n
	 pxs(2*i-1:2*i,p) = xis(1:2,p)/xis(3,p)+noise*randn(2,1);
      end;
   end;
   % pxs

   % reconstruction phase -- standardize+homogenize image coords,
   % then call reconstructor
   for i = 1:m
      for p = 1:n
	 xip = [2/w*pxs(2*i-1,p)-1; 2/h*pxs(2*i,p)-1; 1];
	 xs(3*i-2:3*i,p) = xip; %/norm(xip);
      end;
   end;

   [Ps1,Xs1,cond1] = proj_recons_ppsvd(xs,nplanar,serial);
   % the solution
   % Ps1
   % Xs1
   % cond1

   % estimate projective error by aligning reconstructed points
   % to true ones
   
   [H,cond3] = proj_from_pts_lin(Xs,Xs1);
   err3D = zeros(1,n);
   HXs = H*Xs1;
   for p = 1:n
      err3D(p) = norm(Xs(1:3,p)-HXs(1:3,p)/HXs(4,p));
   end;
   %   [cond1;cond3]
   recons_err_pp = norm(err3D,1)/n;
   reproj_err_pp = sum(sum(abs(proj_err_2D(xs,Ps1,Xs1))))/(m*n);
   
   if bundle
      [Ps2,Xs2] = do_proj_bundle(xs,Ps1,Xs1);
      [H,cond4] = proj_from_pts_lin(Xs,Xs2);
      err3D = zeros(1,n);
      HXs = H*Xs2;
      for p = 1:n
	 err3D(p) = norm(Xs(1:3,p)-HXs(1:3,p)/HXs(4,p));
      end;
      recons_err_bundle = norm(err3D,1)/n;
      reproj_err_bundle = sum(sum(abs(proj_err_2D(xs,Ps2,Xs2))))/(m*n);
      cond_bundle = 0;
   else
      recons_err_bundle = 2;
      reproj_err_bundle = 2;
      cond_bundle = 0;
   end;

   if (n>=8)
      [Ps2,Xs2,cond2] = proj_recons_fsvd(xs,serial,0);
      [H,cond4] = proj_from_pts_lin(Xs,Xs2);
      err3D = zeros(1,n);
      HXs = H*Xs2;
      for p = 1:n
	 err3D(p) = norm(Xs(1:3,p)-HXs(1:3,p)/HXs(4,p));
      end;
      % recons_errs_Fmat = err3D
      recons_err_Fmat = norm(err3D,1)/n;
      reproj_err_Fmat = sum(sum(abs(proj_err_2D(xs,Ps2,Xs2))))/(m*n);
      cond2 = cond2(2)/cond2(1);
   else
      recons_err_Fmat = 2;
      reproj_err_Fmat = 2;
      cond2 = 1;
   end;

   e = [recons_err_pp, reproj_err_pp, cond1, ...
	  recons_err_Fmat, reproj_err_Fmat, cond2, ...
      recons_err_bundle, reproj_err_bundle, cond_bundle ];
%end;

