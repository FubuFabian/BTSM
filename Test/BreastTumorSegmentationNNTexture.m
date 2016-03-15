function [borders imRG] = BreastTumorSegmentationNNTexture(intensityIm,textureIm,net)

imIntensityGray = mat2gray(intensityIm);
imTextureGray = mat2gray(textureIm);

imProb = NeuralNetworkTexture(imIntensityGray,imTextureGray,net);
[borders imRG seedPoint timeRG] = RegionGrowing(imProb,1,.6);

 
