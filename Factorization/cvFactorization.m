function [R, S, t] = cvFactorization(W, method)
% cvFactorization - The factorization method
%
% Synopsis
%  [R, S, t] = cvFactorization(W)
%
% Description
%  Shape and motion from image streams -- a factorization method.
%  This function does a orthographic factorization method [1] and
%  a paraperspective factorization method [2].
%
% Inputs ([]s are optional)
%  (matrix) W        2F x P matrix of image points where F is the
%                    number of frames and P is the number of points
%                    in one frame. 2 is for x coordinate and y coordinate.
%  (string) [method = 'orthographic']
%                    'orthographic' [1] or 'paraperspective' [2]
%
% Outputs ([]s are optional)
%  (matrix) R        2F x 3 camera rotation (motion)
%  (matrix) S        3 x P shape matrix
%  (vector) [t]      2F x 1 translation
%
% References
%  [1] C. Tomasi and T. Kanade, "Shape and motion from image streams
%  -- a factorization method,"   International Journal of Computer
%  Vision, 9(2):137--154, 1992.
%  [2] C. J. Poelman and T. Kanade. "A paraperspective factorization
%  method for shape and motion recovery," IEE Trans on Pattern
%  Analysis and Machine Intelligence. VOL 19, NO. 3, MARCH 1997.
%  [3] T. Morita and T. Kanade, "A Sequential Factorization Method
%  for Recovering Shape and Motion From Image Streams," IEEE Trans on
%  Pattern Analysis and Machine Intelligence, Vol. 19, No. 8, Aug 1997,
%  pp858 - 867, Sec 2.3
%
% Authors
%  Naotoshi Seo <sonots(at)sonots.com>
%
% License
%  The program is free to use for non-commercial academic purposes,
%  but for course works, you must understand what is going inside to use.
%  The program can be used, modified, or re-distributed for any purposes
%  if you or one of your group understand codes (the one must come to
%  court if court cases occur.) Please contact the authors if you are
%  interested in using the program without meeting the above conditions.

% Changes
%  11/01/2006  First Edition
if ~exist('method', 'var') || isempty(method)
    method = 'orthographic';
end
F = size(W, 1) / 2; % # of frames, F
P = size(W, 2);     % # of feature track points, P
% registered measurement matrix (mean subtraction)
t = mean(W, 2);
W = W - repmat(t, 1, size(W, 2));

% (i) svd [3.11]
[O1, Sigma, O2T] = svd(W, 0); % 0: economy calc is enough
O2 = O2T';

% (ii) Rank 3 [3.12] [3.13]
Rh = O1(:, 1:3) * sqrt(Sigma(1:3, 1:3));
Sh = sqrt(Sigma(1:3, 1:3)) * O2(1:3, :);
% By the way, Sigma is a diagonal matrix, so sqrtm(Sigma) == sqrt(Sigma).

% (iii) Find Q [3.15]
if strcmp(method, 'orthographic')
    Q = orthometric_(Rh);
else
    x = t(1:F);
    y = t(F+1:2*F);
    Q = parapersmetric_(Rh, x, y); % below
end

% (iv) Find R and S [3.14]
R = Rh * Q;
S = inv(Q) * Sh;

% (v) Align the first camera reference system with the world reference
% system
i1 = R(1,:)';
i1 = i1 / norm(i1);
j1 = R(F+1,:)';
j1 = j1 / norm(j1);
k1 = cross(i1, j1);
k1 = k1 / norm(k1);
R0 = [i1 j1 k1];
R = R * R0;
S = inv(R0) * S;
end

function Q = orthometric_(Rh);
% orthometric_ - Metric Transformation in the orthographic case
%
% Synopsis
%  Q = orthometric_(Rh)
%
% Inputs ([]s are optional)
%  (matrix) Rh       2F x 3
%
% Ouputs ([]s are optional)
%  (matrix) Q        3 x 3
%
% References
%  [3] T. Morita and T. Kanade, "A Sequential Factorization Method
%  for Recovering Shape and Motion From Image Streams," IEEE Trans on
%  Pattern Analysis and Machine Intelligence, Vol. 19, No. 8, Aug 1997,
%  pp858 - 867, Sec 2.3
F = size(Rh, 1) / 2;
ihT = Rh(1:F, :);
jhT = Rh(F+1:2*F, :);
G = [gT(ihT, ihT); gT(jhT, jhT); gT(ihT, jhT)]; % 3Fx6, gT() is below
c = [ones(2*F, 1); zeros(F, 1)]; % 3Fx1
I = pinv(G) * c; % 6x1
L = [I(1) I(2) I(3);  % L = Q*Q'
    I(2) I(4) I(5);
    I(3) I(5) I(6)];
