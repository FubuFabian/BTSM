%%%%% Loading training images %%%%%%%%

[fileImages, pathImages, wtv] = uigetfile('*.bmp','Load Images','MultiSelect', 'on');

if ischar(fileImages)
    error('More than 1 image is needed');
else
    [wtv nImages] = size(fileImages);
end

[fileTumors, pathTumors, wtv] = uigetfile('*.mat','Load Tumor Segmentation');

tumorsFilename = strcat(pathTumors,fileTumors);
 
tumors = load(tumorsFilename);
tumors = tumors.tumors;

images = cell(nImages,1);

out = struct;

for i=1:nImages
       img_name = strcat(pathImages,fileImages{i});
       imGray = imread(img_name);
%      imGray = rgb2gray(im);
       imGray = mat2gray(imGray);
        
       images{i} = imGray;
end

outRLN = TestRunlength(images,tumors,nImages,'RLN')
outRP = TestRunlength(images,tumors,nImages,'RP')
outSRE = TestRunlength(images,tumors,nImages,'SRE')
outSRHGE = TestRunlength(images,tumors,nImages,'SRHGE')
outSRLGE = TestRunlength(images,tumors,nImages,'SRLGE')
