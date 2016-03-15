function [bayesImage time] = BayesClassifier(imIntensity,imTexture,stats,descriptor)

pTumor = stats.pTumor;
covTumor = stats.covTumor;
eTumor = stats.eTumor;

pBackground = stats.pBackground;
covBackground = stats.covBackground;
eBackground = stats.eBackground;

bayesImage = zeros(size(imIntensity));

tic
for i=1:numel(imIntensity)
    
    imageFeatures = [imIntensity(i); imTexture(i)];
    
    cTumor = (-(imageFeatures-eTumor)'*inv(covTumor)*(imageFeatures-eTumor))/2 -log(det(covTumor))/2 + log(pTumor);
    
    if(strcmp(descriptor,'Probabilidad'))
        bayesImage(i) = cTumor;
    elseif(strcmp(descriptor,'Clasificacion'))
    
        cBackground = (-(imageFeatures-eBackground)'*inv(covBackground)*(imageFeatures-eBackground))/2 -log(det(covBackground))/2 + log(pBackground);
    
        if(cTumor>=cBackground)
            bayesImage(i) = 1;
        end
    end
    
end
time = toc;

bayesImage = mat2gray(bayesImage);
        
    
    