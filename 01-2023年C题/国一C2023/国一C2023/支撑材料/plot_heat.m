%% 绘制热力图
%加载数据
load sale_heat.mat;
load label_heat.mat;
h=heatmap(label_heat,label_heat,sale_heat,'Title','各个单品相关系数矩阵');
%调整配色
colormap('hot');