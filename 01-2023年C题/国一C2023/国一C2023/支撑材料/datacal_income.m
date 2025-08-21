%此处代码用于计算总收入
% clc,clear;
% income_all=[];
% for ii=1:1
%     data=[xlsread('附件2.xlsx',ii+1,'A:A'),xlsread('附件2.xlsx',ii+1,'F:F'),xlsread('附件2.xlsx',ii+1,'G:G')];
%     income=zeros(1095,1);
%     [m,n]=size(data);
%     flag=1;
%     for i=1:m
%         if data(i,1)==flag
%             income(flag,1)=data(i,2)*data(i,3)+income(flag,1);
%         else
%             while data(i,1)~=flag
%                 flag=flag+1;
%                 if data(i,1)==flag
%                     income(flag,1)=data(i,2)*data(i,3)+income(flag,1);
%                     break;
%                 end
%             end
%         end
%     end
%     income_all=[income_all,income];
% end

%%
load sale_all_sig.mat
load income_all.mat
income_all=income_all(366:1095,:);
sale_all=sale_all(366:1095,:);
price=income_all./sale_all;
[p,q]=size(income_all);
miu=zeros(1,6);
sig=zeros(1,6);
high=0;
low=0;
for i=1:q
    for j=1:p
    miu(i)=mean(income_all(:,i));
    sig(i)=std(income_all(:,i),0);
    if income_all(j,i)>miu(i)+3*sig(i)
        high=high+1;
        income_all(j,i)=miu(i)+3*sig(i);
    elseif income_all(j,i)<miu(i)-3*sig(i)
        low=low+1;
        income_all(j,i)=miu(i)-3*sig(i);
    end
    end
end
pick=0.15;
index=[];
for i=1:length(price)
    if rand<pick
        index=[index,i];
    end
end
price=price(index,:);
sale_all=sale_all(index,:);
x1=sale_all(:,1);
x2=sale_all(:,2);
x3=sale_all(:,3);
x4=sale_all(:,4);
x5=sale_all(:,5);
x6=sale_all(:,6);
y1=price(:,1);
y2=price(:,2);
y3=price(:,3);
y4=price(:,4);
y5=price(:,5);
y6=price(:,6);


%% 绘制拟合散点图
v=3:0.1:125;
y=(-4.988*v.^2+476.7*v-305.4)./(v.^2+1.389*v-1.679);
hold on
plot(v,y);
scatter(x6,y6,'r*');
axis([-10 105 -10 70])

% %% 绘制拟合散点图
% v=5:0.1:125;
% w=(-4.009*v.^2+1447*v-1735)./(v.^2+149.7*v-554.3);
% hold on
% plot(v,w);
% scatter(x1,y1,'r*')
% hold off