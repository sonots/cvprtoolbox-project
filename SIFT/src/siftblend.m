function siftblend
if ~exist('im_names', 'var')
    im_names = { ...
        'wadham001'; ...  % Reference view
        'wadham002'; ...
        'wadham003'; ...
        };
    for k = 1:length(im_names)
        im_names{k} = ['../images/' im_names{k} '.pgm'];
    end
end
levels = 4;
s = 2;
search_mask = ones(size(im));
d = 0.02;
r = 10.0;
db_name = '../images/wadham.db';

n = length(im_names);
im_view = cell(1,n);
im_pos = cell(1,n);
im_orient = cell(1,n);
im_scale = cell(1,n);
im_desc = cell(1,n);
for k = 1:n
    if exist([im_names{k} '.sift'])
        eval(sprintf('load ''%s.sift'' pos scale ori desc im -mat', im_names{k}));
    else
        im = double(imread(im_names{k}))./255;
        [ pos scale ori desc ] = SIFT( im, levels, s, search_mask, d, r );
        eval(sprintf('save ''%s.sift'' pos scale ori desc im -mat', im_names{k}));
    end
    im_view{k} = im; im_pos{k} = pos; im_scale{k} = scale; im_orient{k} = ori; im_desc{k} = desc;
end

% Add the first image to a database as the reference view
fprintf( 2, 'Adding reference view %s to database.\n\n', im_names{1} );
db = add_descriptors_to_database( im_view{1}, im_pos{1}, im_scale{1}, im_orient{1}, im_desc{1} );

