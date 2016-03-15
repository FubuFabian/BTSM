function [imTumorMask time] = SegmentedTumorMask(imRGBorders,imFilterOutliers)

tic;
imTumorPoints = imRGBorders | imFilterOutliers;

points = find(imTumorPoints);
[pointsY pointsX] = ind2sub(size(imTumorPoints),points);

cx = mean(pointsX);
cy = mean(pointsY);

a = atan2(pointsY-cy,pointsX-cx);
[~, order] = sort(a);

pointsX = pointsX(order);
pointsY = pointsY(order);
time = toc;

imTumorMask = roipoly(imTumorPoints,pointsX,pointsY);