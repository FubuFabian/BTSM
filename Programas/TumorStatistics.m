function statsTumor = TumorStatistics()

[fileImages, pathImages, wtv] = uigetfile('*.bmp','Load Images','MultiSelect', 'on');

if ischar(fileImages)
    nImages = 1;
else
    [wtv nImages] = size(fileImages);
end

[fileTumors, pathTumors, wtv] = uigetfile('*.mat','Load Tumor Segmentation');

tumorsFilename = strcat(pathTumors,fileTumors);
 
tumors = load(tumorsFilename);
tumors = tumors.tumors;

statsTumor = struct;

tumorPixels= [];

for i=1:nImages
    
    if ischar(fileImages)
        img_name = strcat(pathImages,fileImages);
    else
        img_name = strcat(pathImages,fileImages{i});
    end
    
    im = imread(img_name);
    imDouble = im2double(im);
    imGray = mat2gray(imDouble);
    
    tumor = tumors{i};
    tumorImage = imGray(tumor);
    
    tumorPixels = cat(1,tumorPixels,tumorImage(:));
    
end

statsTumor.mean = mean(tumorPixels);
statsTumor.std = std(tumorPixels);


