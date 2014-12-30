% [Ps,Xs,cond] = proj_recons_fsvd(xs,serial,fixed_rank)
%
% Projective reconstruction of m images of n points by SVD, with
% fundamental matrix based depth estimation. 
%
% Inputs: xs(3*m,n) = matrix of homogeneous image points, standardized
% so that all coordinates are of O(1).
% Flag serial==1 for serial chain, 0 for parallel chain depth recovery.
% Flag fixed_rank==1: use an iterative method based on the rank-4-ness
% of the exact solution, rather than conventional SVD. This is O(m*n)
% rather than O(m*n*min(m,n)), i.e. much faster if both #images and
% #points are large, but not as stable and perhaps slightly less
% accurate than true SVD. For fixed_rank>1, try to guess the best method.
%
% Outputs: Ps(3*m,4) = matrix of m reconstructed 3x4 image projection
% matrices. Xs(4,n) = n reconstructed homogeneous image points. 
% Condition numbers cond = [range of first 4 singular values, step down
% to 5th singular value]. (Ideally, cond ~ [near 1, near 0]).
%
% The projective output frame is numerically well-conditioned, but
% otherwise *completely* arbitrary. It has *no* relation to any
% Euclidean frame.
%
% Method: see [Triggs & Sturm, ECCV'96] or [Triggs, CVPR'96]

function [Ps,Xs,cond,xs] = proj_recons_fsvd(xs,serial,fixed_rank)
   m = size(xs,1)/3;
   n = size(xs,2);
   if (fixed_rank>1)		% try to guess best method: SVD if |data matrix|<30x30
      if (m<=10 | n<=30) fixed_rank=0; end;
   end;
   
   % work out projective depths by F-matrix based propagation
   % (serial==1) ==> use serial image 1->2->3...->m chain, otherwise
   % use parallel 1->2, 1->3,... 1->m chain

   lambda = ones(m,n);
   iref = 1;
   for i = 2:m
      xref = xs(3*iref-2:3*iref,:);
      xi = xs(3*i-2:3*i,:);
      [Fri,eri,eir,cond] = Fmat_from_pts_lin(xref,xi);
      for p = 1:n
	 xrp = xref(:,p);
	 xip = xi(:,p);
	 xe = cross(xip,eri);
	 lambda(i,p) = lambda(iref,p)*abs((xrp'*Fri*xe)/(xe'*xe));
      end;
      if (serial) iref = i; end;	% else iref = 1
   end;

   % balance depth matrix by column/row rescaling. Heuristically
   % two rounds is usually good enough...

   for it = 1:2
      for p = 1:n
	 lp = lambda(:,p);
	 lambda(:,p) = lp/norm(lp);
      end;
      for i = 1:m
	 li = lambda(i,:);
	 lambda(i,:) = li/norm(li);
      end;
   end;

   % rescale the image points
   % rescaled measurement matrix
   for i = 1:m
      for p = 1:n
	 xs(3*i-2:3*i,p) = lambda(i,p)*xs(3*i-2:3*i,p);
      end;
   end;

   % SVD the rescaled points, and pull out the projections & 3D points.
   % We flip the order of the sv's to put the strongest in the 4th 
   % (homogeneous normalization) position, as this tends to give a more
   % Euclidean frame (at least for compact point-sets)

   if (~fixed_rank)
      [U,S,V] = svd(xs);
      S = S/S(1,1);
      cond = [S(4,4),S(5,5)];
   else
      [U,S,V] = limited_rank_svd(xs,4);
      S = S/S(1,1);
      cond = [S(4,4),-1];
   end;
   Ps = fliplr(U(:,1:4));
   Xs = flipud(S(1:4,1:4)*V(:,1:4)');
%end;
