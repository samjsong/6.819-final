% % install MatConvNet first at http://www.vlfeat.org/matconvnet/
% untar('http://www.vlfeat.org/matconvnet/download/matconvnet-1.0-beta23.tar.gz') ;
% cd matconvnet-1.0-beta23
% run matlab/vl_compilenn ;

% Setup MatConvNet.

run matconvnet-1.0-beta23/matlab/vl_setupnn.m ;

% load pre-trained model
load('categoryIDX.mat');
path_model = 'refNet1-epoch-60.mat';
load([path_model]) ;

% load and preprocess an image
image_path = '../final_project_data/images/';
current_image = 'val/00000001.jpg';
im = imread(strcat(image_path, current_image)) ;
im_resize = imresize(im, net.normalization.imageSize(1:2)) ;
im_ = single(im_resize) ; 
for i=1:3
    im_(:,:,i) = im_(:,:,i)-net.normalization.averageImage(i);
end

% change the last layer of CNN from softmaxloss to softmax
net.layers{1,end}.type = 'softmax';
net.layers{1,end}.name = 'prob';

% run the CNN
net = vl_simplenn_tidy(net);
res = vl_simplenn(net, im_) ;

scores = squeeze(gather(res(end).x)) ;
[score_sort, idx_sort] = sort(scores,'descend') ;
figure, imagesc(im_resize) ;

fileID = fopen('results.txt','w');

fprintf(fileID, '%s ', current_image);

for i=1:5
    disp(sprintf('%s (%d), score %.3f', categoryIDX{idx_sort(i),1}, idx_sort(i), score_sort(i)));
    fprintf(fileID, '%d ', idx_sort(i));
end

fclose(fileID);
