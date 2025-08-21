function clr=CLR(x)
%输入：指标值，行为样本，列为指标
%输出：clr后数据
% x=[30 30 40;
%     30 10 60];
[~,n]=size(x);
Gm=prod(x,2).^(1/n);%计算几何平均
clr=log(x./Gm);%计算对数
end