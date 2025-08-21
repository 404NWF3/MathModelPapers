clc;clear;close all;
d=[];e=[];
for k=1:5
    X=xlsread('指标选取.xlsx',1,'B2:I403');
    %正向化
    for i=5:8
        X(:,i)=max(X(:,i))-X(:,i);
    end
    %归一化
    x=mapminmax(X',0.01,1);%mapminmax是将函数的每一行归一为[-1,1]。这里X转置为一行一个特征，然后归一到0.01到1
    x=x';%行为样本，列为指标
    N=400;Pc=0.8;Pm=0.2;M=10;Ci=10;n=8;DaiNo=2;ads=1;
    %遗传算法求解
    [a1,b1]=RAGA(x,N,n,Pc,Pm,M,DaiNo,Ci,ads);
    d=[d,a1];e=[b1;e];
end
[a2 b2]=max(d);
%得到权重
e1=e(b2,:)
%得到评分
ff=e1*x'
xlswrite('指标选取.xlsx',ff',1,'J2:J403')
%% 输出前50
data=readtable('附件1 近5年402家供应商的相关数据.xlsx','Sheet','企业的订货量（m³）');
name=data{:,1};
[score,ind]=sort(ff','descend');%ind返回对应的行索引
result(1).name=name(ind(1:50));
result(1).score=score(1:50);
%% PCA方法
[stf,ind] = PCA_score(x);
result(2).name=name(ind(1:50));
result(2).score=stf(1:50)';
%% TOPSIS
Score0=TOPSIS_score(x);
[score,ind]=sort(Score0','descend');
result(3).name=name(ind(1:50));
result(3).score=score(1:50);





