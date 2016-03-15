function [out] = TestNormalDescriptor(descriptor)

if(nargin<1)
    descriptor = 'Normal';
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

%savePath = 'C:/Users/Public/Documents/Breast Tumor Segmentation/Tumor Segmentation Matlab/Resultados/Homogeneous';

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

for i=1:nImages
    
    if ischar(fileImages)
        img_name = strcat(pathImages,fileImages);
    else
        img_name = strcat(pathImages,fileImages{i});
    end
    
    im = imread(img_name);
    imDouble = im2double(im);
    imGray = mat2gray(imDouble);
        
    %imwrite(imGray,strcat(savePath,'/Imagenes/Normal/',descriptor,'/',fileImages{i}(1:end-4),'_',descriptor,'.bmp'));    
    
    tumor = tumors{i};
    tumorSize = size(tumor);
    
    tumorSizes(i) = tumorSize(1);
    tumorTotalPixels = tumorTotalPixels + tumorSize(1);
   
    tumorImage = imGray(tumor);
    tumorProbability = imhist(tumorImage)/tumorSize(1);
    
    tumorImages{i} = tumorImage;
    tumorProbabilities{i} = tumorProbability; 
    
    background = backgrounds{i};
    backgroundSize = size(background);
    
    backgroundSizes(i) = backgroundSize(1);
    backgroundTotalPixels = backgroundTotalPixels + backgroundSize(1);
   
    backgroundImage = imGray(background);
    backgroundProbability = imhist(backgroundImage)/backgroundSize(1);
    
    backgroundImages{i} = backgroundImage;
    backgroundProbabilities{i} = backgroundProbability;
    
    tumorImageMean = mean(tumorImage);
    backgroundImageMean = mean(backgroundImage);
   
    tumorImageStd = std(tumorImage);
    backgroundImageStd = std(backgroundImage);
   
    SNR(i) = tumorImageMean/tumorImageStd
    CNR(i) = abs(tumorImageMean-backgroundImageMean)/(tumorImageStd+backgroundImageStd)
    
    DM(i) = sum(abs(tumorProbability-backgroundProbability));
    INT(i) = sum(min(tumorProbability,backgroundProbability));
    
end

out.meanSNR = mean(SNR);
out.meanCNR = mean(CNR);

out.stdSNR = std(SNR);
out.stdCNR = std(CNR);

out.meanDM = mean(DM);
out.meanINT = mean(INT);

out.stdDM = std(DM);
out.stdINT = std(INT);

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

save(strcat(savePath,'/Probabilidades/Normal/',descriptor,'/','tumor_',descriptor,'.mat'),'meanTumorProbability');
save(strcat(savePath,'/Probabilidades/Normal/',descriptor,'/','background_',descriptor,'.mat'),'meanTumorProbability');

graf = figure;

xlabel('Gray level'), ylabel('Probability'), title('Probability'), legend('Tumor','Background');
xlim([0 256]);
hold on;
    plot(smooth(meanTumorProbability),'-b');
    plot(smooth(meanBackgroundProbability),'-r');
hold off;
legend('Tumor','Background');


print (graf, '-dbmp', strcat(savePath,'/Graficas/Normal/',descriptor,'/','Probabilidad_',descriptor,'.bmp')); 


