function [borders imRG] = BreastTumorSegmentationNNIntensity(imIntensity,net)

imGray = mat2gray(imIntensity);

imProb = NeuralNetworkIntensity(imIntensity,net);
[borders imRG seedPoint timeRG] = RegionGrowing(imProb,1,.6);

 
