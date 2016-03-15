function [out] = TestRegionGrowing(descriptor)

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

if(strcmp(descriptor,'Probabilidad'))
    
    [fileIntensityProbs, pathIntensityProbs, wtv] = uigetfile('*.mat','Load Intensity Probs Stats');

    intensityProbsFilename = strcat(pathIntensityProbs,fileIntensityProbs);
 
    intensityProbs = load(intensityProbsFilename);
    intensityProbs = intensityProbs.ProbabilidadesIntensidad;

    [fileTextureProbs, pathTextureProbs, wtv] = uigetfile('*.mat','Load Texture Probs Stats');

    textureProbsFilename = strcat(pathTextureProbs,fileTextureProbs);
 
    textureProbs = load(textureProbsFilename);
    textureProbs = textureProbs.ProbabilidadesTextura;

elseif(strcmp(descriptor,'Bayes'))
    
    [fileBayesStats, pathBayesStats, wtv] = uigetfile('*.mat','Load Bayes Stats');

    bayesFilename = strcat(pathBayesStats,fileBayesStats);
 
    stats = load(bayesFilename);
    stats = stats.stats;
    
end

timeIntensity = zeros(nImages,1);
timeTexture = zeros(nImages,1);
timeProb = zeros(nImages,1);
timeRG = zeros(nImages,1);

savePath = 'C:/Users/Fubu/Documents/TumorSegmentation/Pruebas/Resultados/Fantasmas';

classifiedTumors = cell(nImages,1);
seedIdx = cell(nImages,1);
tumorEdge = cell(nImages,1);

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
    
    if(strcmp(descriptor,'Probabilidad'))
        [imProb timeProb(i)] = ProbabilityClassifier(imIntensity,imTexture,intensityProbs,textureProbs,'Probabilidad');
    elseif(strcmp(descriptor,'Bayes'))
        [imProb timeProb(i)] = BayesClassifier(imIntensity,imTexture,stats,'Probabilidad');
    end

    [imRG seedPoint timeRG(i)] = RegionGrowing(imProb,1,.6);
    
    imwrite(imRG,strcat(savePath,'/Imagenes/Crecimiento/',descriptor,'/Clasificacion/',fileImages{i}(1:end-4),'_',descriptor,'.bmp'));
    
    imSeed = imGray;
    imSeed(seedPoint.y,seedPoint.x) = 1;
    
    tumor = tumors{i};
    
    imTumor = zeros(size(imGray));
    imTumor(tumor) = 1;
    
    imTumorEdge = edge(imTumor,'sobel');
    tumorEdge{i} = find(imTumorEdge);
    
    imSeed(tumorEdge{i}) = 1;
    
    imwrite(imSeed,strcat(savePath,'/Imagenes/Crecimiento/',descriptor,'/Semilla/',fileImages{i}(1:end-4),'_',descriptor,'.bmp'));
    
    seedIdx{i} = sub2ind(size(imGray),seedPoint.y,seedPoint.x);
         
    classifiedTumors{i} = find(imRG);
    
end

out.seedIdx = seedIdx;

time = timeIntensity+timeTexture++timeProb+timeRG;
out.meanTime = mean(time);

seedInside = zeros(nImages,1);

for k=1:nImages
    
    if(find(tumors{k}==seedIdx{k}))
        seedInside(k) = 1;
    end
    
end

nSeedsInside = size(find(seedInside),1);
nSeedsOutside = (nImages - nSeedsInside);

nSeedsInside = nSeedsInside/nImages;
nSeedsOutside = nSeedsOutside/nImages;

out.seedsInside = seedInside;

h = figure,

pie([nSeedsOutside nSeedsInside]);
hText = findobj(h,'Type','text');
percentValues = get(hText,'String');
str = {'Dentro: ';'Fuera: '};
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

print (h, '-dbmp', strcat(savePath,'/Graficas/Crecimiento/',descriptor,'/Semilla/','Semilla_',descriptor,'.bmp'))

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

print (h, '-dbmp', strcat(savePath,'/Graficas/Crecimiento/',descriptor,'/Clasificacion','Crecieminto_',descriptor,'.bmp'))
    