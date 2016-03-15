function [out] = TestProbabilityClassifier(descriptor)

out = struct;

if(nargin<1)
    descriptor = 'Probabilidad';
end

[fileImages, pathImages, wtv] = uigetfile('*.bmp','Load Images','MultiSelect', 'on');

if ischar(fileImages)
    nImages = 1;
else
    [wtv nImages] = size(fileImages);
end

[fileTumors, pathTumors, wtv] = uigetfile('*.mat','Load Tumor Segmentation');

tumorsFilename = strcat(pathTumors,fileTumors);
 
tumors = load(tumorsFilename);
tumors = tumors.tumors;
 
[fileBackgrounds, pathBackgrounds, wtv] = uigetfile('*.mat','Load Background Segmentation');

backgroundsFilename = strcat(pathBackgrounds,fileBackgrounds);
 
backgrounds = load(backgroundsFilename);
backgrounds = backgrounds.backgrounds;

[fileIntensityProbs, pathIntensityProbs, wtv] = uigetfile('*.mat','Load Intensity Probs Stats');

intensityProbsFilename = strcat(pathIntensityProbs,fileIntensityProbs);
 
intensityProbs = load(intensityProbsFilename);
intensityProbs = intensityProbs.ProbabilidadesIntensidad;

[fileTextureProbs, pathTextureProbs, wtv] = uigetfile('*.mat','Load Texture Probs Stats');

textureProbsFilename = strcat(pathTextureProbs,fileTextureProbs);
 
textureProbs = load(textureProbsFilename);
textureProbs = textureProbs.ProbabilidadesTextura;

timeIntensity = zeros(nImages,1);
timeTexture = zeros(nImages,1);
timeClassifier = zeros(nImages,1);

savePath = 'C:/Users/Fubu/Documents/TumorSegmentation/Pruebas/Resultados/Fantasmas';

tumorTotalPixels = 0;
backgroundTotalPixels = 0;

tumorSizes = zeros(nImages,1);
backgroundSizes = zeros(nImages,1);

tumorProbabilities = cell(nImages,1);
backgroundProbabilities = cell(nImages,1);

classifiedTumors = cell(nImages,1);

for i=1:nImages
    
    if ischar(fileImages)
        img_name = strcat(pathImages,fileImages);
    else
        img_name = strcat(pathImages,fileImages{i});
    end
    
    im = imread(img_name);
    imDouble = im2double(im);
    imGray = mat2gray(imDouble);
    imGray = rgb2gray(imGray);
    
    [imIntensity timeIntensity(i)] = IntensityProcessing(imGray,'Completo');
    [imTexture timeTexture(i)] = HistogramTexture(imGray,'Media');
    
    [imProbabilidad timeClassifier(i)] = ProbabilityClassifier(imIntensity,imTexture,intensityProbs,textureProbs,descriptor);

    imwrite(imProbabilidad,strcat(savePath,'/Imagenes/Probabilidad/',descriptor,'/',fileImages{i}(1:end-4),'_',descriptor,'.bmp'));    
    
    tumor = tumors{i};
    tumorSize = size(tumor);
    
    if(strcmp(descriptor,'Probabilidad'))
    
        tumorSizes(i) = tumorSize(1);
        tumorTotalPixels = tumorTotalPixels + tumorSize(1);
   
        tumorImage = imProbabilidad(tumor);
        tumorProbability = imhist(tumorImage)/tumorSize(1);
    
        tumorProbabilities{i} = tumorProbability; 
    
        background = backgrounds{i};
        backgroundSize = size(background);
    
        backgroundSizes(i) = backgroundSize(1);
        backgroundTotalPixels = backgroundTotalPixels + backgroundSize(1);
   
        backgroundImage = imProbabilidad(background);
        backgroundProbability = imhist(backgroundImage)/backgroundSize(1);
    
        backgroundProbabilities{i} = backgroundProbability;
        
    elseif(strcmp(descriptor,'Clasificacion'))
        
        classifiedTumors{i} = find(imProbabilidad);
        
    end
end

time = timeIntensity+timeTexture+timeClassifier;
out.meanTime = mean(time);

