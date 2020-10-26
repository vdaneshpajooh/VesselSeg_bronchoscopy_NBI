function [imdsTrain, imdsVal, imdsTest, pxdsTrain, pxdsVal, pxdsTest] = partitionData(imds,pxds,labelIDs)
% Partition data by randomly selecting 70% of the data for training,
% 10% validating, and 20% testing.
    
% Set initial random state for example reproducibility.
rng(0); 
numFiles = numel(imds.Files);
shuffledIndices = randperm(numFiles);

% Use 70% of the images for training.
numTrain = round(0.70 * numFiles);
trainingIdx = shuffledIndices(1:numTrain);

% Use 10% of the images for validation
numVal = round(0.10 * numFiles);
valIdx = shuffledIndices(numTrain+1:numTrain+numVal);

% Use the rest for testing.
testIdx = shuffledIndices(numTrain+numVal+1:end);

% Create image datastores for training and test.
trainingImages = imds.Files(trainingIdx);
valImages = imds.Files(valIdx);
testImages = imds.Files(testIdx);

imdsTrain = imageDatastore(trainingImages);
imdsTrain.ReadFcn = @customReadDatastoreImage;

imdsVal = imageDatastore(valImages);
imdsVal.ReadFcn = @customReadDatastoreImage;

imdsTest = imageDatastore(testImages);
imdsTest.ReadFcn = @customReadDatastoreImage;

% Extract class and label IDs info.
classes = pxds.ClassNames;
% labelIDs = camvidPixelLabelIDs();

% Create pixel label datastores for training and test.
trainingLabels = pxds.Files(trainingIdx);
valLabels = pxds.Files(valIdx);
testLabels = pxds.Files(testIdx);

pxdsTrain = pixelLabelDatastore(trainingLabels, classes, labelIDs);
pxdsTrain.ReadFcn = @customReadDatastoreImage;

pxdsVal = pixelLabelDatastore(valLabels, classes, labelIDs);
pxdsVal.ReadFcn = @customReadDatastoreImage;

pxdsTest = pixelLabelDatastore(testLabels, classes, labelIDs);
pxdsTest.ReadFcn = @customReadDatastoreImage;
end