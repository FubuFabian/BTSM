function [filterImage time] = EdgeProcessing(im,descriptor,seed)

imGray = mat2gray(im);

[nRen nCol] = size(imGray);

tic;
        
imEq = histeq(imGray);
imEq = mat2gray(imEq);
imDiff = SRAD3D(imEq,25,1);
imDiff = mat2gray(imDiff);  

imDiff = imGray;

if(strcmp(descriptor,'Log'))
    
    ws = 17;
    pad = floor(ws/2);
    
    imDiff = padarray(imDiff,[pad pad],'symmetric');
    
    h = fspecial('log',ws,10);
    filterImage = imfilter(imDiff,h);
    
    filterImage = imcrop(filterImage,[pad+1 pad+1 nCol-1 nRen-1]);

    
elseif(strcmp(descriptor,'Sobel'))
    
    ws = 3;
    pad = floor(ws/2);
    
    imDiff = padarray(imDiff,[pad pad],'symmetric');
    
    h = fspecial('sobel');
    
    filterImageY1 = imfilter(imDiff,h);
    filterImageY2 = imfilter(imDiff,flipud(h));
    
    filterImageX1 = imfilter(imDiff,h');
    filterImageX2 = imfilter(imDiff,fliplr(h'));
    
    filterImageY = max(filterImageY1,filterImageY2);
    filterImageX = max(filterImageX1,filterImageX2);
    
    filterImage = sqrt(filterImageX.^2 + filterImageY.^2);
    
    filterImage = imcrop(filterImage,[pad+1 pad+1 nCol-1 nRen-1]);

elseif(strcmp(descriptor,'Gradiente'))
    
    filterImage = DirectionalGradientImage(imDiff,seed);
      
end

filterImage = mat2gray(filterImage);

time = toc;
