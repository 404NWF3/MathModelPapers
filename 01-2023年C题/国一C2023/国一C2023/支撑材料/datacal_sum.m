clc,clear;
%% 计算各个单类总销量
sale_all=[];
for ii=1:6
    %加载数据
%     data=[xlsread('1.xlsx',ii,'A:A'),xlsread('1.xlsx',ii,'B:B')];
dataA = readmatrix('1.xlsx', 'Sheet', ii, 'Range', 'A:A');
% 找到唯一值并创建对应的编号
[uniqueValues, ~, indices] = unique(dataA);
% 创建编号数组，从1开始
numberedDataA = indices;
dataB = readmatrix('1.xlsx', 'Sheet', ii, 'Range', 'B:B');
data = [numberedDataA, dataB];
    %初始化
    sale=zeros(1095,1);
    [m,n]=size(data);
    flag=1;
    %开始计算各个大类的历史销售总额
    for i=1:m
        if data(i,1)==flag&&data(i,2)>=0
            sale(flag,1)=data(i,2)+sale(flag,1);
        elseif data(i,1)==flag&&data(i,2)<0
            sale(flag,1)=data(i,2)+sale(flag,1);
        elseif data(i,1)~=flag&&data(i,2)>=0
            flag=flag+1;
            sale(flag,1)=data(i,2)+sale(flag,1);
        elseif data(i,1)~=flag&&data(i,2)<0
            flag=flag+1;
            sale(flag,1)=data(i,2)+sale(flag,1);
        end
    end
    sale_all=[sale,sale_all];
end

%% 去除异常值
[p,q]=size(sale_all);
miu=zeros(1,6);
sig=zeros(1,6);
high=0;
low=0;
%利用3σ原则进行异常值处理
for i=1:q
    for j=1:p
    miu(i)=mean(sale_all(:,i));
    sig(i)=std(sale_all(:,i),0);
    if sale_all(j,i)>miu(i)+3*sig(i)
        high=high+1;
        sale_all(j,i)=miu(i)+3*sig(i);
    elseif sale_all(j,i)<miu(i)-3*sig(i)
        low=low+1;
        sale_all(j,i)=miu(i)-3*sig(i);
    end
    end
end

%% 绘制有季度分割线的图像
text={'根茎类销量';'食用菌类销量';'辣椒类销量';'花叶类销量';'花菜类销量';'茄子类销量'};
ymax=[300 600 700 1400 200 120]*0.7;
point=sale_all(91:91:1092,:);
for k=1:6
    hold on
    figure(k)
    plot(1:1095,sale_all(:,k),'b')
    line([365 365],[0 ymax(k)],'color','g','linewidth',2)
    line([730 730],[0 ymax(k)],'color','c','linewidth',2)
    line([91 91],[0 ymax(k)*0.8],'linestyle','--','linewidth',1.5,'color','r')
    line([182 182],[0 ymax(k)*0.8],'linestyle','--','linewidth',1.5,'color','r')
    line([273 273],[0 ymax(k)*0.8],'linestyle','--','linewidth',1.5,'color','r')
    line([455 455],[0 ymax(k)*0.8],'linestyle','--','linewidth',1.5,'color','r')
    line([546 546],[0 ymax(k)*0.8],'linestyle','--','linewidth',1.5,'color','r')
    line([637 637],[0 ymax(k)*0.8],'linestyle','--','linewidth',1.5,'color','r')
    line([819 819],[0 ymax(k)*0.8],'linestyle','--','linewidth',1.5,'color','r')
    line([910 910],[0 ymax(k)*0.8],'linestyle','--','linewidth',1.5,'color','r')
    line([1001 1001],[0 ymax(k)*0.8],'linestyle','--','linewidth',1.5,'color','r')
    hold off
    %设置图像参数和标签
    axis([0 1100 0 ymax(k)])
    xlabel('日期代码（单位：天 ）')
    ylabel('日总销量（单位：kg）')
    legend(text{k},'第一周年分界线','第二周年分界线','季度分界点')
end

%% 绘制无季度分割线的图像
text={'根茎类销量';'食用菌类销量';'辣椒类销量';'花叶类销量';'花菜类销量';'茄子类销量'};
ymax=[300 600 700 1400 200 120]*0.7;
point=sale_all(91:91:1092,:);
for k=1:6
    hold on
    figure(k)
    plot(1:1095,sale_all(:,k),'b')
    line([365 365],[0 ymax(k)],'color','g','linewidth',2)
    line([730 730],[0 ymax(k)],'color','c','linewidth',2)
    hold off
    %设置图像参数和标签
    axis([0 1100 0 ymax(k)])
    xlabel('日期代码（单位：天 ）')
    ylabel('日总销量（单位：kg）')
    legend(text{k},'第一周年分界线','第二周年分界线')
end
save('sale_all_sig.mat', 'sale_all');