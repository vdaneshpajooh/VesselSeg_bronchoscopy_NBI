%%% testing Unet on the fly
% load the model
load('VesselExtract_Unet.mat');

% read an NBI frame
img = imread('94_frame4529_151.1844_187.1844.jpg');     

% Unet input image size
M = 256;
N = 256;

% First, resize and crop the image.
% Then segment and finally stitch them back together
imageSize = size(img);
block_end = floor(imageSize(1:2)./[M N]);

img_resized = imresize(img,block_end.*[M,N]);

img_label = zeros(block_end.*[M,N]);
step_size = 64;
for i = 1:block_end(1)
    for j = 1:block_end(2)
        img_64x64 = img_resized((i-1)*M+1:i*M,(j-1)*N+1:j*N,:);
        [pred,class_scores] = semanticseg(img_64x64,net);
        img_label((i-1)*M+1:i*M,(j-1)*N+1:j*N) = pred;
    end
end

% prediction, i.e., segmented image
figure, imshow(img_label - 1) % segmented image
figure, imshow(img_resized)   % NBI frame