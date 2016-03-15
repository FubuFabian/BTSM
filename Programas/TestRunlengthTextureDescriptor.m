function [out] = TestRunlengthTextureDescriptor(descriptor)

if(nargin<1)
    descriptor = 'SRE';
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

time = zeros(nImages,1);

savePath = 'C:/Users/Public/Documents/Breast Tumor Segmentation/Tumor Segmentation Matlab/Resultados/Homogeneous';


tumorTotalPixels = 0;
backgroundTotalPixels = 0;

tumorSizes = zeros(nImages,1);
backgroundSizes = zeros(nImages,1);

tumorImages = cell(nImages,1);
backgroundImages = cell(nImages,1);

tumorProbabilities = cell(nImages,1);
backgroundProbabilities = cell(nImages,1);

SNR = zeros(nImages,1);
CNR = zeros(nImages,1);

DM = zeros(nImages,1);
INT = zeros(nImages,1);

EPI = zeros(nImages,1);

for i=1:nImages
    
    if ischar(fileImages)
        img_name = strcat(pathImages,fileImages);
    else
        img_name = strcat(pathImages,fileImages{i});
    end
    
    im = imread(img_name);
    imDouble = im2double(im);
    imGray = mat2gray(imDouble);
    
    [imTexture time(i)] = RunlengthTexture(imGray,descriptor);

    imwrite(imTexture,strcat(savePath,'/Imagenes/RunLength/',descriptor,'/',fileImages{i}(1:end-4),'_',descriptor,'.bmp'));    
    
    tumor = tumors{i};
    tumorSize = size(tumor);
    
    tumorSizes(i) = tumorSize(1);
    tumorTotalPixels = tumorTotalPixels + tumorSize(1);
   
    tumorImage = imTexture(tumor);
    tumorProbability = imhist(tumorImage)/tumorSize(1);
    
    tumorImages{i} = tumorImage;
    tumorProbabilities{i} = tumorProbability; 
    
    background = backgrounds{i};
    backgroundSize = size(background);
    
    backgroundSizes(i) = backgroundSize(1);
    backgroundTotalPixels = backgroundTotalPixels + backgroundSize(1);
   
    backgroundImage = imTexture(background);
    backgroundProbability = imhist(backgroundImage)/backgroundSize(1);
    
    backgroundImages{i} = backgroundImage;
    backgroundProbabilities{i} = backgroundProbability;

    tumorImageMean = mean(tumorImage);
    backgroundImageMean = mean(backgroundImage);
   
    tumorImageStd = std(tumorImage);
    backgroundImageStd = std(backgroundImage);
   
    SNR(i) = tumorImageMean/tumorImageStd;
    CNR(i) = abs(tumorImageMean-backgroundImageMean)/(tumorImageStd+backgroundImageStd);
    
    DM(i) = sum(abs(tumorProbability-backgroundProbability));
    INT(i) = sum(min(tumorProbability,backgroundProbability));
    
    imTumor = zeros(size(imGray));
    imTumor(tumor) = 1;
    
    imTumorEdge = edge(imTumor,'prewitt');
    tumorEdge = find(imTumorEdge);
    
    [tumorEdgeY tumorEdgeX] = ind2sub(size(imTumor),tumorEdge);
    
    epiTempFilter = 0;
    epiTempOriginal = 0;
    
    for k=1:size(tumorEdge,1)
        
        x = tumorEdgeX(k);
        y = tumorEdgeY(k);
        
        if x==1 || x==size(imTumorEdge,2) || y==1 || y==size(imTumorEdge,1)
            continue
        end
        
        epiTempFilter = epiTempFilter + abs(imTexture(y,x)-imTexture(y+1,x-1));
        epiTempOriginal = epiTempOriginal + abs(imGray(y,x)-imGray(y+1,x-1));
        
    end
    
    EPI(i) = epiTempFilter/epiTempOriginal;
    
end

out.meanSNR = mean(SNR);
out.meanCNR = mean(CNR);

out.stdSNR = std(SNR);
out.stdCNR = std(CNR);

out.meanDM = mean(DM);
out.meanINT = mean(INT);

out.stdDM = std(DM);
out.stdINT = std(INT);

out.meanEPI = mean(EPI);

out.stdEPI = std(EPI);

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

save(strcat(savePath,'/Probabilidades/RunLength/',descriptor,'/','tumor_',descriptor,'.mat'),'meanTumorProbability');
save(strcat(savePath,'/Probabilidades/RunLength/',descriptor,'/','background_',descriptor,'.mat'),'meanBackgroundProbability');

graf = figure;

xlabel('Gray level'), ylabel('Probability'), title('Probability'), legend('Tumor','Background');
xlim([0 256]);
hold on
    plot(smooth(meanTumorProbability),'-b')
    plot(smooth(meanBackgroundProbability),'-r')
hold off
legend('Tumor','Background');


print (graf, '-dbmp', strcat(savePath,'/Graficas/RunLength/',descriptor,'/','Probabilidad_',descriptor,'.bmp')) 