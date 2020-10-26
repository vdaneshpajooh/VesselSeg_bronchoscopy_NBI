%%% Data Preprocessing

% training set directory
xdir = './NBI/train/images';
ydir = './NBI/train/labels';

% validation set directory
valxdir = './NBI/validation/images';
valydir = './NBI/validation/labels';

% class definition an labels
classNames = ["vessel","background"];
labelIDs   = [255 0];

% import training/validation image file names, directories, etc.
% Recommended if you have large dataset. It keeps the memory clear.

imds = imageDatastore(xdir,'FileExtensions','.jpg');
pxds = pixelLabelDatastore(ydir,classNames,labelIDs,'FileExtensions','.png');

val_imds = imageDatastore(valxdir,'FileExtensions','.jpg');
val_pxds = pixelLabelDatastore(valydir,classNames,labelIDs,'FileExtensions','.png');


% Augmentation
augmenter = imageDataAugmenter( ...
  'RandRotation',[-10,10], ...
    'RandXTranslation',[-10 10], ...
    'RandYTranslation',[-10 10], ...
    'RandScale',[0.9,1],...
    'RandXShear',[-10,10], ...
    'RandYShear',[-10,10]);

imageSize = [256 256];
patch_per_image = 100;

% random cropping of large images.
% "randomPatchExtractionDatastore" works only with MATLAB version > 2018b
augimds = randomPatchExtractionDatastore(imds,pxds,imageSize,...
                                      'PatchesPerImage',patch_per_image,...
                                      'DataAugmentation',augmenter);
                                                                         
val_augimds = randomPatchExtractionDatastore(val_imds,val_pxds,imageSize,...
                                      'PatchesPerImage',patch_per_image,...
                                      'DataAugmentation',augmenter);
