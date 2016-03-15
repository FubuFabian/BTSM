function [borders imRG] = BreastTumorSegmentationNNNormal(im,net)

imGray = mat2gray(im);

imProb = NeuralNetworkNormal(imGray,net);
[borders imRG seedPoint timeRG] = RegionGrowing(imProb,1,.6);

 
