function check = CheckTumorSegmentation();

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
    
    imSegmented = imGray;
    imSegmented(tumor) = 1;
    
    figure, imshow(imSegmented)

 end

 check = 1;


