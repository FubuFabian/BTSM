function [textureIm time] = HistogramTexture(im,descriptor)

imGray = mat2gray(im);
[ren col] = size(imGray);

textureIm = zeros(ren,col);

r = 6;     % Adjust for desired window size

M = ren+2*r;
N = col+2*r;

imPad = padarray(imGray,[r r],'symmetric');

tic;
for n = 1+r:N-r
    for m = 1+r:M-r
        
        window = imPad(m+(-r:r),n+(-r:r));
        
        if(strcmp(descriptor,'Diferencia'))
            descriptorVal = abs(window(r+1,r+1)-mean(mean(window)));
        elseif(strcmp(descriptor,'Entropia'))
            descriptorVal = entropy(window);
        elseif(strcmp(descriptor,'Kurtosis'))
            hist = imhist(window);
            descriptorVal = kurtosis(hist);
        elseif(strcmp(descriptor,'Skewness'))
            hist = imhist(window);
            descriptorVal = skewness(hist);
        elseif(strcmp(descriptor,'Media'))
            descriptorVal = mean(mean(window));
        elseif(strcmp(descriptor,'Std'))
            hist = imhist(window);
            descriptorVal = std(hist);
        end
        
        textureIm(m-r,n-r) = descriptorVal;
        
    end
end
time = toc;

textureIm = mat2gray(textureIm);
