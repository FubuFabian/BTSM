function [out] = TestEdgeProcessing(descriptor)

out = struct;

if(nargin<1)
    descriptor = 'Gradiente';
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
    
[fileIntensityProbs, pathIntensityProbs, wtv] = uigetfile('*.mat','Load Intensity Probs Stats');

intensityProbsFilename = strcat(pathIntensityProbs,fileIntensityProbs);
 
intensityProbs = load(intensityProbsFilename);
intensityProbs = intensityProbs.ProbabilidadesIntensidad;

[fileTextureProbs, pathTextureProbs, wtv] = uigetfile('*.mat','Load Texture Probs Stats');

textureProbsFilename = strcat(pathTextureProbs,fileTextureProbs);
 
textureProbs = load(textureProbsFilename);
textureProbs = textureProbs.ProbabilidadesTextura;

time = zeros(nImages,1);

savePath = 'C:/Users/Fubu/Documents/TumorSegmentation/Pruebas/Resultados/Fantasmas';

segmentedTumors = cell(nImages,1);

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
    [imProb timeProb(i)] = ProbabilityClassifier(imIntensity,imTexture,intensityProbs,textureProbs,'Probabilidad');
    %[imProbClas timeProb(i)] = ProbabilityClassifier(imIntensity,imTexture,intensityProbs,textureProbs,'Clasificacion');
    [imRG seedPoint timeRG(i)] = RegionGrowing(imProb,1,.8);
    
    [imEdge timeEdge(i)] = EdgeProcessing(imGray,descriptor,seedPoint);
    
    imwrite(imEdge,strcat(savePath,'/Imagenes/Bordes/',descriptor,'/Filtro/',fileImages{i}(1:end-4),'_',descriptor,'10_17.bmp'));    
   
    imRGBorders = RayCastBordersClas(imRG,seedPoint,1);
    
    imwrite(imRGBorders,strcat(savePath,'/Imagenes/Bordes/',descriptor,'/Bordes/Clasificacion/',fileImages{i}(1:end-4),'_',descriptor,'10_17.bmp'));
    
    imFilterBorders = RayCastBordersFilt(imEdge,seedPoint,1);
    
    imwrite(imFilterBorders,strcat(savePath,'/Imagenes/Bordes/',descriptor,'/Bordes/Filtro/',fileImages{i}(1:end-4),'_',descriptor,'10_17.bmp'));
    
    [imFilterOutliers timeOut(i)]  = RemoveOutliers(imRGBorders,imFilterBorders,seedPoint);
    
    imwrite(imFilterOutliers,strcat(savePath,'/Imagenes/Bordes/',descriptor,'/Bordes/FiltroOut/',fileImages{i}(1:end-4),'_',descriptor,'10_17.bmp'));
     
    [imSegmentedTumor timeSeg(i)] = SegmentedTumorMask(imRGBorders,imFilterOutliers);
    
    tumor = tumors{i};
    segmentedTumors{i} = find(imSegmentedTumor);
  
    imTumor = zeros(size(imGray));
    imTumor(tumor) = 1;
    
    imTumorEdge = edge(imTumor,'sobel');
    tumorEdge = find(imTumorEdge);
    
    imSegmentedTumorEdge = edge(imSegmentedTumor,'sobel');
    segmentedTumorEdge = find(imSegmentedTumorEdge);
    
    imwrite(imSegmentedTumorEdge,strcat(savePath,'/Imagenes/Bordes/',descriptor,'/Bordes/Completo/',fileImages{i}(1:end-4),'_',descriptor,'10_17.bmp'));
   
    tumorEdgeImage = imGray;
    segmentedTumorEdgeImage = imGray;
       
    tumorEdgeImage(tumorEdge) = 1;
    segmentedTumorEdgeImage(segmentedTumorEdge) = 1;
    
    imwrite(tumorEdgeImage,strcat(savePath,'/Imagenes/Bordes/',descriptor,'/Bordes/Mix/',fileImages{i}(1:end-4),'_',descriptor,'_Man10_17.bmp'));
    imwrite(segmentedTumorEdgeImage,strcat(savePath,'/Imagenes/Bordes/',descriptor,'/Bordes/Mix/',fileImages{i}(1:end-4),'_',descriptor,'_Proc10_17.bmp'));
    
end

time = timeIntensity+timeTexture+timeProb+timeRG+timeEdge+timeOut+timeSeg;
out.meanTime = mean(time);

intersection = zeros(nImages,1);
noise = zeros(nImages,1);
TP = zeros(nImages,1); 
FP = zeros(nImages,1); 
FN = zeros(nImages,1); 


for j=1:nImages
  
    tumorSize = size(tumors{j},1);
    segmentedTumorSize = size(segmentedTumors{j},1);
    
    tumorIntersection = intersect(tumors{j},segmentedTumors{j}); 
    tumorIntersectionSize = size(tumorIntersection,1);

    tumorUnion = union(tumors{j},segmentedTumors{j});
    tumorUnionSize = size(tumorUnion,1);
    
    intersection(j) = tumorIntersectionSize/segmentedTumorSize;
    noise(j) = abs(segmentedTumorSize-tumorIntersectionSize)/segmentedTumorSize;
    
    TP(j) = tumorIntersectionSize/tumorSize;
    FP(j) = abs(tumorUnionSize - tumorSize)/tumorSize;
    FN(j) = abs(tumorUnionSize - segmentedTumorSize)/tumorSize; 
    
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

print (h, '-dbmp', strcat(savePath,'/Graficas/Bordes/',descriptor,'/','Bordes_',descriptor,'10_17.bmp'))
    