function borderImage = RayCastBorders(image,seed,step,descriptor)

global im;

im = image;

[nRen nCols] = size(image);
borderImage = zeros(size(image));

x = seed.x;
y = seed.y;

xPos = [];
yPos = [];

global xTemp;
global yTemp;

global newValue;

xTemp = seed.x;
yTemp = seed.y;

y1= y;
y2 = y;

for t=0:step:179
    
    m = tand(t);
    n = y -(tand(t)*x);
    
    if t==90
        
        newValue = 0;
        
        for j=y+1:nRen            
            i = x;
     
            [yes finish] = Desition(j,i,descriptor);
            
            if(finish)
                break;
            end
            
        end
        
        xPos = [xPos; xTemp];
        yPos = [yPos; yTemp];

        newValue = 0;
        
        for j=y-1:-1:1
            i = x;
            
            [yes finish] = Desition(j,i,descriptor);
            
            if(finish)
                break;
            end
            
        end
        
        xPos = [xPos; xTemp];
        yPos = [yPos; yTemp];
        
    else  
        
        y2 = y;
        newValue = 0;
        
        for i=x+1:nCols
        
            y1 = y2;
            y2 = round(m*i+n);
            
            if y1<1
               break;
            elseif y1>nRen
               break;
            end
            
            [yes finish] = Desition(y1,i,descriptor);
            
            if(finish)
                break;
            end
            
            if y2>y1
                step = 1;
            else
                step = -1;
            end
            
            while y1~=y2
                
                y1 = y1 + step;
                
                if y1<1
                    break;
                elseif y1>nRen
                    break;
                end
                
                [yes finish] = Desition(y1,i,descriptor);
            
                if(finish)
                    break;
                end              
                
            end
            
            if(finish)
                break;
            end
                          
        end
    
        y2 = y;
        newValue = 0;
        
        for i=x+1:-1:1
        
            y1 = y2;
            y2 = round(m*i+n);
            
            if y1<1
               break;
            elseif y1>nRen
               break;
            end
            
            [yes finish] = Desition(y1,i,descriptor);
            
            if(finish)
               break;
            end  
            
            if y2>y1
                step = 1;
            else
                step = -1;
            end
            
            while y1~=y2
                
                y1 = y1 + step;
                
                if y1<1
                    break;
                elseif y1>nRen
                    break;
                end
                
                [yes finish] = Desition(y1,i,descriptor);
            
                if(finish)
                    break;
                end                 
                
            end
            
            if(finish)
               break;
            end  
        end
    end
end 

for k=1:size(yPos,1)
 borderImage(yPos(k),xPos(k)) = 1;
end

function [yes finish] = Desition(j,i,descriptor)

global xTemp;
global yTemp;
global newValue;

finish = 0;

    if(strcmp(descriptor,'Clasificacion'))
        yes = Clasificacion(j,i);
 
        if yes
            xTemp = i;
            yTemp = j;
            finish = 1;
        end
    elseif(strcmp(descriptor,'Filtro'))
        [newValue yes] = Filtro(j,i,newValue);
                
        if yes
            xTemp = i;
            yTemp = j;
        end
    end



function finish = Clasificacion(j,i)

global im;

val = im(j,i);

finish = 0;

if val == 0
    finish = 1;
end

function [newValue yes] = Filtro(j,i,oldValue)

global im;

val = im(j,i);

yes = 0;

if val>oldValue
    yes = 1;
    newValue = val;
else
    newValue = oldValue;
end

    
    


    
    