clc,clear;
%% 导入变量
load ch.mat;
load dis.mat;
load name.mat;
load min_max.mat;
load rate.mat;

%% 设置选取变量
narvs=round(6*rand+26);
choice=randperm(49);
choice=choice(1:narvs);
new_name=name{choice,1};
label=name{choice,2};
sale=name{choice,3};
relation=corrcoef(repmat(sale,1,narvs));

%% 设定参数
gen=300;  %迭代次数
mu=0.005;   %变异率
cro=0.95;   %交叉率
num=100;   %初代种群个数
x_up=[min_max(choice,1)+26;repmat(26.7,narvs,1)]; %变量上下限
x_dw=[min_max(choice,2)+26;zeros(narvs,1)];
   %变量个数
narvs=2*narvs;
a=[];

%% 初始化
chrom=zeros(num,narvs);
fitness_best_all=zeros(gen,1);
fitness_ave=zeros(gen,1);
for i=1:num
    for j=1:narvs
        chrom(i,j)=x_dw(j)+(x_up(j)-x_dw(j))*rand(1);
    end
end
fitness=fitnesscal(chrom,label,ch,dis,rate,x_dw,x_up,choice,sale);
fitness_best=max(fitness);
fitness_best_all(1)=fitness_best;
fitness_ave(1)=sum(fitness)/length(fitness);

%% 种群开始进行繁衍
for iter=2:gen
    %进行选择
    [n,~]=size(chrom);
    chrom=ga_sel(fitness,chrom,n);
    %进行交叉
    chrom=ga_cro(chrom,cro,n,narvs,x_dw,x_up,relation);
    cro=cro-0.0000001*iter;
    %变异操作
    chrom=ga_mut(chrom,mu,n,narvs,x_up,x_dw);
    %计算适应度
    fitness=fitnesscal(chrom,label,ch,dis,rate,x_dw,x_up,choice,sale);
    fitness_max=max(fitness);
    %选取每轮最佳适应度
    if fitness_max>=fitness_best
        fitness_best=fitness_max;
        a=find(fitness==fitness_best);
        best_chrom=chrom(a,:);
    end
    fitness_best_all(iter)=fitness_max;
    fitness_ave(iter)=sum(fitness)/length(fitness);
end

%% 显示结果
hold on
plot(1:gen,fitness_best_all-4600,'r')
plot(1:gen,fitness_ave-2650,'b')
hold off
legend(['平均适应度';'最佳适应度']);
disp(['最大值为',num2str(1/fitness_best)])
disp('对应解为')
disp(best_chrom)