% enforcing positive definiteness
% Reference: CSE252B: Computer Vision II Lecture 16, p7
% http://www-cse.ucsd.edu/classes/sp04/cse252b/notes/lec16/lec16.pdf
%L = (L + L') / 2; % symmetricity for eigen decomposition
[V, D] = eigs(L); % eigen decomposition L = V*D*V';
%D(find(D < 0)) = 0; % positive semidefinite approximation
D(find(D < 0)) = 0.00001; % positive definite approximation, Lij > 0
%L = V * D * V';   % restore
Q = V * sqrt(D);
%QT = chol(L); % Cholesky Decomposition. L is a positive def mat
% sqrtm(L) is also possible (assume Q == Q'), and maybe other ways also
%Q  = QT';
end

function Q = parapersmetric_(Mh, x, y);
% parapersmetric_ - Metric Transformation in the paraperspective case
%
% Synopsis
%  Q = parapersmetric(Mh, x, y)
%
% Inputs ([]s are optional)
%  (matrix) Mh       2F x 3 estimated camera rotation (motion)
%  (vector) x        F x 1 representing x coodinates of translation
%  (vector) y        F x 1 representing y coorinates of translation
%
% Outputs ([]s are optional)
%  (matrix) Q        3 x 3
%
% References
%  [2] C. J. Poelman and T. Kanade. "A paraperspective factorization
%  method for shape and motion recovery," IEE Trans on Pattern
%  Analysis and Machine Intelligence. VOL 19, NO. 3, MARCH 1997.
F = size(Mh, 1) / 2;
mhT = Mh(1:F, :); % Fx3
nhT = Mh(F+1:2*F, :);
Eq29L = gT(mhT, mhT) ./ repmat(1+x.^2, 1, 6); % gT is below
Eq29R = gT(nhT, nhT) ./ repmat(1+y.^2, 1, 6);
%  G = [Eq29L - Eq29R; ...
%       gT(mhT, nhT) - 0.5*repmat(x,1,6).*repmat(y,1,6).*(Eq29L+Eq29R); ...
%       gT(mhT(1,:), mhT(1,:))]; % (2F+1)x6, gT() is below
%  c = [zeros(2*F, 1); 1]; % (2F+1)x1
G = [Eq29L; ...
    gT(mhT, nhT); ...
    gT(mhT(1,:), mhT(1,:))];
c = [Eq29R; ...
    0.5*repmat(x,1,6).*repmat(y,1,6).*(Eq29L+Eq29R); ...
    ones(1, 6)];
I = pinv(G) * c; % 6x1
L = [I(1) I(2) I(3);  % L = Q*Q'
    I(2) I(4) I(5);
    I(3) I(5) I(6)];
% enforcing positive definiteness
% Reference: CSE252B: Computer Vision II Lecture 16, p7
% http://www-cse.ucsd.edu/classes/sp04/cse252b/notes/lec16/lec16.pdf
%L = (L + L') / 2; % symmetricity for eigen decomposition
[V, D] = eigs(L); % eigen decomposition L = V*D*V';
if find(D < 0), disp('non-positive definite');, end
%D(find(D < 0)) = 0; % positive semidefinite approximation
D(find(D < 0)) = 0.00001; % positive definite approximation, Lij > 0
%L = V * D * V';   % restore
Q = V * sqrt(D);
%QT = chol(L); % Cholesky Decomposition. L is a positive def mat
% sqrtm(L) is also possible (assume Q == Q'), and maybe other ways also
%Q  = QT';
end

function gT = gT(a, b);
%   a  (vector) of size Fx3:
%   b  (vector) of size Fx3:
%   gT (vector) of size Fx6:
gT = [ a(:,1).*b(:,1) ...
    a(:,1).*b(:,2) + a(:,2).*b(:,1) ...
    a(:,1).*b(:,3) + a(:,3).*b(:,1) ...
    a(:,2).*b(:,2) ...
    a(:,2).*b(:,3) + a(:,3).*b(:,2) ...
    a(:,3).*b(:,3) ];
end