% Loop over the remaining views
for j = 2:n

    % Compute hough transform back to the reference view
    fprintf( 2, 'Performing hough transform for view %s...\n', im_names{j} );
    [im_idx trans theta rho idx nn_idx wght] = hough( db, im_pos{j}, im_scale{j}, im_orient{j}, im_desc{j}, 10.0 );

    % Robustly fit an affine transformation to the largest peak of the hough tranformation
    fprintf( 2, 'Fitting affine transform to largest peak of hough transform...\n' );
    [max_val k] = max(wght);
    c_pos = im_pos{j}(idx{k},:);
    c_desc = im_desc{j}(idx{k},:);
    c_wght = im_scale{j}(idx{k}).^-2;
    nn_pos = db.pos(nn_idx{k},:);
    [aff outliers] = fit_robust_affine_transform( c_pos', nn_pos', c_wght', 0.75 );

    % Dispaly the computed transformation
    fprintf( 2, '\nComputed affine transformation from this view to reference view:\n' );
    disp(aff);

    % Display the view and reference view, showing features the features that match between
    % the images.  Over the reference view, overlay the constraints and indicated whether they
    % are inliers or outliers to the fit.
    fig = figure;
    clf;
    subplot(1,2,1);
    showIm( im_view{j} );
    hold on;
    plot( c_pos(:,1), c_pos(:,2), 'y+' );
    title( 'Nearest Neighbours' );
    subplot(1,2,2);
    showIm( db.im{1} );
    hold on;
    plot( nn_pos(:,1), nn_pos(:,2), 'b+' );
    pts = aff * [c_pos'; ones(1,size(c_pos,1))];
    pts = pts(1:2,:)';
    plot( pts(:,1), pts(:,2), 'go' );
    plot( pts(outliers,1), pts(outliers,2), 'ro' );
    title( 'Robust Affine Alignment' );
    fprintf( 2, '\tView features (yellow +)\n\tReference view features (blue +)\n\n' );
    fprintf( 2, '\t%d constraints\n\t%d inliers (green o)\n\t%d outliers (red o)\n\n', size(pts,1), size(pts,1)-length(outliers), length(outliers) );
    fprintf( 2, 'Press any key to continue...\n' );
    pause;
    close(fig);

    % Display the original view, the reference view, the aligned version of the origianl view,
    % and the reference view minus the aligned view.
    fig = figure;
    clf;
    subplot(2,2,1);
    showIm( im_view{j} );
    title( 'Orignial View' );
    subplot(2,2,2);
    showIm( db.im{1} );
    title( 'Reference View' );
    subplot(2,2,3);
    warped = imWarpAffine( im_view{j}, inv(aff), 1 );
    warped( find(isnan(warped)) ) = 0;
    showIm( warped );
    title( 'Aligned View' );
    subplot(2,2,4);
    showIm( db.im{1} - warped );
    title( 'Reference minus Aligned View' );
    fprintf( 2, 'Press any key to continue...\n\n' );
    pause;
    close(fig);
end

% Clear stuff
clear im_view im_pos im_scale im_orient im_desc db aff c_pos c_desc c_wght nn_pos

%
% % EXAMPLE 2: Architectural Images
% %
%
% % Load in the images.
% im_names = { ...
%     'wadham001'; ...  % Reference view
%     'wadham002'; ...
%     %    'wadham003'; ...
%     %    'wadham004'; ...
%     %    'wadham005'; ...
%     };
% n = length(im_names);
% im_view = cell(1,n);
% im_pos = cell(1,n);
% im_orient = cell(1,n);
% im_scale = cell(1,n);
% im_desc = cell(1,n);
% for k = 1:n
%     [ im_pos{k} im_scale{k} im_orient{k} im_desc{k} im_view{k} ] = SIFT_from_cache( im_path, im_names{k}, cache, octaves, intervals );
% end
%
% % Add the first image to a database as the reference view
% fprintf( 2, 'Adding reference view %s to database.\n\n', im_names{1} );
% db = add_descriptors_to_database( im_view{1}, im_pos{1}, im_scale{1}, im_orient{1}, im_desc{1} );
%
% % Loop over the remaining views
% for j = 2:n
%
%     % Compute hough transform back to the reference view
%     fprintf( 2, 'Performing hough transform for view %s...\n', im_names{j} );
%     [im_idx trans theta rho idx nn_idx wght] = hough( db, im_pos{j}, im_scale{j}, im_orient{j}, im_desc{j}, 10.0 );
%
%     % Robustly fit an affine transformation to the largest peak of the hough tranformation
%     fprintf( 2, 'Fitting affine transform to largest peak of hough transform...\n' );
%     [max_val k] = max(wght);
%     c_pos = im_pos{j}(idx{k},:);
%     c_desc = im_desc{j}(idx{k},:);
%     c_wght = im_scale{j}(idx{k}).^-2;
%     nn_pos = db.pos(nn_idx{k},:);
%     [aff outliers] = fit_robust_affine_transform( c_pos', nn_pos', c_wght', 0.75 );
%
%     % Dispaly the computed transformation
%     fprintf( 2, '\nComputed affine transformation from this view to reference view:\n' );
%     disp(aff);
%
%     % Display the view and reference view, showing features the features that match between
%     % the images.  Over the reference view, overlay the constraints and indicated whether they
%     % are inliers or outliers to the fit.
%     fig = figure;
%     clf;
%     subplot(1,2,1);
%     showIm( im_view{j} );
%     hold on;
%     plot( c_pos(:,1), c_pos(:,2), 'y+' );
%     title( 'Nearest Neighbours' );
%     subplot(1,2,2);
%     showIm( db.im{1} );
%     hold on;
%     plot( nn_pos(:,1), nn_pos(:,2), 'b+' );
%     pts = aff * [c_pos'; ones(1,size(c_pos,1))];
%     pts = pts(1:2,:)';
%     plot( pts(:,1), pts(:,2), 'go' );
%     plot( pts(outliers,1), pts(outliers,2), 'ro' );
%     title( 'Robust Affine Alignment' );
%     fprintf( 2, '\tView features (yellow +)\n\tReference view features (blue +)\n\n' );
%     fprintf( 2, '\t%d constraints\n\t%d inliers (green o)\n\t%d outliers (red o)\n\n', size(pts,1), size(pts,1)-length(outliers), length(outliers) );
%     fprintf( 2, 'Press any key to continue...\n' );
%     pause;
%     close(fig);
%
%     % Display the original view, the reference view, the aligned version of the origianl view,
%     % and the reference view minus the aligned view.
%     fig = figure;
%     clf;
%     subplot(2,2,1);
%     showIm( im_view{j} );
%     title( 'Orignial View' );
%     subplot(2,2,2);
%     showIm( db.im{1} );
%     title( 'Reference View' );
%     subplot(2,2,3);
%     warped = imWarpAffine( im_view{j}, inv(aff), 1 );
%     warped( find(isnan(warped)) ) = 0;
%     showIm( warped );
%     title( 'Aligned View' );
%     subplot(2,2,4);
%     showIm( db.im{1} - warped );
%     title( 'Reference minus Aligned View' );
%     fprintf( 2, 'Press any key to continue...\n\n' );
%     pause;
%     close(fig);
% end
%
% % Clear stuff
% clear im_view im_pos im_scale im_orient im_desc db aff c_pos c_desc c_wght nn_pos
%
