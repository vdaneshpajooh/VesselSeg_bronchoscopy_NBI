%%% testing Unet

% load the model
load('VesselExtract_Unet.mat');

% testing set directory
xdir_test = './NBI/test/images';
ydir_test = './NBI/test/labels';

imglist = dir([xdir_test,'/*.jpg']);
labellist = dir([ydir_test,'/*.png']);

n = numel(imglist);

% First, resize and crop the image.
% Then segment and finally stitch them back together

% Unet input image size
M = 256;
N = 256;

pred_list = cell(n,1);
t_start = tic;
for k = 1:n
    img = imread([xdir_test,'/',imglist(k).name]);
    label = imread([ydir_test,'/',labellist(k).name]);
    
    imageSize = size(img);
    block_end = floor(imageSize(1:2)./[M N]);
    
    img_resized = imresize(img,block_end.*[M,N]);
    label_resized = imresize(label,block_end.*[M,N]);
    
    img_label = zeros(block_end.*[M,N]);
    for i = 1:block_end(1)
        for j = 1:block_end(2)
            img_patch = img_resized((i-1)*M+1:i*M,(j-1)*N+1:j*N,:);
            [pred,class_scores] = semanticseg(img_patch,net);
            img_label((i-1)*M+1:i*M,(j-1)*N+1:j*N) = pred;
        end
    end
    pred_list{k} = img_label-1;
%     pred_overlayed{k} = labeloverlay(label_resized,img_label);
    
% figure, imshow(pred_list{k} < 1)
    scores = quant_eval( pred_list{k} < 1 , label_resized > 0 );
    
    % scoreboard
    test_case{k,1} = sprintf('test%.2d',k);
    accuracy(k,1) = scores.accuracy;
    precision(k,1) = scores.precision;
    sensitivity(k,1) = scores.sensitivity;
    specificity(k,1) = scores.specificity;
    F1_score(k,1) = scores.F1_score;
end
t_end = toc(t_start);
fprintf('===================\nRunning time: %.2d fps\n\n',t_end/n);

T = table(accuracy,precision,sensitivity,specificity,F1_score,'RowNames',test_case)

fprintf('mean\n\t\t');
disp(mean(T.Variables));

fprintf('std\n\t\t');
disp(std(T.Variables));