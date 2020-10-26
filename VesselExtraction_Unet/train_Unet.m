clear,clc

try
    nnet.internal.cnngpu.reluForward(1);
catch ME
end

%% Read and augment data
preprocess_data();

%% create Unet network
% parameters
% imageSize: it is set in the preprocess_data.m file (256,256)
% other parameters such as convolution kernel size, # of channels, etc can
% be set inside the createUnet() function.
dropout_prob = 0.4; % probability of droping data from encoder to decoder
encoderDepth = 4;   % encoder decoder depth is Unet. 

Unet_network = createUnet(imageSize,dropout_prob,encoderDepth);

%% training options
initialLearningRate = 0.001;
maxEpochs = 50;
minibatchSize = 16;

options = trainingOptions('adam', ...
    'MaxEpochs',maxEpochs, ...
    'InitialLearnRate',initialLearningRate, ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropPeriod',5, ...
    'LearnRateDropFactor',0.95, ...
    'ValidationData',val_augimds, ...
    'ValidationFrequency',30,...
    'Plots','training-progress', ...
    'Verbose',true, ...
    'MiniBatchSize',minibatchSize);

%% training
[Unet,info] = trainNetwork(augimds,Unet_network,options);

save('VesselExtract_Unet.mat','Unet','options','patch_per_image')