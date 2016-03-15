function [textureIm time] = RunlengthTexture(im,descriptor)

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

        glrlm = grayrlmatrix(window,'GrayLimits',[0 1],'NumLevels',16);
        glrlm = round((glrlm{1} + glrlm{2} + glrlm{3} + glrlm{4})/4);
        
        if(strcmp(descriptor,'SRE'))
            stats = grayrlprops(glrlm,descriptor);
            descriptorVal = stats.SRE;
        elseif(strcmp(descriptor,'LRE'))
            stats = grayrlprops(glrlm,descriptor);
            descriptorVal = stats.LRE;
        elseif(strcmp(descriptor,'GLN'))
            stats = grayrlprops(glrlm,descriptor);
            descriptorVal = stats.GLN;  
        elseif(strcmp(descriptor,'RLN'))
            stats = grayrlprops(glrlm,descriptor);
            descriptorVal = stats.RLN;
        elseif(strcmp(descriptor,'RP'))
            stats = grayrlprops(glrlm,descriptor);
            descriptorVal = stats.RP;
        elseif(strcmp(descriptor,'LGRE'))
            stats = grayrlprops(glrlm,descriptor);
            descriptorVal = stats.LGRE;
        elseif(strcmp(descriptor,'HGRE'))
            stats = grayrlprops(glrlm,descriptor);
            descriptorVal = stats.HGRE;
        elseif(strcmp(descriptor,'SRLGE'))
            stats = grayrlprops(glrlm,descriptor);
            descriptorVal = stats.SRLGE;
        elseif(strcmp(descriptor,'SRHGE'))
            stats = grayrlprops(glrlm,descriptor);
            descriptorVal = stats.SRHGE;
        elseif(strcmp(descriptor,'LRLGE'))
            stats = grayrlprops(glrlm,descriptor);
            descriptorVal = stats.LRLGE;
        elseif(strcmp(descriptor,'LRHGE'))
            stats = grayrlprops(glrlm,descriptor);
            descriptorVal = stats.LRHGE;
        end
      
       textureIm(m-r,n-r) = descriptorVal;
        
    end
end
time = toc;

textureIm = mat2gray(textureIm);
