function [intensityIm time] = IntensityProcessing(im,descriptor)

imGray = mat2gray(im);
[ren col] = size(imGray);

intensityIm = zeros(ren,col);

tic;
        
if(strcmp(descriptor,'Completo'))
    imEq = histeq(imGray);
    imEq = mat2gray(imEq);
    intensityIm = SRAD3D(imEq,25,1);
elseif(strcmp(descriptor,'Ecualizacion'))
    intensityIm = histeq(imGray);
elseif(strcmp(descriptor,'Filtro'))
    intensityIm = SRAD3D(imGray,25,1);
end

time = toc;

intensityIm = mat2gray(intensityIm);
