clc,clear
close all;

% load prediction files 

% load('./testResults_168/FileNames.mat')
load('./testResults_157/FileNames.mat')

% sort files in natural order, i.e., 1,2,3,...
[c_natsorted,ndx,~] = natsortfiles(c);
% fileparts = split(c_natsorted,'\');

N = numel(c_natsorted);

% structuring elements used for morphological operations
SE1 = strel('disk',20);
SE2 = strel('disk',5);

% a pre-defined threshold on the following ratio:
% # of pixels in an ROI in the segmented frame / total # of pixels
alert_thresh = 0.05;

imgIdx_abnormal = [];

% case study and the interval to create the overlayed (segmented) video: [from:to]
caseStudy = 157;
from = 150;
to = 820;

% preparing the video writer
video_filename = sprintf('case21405.%d_frames%04d-%04d_labeloverlay.avi',caseStudy,from,to);
outputVideo = VideoWriter(video_filename);
outputVideo.FrameRate = 10;
open(outputVideo)

for frame = from:to 
    img = imread(c_natsorted{frame});
    size_img = size(img);
    label = imread(sprintf('./testResults_%d/pixelLabel_%04d.png',caseStudy,ndx(frame)));
    
    size_label = size(label);
    if size_label(2) ~= size_img(2)
        img = imresize(img,size_label);
    end
    
    if frame==from
        total_NumFrames = numel(label);
    end
    
    bw_filled = imopen(label==2,SE1);
    bw_eroded = imerode(bw_filled,SE2);
    bw_contour = and(bw_filled,~bw_eroded);
    
    bw_regions = bwlabel(bw_filled);
    NumRegions = max(bw_regions(:));
    
    layover = bw_contour;
%     B = labeloverlay(img,bw,'Transparency',0.70,'Colormap',[0.5 0 0.8]); % for bw_filled
    B = labeloverlay(img,layover,'Transparency',0.0,'Colormap',[1 0 0]); % for bw_contour
    
    if NumRegions > 0
       cnt_ROI = 0;
       for i=1:NumRegions
           ROI_pixels(i) = sum(bw_regions(:)==i);
           if (ROI_pixels(i)/total_NumFrames) > alert_thresh
               cnt_ROI = cnt_ROI+1;
               
               [r,c] = find(bw_regions == i);
               x1 = min(c);
               y1 = min(r);
               dx = max(c) - x1;
               dy = max(r) - y1;
               bbox = [x1 y1 dx dy];
               
               imgIdx_abnormal = [imgIdx_abnormal; frame,cnt_ROI,bbox];
               fprintf('found large (ratio > %.2f) vascular pattern in frame %d (ROI%d)\n',alert_thresh,frame,i);
               
               B = insertText(B, [x1 y1], sprintf('ROI%d',cnt_ROI),'FontSize',20,'TextColor','black');
           end
       end
%        show a warning messege on the current frame that a large vascular
%        structure is detected.
%        if cnt_ROI > 0
%           B = insertText(B, [10 10], 'large vascular structure!','FontSize',30,'BoxColor',...
%                         'red','BoxOpacity',0.9,'TextColor','black');
%        end
    end    
    writeVideo(outputVideo,B);
end

close(outputVideo);