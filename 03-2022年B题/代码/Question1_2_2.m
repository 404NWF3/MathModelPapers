%% 当新增发射信号无人机数目n=2（即共有四架无人机发射信号）的情况
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
RA=1;
% QQ=[40,80,120,160,200,240,280,320];
QQ=[40/180*pi,80/180*pi,120/180*pi,160/180*pi,200/180*pi,240/180*pi,280/180*pi,320/180*pi];
result={};                                       %模拟次数所有结果
allselect=nchoosek(QQ,2);
for l=1:28
    allselect(28+l,1)=allselect(l,2);
    allselect(28+l,2)=allselect(l,1);
end
%% 选择增加发射信号无人机位置
for k=1:56
qq=QQ;
% m=find(QQ==allselect(k,1));
% n=find(QQ==allselect(k,2));
select(1,1)=allselect(k,1);
select(1,2)=allselect(k,2);
qq(qq==(allselect(k,1)))=[];
qq(qq==(allselect(k,2)))=[];
rest=qq;
%% 剩余接收信号无人机位置
for ii=1:6
    QA=rest(ii);
    j=1;
%% 随机产生满足约束的1000个模拟点
while(1)
    R1=R+R*(1-2*rand);
    Q=QA+(1-2*rand);
    if((RA*cos(QA)-R1*cos(Q))^2+(RA*sin(QA)-R1*sin(Q))^2<=(0.02*R)^2)
        coordinate(j,1)=R1;
        coordinate(j,2)=Q;
        j=j+1;
    end
    if j==1001
        break;
    end
end
%% 根据多种情况组合，确定发射信号无人机以及接受信号无人机，模拟10000次开始
for j=1:1000    
    AB=sqrt((coordinate(j,1)*cos(coordinate(j,2))-R)^2+(coordinate(j,1)*sin(coordinate(j,2))-0)^2); 
    AC=sqrt((coordinate(j,1)*cos(coordinate(j,2))-R*cos(select(1,1)))^2+(coordinate(j,1)*sin(coordinate(j,2))-R*sin(select(1,1)))^2);
    BC=sqrt((R*cos(select(1,1))-R)^2+(R*sin(select(1,1))-0)^2);
    CD=sqrt((R*cos(select(1,1))-R*cos(select(1,2)))^2+(R*sin(select(1,1))-R*sin(select(1,2)))^2);
    BD=sqrt((R*cos(select(1,2))-R)^2+(R*sin(select(1,2))-0)^2);
    AD=sqrt((coordinate(j,1)*cos(coordinate(j,2))-R*cos(select(1,2)))^2+(coordinate(j,1)*sin(coordinate(j,2))-R*sin(select(1,2)))^2);
    x1=acos((AB^2+(coordinate(j,1))^2-R^2)/(2*(coordinate(j,1))*AB));
    x2=acos((AC^2+(coordinate(j,1))^2-R^2)/(2*(coordinate(j,1))*AC));
    x3=acos((AB^2+AC^2-BC^2)/(2*AB*AC));
    x4=acos(((coordinate(j,1))^2+AD^2-R^2)/(2*coordinate(j,1)*AD));
    x5=acos((AC^2+AD^2-CD^2)/(2*AD*AC));
    x6=acos((AB^2+AD^2-BD^2)/(2*AB*AD));
    x1=x1/pi*180;
    x2=x2/pi*180;
    x3=x3/pi*180;
    x4=x4/pi*180;
    x5=x5/pi*180;
    x6=x6/pi*180;
    x=[x1,x2,x3,x4,x5,x6];
    x=sort(x);
    X(j,1)=(abs(x(1,1)-9.8)+abs(x(1,2)-20.58)+abs(x(1,3)-20.96)+abs(x(1,4)-30.68)+abs(x(1,5)-41.54)+abs(x(1,6)-51.34))/6;      %求解随机模拟确定角度与实际值总误差；
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