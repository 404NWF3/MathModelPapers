%%从数据中筛选指标
clc;clear;close all;
%导入数据
data=xlsread("附件1 近5年402家供应商的相关数据.xlsx",2,'C2:IH403');%供货量
%% 指标评价体系
%% 1.供货水平指标
for i=1:402
    MAX(i)=max(data(i,:));%最大供货量
    SUM(i)=sum(data(i,:));%总供货量
    WEEK(i)=sum(~ismember(data(i,:),0));%判断data的第i行里面是否不是0，并相加，供货频次
    MEANW(i)= SUM(i)/WEEK(i);%周平均供货量
    STD(i)=std(data(i,~ismember(data(i,:),0)));%供货标准差（只算供货的周次）
end
zhibiao1=[MAX' SUM' WEEK' MEANW' STD'];
xlswrite('指标选取.xlsx',zhibiao1,'B2:F403');
%% 2.订单完成水平指标
data2=xlsread("附件1 近5年402家供应商的相关数据.xlsx",1,'C2:IH403');%订货量
%代入偏差函数
%函数图像
r=-1:0.01:1;
for i=1:length(r)
    fdev(i)=Dev(r(i));
end
figure
plot(r,fdev,'LineWidth',1.5)
%订供偏差值
for i=1:402
    for j=1:240
        DR(i,j)=(data2(i,j)-data(i,j))/data2(i,j);%订供偏差率
        DR(i,j)=Dev(DR(i,j));
    end
end
%订供偏差的均值与标准差
for i=1:402
    MEANDR(i)=mean(DR(i,~isnan(DR(i,:))));
    STDDR(i)=std(DR(i,~isnan(DR(i,:))));
end
DR=[DR MEANDR' STDDR'];
xlswrite('指标选取.xlsx',DR,2,'B2:II403');
xlswrite('指标选取.xlsx' ,MEANDR',1,'G2:G403');
xlswrite('指标选取.xlsx' ,STDDR',1,'H2:H403');
%% 3.供应类别指标
%指定工作范围
opts=spreadsheetImportOptions('NumVariables',1);
opts.Sheet="企业的订货量（m³）";%指定要导入的表单sheet
opts.DataRange="B1:B403";% 指定要导入表单的范围
%指定名称
opts.VariableNames = "VarName2";
opts.VariableTypes = "categorical";
opts=setvaropts(opts,'VarName2','Emptyfieldrule','auto');
%导入数据
classify=readtable('附件1 近5年402家供应商的相关数据.xlsx',opts,'UseExcel',false);
classify(1,:)=[];%删除第一行（标题）
%将ABC类别转化为123
classify_double=table2array(varfun(@double,classify));
a=[1.2 1.1 1];
b=[0.6 0.66 0.72];
c1=1;%单位原材料
c2=1;%单位运费
%计算成本指标值
classify_score=(a(classify_double).*c1+c2).*b(classify_double);%单位产品综合成本：
% a(classify_double).*b(classify_double)为采购成本，c2.*b(classify_double)为运输成本
xlswrite('指标选取.xlsx' ,classify_score',1,'I2:I403');



