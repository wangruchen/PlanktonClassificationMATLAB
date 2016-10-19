close all;
clear all;
clc;

addpath('common_innerdist/');

TrainingBinarySetInfo = importdata('../zooscan/zooscanBinary.txt');
TrainingSetNum = length(TrainingBinarySetInfo);
% trainSet = importdata('Training_Set.txt');
% label = trainSet.data;

templateBinarySetInfo = importdata('template.txt');
templateNum = length(templateBinarySetInfo);

match_cost = [];

for i = 1:TrainingSetNum
    imageNameNum = strfind(TrainingBinarySetInfo{i, 1},'/');
%     classifyNameNum = strfind(TrainingBinarySetInfo.textdata{i, 1},'/T');
    if ~isempty(imageNameNum)
        imageName=TrainingBinarySetInfo{i, 1}((imageNameNum(1,4)+1):end);
    end
    imgBinary = imread(TrainingBinarySetInfo{i, 1});
    imgBinary = bwmorph(imgBinary,'majority');
    for j = 1:templateNum
        imgTemplate = imread(templateBinarySetInfo{j, 1});
%         imgTemplate = bwmorph(imgTemplate,'majority');
        match_cost(i,j)=comIDSC(imgBinary,imgTemplate);
    end
end
lowvec=min(match_cost);  
upvec=max(match_cost);
trainFeature = scaling( match_cost,lowvec,upvec);

save ../zooscan/zooscan-Train-Features-IDSC.mat trainFeature


% resultCM = zeros(classesNum, classesNum);
% for trial = 1:repetitions
%     indices = crossvalind('Kfold', trainSetNum, folds);
%     num=1;
%     for k = 1:folds
%         test = (indices == k); 
%         train = ~test;
%         train_data = trainFeature(train,:);
%         train_target = label(train);
%         test_data = trainFeature(test, :);
%         test_target = label(test);
%         model = svmtrain(train_target, train_data, '-s 0 -t 0 -d 1 -g 0 -r 0 -c 1 -e 0.0001 -h 1');
%         [predict_label, accuracy, decision_values] = svmpredict(test_target, test_data, model);
%         labelSize = length(predict_label);
%         for i = 1:labelSize
%             predictLabel(num,1) = predict_label(i, 1);
%             actualLabel(num,1) = test_target(i, 1);
%             num = num+1;
%         end
%     end
%     [cm,order] = confusionmat(actualLabel, predictLabel);
%     resultCM = resultCM+cm;
% end
% writeData(resultCM, strcat('changeIDSC-', num2str(folds), '-folds-', num2str(repetitions), '-repetitions', '.txt'));