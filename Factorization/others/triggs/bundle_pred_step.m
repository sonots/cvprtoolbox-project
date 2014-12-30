% Assorted step prediction methods for bundle adjustment.

function dx = bundle_pred_step(A,b,lambda,method)
   meth = method(1);
   m = method(2);
   n = method(3);
   npars = size(A,2);
   dx = zeros(npars,1);
   if meth<200
      % Methods based on normal equations start by building normal
      % matrix. Boost too-small lambdas as we don't want Cholesky to
      % fail.

      lambda = max(lambda,2e-8*norm(A,1));
      % flipud(sort(eig(A'*A)))'
      H = A'*A + lambda^2*speye(npars);
      g = A'*b;
      if meth<100	 % Various Cholesky based methods.
	 switch mod(meth,10)	% Variable ordering scheme
	    case 2,
	       p = symmmd(H);
	    case 3,
	       p = symrcm(H);
	    otherwise,
	       p = 1:npars;
	 end;
	 switch floor(meth/10)	% Solution method
	    case 0,
	       % Standard complete Cholesky
	       if 0
		  global do_save; if isempty(do_save), do_save=0; end;
		  f = ['figs/mat',num2str(do_save)];
		  spy(H); title('Hessian'); pause;
		  if do_save, print('-f',gcf,'-depsc2',[f,'nat-hess.ps']); end;
		  U = chol(H);
		  spy(U); title('Natural Order Cholesky'); pause;
		  if do_save, print('-f',gcf,'-depsc2',[f,'nat-chol.ps']); end;

		  p = symmmd(H);
		  spy(H(p,p)); title('Minimum Degree Hessian'); pause;
		  if do_save, print('-f',gcf,'-depsc2',[f,'mdeg-hess.ps']); end;
		  U = chol(H(p,p));
		  spy(U); title('Minimum Degree Cholesky'); pause;
		  if do_save, print('-f',gcf,'-depsc2',[f,'mdeg-chol.ps']); end;

		  p = symrcm(H);
		  spy(H(p,p)); title('Reverse Cuthill-McKee Hessian'); pause;
		  if do_save, print('-f',gcf,'-depsc2',[f,'rcm-hess.ps']); end;
		  U = chol(H(p,p));
		  spy(U); title('Reverse Cuthill-McKee Cholesky'); pause;
		  if do_save, print('-f',gcf,'-depsc2',[f,'rcm-chol.ps']); end;
		  do_save = 0;
		  p = 1:npars;
	       end;
	       U = chol(H(p,p));
	       dx(p) = -(U \ (U' \ g(p)));
	    case 1,
	       % Zero-fill incomplete Cholesky - fails here
	       class(H)
	       U = cholinc(H(p,p),'0');
	       dx(p) = -(U \ (U' \ g(p)));
	    case 2,
	       % Drop-tolerance incomplete Cholesky
	       U = cholinc(H(p,p),1e-7*norm(H,1));
	       dx(p) = -(U \ (U' \ g(p)));
	    case 3,
	       % Conjugate gradient with zero-fill incomplete Cholesky
	       % preconditioner
	       if meth==30, 
		  U = []; % no preconditioner
	       else 
		  U = cholinc(H(p,p),'0');
	       end;
	       dx(p) = -pcg(H,g,1e-6,max(npars,20),U',U);
	    case 4,
	       % Conjugate gradient with drop-tolerance incomplete Cholesky
	       % preconditioner
	       if meth==40, 
		  U = [];	% no preconditioner
	       else 
		  U = cholinc(H(p,p),1e-4*norm(H,1));
	       end;
	       dx(p) = -pcg(H,g,1e-6,max(2*npars,20),U',U);
	    case 5,
	       % Conjugate gradient with block diagonal incomplete Cholesky
	       % preconditioner
	       if meth==50, 
		  U = [];	% no preconditioner
	       else
		  H1 = H+1e-60*speye(npars);
		  [i,j,v] = find(H1);
		  ind = find((i<=3*n & j<=3*n) | (i>3*n & j>3*n));
		  H1 = sparse(i(ind),j(ind),v(ind),npars,npars);
		  U = chol(H1);
	       end;
	       dx = -pcg(H,g,1e-6,max(2*npars,20),U',U);
	    case 6,
	       % Standard complete Cholesky, non-sparse matrix method
	       U = chol(full(H(p,p)));
	       dx(p) = -(U \ (U' \ g(p)));
	    otherwise,
	       error('Unknown solution method');
	 end
	 return;
      end;
   end;
   switch meth
%      case 1,
%	 % sparse Cholesky, input ordering
%	 U = chol(H);
%	 dx = -(U \ (U' \ g));
%      case 2,
%	 % sparse Cholesky, minimum degree ordering
%	 p = symmmd(H);
%	 U = chol(H(p,p));
%	 dx = zeros(npars,1);
%	 dx(p) = -(U \ (U' \ g(p)));
%      case 3,
%	 % sparse Cholesky, reverse Cuthill-McKee ordering
%	 p = symrcm(H);
%	 U = chol(H(p,p));
%	 dx = zeros(npars,1);
%	 dx(p) = -(U \ (U' \ g(p)));

      case 100,
	 % Ignore off-diagonal blocks to simulate alternation. 
	 if 1
	    H1 = H+1e-6*speye(npars);
	    % Doing it like this is 100x slower...
	    %   H1(1:3*n,3*n+1:npars) = 0;
	    %   H1(3*n+1:npars,1:3*n) = 0;
	    % ... and this gives singular matrices
	    %   bandwidth = 11; 
	    %   H1 = tril(triu(H,-bandwidth),bandwidth);
	    %   [min(diag(H)),min(diag(H1))]

	    [i,j,v] = find(H1);
	    ind = find((i<=3*n & j<=3*n) | (i>3*n & j>3*n));
	    H1 = sparse(i(ind),j(ind),v(ind),npars,npars);
	    % flipud(sort(eig(H1)))'
	 else 
	 end;
	 % spy(H1); pause;
	 U = chol(H1);
	 % spy(U); pause;
	 dx = -(U \ (U' \ g));
      case 101,
	 % Fake alternating resection and intersection
	 global RESECT; if isempty(RESECT), RESECT=0; end;
	 H1 = H+1e-6*speye(npars);
	 [i,j,v] = find(H1);
	 if RESECT
	    ind = find(i>3*n & j>3*n);
	    H1 = sparse(i(ind)-3*n,j(ind)-3*n,v(ind),npars-3*n,npars-3*n);
	    slice = 3*n+1:npars;
	    RESECT = 0;
	 else 
	    ind = find(i<=3*n & j<=3*n);
	    H1 = sparse(i(ind),j(ind),v(ind),3*n,3*n);
	    slice = 1:3*n;
	    RESECT = 1;
	 end;
	 % spy(H1); pause;
	 U = chol(H1);
	 dx(slice) = -(U \ (U' \ g(slice)));
      otherwise,
	 error(['unknown step prediction method # ',num2str(method)]);
      end;
   fprintf(1,'done pred_step\n');   
%end;