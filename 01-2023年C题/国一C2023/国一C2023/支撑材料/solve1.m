%% 求解第二问模型
clc,clear;
%导入数据
load predict.mat;
c=predict;
rate=[1.32204725500000, 10.9839178300000, 14.1584886500000 8.47212605900000, 7.84135120100000, 5.74567672500000]/100;
p1= [1.357, -4.009, 7.92, 1.116, 2.256, -4.988];
p2= [103, 1447, -927.9, 423.8, 835, 476.7];
p3=[-156.5, -1735, 35760, -13.61, -341.4, -305.4];
q1=[-3.975, 149.7, -104.3, -23.42, 23.51, 1.389];
q2=[4.276, -554.3, 3153, 2702, -18.46, -1.679];
x=zeros(7,6);
f=zeros(7,6);
p=zeros(7,6);
%由于此处目标函数形式较为简单，可以通过暴力搜索算法进行求解
for i=1:7
    for j=1:6
        x_best=0;
        f_best=-1000000;
        xline=0:0.1:300;
        for k=1:length(xline)
            xin=xline(k);
            xiao=xin*(1-rate(j));
            fs=(p1(j)*xiao^2+p2(j)*xiao+p3(j))/(xiao^2+q1(j)*xiao+q2(j))*xiao-c(i,j)*xin;
            ps=(p1(j)*xiao^2+p2(j)*xiao+p3(j))/(xiao^2+q1(j)*xiao+q2(j))
            if fs>f_best
                f_best=fs;
                x_best=xin;
                p_best=ps;
            end
        end
        f(i,j)=f_best;
        x(i,j)=x_best;
        p(i,j)=p_best;
    end
end
%显示总利润
sum(f);
sum(ans);