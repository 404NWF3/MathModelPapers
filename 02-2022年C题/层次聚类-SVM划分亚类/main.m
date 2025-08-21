clc;clear;close all;
%% 导入数据，表单一与表单二数据
ori_data1=readtable('附件.xlsx',Sheet='表单1');
ori_data2=readtable('附件.xlsx',Sheet='表单2');
%提取序号
Number1=str2double(ori_data1{:,1});
Number2=str2double(extractBefore(ori_data2{:,1},3));
%高钾为0，铅钡为1，无风化为0，风化为1
data0(:,1)=Number2;
for i=1:length(Number2)
    ind=find(Number1==Number2(i));
    if ori_data1{ind,3}=="高钾"
        data0(i,2)=0;
    elseif ori_data1{ind,3}=="铅钡"
        data0(i,2)=1;
    end

    if ori_data1{ind,5}=="无风化"
        data0(i,3)=0;
    elseif ori_data1{ind,5}=="风化"
        data0(i,3)=1;
    end
end
%提取数据
data0(contains(ori_data2{:,1},'未风化'),3)=0;
data0=[data0 ori_data2{:,2:end}];

%% 数据预处理
%缺省值处理
data0=fillmissing(data0,'constant',0.04);
%数据删除
data1=data0;
data1(sum(data1(:,4:end),2)>105,:)=[];
data1(sum(data1(:,4:end),2)<85,:)=[];
%筛选出未风化的样本
data_X=data1(data1(:,3)==0,[5 7:10]);%指标
data_ind=data1(data1(:,3)==0,1);%样本序号
data_X(data_X==0)=0.04;
data_Y=data1(data1(:,3)==0,1:2);%分类结果/标签
%% 中心对数比变化
data_X=CLR(data_X);
%% 层次聚类
%高钾聚类
ind=find(data_Y(:,2)==0);
data_K=data_X(ind,:);%高钾指标值
data_K_ind=data_ind(ind,:);%高钾的实际样本序号
depth=3.5;%聚类的深度
maxclust=3;%聚类数
S_K=Cluster_Hierarchy(data_K,data_K_ind,maxclust,depth);%调用函数聚类，返回聚类结果
%铅钡聚类
ind=find(data_Y(:,2)==1);
data_Pb=data_X(ind,:);%铅钡指标值
data_Pb_ind=data_ind(ind,:);%铅钡的实际样本序号
depth=2.88;%聚类的深度
maxclust=2;%聚类数
S_Pb=Cluster_Hierarchy(data_Pb,data_Pb_ind,maxclust,depth);%调用函数聚类，返回聚类结果
%% SVM 亚类划分——以高钾为例
%确定数据
data_K_x=[S_K(1).data;S_K(2).data;S_K(3).data];%高钾数据
num_0=length([S_K(1).class;S_K(2).class]);%高钾聚类1数量
num_1=length(S_K(3).class);%高钾聚类2数量
data_K_y=[zeros(num_0,1);ones(num_1,1)];%高钾数据标签
%高钾散点图
name=['氧化钠';'氧化钙';'氧化镁';'氧化铝';'氧化铁'];
plot_compare(data_K_x,data_K_y,name);%调用函数画散点图

index=[2 3];%SVM分类所用指标
%高钾SVM
[trainedClassifier, validationAccuracy] = SVM_Classifier(data_K_x,index,data_K_y);%调用函数画散点图
%预测
yfit = trainedClassifier.predictFcn(data_K_x);%得到预测值
%% 结果展示
%混淆矩阵
figure
plotconfusion(data_K_y',yfit')
%支持向量超平面
figure
set(gcf,'unit','normalized','position',[0.1 0.1 0.25 0.75]);
newdata=data_K_x(:,index);
new_label=data_K_y;
SVMModel=trainedClassifier.ClassificationSVM;
sv2 = SVMModel.SupportVectors; % 获得支持向量
h=gscatter(newdata(:,1),newdata(:,2),new_label,'gr','^o',5); % 绘制数据
h(1).LineWidth=2;%图形线宽
h(2).LineWidth=2;%图形线宽
hold on
plot(sv2(:,1),sv2(:,2),'ko','MarkerSize',10) % 绘制支持向量
hold on
% 绘制分类超平面
x = -3:0.1:1;%超平面的绘制范围
x2=-2:0.1:2.5;%下界的绘制范围
x3=-3.5:0.1:-1;%上界的绘制范围
a = - SVMModel.Beta(1)/SVMModel.Beta(2);
b = -SVMModel.Bias/SVMModel.Beta(2);
Y = a*x + b;    % 计算分类超平面
Y2 = a*x2 + b-1/SVMModel.Beta(2);
Y3 = a*x3 + b+1/SVMModel.Beta(2);
plot(x,Y,'k-',x2,Y2,'k--',x3,Y3,'k--','LineWidth',1.5)
legend('低镁高钙','低钙高镁','Support Vector','Location','northwest')
xlabel('氧化钙')
ylabel('氧化镁')
axis([-inf inf -inf inf])
title('SVM分类')







