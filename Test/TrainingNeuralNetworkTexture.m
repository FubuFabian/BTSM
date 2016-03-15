function net = TrainingNeuralNetworkTexture(intensityImages,textureImages,tumors)

[nImages wtv] = size(intensityImages); 

intensityInputs = [];
textureInputs = [];
outputs = [];

for i=1:nImages
    
    intensityIm = mat2gray(intensityImages{i});
    textureIm = mat2gray(textureImages{i});
    
    intensityInputPixels = intensityIm(:)';
    intensityInputs = horzcat(intensityInputs,intensityInputPixels);
    
    textureInputPixels = textureIm(:)';
    textureInputs = horzcat(textureInputs,textureInputPixels);
    
    imTumor = zeros(size(intensityIm));
    tumorseg = tumors{i};
    imTumor(tumorseg) = 1;
    
    outputPixels = imTumor(:)';
    outputs = horzcat(outputs,outputPixels);

end

inputs = [intensityInputs; textureInputs];

setdemorandstream(491218382)
net = patternnet(10);
net.trainFcn = 'trainbfg';
net.trainParam.epochs = 100;
net.trainParam.min_grad = 1e-4;
net.trainParam.showWindow = 0;
[net,tr] = train(net,inputs,outputs);






