%%%%% Loading training images %%%%%%%%

function out = Time()

[fileImages, pathImages, wtv] = uigetfile('*.bmp','Load Images','MultiSelect', 'on');

if ischar(fileImages)
    error('More than 1 image is needed');
else
    [wtv nImages] = size(fileImages);
end

images = cell(nImages,1);

out = struct;

for i=1:nImages
       img_name = strcat(pathImages,fileImages{i});
       imGray = imread(img_name);
%      imGray = rgb2gray(im);
       imGray = mat2gray(imGray);
        
       images{i} = imGray;         
end

warning off;

[out.meanSRE out.stdSRE] = RunLengthTime(images,'SRE');
[out.meanLRE out.stdLRE] = RunLengthTime(images,'LRE');
[out.meanGLN out.stdGLN] = RunLengthTime(images,'GLN');
[out.meanRLN out.stdRLN] = RunLengthTime(images,'RLN');
[out.meanRP out.stdRP] = RunLengthTime(images,'RP');

