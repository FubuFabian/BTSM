function [meanTime stdTime] = RunLengthTime(images,descriptor)

nImages = size(images,1);
times = zeros(nImages,1);

for i=1:nImages
    [wtv times(i)] = RunlengthTexture(images{i},descriptor);
end

meanTime = mean(times);
stdTime = std(times);
    
    