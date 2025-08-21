function plot_compare(data,label,name)
%输入：数据、名称
%输出
figure
set(gcf,'unit','normalized','position',[0.1 0.1 0.45 0.75]);
for i=1:size(data,2)
    for j=1:size(data,2)
        h(5*(i-1)+j)=subplot(5,5,5*(i-1)+j);
        h(5*(i-1)+j).XTick=[];
        h(5*(i-1)+j).YTick=[];
        box on
        if i==j
            text(0.25,0.5,name(i,:),'FontSize',10)
        else
            gscatter(data(:,i),data(:,j),label,'gr','^o',5)
        end
        legend('off')
    end
end
end