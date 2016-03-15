function [probabilityImage time] = ProbabilityClassifierNormal(imIntensity,intensityProbs,descriptor)

tumorIntensityPdf = intensityProbs;

probabilityImage = zeros(size(imIntensity));

tic
for i=1:numel(imIntensity)
    
    imageFeatures = [imIntensity(i)];
    imageFeatures = round(imageFeatures*255 + 1);
    
    tumorIntensityProbability = tumorIntensityPdf(imageFeatures(1));
    
    tumorProbability = tumorIntensityProbability;
    
    if(strcmp(descriptor,'Probabilidad'))
        probabilityImage(i) = tumorProbability;
    elseif(strcmp(descriptor,'Clasificacion'))
     
    end
    
end
time = toc;

probabilityImage = mat2gray(probabilityImage);
