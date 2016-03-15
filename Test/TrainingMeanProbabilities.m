function [meanTumorIntensityProbability meanTumorTextureProbability] = TrainingMeanProbabilities(images,tumors,descriptor)

tumorIntensityProb = zeros(256,1);
tumorTextureProb = zeros(256,1);

%%%%% Segmenting and processing Images %%%%%%%%%%%%%

[nImages wtv] = size(images); 

tumorTotalPixels = 0;
tumorSizes = zeros(nImages,1);

tumorIntensityProbabilities = cell(nImages,1);
tumorTextureProbabilities = cell(nImages,1);

for i=1:nImages

    imGray = images{i};

    [imIntensity timeIntensity(i)] = IntensityProcessing(imGray,'Completo');
    [imTexture timeTexture(i)] = RunlengthTexture(imGray,descriptor);

    tumor = tumors{i};
    tumorSize = size(tumor);
    
    tumorSizes(i) = tumorSize(1);
    tumorTotalPixels = tumorTotalPixels + tumorSize(1);
   
    tumorIntensityImage = imIntensity(tumor);
    tumorIntensityProbability = imhist(tumorIntensityImage)/tumorSize(1);
    
    tumorIntensityProbabilities{i} = tumorIntensityProbability; 
    
    tumorTextureImage = imTexture(tumor);
    tumorTextureProbability = imhist(tumorTextureImage)/tumorSize(1);
    
    tumorTextureProbabilities{i} = tumorTextureProbability; 
    
end

meanTumorIntensityProbability = 0;
meanTumorTextureProbability = 0;

for j=1:nImages
    
   wTumor = tumorSizes(j)/tumorTotalPixels;
   
   wTumorIntensityProbability = wTumor*tumorIntensityProbabilities{j};
   meanTumorIntensityProbability = meanTumorIntensityProbability + wTumorIntensityProbability;
   
   wTumorTextureProbability = wTumor*tumorTextureProbabilities{j};
   meanTumorTextureProbability = meanTumorTextureProbability + wTumorTextureProbability;
   
end





