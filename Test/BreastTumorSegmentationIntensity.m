function [borders imRG] = BreastTumorSegmentationIntensity(im,intensityProbs)

imGray = mat2gray(im);

[imIntensity timeIntensity] = IntensityProcessing(imGray,'Completo');

[imProb timeProb] = ProbabilityClassifierIntensity(imIntensity,intensityProbs,'Probabilidad');
[borders imRG seedPoint timeRG] = RegionGrowing(imProb,1,.6);

 
