% function [pars,obs,b,A] = bundle_jacobian(obs,pars)
% ----------------------------------------------------------------------
% Calculate the residual error vector b and the design matrix
% (Gauss-Newton Jacobian) A for a bundle adjustment with observations
% obs and parameters pars. A is returned as a sparse Matlab matrix.
% Solving the least squares problem minimize |A*dx - b|^2 gives the
% Gauss-Newton step for the parameter refinement dx.

% PARS: Each column of the matrix PARS contains a block of parameters
% representing a single problem entity in some specific parametrization,
% e.g.: a 3D point represented by 4 homogeneous coordinates; an exterior
% viewing pose represented by a quaternion and a translation; a block of
% 5 basic internal camera parameters.  
%
% - The first row of PARS contains integer tags giving the block (entity
% and parametrization) type, and hence the code to run.
%
% - The second row of PARS will contain the column index in A / row
% index in dx at which the linearized parameters associated with the
% block start. Each block type knows how many parameters it needs --
% this is *not* necessarily the same as the number of parameters it
% stores internally, e.g. homogeneous 3D points and quaternions each
% have 4 components, but one is an arbitrary scale so each only
% contributes 3 to the step prediction.
%
% - The third and subsequent rows of PARS are type dependent, but will
% generally contain some subset of: (i) indices to other blocks of PARS
% (e.g. a view block might reference an intrinsic parameter block shared
% between several views); (ii) the actual parameters of the block in
% some internal representation; (iii) cached partial results to speed
% matrix evaluation (e.g. the matrix form of a quaternion).

% OBS: Similarly to PARS, the columns of OBS define blocks of
% observations of various different types (2D image points, prior camera
% calibrations, etc). The first row of OBS gives the observation type
% and parametrization. The second gives the row index of the
% observation's equations in A and b. Subsequent rows are type dependent
% and give references to the contributing parameter blocks (3D point,
% camera...), actual observations values and covariances, etc. 
%
% By the time they get into A, all observation equations should be
% evenly weighted (e.g. by pre-multiplying the equations by the Cholesky
% factor of their inverse covariance). Constraints can be represented by
% very heavily weighted observations, although by no means all numerical
% schemes for solving A*dx=b handle this gracefully.
% ----------------------------------------------------------------------
function [obs,pars,b,A] = bundle_jacobian(obs,pars)
   global obs_sizes empty_obs aff_im_pt;
   global par_sizes empty_par aff_3D_pt proj_3D_pt proj_cam_mat;
   if isempty(obs_sizes), bundle_globals; end;

   nobs = size(obs,2);
   npars = size(pars,2);

   % Stage 1: work out size(A) and assign positions for parameter and observation
   % blocks. We just assign space in the given order of obs and pars.

   obs_sizes(obs(1,:)) .* obs(2,:);
   s = cumsum(obs_sizes(obs(1,:)) .* obs(2,:));
   nrows = s(nobs);
   obs(3,:) = ([0,s(1:nobs-1)]+1) .* obs(2,:);

   s = cumsum(par_sizes(pars(1,:)) .* pars(2,:));
   ncols = s(npars);
   pars(3,:) = ([0,s(1:npars-1)]+1) .* pars(2,:);

   % Build A' by columns not A by rows for speed
   % if nargout>=4, A = sparse(nrows,ncols); end; 
   if nargout>=4, A = sparse(ncols,nrows); end;
   b = zeros(nrows,1);

   % Stage 2: build observation equations and copy them into A.
   for o=1:nobs
      ob = obs(:,o);
      if ob(2)		% observation is active, e.g. not outlier
	 % Find residual vector r and Jacobian J of the block of observations. J is in
	 % blocks indexed by Jind, one for each contributing parameter block. Blocks
	 % are accumulated and transformed essentially by using the chain rule.

	 Jind = zeros(2,0);	% [[parameter block #; offset in J],...]
	 switch ob(1)		% observation type
	    case aff_im_pt,	% image point, affine parametrization
	       pointid = ob(4);	% parent 3D point #
	       viewid = ob(5);		% view #
	       point = pars(:,pointid);
	       view = pars(:,viewid);
	       xobs = ob(6:7);		% observed image coordinates
	       xnorm = [ob(8:9),[0;ob(10)]]; % inv sqrt obs covariance
	       J = zeros(4,0);
	       switch point(1)		% 3D point type
		  case aff_3D_pt,	% 3D point, affine parametrization
		     X = [point(4:6);1]; % homog 3D point coordinates
		     if point(2)	% accumulate Jacobian if point is active
			Jind = [pointid; size(J,2)+1];
			J = eye(4,3);
		     end;
		  case proj_3D_pt,	% 3D point, projective parametrization
		     X = point(4:7);	% homog 3D point coordinates
		     if point(2)	% accumulate Jacobian if point is active
			Jind = [pointid; size(J,2)+1];
			[Q1,R1] = qr(X);
			J = Q1(:,2:4);
		     end;
		  otherwise,
		     error(['unknown 3D point type ',num2str(point(1))]);
	       end;
	       switch view(1)		% view type
		  case proj_cam_mat,	% projective camera, no other calibration
		     P = reshape(view(4:15),3,4);	% 3x4 projection matrix
		     u = P*X;		% project point & its Jacobian
		     J = P*J;
		     if view(2)		% add Jacobian for projection if active
			Jind = [Jind, [viewid; size(J,2)+1]];
			dP = kron(X',eye(3));
			J = [J, dP(:,1:11)];
			% J = [J, dP(:,2:12)];
		     end;
		  otherwise,
		     error(['unknown view type ',num2str(view(1))]);
	       end;

	       x = u(1:2)/u(3);		% rescaled image pt & its Jacobian
	       J = [eye(2)/u(3), -u(1:2)/u(3)^2] * J;

	       % Calibration + distortion goes here ...

	       r = xnorm * (x - xobs);	       
	       J = xnorm * J;
	    otherwise,
	       fprintf(stderr,'Skipping unknown observation type %d\n',otype);
	 end;	% /switch observation type

	 % Fold observation into A. r is final residual vector of the observation block, J
	 % is Jacobian in blocks, one for each parameter.
	 
	 row0 = ob(3);
	 row1 = row0 + size(r,1)-1;
	 b(row0:row1) = r;
	 if nargout>1
	    Jind = [Jind, [0; size(J,2)+1]];
	    for p = 1:size(Jind,2)-1
	       i0 = Jind(2,p);
	       i1 = Jind(2,p+1)-1;
	       o0 = pars(3,Jind(1,p));
	       % A(row0:row1,o0:o0+i1-i0) = J(:,i0:i1);
	       A(o0:o0+i1-i0,row0:row1) = J(:,i0:i1)';
	    end;
	 end;

      end; % /active observations
   end; % /observations
   A = A';
   % b'
   % fprintf(1,'done jacobian\n');
%end;
