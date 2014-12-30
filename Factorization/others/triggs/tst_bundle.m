function [A,b] = tst_bundle(method)

   if 0
      obs = [2,1,0, 1,2, 2.0,3.0, 1.0,0.0,1.0]';
      X = [2,1,0, 1,0,2,1]';
      P = [10,1,0, 1,0,0, 0,1,0, 0,0,1, 0,0,0]';
      pars = 999*ones(size(P,1),2);
      pars(1:size(X,1),1) = X;
      pars(1:size(P,1),2) = P;
   else
      m = 10;
      n = 20;
      imnoise = 1e-4;
      camdist = 4;
      viewangle = 360;
      parnoise = 1e-1;
      viewcos = 0.3;
      viewcos = -1.0;      
      [m,n,obs,pars,truepars] = bundle_scene(m,n,imnoise,camdist,...
	  viewangle,viewcos,parnoise);
      [m,n]
      if 0
	 [obs1,pars1,b,A] = bundle_jacobian(obs,pars);
	 % full(A)
	 % dx = A \ b;
	 return;
      end;
      f0 = flops;
      [pars1,info,Ab] = bundle_adjust(obs,pars,[method,m,n]);
      fprintf(1,'%.2g flops\n',flops-f0);
   end;
%end;
