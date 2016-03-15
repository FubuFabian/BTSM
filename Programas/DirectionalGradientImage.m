function gradientImage = DirectionalGradientImage(im,seed)

im = mat2gray(im);

Vx = zeros(size(im));
Vy = zeros(size(im));

[Gx Gy] = gradient(im);

for i=1:size(Vx,2)
    Vx(:,2) = i;
end

for i=1:size(Vy,1)
    Vy(i,:) = i;
end

x = Vx - seed.x;
y = Vy - seed.y;

nx = x/norm(x+y);
ny = y/norm(x+y);

G = Gx.*nx + Gy.*ny;

gradientImage = -G/norm(G);