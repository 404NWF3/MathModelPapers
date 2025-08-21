function S=Cluster_Hierarchy(data,data_ind,maxclust,depth)
%输入：行为样本，列为指标
%输出：聚类与序号
%% 聚类
figure
Distance=pdist(data);
Tree=linkage(Distance);
%% 分类
T=cluster(Tree,'maxclust',maxclust,'depth',depth);
cate_T=unique(T);
cutoff = mean(Tree(end-maxclust+1:end-maxclust+2,3));
h=dendrogram(Tree,'ColorThreshold',cutoff);
for i=1:length(h)
    h(i).LineWidth=1.5;
end
for i=1:length(cate_T)
    S(i).class=data_ind(T==cate_T(i));
    S(i).data=data(T==cate_T(i),:);
end
end