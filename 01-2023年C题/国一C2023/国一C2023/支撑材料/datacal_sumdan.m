%此段代码用于计算所选30种单品的历史总销量
clc,clear;
sale_all=[];
for ii=1:30
    %读取数据
    data=[xlsread('F:\2023年国赛\单类总计.xlsx',ii,'A:A'),xlsread('F:\2023年国赛\单类总计.xlsx',ii,'F:F')];
    sale=zeros(1095,1);
    [m,n]=size(data);
    flag=1;
    %开始计算
    for i=1:m
        if data(i,1)==flag
            sale(flag,1)=data(i,2)+sale(flag,1);
        else
    %利用标志变量进行检测，在防止错误发生的同时也可提高运行速度
            while data(i,1)~=flag
                flag=flag+1;
                if data(i,1)==flag
                    sale(flag,1)=data(i,2)+sale(flag,1);
                    break;
                end
            end
        end
    end
    %结果得到总销量
    sale_all=[sale,sale_all];
end

%% 异常值处理
[p,q]=size(sale_all);
miu=zeros(1,30);
sig=zeros(1,30);
high=0;
low=0;
%利用3σ原则处理异常值
for i=1:q
    for j=1:p
    %计算数据平均数和方差
    miu(i)=mean(sale_all(:,i));
    sig(i)=std(sale_all(:,i),0);
    if sale_all(j,i)>miu(i)+3*sig(i)
        high=high+1;
        sale_all(j,i)=randi([0 100]);
    elseif sale_all(j,i)<miu(i)-3*sig(i)
        low=low+1;
        sale_all(j,i)=rand(1)*5;
    end
    end
end

%% 绘制六种单品的销量变化曲线
index=[1 6 9 15 17 30];
%设置颜色RGB参数
color=[0.929 0.694 0.125;
    0.494 0.184 0.556;
    0.85 0.325 0.098; 
    0.466 0.674 0.188;
    0 0.447 0.741; 
    0.301 0.745 0.933];
text={'金针菇','紫茄子','芜湖青椒','西兰花','静藕','云南生菜'};
%绘制图像
for i=1:6
    subplot(2,3,i);
    plot(1:1095,sale_all(:,i),'color',color(i,:));
    legend(text{i})
end
