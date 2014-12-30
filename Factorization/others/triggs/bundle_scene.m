% Generate random scene for bundle methods
% Inputs:
%   Generates m images of n points with noise pixels noise.

function [m,n,obs,pars,truepars] = bundle_scene(m,n,imnoise,...
       camdist,viewangle,visiblecos,parnoise);
   global obs_sizes empty_obs aff_im_pt;
   global par_sizes empty_par aff_3D_pt proj_cam_mat;
   if isempty(obs_sizes), bundle_globals; end;

   % parameters
   w = 1; h = 1;	% image width, height (use normalized image coords)
   scenediam = 2;	% test scene diameter
   f = max([w,h])*max(1,camdist/scenediam); % focal length in pixels for
                                         % a 0.5-full image of scene
   viewangle = pi/180*viewangle;					 
   a = viewangle/m;
   cam_R = [cos(a),0,sin(a); 0,1,0; -sin(a),0,cos(a)];
   cam_t = [0; 0; -camdist];
   % K = [f,0,w/2; 0,f,h/2; 0,0,1];
   K = [f,0,0; 0,f,0; 0,0,1];
   
   % Loop until we get at least some reconstructable set of visible
   % points and cameras.

   for trial = 1:10
      % generate scene, projections, images
      Xs = zeros(4,n);
      obs = zeros(10,m*n);
      pars = zeros(15,n+m);
      truepars = zeros(15,n+m);
      par = 1;
      ob = 1;
      for p = 1:n
	 X = randn(3,1);
	 X = X/norm(X);
	 % X = X/norm(X)*rand(1)^0.3333;   % uniform unit sphere of points
	 % X = X;			  % spherical gaussian point distrib.
	 Xs(:,p) = [X;1];
	 truepars(1:6,par) = [aff_3D_pt; 1; 0; X];
	 pars(1:6,par) = [aff_3D_pt; 1; 0; X+parnoise*norm(X)*randn(3,1)];
	 par = par+1;
      end;
      for i = 1:m
	 [Q,R] = qr(randn(3,5)); R = Q/det(Q);
	 %R = cam_R^i;
	 oc = R'*cam_t;
	 P = K*[R,cam_t];
	 Pv = reshape(P,12,1);
	 truepars(1:15,par) = [proj_cam_mat; 1; 0; Pv];
	 pars(1:15,par) = [proj_cam_mat; 1; 0; Pv+parnoise*norm(Pv)*randn(12,1)];
	 par = par+1;
	 xs = [R,cam_t]*Xs;
	 ns = -R*Xs(1:3,:);
	 xns = sum(xs.*ns)./sqrt(sum(xs.^2).*sum(ns.^2));
	 for p = 1:n
	    if (xns(p)>visiblecos)		% facing camera & not too slanted
	       x = K*xs(:,p);
	       x = x(1:2)/x(3) + imnoise*randn(2,1);
	       if max(abs(x))<1
		  obs(1:10,ob) = [aff_im_pt; 1;0; p;n+i; x; 1;0;1];
		  ob = ob+1;
	       end;
	    end;
	 end;
      end;
      obs = obs(:,1:ob-1);
      % if visiblecos<=-1, break; end;

      % Detect and squeeze out any points and cameras that are
      % unreconstructable owing to visibility testing (points with <2
      % images, cameras with <6 points). As removing cameras can make
      % additional points unreconstructable and vice versa, loop over
      % observations squeezing until we stabilize. Then rewire point and
      % camera numbers in parameter block for compactness.
      while 1
	 Xseen = zeros(1,n);
	 Pseen = zeros(1,m);
	 for p = obs(4,:), Xseen(p) = Xseen(p)+1; end;
	 for i = obs(5,:)-n, Pseen(i) = Pseen(i)+1; end;
	 Xok = (Xseen>=2);
	 Pok = (Pseen>=6);
	 ind = find(Xok(obs(4,:)) & Pok(obs(5,:)-n));
	 if size(ind,2) == size(obs,2), break; end;
	 obs = obs(:,ind);
      end;
      nseen = sum(Xok');
      mseen = sum(Pok');
      if mseen>=2 & nseen>=6
	 Xok = find(Xok);
	 Pok = find(Pok);
	 totipts = sum(Xseen(Xok));
	 [totipts/mseen,totipts/nseen]
	 Xind = zeros(1,n);
	 Pind = zeros(1,m);
	 Xind(Xok) = [1:nseen];
	 Pind(Pok) = [1:mseen];
	 obs(4,:) = Xind(obs(4,:));
	 obs(5,:) = Pind(obs(5,:)-n) + nseen;
	 pars = pars(:,[Xok,Pok+n]);
	 m = mseen;
	 n = nseen;
	 break;
      end;
      % Failed to find a reconstructable set of visible points,
      % increase n and try again.
      n = floor(1.5*n);
   end;
%end;

