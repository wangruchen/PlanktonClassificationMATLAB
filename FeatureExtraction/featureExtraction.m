clear
clc

datasetName = 'zooscan';
TrainSetInfo = importdata('./zooscan/zooscan.txt');
TrainBinarySetInfo = importdata('./zooscan/zooscanBinary.txt');
TrainSetNum = length(TrainBinarySetInfo);

for i = 1:TrainSetNum
    imageNameNum = strfind(TrainBinarySetInfo{i, 1},'/');
    if ~isempty(imageNameNum)
        imageName=TrainBinarySetInfo{i, 1}((imageNameNum(1,6)+1):end);
    end
    imgBinary = imread(TrainBinarySetInfo{i, 1});   
    img = imread(TrainSetInfo.textdata{i, 1});
    [imgRows,imgCols] = size(img);
    
    num = 1;
    imgGray = [];
    for x=1:imgRows
        for y=1:imgCols
            if imgBinary(x,y)==1
                imgGray(num) = img(x,y);%分割后的图像灰度
%                 imgObjectXY(num,:) = [x,y];%分割后的图像坐标
                num = num+1;
            end
        end
    end
    
    regionFeatures = regionprops(imgBinary,{'area','MajorAxisLength','MinorAxisLength','Eccentricity','Orientation',...
        'FilledArea','ConvexArea','EulerNumber','EquivDiameter','Solidity','Extent','Perimeter'});
    
    regionFeaturesAll = regionprops(imgBinary,'all');
    regionFeaturesWH = regionprops(imgBinary,'BoundingBox');
    regionFeaturesConv = regionprops(imgBinary,'ConvexImage');
    regionFeaturesCentroid = regionprops(imgBinary,'Centroid');
    
    [~,ind] = sort([regionFeatures.Area], 2,'descend');
    features = regionFeatures(ind(1));
    
    % gray
    features = grayExtraction(img, imgBinary, features);
    
    features.IntDen = sum([regionFeatures(:).Area])*features.meanGray;
    features.feret = imMaxFeretDiameter(imgBinary);%Feret直径
    features.circularity = (4*pi*features.Area)/features.Perimeter^2;
    features.elongation = features.MajorAxisLength/features.MinorAxisLength;
    features.convexHull = features.Area/features.ConvexArea;%凸率
    features.wh = regionFeaturesWH(ind(1)).BoundingBox(3)/regionFeaturesWH(ind(1)).BoundingBox(4);
    features.perimArea = features.Perimeter/features.Area;
    
    convexPerim = regionprops(regionFeaturesConv(ind(1)).ConvexImage,'Perimeter');
    features.convexPerim = convexPerim.Perimeter;
    
    B = imrotate(imgBinary,pi-features.Orientation,'bicubic','crop');%旋转
    BSymmetryY = max((imgCols-round(regionFeaturesCentroid(ind(1)).Centroid(2)))*2,round(regionFeaturesCentroid(ind(1)).Centroid(2))*2);
    BSymmetry = zeros(imgRows,BSymmetryY);
    BSymmetry(:,(BSymmetryY/2-round(regionFeaturesCentroid(ind(1)).Centroid(2))+1):(BSymmetryY/2+imgCols-round(regionFeaturesCentroid(ind(1)).Centroid(2)))) = B;
    BFX = flipud(BSymmetry);%上下翻转，关于水平轴对称
    BFY = fliplr(BSymmetry);%左右翻转，关于竖直轴对称
    BorBFX = BSymmetry | BFX;
    BorBFY = BSymmetry | BFY;
    symmetryX = sum(sum(BorBFX))/sum(sum(BSymmetry));
    symmetryY = sum(sum(BorBFY))/sum(sum(BSymmetry));
    
    features.symmetryX = symmetryX;
    features.symmetryY = symmetryY;
    
    features = invmomentsExtraction(img, features);
    
%     % 增加特征
%     s = [];
%     s = bwmorph(imgBinary, 'skel',16);
%     s = bwmorph(s,'spur',8);
%     features.skelArea = sum(sum(s));%骨架面积
%     
%     features.rectangularity = features.Area/(regionFeaturesWH(ind(1)).BoundingBox(3)*regionFeaturesWH(ind(1)).BoundingBox(4));% 矩形度
%     features.intensity = (features.Perimeter)^2/(4*pi*features.Area);% 密集度
%     features.elong2 = features.Perimeter/(regionFeaturesWH(ind(1)).BoundingBox(3)*regionFeaturesWH(ind(1)).BoundingBox(4));% 伸长度
    
%     convexAreaComp = regionprops(imgBinary, 'ConvexImage');
%     convexInfo = regionprops(convexAreaComp(ind(1)).ConvexImage,'Perimeter');
%     features.periConvexPeri = regionFeatures(ind(1)).Perimeter/convexInfo.Perimeter;
    
%     %对称性   
%     B = imrotate(imgBinary,pi-regionFeatures(ind(1)).Orientation,'bicubic','crop');%旋转
%     BSymmetryY = max((imgCols-round(regionFeaturesAll(ind(1)).Centroid(2)))*2,round(regionFeaturesAll(ind(1)).Centroid(2))*2);
%     BSymmetry = zeros(imgRows,BSymmetryY);
%     BSymmetry(:,(BSymmetryY/2-round(regionFeaturesAll(ind(1)).Centroid(2))+1):(BSymmetryY/2+imgCols-round(regionFeaturesAll(ind(1)).Centroid(2)))) = B;
%     BFX = flipud(BSymmetry);%上下翻转，关于水平轴对称
%     BFY = fliplr(BSymmetry);%左右翻转，关于竖直轴对称
%     BorBFX = BSymmetry | BFX;
%     BorBFY = BSymmetry | BFY;
%     symmetryX = sum(sum(BorBFX))/sum(sum(BSymmetry));
%     symmetryY = sum(sum(BorBFY))/sum(sum(BSymmetry));
%     features.Symetrieh = symmetryX;
% 	features.Symetriev = symmetryY;
%     
%     grayHist = hist(imgGray,256);
%     features.skew = skewness(grayHist);
    
    featuresCell = struct2cell(features);
    featuresMatrix(i,:) = cell2mat(featuresCell)';
end

[m n] = size(featuresMatrix);
fid = fopen('./zooscan/zooscan-Train-Features.txt','w');
for i = 1:m
    for j = 1:n
        fprintf(fid, '%g\t', featuresMatrix(i,j)); 
    end
    fprintf(fid, '\n');
end
fclose(fid);
