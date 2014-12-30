% [X,xs,xtx] = incr_proj_recons(xm,X,xs,xtx,serial)
%
% Add one more image to an incremental projective reconstruction of a
% fixed set of n points tracked through a sequence of m images. As each
% new image is added the projective 3D structure is updated in O(n^2)
% (i.e. independent of m) to reflect the new image data. The projective
% 3D frame is *not* constant, but changes as each new image is
% merged. At each step, the corresponding projection matrices can be
% found in O(n) per projection or O(m*n) total, but are not otherwise
% required by the iteration.
%
% Input: 
%	xm(3,n) - n normalized homogeneous image points of image m
%	X(4,n) - 3D projective structure from images 1 to m-1
%	xs(3*(m-1),n), xtx=xs'*xs - accumulated rescaled image data matrices
%		Only xtx is needed below, but xs can be used to find the 
%		projections by P = xs(proj_rows,:)*X' where 
%		proj_rows=3*i-2:3*i for	image i projection, 1:3*m for 
%		all of them, etc.
%	serial - use serial (1->2->...->m) rather than parallel (1->2,...,1->m)
%		image chain for depth recovery
% Output: 
%	X,xs,xtx,shift updated to include image m. The 3D frame for X
%	changes at each iteration.
%
% Method:
% Factorization-based projective reconstruction as in
% proj_recons_fsvd(), using a limited-rank SVD based on QR power
% iteration as in limited_rank_svd(). The only difference is that we
% accumulate the O(m) quantities incrementally to reduce the cost to
% O(n^2) per image instead of O(m*n) in total. I.e. the trade off is
% *only* worthwhile if m>>n *and* incremental structure is required,
% e.g. for tracking.

function [X,xs,xtx] = incr_proj_recons(xm,X,xs,xtx,serial)
   m = size(xs,1)/3+1;
   n = size(xs,2);

   % find image m projective depths by F-matrix based propagation
   % (serial) ==> use serial image 1->2->3...->m chain, otherwise
   % use stabler parallel one 1->2, 1->3,... 1->m

   lambda = ones(1,n);
   if (serial) iref = m-1; else iref = 1; end;
   xref = xs(3*iref-2:3*iref,:);
   [Frm,erm,emr,cond] = Fmat_from_pts_lin(xref,xm);
   for p = 1:n
      xe = cross(xm(:,p),erm);
      lambda(p) = abs((xref(:,p)'*Frm*xe)/(xe'*xe));
   end;

   % Balance depth vector so no one image predominates, and build
   % updated xs and xtx matrices. Ideally we would also balance
   % columnwise to ensure that no one point predominates, but this would
   % require an O(m*n) update of xs and recalculation of xtx, so we avoid
   % it.
   lambda = (sqrt(n)/norm(lambda))*lambda;
   for p = 1:n
      xm(:,p) = lambda(p)*xm(:,p);
   end;
   xs = [xs; xm];
   xtx = xtx + xm'*xm;

   % QR power iteration to find updated 3D structure X -- see
   % description in limited_rank_svd(). We don't use a shift here, as it
   % is too difficult to guess reliably from R
   for it = 1:20
      Xprev = X;
      A = X*xtx;
      [X,R] = qr(A',0);
      X = X';
      na = norm(A-(A*Xprev')*Xprev,1);
      fprintf(1,'it=%d.%d: na=%g\n',m,it,na);
      if (na<1e-6) break; end;
   end;
   % projection update: Ps(...proj_rows...,:) = xs(...proj_rows...,:)*X';
%end;
