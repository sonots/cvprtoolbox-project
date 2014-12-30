function [pars] = bundle_update(pars,dx)
   % global tags
   global obs_sizes empty_obs aff_im_pt;
   global par_sizes empty_par aff_3D_pt proj_3D_pt proj_cam_mat;
   if ~isglobal(obs_sizes), bundle_globals; end;

   for p = 1:size(pars,2)	% parameter blocks
      par = pars(:,p);
      if par(2)			% update active block
	 switch par(1)		% block type
	    case aff_3D_pt,
	       par(4:6) = par(4:6) + dx(par(3):par(3)+2);
	    case proj_3D_pt,
	       [Q1,R1] = qr(par(4:7));
	       par(4:7) = par(4:7) + Q1(:,2:4)*dx(par(3):par(3)+2);
	    case proj_cam_mat,
	       par(4:14) = par(4:14) + dx(par(3):par(3)+10);
	       % par(5:15) = par(5:15) + dx(par(3):par(3)+10);
	    otherwise,
	       error('unknown parameter block type ',par(1));	    
	 end; % /par block types
	 pars(:,p) = par;
      end;
   end; % /pars(:,p)

%end;