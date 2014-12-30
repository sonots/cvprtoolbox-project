function [pars,info,Ab,stdev] = bundle_adjust(obs,pars,method)

   mindb = 1e-6;	% min relative residual change |db/b| for convergence
   mindx = 1e-6;	% min |dx| for convergence test
   maxdx = 1e0;		% max |dx| for step limitation
   maxiter = 20;	% max number of major iterations (x updates)
   maxtrial = 25;	% max no. of lambda's to try for any x update 
   minbsq = 1e-10;	% residual so small that we return immediately      
   maxcond = 1e7;	% max condition no. of dy/dx to allow
   verbose = 0;		% verbosity 
   linesearch = 1;	% do a line search
   lambda = 1e-7;
   if method(1)>=200, linesearch=0; method(1)=method(1)-200; end;
   flops0 = flops;

   [obs,pars,b,A] = bundle_jacobian(obs,pars);
   bsq = b'*b;

   for iter = 1:maxiter			% main loop over x updates
      Amax = norm(A,1);
      % Find a lambda giving a safe, cost decreasing step.
      trial = 1;
      while (1)
	 dx = bundle_pred_step(A,b,lambda,method);
	 ndx = norm(dx,inf);
	 if (ndx>maxdx)
	    % Limit oversize step
	    if (verbose>0)
	       fprintf(1,'     %d: lambda[%d]=%g limiting |dx|=%g err=%g\n',...
		   iter,trial,lambda,ndx,sqrt(bsq));
	    end;
	    % initial lambda. If lmax,lmin are max & min sing.vals of
	    % A: |A(l)| ~= lmax+l, |inv(A(l))| ~= 1/(lmin+l), and
	    % |dx(l)| ~= |inv(A(l))||b| ~= |b|/(lmin+l) 
	    % Use this twice.  lmin ~= |b|/|x(l)| - l gives lmin from
	    % trial step. Hence for |x|~= maxstep we need
	    % l' ~= |b|(1/maxstep-1/|x(l)|) + l

	    lambda = max(3*lambda,norm(b)*(1/maxdx-1/ndx)+lambda);
	    % lambda = max(3*lambda,Amax*min(0.5*sqrt(ndx/maxdx-1),1));
	 else
	    % Step size ok, accept it if it decreased error, otherwise
	    % boost lambda and retry.
	    if ~linesearch
	       best_step = 1;
	       best_pars = bundle_update(pars,dx);
	       [obs,best_pars,best_b,best_A] = bundle_jacobian(obs,best_pars);
	       best_bsq = best_b'*best_b;
	       if (best_bsq<max(minbsq,bsq + max(bsq,1)*1e-16) ...
		   | ndx<mindx) break; end; 	% accept step
	    else
	       step1 = 1;
	       maxstep = 1e10;
	       minstep = 1e-10;
	       best_bsq = 1e100;
	       for trial2 = 1:10
		  pars1 = bundle_update(pars,step1*dx);
		  [obs,pars1,b1,A1] = bundle_jacobian(obs,pars1);
		  b1sq = b1'*b1;
		  if b1sq<best_bsq
		     best_bsq = b1sq;
		     best_step = step1;
		     best_b = b1;
		     best_A = A1;
		     best_pars = pars1;
		  end;
		  db = (b1-b)/step1;
		  bdb = b'*db;
		  if bdb>=0, break; end; % non-decrease direction, failed 

		  % Predicted step to minimum - linear model 
		  % in residual b(step)=b0+db*step => quadratic in error
		  dbsq = db'*db;
		  step2 = -bdb/dbsq;
		  d_b2sq = step2*bdb;

		  % Accept best step if we already got most of
		  % expected decrease, or we're oscillating between
		  % large & small steps.
		  if best_bsq-bsq <0.95*d_b2sq ...
			 | step2<=minstep | step2>=maxstep
		     break; 
		  end;
		  % retry with new step
		  step1 = step2;
		  if step1>best_step, minstep = best_step; end;
		  if step1<best_step, maxstep = best_step; end;
		  if verbose>0
		     fprintf(1,'     %d: lambda[%d]=%g step[%d]=%g err=%g\n',...
			 iter,trial,lambda,trial2,step1,sqrt(b1sq));
		  end;
	       end;
	       % accept step if we did OK, if not increase lambda
	       if (best_bsq<max(minbsq,bsq + max(bsq,1)*1e-16) ...
			 | ndx<mindx) 
		  break; 
	       end;
	    end;
	    % Increase lambda and retry
	    if (verbose>0)
	       fprintf(1,'     %d: lambda[%d]=%g |dx|=%g err=%g\n',...
		   iter,trial,lambda,ndx,sqrt(best_bsq));
	    end;
	    lambda = max(3*lambda,Amax/maxcond);
	 end;
	 trial = trial+1;
	 if (trial>maxtrial) 
	    error(sprintf(['Could not find a step that reduced cost, even for lambda=%g:',...
	       'giving up after %d trials (iteration %d, err=%g, |b|=%g, |A|=%g)\n'],...
	       lambda,trial-1,iter,sqrt(bsq),norm(b,inf),Amax));
	 end;
      end;

      % Accept step and check for convergence.
      if 1
	 global dxs bs;
	 % if iter>1, dxs = [dxs,dx]; else dxs = dx; end;
	 if iter>1, bs = [bs,b]; else bs = b; end;
      end;
      % b0 = b - best_step*(A*dx);
      % depred = bsq - b0'*b0;
      % detrue = bsq - best_bsq;
      pars = best_pars;
      % A = best_A;
      if mod(iter,1) == 0, A = best_A; end;
      b = best_b;
      bsq = best_bsq;
      if (verbose>0)
	 fprintf(1,'step %d: lambda[%d]=%g |dx|=%g err=%g flops=%g\n',...
	     iter,trial,lambda,ndx,sqrt(bsq),flops-flops0);
      end;
      if (ndx<mindx | bsq<minbsq) break; end; % converged

      % Increase or decrease lambda according to whether predicted
      % error decrease was realized, i.e. 2nd order Gauss-Newton error
      % model seems locally accurate.

      % mu = (depred-detrue)/max(depred,1e-14*(1+bsq));
      % lambda = min(max(0.4,3*mu),2)*lambda;
      lambda = min(max(0.4,0.8/best_step),2)*lambda;
      lambda = max(lambda,1e-8);
   end;
   if 0
      global SS;
      SS = eig(full(A'*A));
   end;
   if nargout>=2
      info = [iter,bsq,Amax,lambda]; 
      if nargout>=3
	 Ab = [A,b];
	 if nargout>=4
	    % Find lower triangular right hand standard deviation matrix
	    % covariance = stdev'*stdev
	    U = chol(A'*A + 1e-10*speye(size(A,2)));
	    stddev = inv(U');
	 end;
      end;
   end;
% end;
