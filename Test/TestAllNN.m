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
imagesIntensity = cell(nImages,1);
imagesTexture = cell(nImages,1);

pathIntensityImages = 'C:/Users/Public/Documents/Breast Tumor Segmentation/Tumor Segmentation Matlab/Resultados/Homogeneous/Imagenes/Intensidad/';
%pathTextureImages = 'C:/Users/Public/Documents/Breast Tumor Segmentation/Tumor Segmentation Matlab/Resultados/Homogeneous/Imagenes/RunLength/';

for j=1:3
    
    switch j
        case 1 
            descriptor = 'Completo';
        case 2 
            descriptor = 'Filtro';
        case 3 
            descriptor = 'Ecualizacion';
    end
    
    for i=1:nImages
       img_name = strcat(pathImages,fileImages{i});    
       
       imageFileName = strsplit(fileImages{i},'.');
       intensity_name = strcat(pathIntensityImages,descriptor,'/',imageFileName{1},'_',descriptor,'.bmp');
       %texture_name = strcat(pathTextureImages,descriptor,'/',imageFileName{1},'_',descriptor,'.bmp');
       
       
       imGray = imread(img_name);
       imGray = mat2gray(imGray);
       imIntensity = imread(intensity_name);
       imIntensity = mat2gray(imIntensity);
       %imTexture = imread(texture_name);
       %imTexture = mat2gray(imTexture);
       
       images{i} = imGray;
       imagesIntensity{i} = imIntensity;
       %imagesTexture{i} = imTexture;
    end
    
    descriptor
    out = TestIntensityNN(imagesIntensity,tumors)
 
end