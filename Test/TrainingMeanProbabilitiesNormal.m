function [meanTumorIntensityProbability] = TrainingMeanProbabilitiesNormal(images,tumors)


%%%%% Segmenting and processing Images %%%%%%%%%%%%%

[nImages wtv] = size(images); 

tumorTotalPixels = 0;
tumorSizes = zeros(nImages,1);

tumorIntensityProbabilities = cell(nImages,1);

for i=1:nImages

    imGray = images{i};

    tumor = tumors{i};
    tumorSize = size(tumor);
    
    tumorSizes(i) = tumorSize(1);
    tumorTotalPixels = tumorTotalPixels + tumorSize(1);
   
    tumorIntensityImage = imGray(tumor);
    tumorIntensityProbability = imhist(tumorIntensityImage)/tumorSize(1);
    
    tumorIntensityProbabilities{i} = tumorIntensityProbability; 
    
end

meanTumorIntensityProbability = 0;

for j=1:nImages
    
   wTumor = tumorSizes(j)/tumorTotalPixels;
   
   wTumorIntensityProbability = wTumor*tumorIntensityProbabilities{j};
   meanTumorIntensityProbability = meanTumorIntensityProbability + wTumorIntensityProbability;
   
end





