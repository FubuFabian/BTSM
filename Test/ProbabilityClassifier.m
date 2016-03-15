function [probabilityImage time] = ProbabilityClassifier(imIntensity,imTexture,intensityProbs,textureProbs,descriptor)

tumorIntensityPdf = intensityProbs;

tumorTexturePdf = textureProbs;

probabilityImage = zeros(size(imIntensity));

tic
for i=1:numel(imIntensity)
    
    imageFeatures = [imIntensity(i); imTexture(i)];
    imageFeatures = round(imageFeatures*255 + 1);
    
    tumorIntensityProbability = tumorIntensityPdf(imageFeatures(1));
    tumorTextureProbability = tumorTexturePdf(imageFeatures(2));
    
    tumorProbability = tumorIntensityProbability*tumorTextureProbability;
    
    if(strcmp(descriptor,'Probabilidad'))
        probabilityImage(i) = tumorProbability;
    elseif(strcmp(descriptor,'Clasificacion'))
     
    end
    
end
time = toc;

probabilityImage = mat2gray(probabilityImage);