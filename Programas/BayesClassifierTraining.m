function stats = BayesClassifierTraining()

stats = struct;

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
 
[fileBackgrounds, pathBackgrounds, wtv] = uigetfile('*.mat','Load Background Segmentation');

backgroundsFilename = strcat(pathBackgrounds,fileBackgrounds);
 
backgrounds = load(backgroundsFilename);
backgrounds = backgrounds.backgrounds;

tumorFeatures = [];
backgroundFeatures = [];

for i=1:nImages
    
    if ischar(fileImages)
        img_name = strcat(pathImages,fileImages);
    else
        img_name = strcat(pathImages,fileImages{i});
    end
    
    im = imread(img_name);
    imDouble = im2double(im);
    imGray = mat2gray(imDouble);
    
    [imIntensity wtv] = IntensityProcessing(imGray,'Completo');
    [imTexture wtv] = HistogramTexture(imGray,'Media');
    
    tumor = tumors{i};
    tumorSize = size(tumor);
  
    for j=1:tumorSize(1)
        tumorFeatures = [ tumorFeatures [imIntensity(tumor(j)); imTexture(tumor(j))] ];
    end
    

    background = backgrounds{i};
    backgroundSize = size(background);
    
    for k=1:backgroundSize(1)
        backgroundFeatures = [ backgroundFeatures [imIntensity(background(k)); imTexture(background(k))] ];
    end
    
end

nPixTumor = size(tumorFeatures);
nPixBackground = size(backgroundFeatures);
nPix = nPixTumor + nPixBackground;

pTumor = nPixTumor(2)/nPix(2);
eTumor = mean(tumorFeatures,2);
covTumor = zeros(2);

for i=1:nPixTumor(2)
    covTumor = covTumor + (tumorFeatures(:,i)-eTumor)*(tumorFeatures(:,i)-eTumor)';    
end

covTumor = covTumor/nPixTumor(2);

stats.pTumor = pTumor;
stats.covTumor = covTumor;
stats.eTumor = eTumor;

pBackground = nPixBackground(2)/nPix(2);
eBackground = mean(backgroundFeatures,2);
covBackground = zeros(2);

for i=1:nPixBackground(2)
    covBackground = covBackground + (backgroundFeatures(:,i)-eBackground)*(backgroundFeatures(:,i)-eBackground)';    
end

covBackground = covBackground/nPixBackground(2);

stats.pBackground = pBackground;
stats.covBackground = covBackground;
stats.eBackground = eBackground;