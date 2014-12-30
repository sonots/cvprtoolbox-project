function bundle_globals
   global obs_sizes empty_obs aff_im_pt;
   global par_sizes empty_par aff_3D_pt proj_3D_pt proj_cam_mat;
   
   % Observation types
   empty_obs = 1;
   aff_im_pt = 2;

   obs_sizes([empty_obs,aff_im_pt]) = [0,2];
   
   % Parameter block types
   empty_par = 1;
   aff_3D_pt = 2;
   proj_3D_pt = 3;
   proj_cam_mat = 10;

   par_sizes([empty_par,aff_3D_pt,proj_3D_pt,proj_cam_mat]) = [0,3,3,11];
%end;
