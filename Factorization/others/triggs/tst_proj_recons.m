% tst_proj_recons(m,n,noise,serial,fixed_rank,incremental) 
%
% Test driver for factorization based projective reconstruction.
% Generates a random scene and runs SVD, limited rank, or incremental
% factorization based projective reconstruction on it. The scene is n
% points uniformly distributed in a unit sphere at the origin. There are
% m cameras in a uniform arc around the sphere and looking straight at
% it. Noise is isotropic Gaussian in pixels.
% Inputs:
%   m images of n points with noise noise.
%   serial=1 for serial chain, 0 for parallel chain depth estimation
%   (parallel is stablest).
%   fixed_rank==1 - use limited rank SVD method (faster than normal SVD
%   if both m & n are large)
%   incremental==m1 - run batch econstruction up to image m1, then fold
%   in following ones incrementally

function tst_proj_recons(m,n,noise,serial,fixed_rank,incremental);
   % parameters
   f = 1000;			% focal length in pixels
   w = 512; h = 512;		% image width, height
   d = 10;			% camera distance from scene centre
   a = pi/4;			% angle from first to last camera
   cam_t = [0; 0; d];
   cam_R = [cos(a/m),0,sin(a/m); 0,1,0; -sin(a/m),0,cos(a/m)];
   K = [f,0,w/2; 0,f,h/2; 0,0,1];
   
   % generate scene, projections, images

   Xs = zeros(4,n);
   Ps = zeros(3*m,4);
   pxs = zeros(2*m,n);
   for p = 1:n
      X = randn(3,1);
      Xs(:,p) = [X/norm(X)*rand(1)^0.3333; 1;];   % uniform unit sphere of points
%      Xs(:,p) = [X; 1;];			  % spherical gaussian point distrib.
   end;
   for i = 1:m
      P = K*[cam_R^i,cam_t];
      Ps(3*i-2:3*i,:) = P;
      xis = P*Xs;
      for p = 1:n
	 pxs(2*i-1:2*i,p) = xis(1:2,p)/xis(3,p)+noise*randn(2,1);
      end;
   end;

   % reconstruction phase -- standardize+homogenize image coords,
   % then call reconstructor
   for i = 1:m
      for p = 1:n
	 xip = [2/w*pxs(2*i-1,p)-1; 2/h*pxs(2*i,p)-1; 1];
	 xs(3*i-2:3*i,p) = xip/norm(xip);
      end;
   end;

   if (incremental<=1)		% standard batch factorization

      [Ps1,Xs1,cond] = proj_recons_fsvd(xs,serial,fixed_rank);
   
   else		% incremental method starting from batch solution at image # incremental

      [Ps1,Xs1,cond,xs1] = proj_recons_fsvd(xs(1:3*incremental,:),serial,fixed_rank);
      xtx = xs1'*xs1; 
      for i = incremental+1:m

	 % info only -- calculate and print reconstruction error
	 err3D = zeros(1,n);
      	 [H,cond1] = proj_from_pts_lin(Xs,Xs1);
	 HXs = H*Xs1;
	 for p = 1:n
	    err3D(p) = norm(Xs(1:3,p)-HXs(1:3,p)/HXs(4,p));
	 end;
	 norm_err3d=norm(err3D,1)
       
	 [Xs1,xs1,xtx] = incr_proj_recons(xs(3*i-2:3*i,:),Xs1,xs1,xtx,serial);
      end;
      Ps1 = xs1*Xs1';
      normPX=norm(Ps1*Xs1-xs1)
   end;

   Ps1	% the solution
   Xs1
   
   % estimate projective error by aligning reconstructed points
   % to true ones
   
   [H,cond1] = proj_from_pts_lin(Xs,Xs1);
   err3D = zeros(1,n);
   HXs = H*Xs1;
   for p = 1:n
      err3D(p) = norm(Xs(1:3,p)-HXs(1:3,p)/HXs(4,p));
   end;
%   [cond;cond1]
   recons_errs=err3D
   mean_recons_err=norm(err3D,1)/n
%end;

