function [trainedClassifier,validationAccuracy] = SVM_Classifier(trainingData,index,responseData)
% [trainedClassifier, validationAccuracy] = trainClassifier(trainingData,
% responseData)
% 返回经过训练的分类器及其 准确度。以下代码重新创建在分类学习器中训练的分类模型。您可以使用
% 该生成的代码基于新数据自动训练同一模型，或通过它了解如何以程序化方式训练模型。
%
%  输入:
%      trainingData: 一个与导入 App 中的矩阵具有相同列数和数据类型的矩阵。
%
%      responseData: 一个与导入 App 中的向量具有相同数据类型的向量。responseData 的
%       长度和 trainingData 的行数必须相等。
%
%  输出:
%      trainedClassifier: 一个包含训练的分类器的结构体。该结构体中具有各种关于所训练分
%       类器的信息的字段。
%
%      trainedClassifier.predictFcn: 一个对新数据进行预测的函数。
%
%      validationAccuracy: 包含准确度百分比的双精度值。在 App 中，"模型" 窗格显示每
%       个模型的总体准确度分数。
%
% 使用该代码基于新数据来训练模型。要重新训练分类器，请使用原始数据或新数据作为输入参数
% trainingData 和 responseData 从命令行调用该函数。
%
% 例如，要重新训练基于原始数据集 T 和响应 Y 训练的分类器，请输入:
%   [trainedClassifier, validationAccuracy] = trainClassifier(T, Y)
%
% 要使用返回的 "trainedClassifier" 对新数据 T2 进行预测，请使用
%   yfit = trainedClassifier.predictFcn(T2)
%
% T2 必须是仅包含用于训练的预测变量列的矩阵。有关详细信息，请输入:
%   trainedClassifier.HowToPredict

% 提取预测变量和响应
% 以下代码将数据处理为合适的形状以训练模型。
%
% 将输入转换为表
inputTable = array2table(trainingData(:,index));
predictors = inputTable;
response = responseData;
% 训练分类器
% 以下代码指定所有分类器选项并训练分类器。
classificationSVM = fitcsvm(...
    predictors, ...
    response, ...
    'KernelFunction', 'linear');

% classificationSVM = fitcsvm(...
%     predictors, ...
%     response, ...
%     'KernelFunction', 'gaussian', ...
%     'PolynomialOrder', [], ...
%     'KernelScale', 5.7, ...
%     'BoxConstraint', 1, ...
%     'Standardize', true, ...
%     'ClassNames', [0; 1]);

% 使用预测函数创建结果结构体
predictorExtractionFcn = @(x) array2table(x(:,index));
svmPredictFcn = @(x) predict(classificationSVM, x);
trainedClassifier.predictFcn = @(x) svmPredictFcn(predictorExtractionFcn(x));

% 向结果结构体中添加字段
trainedClassifier.ClassificationSVM = classificationSVM;

% 提取预测变量和响应
% 执行交叉验证
partitionedModel = crossval(trainedClassifier.ClassificationSVM, 'KFold', 5);

% 计算验证预测
[validationPredictions, validationScores] = kfoldPredict(partitionedModel);

% 计算验证准确度
validationAccuracy = 1 - kfoldLoss(partitionedModel, 'LossFun', 'ClassifError');