if(strcmp(descriptor,'Probabilidad'))

    meanTumorProbability = 0;
    meanBackgroundProbability = 0;

    for j=1:nImages
    
        wTumor = tumorSizes(j)/tumorTotalPixels;
        wTumorProbability = wTumor*tumorProbabilities{j};
   
        meanTumorProbability = meanTumorProbability + wTumorProbability;
   
        wBackground = backgroundSizes(j)/backgroundTotalPixels;
        wBackgroundProbability = wBackground*backgroundProbabilities{j};
   
        meanBackgroundProbability = meanBackgroundProbability + wBackgroundProbability;
    
    end

    greylevels = 1:256;
    
    %%%standard = std(greylevels*meanTumorProbability)
    
    tumorProbabilityMean = sum(greylevels*meanTumorProbability);
    backgroundProbabilityMean = sum(greylevels*meanBackgroundProbability);

    out.meanDistance = abs(tumorProbabilityMean - backgroundProbabilityMean);

    minProbability = min(meanTumorProbability,meanBackgroundProbability);
    out.intersection = sum(minProbability);

    save(strcat(savePath,'/Probabilidades/Probabilidad/',descriptor,'/','tumor_',descriptor,'.mat'),'meanTumorProbability');
    save(strcat(savePath,'/Probabilidades/Probabilidad/',descriptor,'/','background_',descriptor,'.mat'),'meanBackgroundProbability');

    graf = figure;
    hold on
        plot(smooth(meanTumorProbability),'-b')
        plot(smooth(meanBackgroundProbability),'-r')
    hold off
    xlabel('Gray level'), ylabel('Probability'), title('Probability'), legend('Tumor','Background');
    xlim([0 256]);
    
    legend('Tumor','Background');


    print (graf, '-dbmp', strcat(savePath,'/Graficas/Probabilidad/',descriptor,'/','Probabilidad_',descriptor,'.bmp')) 

elseif(strcmp(descriptor,'Clasificacion'))
    
    intersection = zeros(nImages,1);
    noise = zeros(nImages,1);
    TP = zeros(nImages,1); 
    FP = zeros(nImages,1); 
    FN = zeros(nImages,1); 


    for j=1:nImages
  
        tumorSize = size(tumors{j},1);
        classifiedTumorSize = size(classifiedTumors{j},1);
    
        tumorIntersection = intersect(tumors{j},classifiedTumors{j}); 
        tumorIntersectionSize = size(tumorIntersection,1);
    
        tumorUnion = union(tumors{j},classifiedTumors{j});
        tumorUnionSize = size(tumorUnion,1);
    
        intersection(j) = tumorIntersectionSize/classifiedTumorSize;
        noise(j) = abs(classifiedTumorSize-tumorIntersectionSize)/classifiedTumorSize;
    
        TP(j) = tumorIntersectionSize/tumorSize;
        FP(j) = abs(tumorUnionSize - tumorSize)/tumorSize;
        FN(j) = abs(tumorUnionSize - classifiedTumorSize)/tumorSize; 
    
    end

    out.meanIntersection = mean(intersection);
    out.meanNoise = mean(noise);
    out.meanTP = mean(TP);
    out.meanFN = mean(FN);
    out.meanFP = mean(FP);

    h = figure,

    pie([out.meanFN out.meanTP]);
    hText = findobj(h,'Type','text');
    percentValues = get(hText,'String');
    str = {'True Positive: ';'FalsePositive: '};
    combinedstrings = strcat(str,percentValues);
    oldExtents_cell = get(hText,'Extent');
    oldExtents = cell2mat(oldExtents_cell);
    set(hText,{'String'},combinedstrings);
    newExtents_cell = get(hText,'Extent'); 
    newExtents = cell2mat(newExtents_cell); 
    width_change = newExtents(:,3)-oldExtents(:,3);
    signValues = sign(oldExtents(:,1));
    offset = signValues.*(width_change/2);
    textPositions_cell = get(hText,{'Position'});
    textPositions = cell2mat(textPositions_cell); 
    textPositions(:,1) = textPositions(:,1) + offset;
    set(hText,{'Position'},num2cell(textPositions,[3,2]));

    print (h, '-dbmp', strcat(savePath,'/Graficas/Probabilidad/',descriptor,'/','Probabilidad_',descriptor,'.bmp'))
    
end