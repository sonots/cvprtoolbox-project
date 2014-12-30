% evaluate image error of a projective reconstruction 
function err = proj_err_2D(xs,Ps,Xs)
   [m,n] = size(xs);
   m = m/3;
   xxs = reshape(xs,3,m*n);
   pxs = reshape(Ps*Xs,3,m*n);
   err = xxs./(ones(3,1)*sqrt(sum(xxs.^2))) ...
       - pxs./(ones(3,1)*sqrt(sum(pxs.^2)));
   err = reshape(sqrt(sum(err.^2)),m,n);
%end;