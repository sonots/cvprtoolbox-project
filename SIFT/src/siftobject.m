function siftobject

%
% EXAMPLE 3: Object Recognition
%

% Load the images
im_names = { ...
   'nutshell0003'; ...  % Model of Java book
   'phone0003'; ...     % Model of coreless phone
   'phone0007'; ...
   'nutshell0007'; ...
   'phone0018'; ...
   'nutshell0008'; ...
   'phone0005'; ...
   'nutshell0009'; ...   
   'phone0017'; ...   
   'nutshell0012'; ...
   'phone0016'; ...  % Does not find compute correct affine transform for this image
   'nutshell0004'; ...
   'nutshell0010'; ...
   'nutshell0011'; ...
};
num_obj = 2;
n = length(im_names);
obj_im = cell(1,n);
obj_mask = cell(1,n);
obj_pos = cell(1,n);
obj_scale = cell(1,n);
obj_orient = cell(1,n);
obj_desc = cell(1,n);
for k = 1:n
   [ obj_pos{k} obj_scale{k} obj_orient{k} obj_desc{k} obj_im{k} obj_mask{k} ] = SIFT_from_cache( im_path, im_names{k}, cache, octaves, intervals );
end

% Add the models to the database.  There are two models, a phone and a Java
% book, both segmented from the background.
db = empty_descriptor_database;
for k = 1:num_obj
   fprintf( 2, 'Adding keypoints for image %s to database.\n', im_names{k} );   
   db = add_descriptors_to_database( obj_im{k}, obj_pos{k}, obj_scale{k}, obj_orient{k}, obj_desc{k}, db );
end

% Loop over the remaining images
for j = (num_obj+1):n
   
   % Perform hough tranform between the test image and the database
   fprintf( 2, '\nPerforming hough transform for image %s.\n', im_names{j} );
	[im_idx trans theta rho idx nn_idx wght] = hough( db, obj_pos{j}, obj_scale{j}, obj_orient{j}, obj_desc{j}, 1.5 );
   
   % Determine if a match is found
   if isempty(im_idx)
      fprintf( 2, 'No match.\n' );
      fprintf( 2, 'Press any key to continue...\n' );
      pause;
   else
      matches = length(im_idx);
      aff = cell(1,matches);
      c_pos = cell(1,matches);
      nn_pos = cell(1,matches);
      outliers = cell(1,matches);
      
      % Select the match that has the largest peak in the hough transform
      fprintf( 2, 'Determining best match.\n' );
      [max_wght k] = max(wght);
      for m = k
         c_pos{m} = obj_pos{j}(idx{m},:);
         c_desc = obj_desc{j}(idx{m},:);
         c_wght = obj_scale{j}(idx{m}).^-2;
         nn_pos{m} = db.pos(nn_idx{m},:);                   
         
         % Robustly fit an affine tranformaton between the image and the model if enough features
         % were matched.
         fprintf( 2, 'Matches %s.\n', im_names{im_idx(m)} );      
         if length(idx{m}) < 3
            fprintf( 2, 'Too few points to fit affine transform.\n' );
         else
            fprintf( 2, '\nComputed affine transformation from %s to %s:\n', im_names{j}, im_names{im_idx(m)} );
            [aff{m} outliers{m} robustError] = fit_robust_affine_transform( c_pos{m}', nn_pos{m}', c_wght', 0.75 );
            disp(aff{k});
			   fprintf( 2, '\tImage features (yellow +)\n\tModel features (blue +)\n\n' );
            fprintf( 2, '\t%d constraints\n\t%d inliers (green o)\n\t%d outliers (red o)\n\n', size(c_pos{m},1), size(c_pos{m},1)-length(outliers{m}), length(outliers{m}) );
         end         
         
         % Display the image, the model, and the location of the model in the
         % image according to the computed transfromation.
         fig = figure;
         clf;
         subplot(1,3,1);
         showIm( obj_im{j}, [0 1] );
         hold on;
         plot( c_pos{m}(:,1), c_pos{m}(:,2), 'y+' );
         title( 'Image' );
         subplot(1,3,2);
         im = db.im{im_idx(m)};
         im(find(obj_mask{im_idx(m)}==0)) = 0;
         showIm( im, [0 1] );
         hold on;
         plot( nn_pos{m}(:,1), nn_pos{m}(:,2), 'b+' );
         title( 'Model' );  
         if length(idx{m}) >= 3
            pts = aff{m} * [c_pos{m}'; ones(1,size(c_pos{m},1))];
            pts = pts(1:2,:)';
            plot( pts(:,1), pts(:,2), 'go' );
            plot( pts(outliers{m},1), pts(outliers{m},2), 'ro' );
            aligned = imWarpAffine( obj_mask{im_idx(m)}, aff{m}, 1 );
            aligned(find(isnan(aligned))) = 0;
            subplot(1,3,3);
            showIm( obj_im{j} - aligned );
            title( 'Location' );
         end
         fprintf( 2, 'Press any key to continue...\n' );
         pause;
         close(fig);
      end
      
   end
end

% Clear stuff
clear obj_im obj_mask obj_pos obj_scale obj_orient obj_desc db aff c_pos c_desc c_wght nn_pos

