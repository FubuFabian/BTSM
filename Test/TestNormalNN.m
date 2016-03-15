function out = TestNormalNN(images,tumors)

[nImages wtv] = size(images);

accuracy = zeros(nImages,1);
sensibility = zeros(nImages,1);
specificity = zeros(nImages,1);
PPV = zeros(nImages,1);
NPV = zeros(nImages,1);

for i=1:nImages
    
    trainingImages = images;
    trainingImages(i,:) = [];

    trainingTumors = tumors;
    trainingTumors(i,:) = [];
    
    net = TrainingNeuralNetworkNormal(trainingImages,trainingTumors);
    
    testImage = images{i};
    [segmentedTumorEdge segmentedTumorImage] = BreastTumorSegmentationNNNormal(testImage,net);
    
    testTumor = tumors{i};
    segmentedTumor = find(segmentedTumorImage);
    
    imageSize = numel(testImage);
    manualTumorSize = size(testTumor,1);
    segmentedTumorSize = size(segmentedTumor,1);
    segmentedBackgroundSize = imageSize - segmentedTumorSize;
    
    tumorIntersection = intersect(testTumor,segmentedTumor); 
    tumorIntersectionSize = size(tumorIntersection,1);
    
    tumorUnion = union(testTumor,segmentedTumor);
    tumorUnionSize = size(tumorUnion,1);
    
    TP = tumorIntersectionSize/segmentedTumorSize;
    TN = abs(imageSize - tumorUnionSize)/segmentedBackgroundSize; 
    FP = abs(tumorUnionSize - manualTumorSize)/segmentedTumorSize;
    FN = abs(tumorUnionSize - segmentedTumorSize)/segmentedBackgroundSize; 
    
    accuracy(i) = (TP+TN)/(TP+TN+FP+FN);
    sensibility(i) = TP/(TP+FN);
    specificity(i) = TN/(TN+FP);
    PPV(i) = TP/(TP+FP);
    NPV(i) = TN/(TN+FN);
    
%    statistics(i,:) = [accuracy sensibility specificity PPV NPV];
    
    manualTumorImage = zeros(size(testImage));
    
    manualTumorImage(testTumor) = 1;
    manualTumorEdge = bwboundaries(manualTumorImage);
    manualTumorEdge = manualTumorEdge{1};
    
    figure, imshow(testImage), title('Tumor Borders') 
    hold all
    plot(manualTumorEdge(:,2), manualTumorEdge(:,1), 'LineWidth', 2, 'Color', 'blue')
    plot(segmentedTumorEdge(:,1), segmentedTumorEdge(:,2), 'LineWidth', 2, 'Color', 'red')
    hold off
    
end

out.meanAccuracy =  mean(accuracy);
out.meanSensibility =  mean(sensibility);
out.meanSpecificity =  mean(specificity);
out.meanPPV =  mean(PPV);
out.meanNPV =  mean(NPV);

out.stdAccuracy =  std(accuracy);
out.stdSensibility =  std(sensibility);
out.stdSpecificity =  std(specificity);
out.stdPPV =  std(PPV);
out.stdNPV =  std(NPV);
