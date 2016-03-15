function net = TrainingNeuralNetworkIntensity(images,tumors)

[nImages wtv] = size(images); 

inputs = [];
outputs = [];

for i=1:nImages
    
    im = mat2gray(images{i});
    
    inputPixels = im(:)';
    inputs = horzcat(inputs,inputPixels);
    
    imTumor = zeros(size(im));
    tumorseg = tumors{i};
    imTumor(tumorseg) = 1;
    
    outputPixels = imTumor(:)';
    outputs = horzcat(outputs,outputPixels);

end

setdemorandstream(491218382)
net = patternnet(10);
net.trainFcn = 'trainbfg';
net.trainParam.epochs = 100;
net.trainParam.min_grad = 1e-4;
net.trainParam.showWindow = 0;
[net,tr] = train(net,inputs,outputs);






