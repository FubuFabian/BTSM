function [imRGOutliers imFilterOutliers]  = RemoveOutliners(imRGBorders,imFilterBorders,seedPoint)
    
imRGOutliers = zeros(size(imRGBorders));
imFilterOutliers = zeros(size(imFilterBorders));

rgPoints = find(imRGBorders);
filterPoints = find(imFilterBorders);

[rgPointsY rgPointsX] = ind2sub(size(imRGBorders),rgPoints); 
[filterPointsY filterPointsX] = ind2sub(size(imFilterBorders),filterPoints);

mind = zeros(size(filterPoints));

for i=1:size(filterPoints)
    
    dist = zeros(size(rgPoints));
    
    for j=1:size(rgPoints)
        dist(j) = sqrt((rgPointsX(j) - filterPointsX(i)).^2 + (rgPointsY(j) - filterPointsY(i)).^2);
    end
    
    mind(i) = min(dist);
end

meand = mean(mind);

tempX = [];
tempY = []; 

for i=1:size(mind) 
    
    if mind(i)<=meand
        tempX = [tempX; filterPointsX(i)];
        tempY = [tempY; filterPointsY(i)];
    end
    
end

filterPointsX = tempX;
filterPointsY = tempY;

drg = sqrt((rgPointsX - seedPoint.x).^2 + (rgPointsY - seedPoint.y).^2);
dfilter = sqrt((filterPointsX - seedPoint.x).^2 + (filterPointsY - seedPoint.y).^2);  

drg = mean(drg);
dfilter = mean(dfilter);
dfilterN = 10000000;

afar = 1;
anear = 0;

while abs(dfilter-drg)>3
    
   tempX = [];
   tempY = []; 
    
   for i = 1:size(filterPointsX)
   
    d = sqrt((filterPointsX(i) - seedPoint.x)^2 + (filterPointsY(i) - seedPoint.y)^2); 
    
    if d<(drg + afar*drg) && d>(drg - anear*drg)
        tempX = [tempX; filterPointsX(i)];
        tempY = [tempY; filterPointsY(i)];
    end

   end 
   
   filterPointsX = tempX;
   filterPointsY = tempY;
   
   dfilterN = dfilter;
   
   dfilter = sqrt((filterPointsX - seedPoint.x).^2 + (filterPointsY - seedPoint.y).^2); 
   dfilter = mean(dfilter);
    
   afar = afar - .05;
   anear = anear + .05;
   
   if afar<0
       afar = 0;
       if anear>1
           break;
       end
   end
   
   if anear>1
       anear = 1;
       if afar<0
           break;
       end
   end
         
   
end

for k=1:size(filterPointsX)
 imFilterOutliers(filterPointsY(k),filterPointsX(k)) = 1;
end







    
    