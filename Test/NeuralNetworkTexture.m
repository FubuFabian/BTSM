function probabilityImage = NeuralNetworkNormal(imIntensity,imTexture,net)

intensityInputs = imIntensity(:)';
textureInputs = imTexture(:)';

inputs = [intensityInputs; textureInputs];

outputs = net(inputs);
probabilityImage = vec2mat(outputs,size(imIntensity,1))';


