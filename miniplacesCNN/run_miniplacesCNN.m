% % install MatConvNet first at http://www.vlfeat.org/matconvnet/
% untar('http://www.vlfeat.org/matconvnet/download/matconvnet-1.0-beta16.tar.gz') ;
% cd matconvnet-1.0-beta16
% run matlab/vl_compilenn ;

% Setup MatConvNet.
run matconvnet-1.0-beta16/matlab/vl_setupnn.m ;

% data selection param
data_selection = 'val'; % val or test

% load pre-trained model
load('categoryIDX.mat');
path_model = 'refNet1-epoch-60.mat';
load([path_model]) ;
% net = cnn_imagenet_init();

% change the last layer of CNN from softmaxloss to softmax
net_norm = net.normalization;
net.layers{1,end}.type = 'softmax';
net.layers{1,end}.name = 'prob';
% net = vl_simplenn_tidy(net);

% open results.txt file
fileID = fopen(strcat('results_',data_selection,'.txt'),'w');

% load and preprocess an image
image_path = '../final_project_data/images/';
files = dir(strcat('../final_project_data/images/',data_selection,'/*.jpg'));

index = 1;
for file = files'
    if index <= 10
        current_image = strcat(data_selection,'/',file.name);
        im = imread(strcat(image_path, current_image)) ;
        im_resize = imresize(im, net_norm.imageSize(1:2)) ;
        im_ = single(im_resize) ; 
        for i=1:3
            im_(:,:,i) = im_(:,:,i)-net_norm.averageImage(i);
        end

        % run the CNN
        res = vl_simplenn(net, im_) ;

        scores = squeeze(gather(res(end).x)) ;
        [score_sort, idx_sort] = sort(scores,'descend') ;
    %     figure, imagesc(im_resize) ;

        % prints image name and categories to results.txt
        fprintf(fileID, '%s ', current_image);
        for i=1:5
    %         disp(sprintf('%s (%d), score %.3f', categoryIDX{idx_sort(i),1}, idx_sort(i), score_sort(i)));
            fprintf(fileID, '%d ', idx_sort(i)-1);
        end
        fprintf(fileID, '\n');
        
        index = index + 1;
    end
end    

% close results.txt file
fclose(fileID);
