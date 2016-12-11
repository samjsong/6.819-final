function imdb = refNet_setup_data()

SceneJPGsPath = '../final_project_data/images/';

num_train_per_category = 1000; %1000
num_val = 10000; %10,000
total_images = 100*num_train_per_category + num_val; % 110,000

image_size = [126 126];

imdb.images.data   = zeros(image_size(1), image_size(2), 3, total_images, 'single');
imdb.images.labels = zeros(1, total_images, 'single');
imdb.images.set    = zeros(1, total_images, 'uint8');
image_counter = 1;
          
fname = fullfile('devkit_data', 'categories.txt') ;
fileID = fopen(fname, 'r') ;
categories = textscan(fileID, '%s %d\n') ;
categories = categories{1};
fclose(fileID);
          
fname = fullfile('devkit_data', 'val.txt') ;
fileID = fopen(fname, 'r') ;
val_categories = textscan(fileID, '%s %d\n');
val_categories = val_categories{2};
fclose(fileID);

sets = {'train', 'val'};

fprintf('Loading %d train and %d test images from each category\n', ...
          num_train_per_category, num_val)
fprintf('Each image will be resized to %d by %d\n', image_size(1),image_size(2));

%Read each image
for set = 1:length(sets)
    if strcmp(sets{set},'train')
        for category = 1:length(categories)
            cur_path = fullfile( SceneJPGsPath, sets{set}, categories{category});
            cur_images = dir( fullfile( cur_path,  '*.jpg') );

            fprintf('Taking %d out of %d images in %s\n', num_train_per_category, length(cur_images), cur_path);
            cur_images = cur_images(1:num_train_per_category) ;

            for i = 1:length(cur_images)
                cur_image = imread(fullfile(cur_path, cur_images(i).name));
                cur_image = imresize(cur_image, image_size);
                cur_image = single(cur_image);
                
%                 for i=1:3
%                     im_(:,:,i) = im_(:,:,i)-net_norm.averageImage(i);
%                 end
                
                imdb.images.data(:,:,:,image_counter) = cur_image;            
                imdb.images.labels(1,image_counter) = category - 1;
                imdb.images.set(1,image_counter) = set; %1 for train, 2 for val
                
                image_counter = image_counter + 1;
            end
        end
    else
        cur_path = fullfile( SceneJPGsPath, sets{set});
        cur_images = dir( fullfile( cur_path,  '*.jpg') );

        fprintf('Taking %d out of %d images in %s\n', num_val, length(cur_images), cur_path);
        cur_images = cur_images(1:num_val);

        for i = 1:length(cur_images)
            cur_image = imread(fullfile(cur_path, cur_images(i).name));
            cur_image = imresize(cur_image, image_size);
            cur_image = single(cur_image);
            
            imdb.images.data(:,:,:,image_counter) = cur_image;            
            imdb.images.labels(1,image_counter) = val_categories(i);
            imdb.images.set(1,image_counter) = set; %1 for train, 2 for val
            
            image_counter = image_counter + 1;
        end
    end
    
end