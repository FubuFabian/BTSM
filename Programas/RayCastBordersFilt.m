function borderImage = RayCastBordersFilt(image,seed,degree)

%figure, imshow(image)

[nRen nCols] = size(image);
borderImage = zeros(size(image));

x = seed.x;
y = seed.y;

for t=0:degree:360
        
    tempX = x; 
    tempY = y;    
    val1 = image(y,x);
    
    for i=1:nCols
            
        xp = round(i*cosd(t))+1+x;
        yp = round(i*sind(t))+1+y;
            
        if yp>nRen
            break;
        elseif yp<1
            break;
        end
            
        if xp>nCols
            break;
        elseif xp<1
            break;
        end
            
        val2 = image(yp,xp);
        
        if val2>val1
            tempX = xp;
            tempY = yp;
            val1 = val2;  
        end 
            
    end
     
    borderImage(tempY,tempX) = 1;
        
end

