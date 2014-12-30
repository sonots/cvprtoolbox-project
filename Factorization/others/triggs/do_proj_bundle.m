% Run projective bundle on projective factorization output

function [Ps,Xs] = do_proj_bundle(xs,Ps,Xs);
   global obs_sizes empty_obs aff_im_pt;
   global par_sizes empty_par aff_3D_pt proj_3D_pt proj_cam_mat;
   if isempty(obs_sizes), bundle_globals; end;
   pperm = 3+[1:3:10,2:3:11,3:3:12];

   n = size(Xs,2);
   m = size(Ps,1)/3;

   obs = zeros(10,m*n);
   pars = zeros(15,n+m);
   par = 1;
   ob = 1;
   pars(1:3,1:n) = [proj_3D_pt; 1; 0] * ones(1,n);
   pars(4:7,1:n) = Xs;
   pars(1:3,n+1:n+m) = [proj_cam_mat; 1; 0] * ones(1,m);
   pars(pperm,n+1:n+m) = reshape(Ps',12,m);
   
   if size(xs,1) == 3*m
      xx = reshape(xs,3,m*n);
      xx = xx(1:2,:) ./ (ones(2,1)*xx(3,:));
   else
      xx = reshape(xs,2,m*n);      
   end;
   obs(1:3,:) = [aff_im_pt; 1;0] * ones(1,m*n);
   obs(4:5,:) = [kron(1:n,ones(1,m)); n+kron(ones(1,n),1:m)];
   obs(6:7,:) = xx;
   obs(8:10,:) = [1;0;1] * ones(1,m*n);
   meth = 1;
   [pars1,info] = bundle_adjust(obs,pars,[meth,m,n]);

   Xs = pars1(4:7,1:n);
   Ps = reshape(pars1(pperm,n+1:n+m),4,3*m)';

%end;

