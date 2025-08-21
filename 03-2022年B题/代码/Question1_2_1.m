%% 当新增发射信号无人机数目n=1（即共有三架无人机发射信号）的情况
% R 无人机编队所围圆周半径
% Q 无人机接收到的方向信息
% 程序的运行时间约为1分钟
%% 清除
clc
clear 
tic
%% 程序求解初始化
R=1;                                             %人为假定无人机编队圆周（可根据实际情况改变）
n=9;                                             %圆周上无人机编队数目
result={};                                       %模拟次数所有结果
%% 选择增加发射信号无人机位置
for k=1:8                                        
    RA=1;                                        
    QQ=[40/180*pi,80/180*pi,120/180*pi,160/180*pi,200/180*pi,240/180*pi,280/180*pi,320/180*pi];
    select=QQ(k);
    qq=QQ;
    qq(k)=[];
    rest=qq;
%% 剩余接收信号无人机位置
for ii=1:7
    QA=rest(ii);
    j=1;
%% 随机产生满足约束的10000个模拟点
while(1)
    R1=R+R*(1-2*rand);
    Q=QA+(1-2*rand);
    if((RA*cos(QA)-R1*cos(Q))^2+(RA*sin(QA)-R1*sin(Q))^2<=(0.1*R)^2)
        coordinate(j,1)=R1;
        coordinate(j,2)=Q;
        j=j+1;
    end
    if j==10001
        break;
    end
    end
%% 根据多种情况组合，确定发射信号无人机以及接受信号无人机，模拟10000次开始
for j=1:10000                                   
    AB=sqrt((coordinate(j,1)*cos(coordinate(j,2))-R)^2+(coordinate(j,1)*sin(coordinate(j,2))-0)^2); 
    AC=sqrt((coordinate(j,1)*cos(coordinate(j,2))-R*cos(select))^2+(coordinate(j,1)*sin(coordinate(j,2))-R*sin(select))^2);
    BC=sqrt((R*cos(select)-R)^2+(R*sin(select)-0)^2);
    x1=acos((AB^2+(coordinate(j,1))^2-R^2)/(2*(coordinate(j,1))*AB));
    x2=acos((AC^2+(coordinate(j,1))^2-R^2)/(2*(coordinate(j,1))*AC));
    x3=acos((AB^2+AC^2-BC^2)/(2*AB*AC));
    x1=x1/pi*180;
    x2=x2/pi*180;
    x3=x3/pi*180;
    x=[x1,x2,x3];
    x=sort(x);
    X(j,1)=(abs(x(1,1)-9.8)+abs(x(1,2)-20.58)+abs(x(1,3)-30.68))/3;      %求解随机模拟确定角度与实际值总误差；
    min_X=min(X);
    [row,column]=find(X==min_X);                                       %寻找最接近实际值所取点极坐标
    X=sort(X);
end
    result{k,ii}=X;
    minresult(k,ii)=min(result{k,ii});                                 %求解最小总误差结果
    minresult_coordinateR=coordinate(row,1);                           %求解最小误差极径
    minresult_coordinateQ=coordinate(row,2);                           %求解最小误差极点
    minresult_coordinate{k,ii}=[coordinate(row,1),coordinate(row,2)/pi*180];
end
end
toc