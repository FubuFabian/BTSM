function [textureIm time] = HaralickTexture(im,descriptor)

imGray = mat2gray(im);
[ren col] = size(imGray);

textureIm = zeros(ren,col);

r = 6;     % Adjust for desired window size

M = ren+2*r;
N = col+2*r;

imPad = padarray(imGray,[r r],'symmetric');

offsets = [[0 -1 -1 -1]' , [1 1 -1 -1]'];

tic;
for n = 1+r:N-r
    for m = 1+r:M-r
        
        window = imPad(m+(-r:r),n+(-r:r));

        glcm = graycomatrix(window,'GrayLimits',[0 1],'NumLevels',16,'Offset',offsets);
        glcm = round((glcm(:,:,1) + glcm(:,:,2) + glcm(:,:,3) + glcm(:,:,4))/4);
        
        if(strcmp(descriptor,'Variance'))
            descriptorVal = var(glcm(:));
        elseif(strcmp(descriptor,'Contrast'))
            stats = graycoprops(glcm,descriptor);
            descriptorVal = stats.Contrast;
        elseif(strcmp(descriptor,'Correlation'))
            stats = graycoprops(glcm,descriptor);
            descriptorVal = stats.Correlation;
        elseif(strcmp(descriptor,'Energy'))
            stats = graycoprops(glcm,descriptor);
            descriptorVal = stats.Energy;
        elseif(strcmp(descriptor,'Homogeneity'))
            stats = graycoprops(glcm,descriptor);
            descriptorVal = stats.Homogeneity;
        end
        
        textureIm(m-r,n-r) = descriptorVal;
        
    end
end
time = toc;

textureIm = mat2gray(textureIm);
