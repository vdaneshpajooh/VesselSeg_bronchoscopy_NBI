% Using this script you can segment your images using a pre-trained network
% This script generates segmentation labels and label-overlayed images.

clear,clc,close all

% load the pre-trained net
load('VesselSeg_DeepLabv3plus.mat');

% load images
imds = imageDatastore('Y:\Hershey\2017Nov-Hershey\Projects\2020NBI-Vessels-SingleFrame\Frames\21405-157-Frames','FileExtensions','.jpg');

% you need this function if your images have different sizes
% modify the custom read function accordingly.
imds.ReadFcn = @customReadDatastoreImage;

NumFrames = numel(imds.Files);

outputFolder = pwd;
predictFolder = [outputFolder,'\testResults_157'];

t_start = tic;

% start segmentation using pre-trained network "net" 
pxdsResults = semanticseg(imds,net, ...
    'MiniBatchSize',2, ...
    'WriteLocation',predictFolder,...
    'Verbose',true);

t_total = toc(t_start);
fprintf('===============\n Running time (fps): %d\n',NumFrames/t_total);

c = imds.Files;
save([predictFolder,'\FileNames.mat'],'c');

fileparts = split(c,'\');

% warning: create the directory "labelsoverlay" before running this script
% otherwise it will produce an error here.
labeloverlay_dir = [predictFolder,'\labelsoverlay\'];

N = numel(c);
for i = 1:N
    img = imread(c{i});
    size_img = size(img);
    
    label = imread([predictFolder,'\',sprintf('pixelLabel_%04d.png',i)]);
    size_label = size(label);
    if size_label(2) ~= size_img(2)
        img = imresize(img,size_label);
    end
        
    B = labeloverlay(img,label,'Transparency',0.85);
    imwrite(B,[labeloverlay_dir,'overlay_',fileparts{i,end-1},'_',fileparts{i,end}]);
end