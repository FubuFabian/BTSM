function probabilityImage = NeuralNetworkNormal(imIntensity,net)

inputs = imIntensity(:)';
outputs = net(inputs);
probabilityImage = vec2mat(outputs,size(imIntensity,1))';


