function [borders imRG] = BreastTumorSegmentation(im,intensityProbs,textureProbs,descriptor)

imGray = mat2gray(im);

[imIntensity timeIntensity] = IntensityProcessing(imGray,'Completo');
[imTexture timeTexture] = RunlengthTexture(imGray,descriptor);
[imProb timeProb] = ProbabilityClassifier(imIntensity,imTexture,intensityProbs,textureProbs,'Probabilidad');
[borders imRG seedPoint timeRG] = RegionGrowing(imProb,1,.6);

 
