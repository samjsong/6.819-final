function imdb = proj6_part1_setup_data()
%code for Computer Vision, Georgia Tech by James Hays

%This path is assumed to contain 'test' and 'train' which each contain 15
%subdirectories. The train folder has 100 samples of each category and the
%test has an arbitrary amount of each category. This is the exact data and
%train/test split used in Project 4.
SceneJPGsPath = '../final_project_data/images/';

num_train_per_category = 100;
num_val_per_category = 100;
% num_test_per_category  = 100; %can be up to 110
total_images = 100*num_train_per_category + 100*num_val_per_category; % 110,000

image_size = [126 126]; %downsampling data for speed and because it hurts
% accuracy surprisingly little

imdb.images.data   = zeros(image_size(1), image_size(2), 3, total_images, 'single');
imdb.images.labels = zeros(1, total_images, 'single');
imdb.images.set    = zeros(1, total_images, 'uint8');
image_counter = 1;

% categories = {'bedroom', 'coast', 'forest', 'highway', ...
%               'industrial', 'insidecity', 'kitchen', ...
%               'livingroom', 'mountain', 'office', 'opencountry', ...
%               'store', 'street', 'suburb', 'tallbuilding'};
          
fname = fullfile('..', 'devkit_data', 'categories.txt') ;
fileID = fopen(fname, 'r') ;
categories = textscan(fileID, '%s %*[^\n]') ;
categories = categories{1} ;
fclose(fileID);
          
sets = {'train', 'val'};

fprintf('Loading %d train and %d test images from each category\n', ...
          num_train_per_category, num_val_per_category)
fprintf('Each image will be resized to %d by %d\n', image_size(1),image_size(2));

%Read each image and resize it to 224x224
for set = 1:length(sets)
    if strcmp(sets{set},'train')
        for category = 1:length(categories)
            cur_path = fullfile( SceneJPGsPath, sets{set}, categories{category});
            cur_images = dir( fullfile( cur_path,  '*.jpg') );

            fprintf('Taking %d out of %d images in %s\n', num_train_per_category, length(cur_images), cur_path);
            cur_images = cur_images(1:num_train_per_category) ;

            for i = 1:length(cur_images)

                cur_image = imread(fullfile(cur_path, cur_images(i).name));
                cur_image = single(cur_image);
                cur_image = imresize(cur_image, image_size);

                % Stack images into a large 224 x 224 x 1 x total_images matrix
                % images.data
                imdb.images.data(:,:,:,image_counter) = cur_image;            
                imdb.images.labels(  1,image_counter) = category - 1;
                imdb.images.set(     1,image_counter) = set; %1 for train, 2 for test (val?)

                image_counter = image_counter + 1;
            end
        end
    else
        cur_path = fullfile( SceneJPGsPath, sets{set});
        cur_images = dir( fullfile( cur_path,  '*.jpg') );

        if(set == 2)
            fprintf('Taking %d out of %d images in %s\n', num_val_per_category, length(cur_images), cur_path);
            cur_images = cur_images(1:num_val_per_category);
        elseif(set == 3)
            fprintf('Taking %d out of %d images in %s\n', num_test_per_category, length(cur_images), cur_path);
            cur_images = cur_images(1:num_test_per_category);
        end

        for i = 1:length(cur_images)

            cur_image = imread(fullfile(cur_path, cur_images(i).name));
            cur_image = single(cur_image);
            cur_image = imresize(cur_image, image_size);

            % Stack images into a large 224 x 224 x 1 x total_images matrix
            % images.data
            imdb.images.data(:,:,:,image_counter) = cur_image;            
            imdb.images.labels(  1,image_counter) = category;
            imdb.images.set(     1,image_counter) = set; %1 for train, 2 for test (val?)

            image_counter = image_counter + 1;
        end
    end
    
end


