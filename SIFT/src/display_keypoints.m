function hh = display_keypoints( pos, scale, orient, varargin )

% h = display_keypoints( pos, orient, scale, magnify )
%
% Display an image with keyponts overlayed showing orientation
% and scale.
%
% Input:
% pos - keypoint position matrix from SIFT function.
% scale - keypoint scale matrix from SIFT function.
% orient - keypoint orientation vector from SIFT function.
% magnify - factor to scale the length of the vectors by. 
%
% Output:
% h - returns a vector of the line handles.
%
% Thomas F. El-Maraghi
% May 2004

hold on;

% Arrow head parameters
alpha = 0.33; % Size of arrow head relative to the length of the vector
beta = 0.33;  % Width of the base of the arrow head relative to the length
autoscale = 1.5; % Autoscale if ~= 0 then scale by this.
plotarrows = 1; % Plot arrows
sym = '';

filled = 0;
ls = '-';
ms = '';
col = '';

varin = nargin - 3;

% Parse the string inputs
while (varin > 0) & isstr(varargin{varin}),
   vv = varargin{varin};
   if ~isempty(vv) & strcmp(lower(vv(1)),'f')
      filled = 1;
      nin = nin-1;
   else
      [l,c,m,msg] = colstyle(vv);
      if ~isempty(msg), 
         error(sprintf('Unknown option "%s".',vv));
      end
      if ~isempty(l), ls = l; end
      if ~isempty(c), col = c; end
      if ~isempty(m), ms = m; plotarrows = 0; end
      if isequal(m,'.'), ms = ''; end % Don't plot '.'
      varin = varin-1;
   end
end

% Parse autoscale
if varin > 0
   autoscale = varargin{varin};
end
   
x = pos(:,1);
y = pos(:,2);
u = scale.*cos(orient);
v = scale.*sin(orient);

% Scalar expand u,v
if prod(size(u))==1, u = u(ones(size(x))); end
if prod(size(v))==1, v = v(ones(size(u))); end

if autoscale,
  u = u*autoscale; v = v*autoscale;
end

ax = newplot;
next = lower(get(ax,'NextPlot'));
hold_state = ishold;

% Make feature vectors
x = x(:).'; y = y(:).';
u = u(:).'; v = v(:).';
uu = [x;x+u;repmat(NaN,size(u))];
vv = [y;y+v;repmat(NaN,size(u))];

h1 = plot(uu(:),vv(:),[col ls]);

if plotarrows,
  % Make arrow heads and plot them
  hu = [x+u-alpha*(u+beta*(v+eps));x+u; ...
        x+u-alpha*(u-beta*(v+eps));repmat(NaN,size(u))];
  hv = [y+v-alpha*(v-beta*(u+eps));y+v; ...
        y+v-alpha*(v+beta*(u+eps));repmat(NaN,size(v))];
  hold on
  h2 = plot(hu(:),hv(:),[col ls]);
else
  h2 = [];
end

if ~isempty(ms), % Plot marker on base
  hu = x; hv = y;
  hold on
  h3 = plot(hu(:),hv(:),[col ms]);
  if filled, set(h3,'markerfacecolor',get(h1,'color')); end
else
  h3 = [];
end

if ~hold_state, hold off, view(2); set(ax,'NextPlot',next); end

if nargout>0, hh = [h1;h2;h3]; end
