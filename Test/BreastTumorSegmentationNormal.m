function [borders imRG] = BreastTumorSegmentationNormal(im,intensityProbs)

imGray = mat2gray(im);


[imProb timeProb] = ProbabilityClassifierNormal(imGray,intensityProbs,'Probabilidad');
[borders imRG seedPoint timeRG] = RegionGrowing(imProb,1,.6);

 
