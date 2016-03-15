function [rgImage seedPoint time] = RegionGrowing(image, upperThresh, lowerThresh)

global wS;
global x;
global y;
global uT;
global lT;
global mat;
global regVal;
global ren;
global col;
global probImage;

probImage = image;

uT = upperThresh;
lT = lowerThresh;

[ren col] = size(probImage);

imCenter = [ren/2 col/2];

mat = zeros([ren col]);
seedImage = zeros([ren col]);

nSize = 7;
r = floor(nSize/2);

M = ren+2*r;
N = col+2*r;

imPad = padarray(probImage,[r r],'symmetric');

tic
for n = 1+r:N-r
    for m = 1+r:M-r
    
        p = probImage(m-r,n-r);        
        window = imPad(m+(-r:r),n+(-r:r));
        j = mean(window(:));
        dy = m-r;
        d  = sqrt(sum((imCenter - [m-r n-r]).^ 2));
        
        if(d==0)
            d = 0.1;
        end
        
        T = (p*j*dy)/d;
        
        seedImage(m-r,n-r) = T;
         
    end
end

imshow(seedImage)

[wtv seedIdx] = max(seedImage(:));

[seedY seedX] = ind2sub(size(probImage),seedIdx);
seedPoint = struct;
seedPoint.x = seedX;
seedPoint.y = seedY;

seed = [seedY seedX];

[borders, rgImage] = RegionGrowingBreast(probImage,seed,upperThresh,lowerThresh,[],false,true,true);

rgImage = mat2gray(rgImage);

time = toc;

% leftStep = 1;
% rightStep = 1;
% upStep = 1;
% downStep = 1;
% 
% y = seedY;
% x = seedX;
% 
% xLeftStep = x;
% xRightStep = x;
% yUpStep = y;
% yDownStep = y;
% 
% mat(y,x) = 1;
% 
% wS = 1;
% 
% if (x-wS)<1
%     wx = 1;
% else
%     wx = x-wS;
% end
% 
% if (x+wS)>col
%     wX = col;
% else
%     wX = x+wS;
% end
% 
% if (y-wS)<1
%     wy = 1;
% else
%     wy = y-wS;
% end
% 
% if (y+wS)>ren
%     wY = ren;
% else
%     wY = y+wS;
% end
% 
% seedRegion = probImage(wy:wY,wx:wX);
% regVal = mean(mean(seedRegion));
% 
% while( leftStep || rightStep || upStep || downStep)
%     
%     if (xLeftStep-1) >= 1
%         xLeftStep = xLeftStep - 1;
%     else
%         leftStep = 0;
%     end
%     
%     if (xRightStep+1) <= col
%         xRightStep = xRightStep + 1;
%     else
%         rightStep = 0;
%     end
% 
%     if (yUpStep-1) >= 1
%         yUpStep = yUpStep - 1;
%     else
%         upStep = 0;
%     end
%     
%     if (yDownStep+1) <= ren
%         yDownStep = yDownStep + 1;
%     else
%         downStep = 0;
%     end
%    
%     for i=y-1:-1:yUpStep
%             y = y - 1;        
%             mat(y,x) = BelongToRegion(probImage(y,x));
%     end
%    
%     if (upStep)
%         for i=x+1:1:xRightStep
%             x = x + 1;
%             mat(y,x) = BelongToRegion(probImage(y,x));        
%         end
%     else
%         x = xRightStep;
%         if (rightStep)
%             mat(y,x) = BelongToRegion(probImage(y,x));
%         end
%     end
%     
%     if(rightStep)   
%         for i=y+1:1:yDownStep        
%             y = y + 1;
%             mat(y,x) = BelongToRegion(probImage(y,x));
%         end
%     else
%         y = yDownStep;
%         if (downStep)
%             mat(y,x) = BelongToRegion(probImage(y,x));
%         end
%     end
%     
%     if(downStep)
%         for i=x-1:-1:xLeftStep 
%             x = x - 1;
%             mat(y,x) = BelongToRegion(probImage(y,x));
%         end
%     else
%         x = xLeftStep;
%         if (leftStep)
%             mat(y,x) = BelongToRegion(probImage(y,x));
%         end
%     end
%     
%     if(leftStep)
%         for i=y-1:-1:yUpStep       
%             y = y - 1;
%             mat(y,x) = BelongToRegion(probImage(y,x));
%         end
%     else
%         y = yUpStep;
%     end
%     
% end
% 
% time = toc;
% 
% seedPoint = struct;
% seedPoint.x = seedX;
% seedPoint.y = seedY;
% 
% mat = imfill(mat,'holes');
% 
% rgImage = mat;
% 
% function belong = BelongToRegion(probVal)
% 
% global wS;
% global x;
% global y;
% global uT;
% global lT;
% global mat;
% global regVal;
% global ren;
% global col;
% global probImage;
% 
% if (x-wS)<1
%     wx = 1;
% else
%     wx = x-wS;
% end
% 
% if (x+wS)>col
%     wX = col;
% else
%     wX = x+wS;
% end
% 
% if (y-wS)<1
%     wy = 1;
% else
%     wy = y-wS;
% end
% 
% if (y+wS)>ren
%     wY = ren;
% else
%     wY = y+wS;
% end
% 
% window = mat(wy:wY,wx:wX);
% 
% if (probVal<=regVal+uT) && (probVal>=regVal-lT) && ~isempty(find(window,1))
%     belong = 1;
%     regVal = mean(mean(probImage(mat>0)));
% else
%     belong = 0;
% end



    


    