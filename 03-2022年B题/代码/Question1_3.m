%% 新增发射信号无人机数目n=1（即共有三架无人机发射信号）的情况
% R 无人机编队所围圆周半径
% Q 无人机接收到的方向信息
% 程序的运行时间约为80s
%% 清除
clc
clear 
tic
%% 程序求解初始化
R=100;                                           %人为假定无人机编队圆周（可根据实际情况改变）
n=9;                                             %圆周上无人机编队数目
result={};                                       %模拟次数所有结果
%% 模拟除FYOO与FYO1外所有无人机位置调度五十次循环
for m=1:50
for k=1:8                                        
    RA=1;                                        
    QQ=[40/180*pi,80/180*pi,120/180*pi,160/180*pi,200/180*pi,240/180*pi,280/180*pi,320/180*pi];
    QQ1=[40.10/180*pi,80.21/180*pi,119.75/180*pi,159.86/180*pi,199.96/180*pi,240.07/180*pi,280.17/180*pi,320.28/180*pi];
    RR=[98,112,105,98,112,105,112,98];
    select_ideal=QQ(k);
    mm=QQ;
    mm(k)=[];
    ideal=mm;
    select_Q=QQ1(k);
    qq=QQ1;
    qq(k)=[];
    rest=qq;
    select_R=RR(k);
    FF=RR;
    FF(k)=[];
    actual_R=FF;
%% 剩余接收信号无人机位置
for ii=1:7
    rest_actual=rest(ii);
    rest_ideal1=ideal(ii);
    rest_R=actual_R(ii);
    j=1;
    AB=sqrt((R*cos(select_ideal)-100)^2+(R*sin(select_ideal)-0)^2); 
    AC=sqrt((R*cos(select_ideal)-R*cos(rest_ideal1))^2+(R*sin(select_ideal)-R*sin(rest_ideal1))^2);
    BC=sqrt((R*cos(rest_ideal1)-100)^2+(R*sin(rest_ideal1)-0)^2);
    x4=acos((AC^2+R^2-R^2)/(2*AC*R));
    x5=acos((R^2+BC^2-R^2)/(2*R*BC));
    x6=acos((BC^2+AC^2-AB^2)/(2*BC*AC));
    x4=x4/pi*180;
    x5=x5/pi*180;
    x6=x6/pi*180;
    XX=[x4,x5,x6];
    XX=sort(XX);
%% 随机产生满足约束的2000个模拟点
while(1)
    a=-1;b=1;
    R1=rest_R+a+(b-a)*rand;
    Q=(rest_actual*180/pi-1+(1+1)*rand)/180*pi;
    if((rest_R*cos(rest_actual)-R1*cos(Q))^2+(rest_R*sin(rest_actual)-R1*sin(Q))^2<=(0.05*R)^2)
        coordinate(j,1)=R1;
        coordinate(j,2)=Q;
        j=j+1;
    end
    if j==2001
        break;
    end
end
%% 根据多种情况组合，确定发射信号无人机以及接受信号无人机，模拟1000次开始
for j=1:2000                                   
    AB=sqrt((select_R*cos(select_Q)-100)^2+(select_R*sin(select_Q)-0)^2); 
    AC=sqrt((select_R*cos(select_Q)-coordinate(j,1)*cos(coordinate(j,2)))^2+(select_R*sin(select_Q)-coordinate(j,1)*sin(coordinate(j,2)))^2);
    BC=sqrt((coordinate(j,1)*cos(coordinate(j,2))-100)^2+(coordinate(j,1)*sin(coordinate(j,2))-0)^2);
    x1=acos((AC^2+coordinate(j,1)^2-AB^2)/(2*AC*coordinate(j,1)));
    x2=acos((coordinate(j,1)^2+BC^2-R^2)/(2*coordinate(j,1)*BC));
    x3=acos((BC^2+AC^2-AB^2)/(2*BC*AC));
    x1=x1/pi*180;
    x2=x2/pi*180;
    x3=x3/pi*180;
    x=[x1,x2,x3];
    x=sort(x);
    X(j,1)=(abs(x(1,1)-XX(1,1))+abs(x(1,2)-XX(1,2))+abs(x(1,3)-XX(1,3)))/3;      %求解随机模拟确定角度与实际值总误差；
    min_X=min(X);
    [row,column]=find(X==min_X);                                       %寻找最接近实际值所取点极坐标
    X=sort(X);
end
    result{k,ii}=X;
    minresult(k,ii)=min(result{k,ii});                                 %求解最小总误差结果
    distance1(k,ii)=sqrt((coordinate(row,1)*cos(coordinate(row,2))-100*cos(rest_ideal1))^2+(coordinate(row,1)*sin(coordinate(row,2))-100*sin(rest_ideal1))^2);
    distance2(k,ii)=sqrt((select_R*cos(rest_actual)-100*cos(rest_ideal1))^2+( select_R*sin(rest_actual)-100*sin(rest_ideal1))^2);
    if (distance1(k,ii)-distance2(k,ii)>0)
       distance(k,ii)= distance2(k,ii);
       minresult_coordinate{k,ii}=[select_R,rest_actual/pi*180];
    else
        distance(k,ii)= distance1(k,ii);
        minresult_coordinate{k,ii}=[coordinate(row,1),coordinate(row,2)/pi*180];
    end
%     minresult_coordinateR=coordinate(row,1);                           
%     minresult_coordinateQ=coordinate(row,2);                           
%     minresult_coordinate{k,ii}=[coordinate(row,1),coordinate(row,2)/pi*180];
%      number=sum(distance,2);
%      [v,t]=min(number);
%      [c,r]=find(distance==min(distance(:,t)));
%      resrnumber=distance(c,r);
%      dis=v+resrnumber;
%      plot(m,dis);
     
end
end
end
finally=sum(distance,2);
[p,y]=min(finally);
[c,r]=find(distance==min(distance(:,y)));
Polar_coordinateslast(8,:)=minresult_coordinate{c,r};
for i=1:7
    Polar_coordinateslast(i,:)=minresult_coordinate{y,i};
end
Polar_coordinateslast(9,:)=[0,0];
Polar_coordinateslast(10,:)=[100,0];
%% 绘制调度前与调度后无人机图像
Polar_coordinates=[0,0;100,0;98,40.10;112,80.21;105,119.75;98,159.86;112,199.96;105,240.07;98,280.17;112,320.28];
axis([-120,120 -120,120]);
for i=1:10
    center_coordinate(i,1)=Polar_coordinates(i,1)*cos((Polar_coordinates(i,2))/180*pi);
    center_coordinate(i,2)=Polar_coordinates(i,1)*sin((Polar_coordinates(i,2))/180*pi);
    draw_coordinate=center_coordinate(i,:);
    DrawAirplane(draw_coordinate);
    hold on
end
for i=1:10
    center_coordinatelast(i,1)=Polar_coordinateslast(i,1)*cos((Polar_coordinateslast(i,2))/180*pi);
    center_coordinatelast(i,2)=Polar_coordinateslast(i,1)*sin((Polar_coordinateslast(i,2))/180*pi);
    draw_coordinate=center_coordinatelast(i,:);
    DrawAirplane1(draw_coordinate);
    hold on
    colormap winter;

end
xlabel('X');
ylabel('Y');
title('无人机调度前与调度后位置对比');
toc