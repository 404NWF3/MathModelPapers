%% 求解第二问中无人机调度成方形编队队形
%% 程序运行大致需要16s
%% 清除
clc
clear 
tic
%% 初始化
L=100;
C=0;
Target_location=[100,100;100,400;400,100;200,100;300,100;100,200;200,200;300,200;400,200;100,300;200,300;300,300;400,300;200,400;300,400;400,400];
Actual_coordinates=[100,100;102,398;402,101;198,98;298,101;99,202;198,201;298,201;401,200;99,298;199,302;302,298;401,303;204,399;302,401;398,402];
% deviation_location=[];
%      draw_coordinate=[100,100];
%      DrawAirplane(draw_coordinate);
%      hold on
% end
% for N=1:1000
%% 调度外围三个顶点所在无人机飞向目标位置

Vertex_position1=[100,400];
Vertex_position2=[400,100];
j=1;i=1;
while(1)
    a=-1;b=1;
    Simulate_pointsx1=Vertex_position1(1,1)+a+(b-a)*rand;
    Simulate_pointsy1=Vertex_position1(1,2)+a+(b-a)*rand;
    if(((Simulate_pointsx1-Vertex_position1(1,1))^2+(Simulate_pointsy1-Vertex_position1(1,2))^2)<3)
    Simulate_points1(j,1)=Simulate_pointsx1;
    Simulate_points1(j,2)=Simulate_pointsy1;
    j=j+1;
    end
    if j==10001
        break;
    end
end
    while(1)
    a=-1;b=1;
    Simulate_pointsx2=Vertex_position2(1,1)+a+(b-a)*rand;
    Simulate_pointsy2=Vertex_position2(1,2)+a+(b-a)*rand;
    if(((Simulate_pointsx2-Vertex_position2(1,1))^2+(Simulate_pointsy2-Vertex_position2(1,2))^2)<3)
    Simulate_points2(i,1)=Simulate_pointsx2;
    Simulate_points2(i,2)=Simulate_pointsy2;
    i=i+1;
    end
    if i==10001
        break;
    end
    end
    for ii=1:2000
    eq1=(Simulate_points2(ii,1)-Vertex_position1(1,1))^2;
    eq2=(Simulate_points2(ii,2)-Vertex_position1(1,2))^2;
    eq3=(Simulate_points2(ii,1)-100)^2;
    eq4=(Simulate_points2(ii,2)-100)^2;
    eq5=(100-Vertex_position1(1,1))^2;
    eq6=(100-Vertex_position1(1,2))^2;
    eq7=sqrt(eq1+eq2);
    eq8=sqrt(eq3+eq4);
    Q1=acos((eq1+eq2+eq3+eq4-eq5-eq6)/(2*eq7*eq8));
    Q1=Q1/pi*180;
    deviationQ1(1,ii)=abs(Q1-45); %计算其与领航与另一顶点的夹交，使其无限逼近45°保留其优结果
    eq1=(Simulate_points1(ii,1)-Vertex_position2(1,1))^2;
    eq2=(Simulate_points1(ii,2)-Vertex_position2(1,2))^2;
    eq3=(Simulate_points1(ii,1)-100)^2;
    eq4=(Simulate_points1(ii,2)-100)^2;
    eq5=(100-Vertex_position2(1,1))^2;
    eq6=(100-Vertex_position2(1,2))^2;
    eq7=sqrt(eq1+eq2);
    eq8=sqrt(eq3+eq4);
    Q2=acos((eq1+eq2+eq3+eq4-eq5-eq6)/(2*eq7*eq8));
    Q2=Q2/pi*180;
    deviationQ2(1,ii)=abs(Q2-45);%计算其与领航与另一顶点的夹交，使其无限逼近45°保留其优结果
    Q(1,ii)=deviationQ1(1,ii)+deviationQ2(1,ii);
    end
    [x,y]=min(Q);
    Determine_vertices1(1,1)=Simulate_points1(y,1);
    Determine_vertices1(1,2)=Simulate_points1(y,2);
    Determine_vertices2(1,1)=Simulate_points2(y,1);
    Determine_vertices2(1,2)=Simulate_points2(y,2);
 for N=1:1000
for i=4:16
    x=Target_location(i,1);
    y=Target_location(i,2); 
    j=1;
    while(1)
    a=-1;b=1;
    Simulate_coordinates1=Actual_coordinates(i,1)+a+(b-a)*rand;
    Simulate_coordinates2=Actual_coordinates(i,2)+a+(b-a)*rand;
    if(((Simulate_coordinates1-Actual_coordinates(i,1))^2+(Simulate_coordinates2-Actual_coordinates(i,2))^2)<3)
    Simulate_collections(j,1)=Simulate_coordinates1;
    Simulate_collections(j,2)=Simulate_coordinates2;
    j=j+1;
    if j>2001
        break;
    end
    end
    end
    [a1,a2,a3]=Ideal_Cosine_theorem(x,y);
    A=sort([a1 a2 a3]);
    for n=1:2000
        xx=Simulate_collections(n,1);
        yy=Simulate_collections(n,2);
        [x1,x2,x3]=Actual_Cosine_theorem(xx,yy,Determine_vertices1(1,1),Determine_vertices1(1,2),Determine_vertices2(1,1),Determine_vertices2(1,2));
        B=sort([x1,x2,x3]);
        C(1,n)=abs(A(1,1)-B(1,1))+abs(A(1,2)-B(1,2))+abs(A(1,3)-B(1,3)); 
end
     [f,g]=min(C);
     New_coordinates(2,1)=Determine_vertices1(1,1);
     New_coordinates(2,2)=Determine_vertices1(1,2);
     New_coordinates(1,1)=100;
     New_coordinates(1,2)=100;
     New_coordinates(3,1)=Determine_vertices2(1,1);
     New_coordinates(3,2)=Determine_vertices2(1,2);
     New_coordinates(i,1)=Simulate_collections(g,1);
     New_coordinates(i,2)=Simulate_collections(g,2);
   
end
 distance1=0;distance2=0;
for kk=1:16
     dis1=sqrt((New_coordinates(kk,1)-Target_location(kk,1))^2+(New_coordinates(kk,2)-Target_location(kk,2))^2);
     distance1=distance1+dis1;
     dis2=sqrt((Actual_coordinates(kk,1)-Target_location(kk,1))^2+(Actual_coordinates(kk,1)-Target_location(kk,2))^2);
     distance2=distance2+dis2;
end
    distance(1,N)=distance1;
end
distance=sort(distance,2,'descend');
%% 绘制调度前与调度后无人机图像
% axis([-120,120 -120,120]);
for mm=1:16
    center_coordinate(mm,1)=Actual_coordinates(mm,1);
    center_coordinate(mm,2)=Actual_coordinates(mm,2);
    draw_coordinate=center_coordinate(mm,:);
    DrawAirplane(draw_coordinate);
    hold on
end
for nn=1:16
    center_coordinatelast(nn,1)=New_coordinates(nn,1);
    center_coordinatelast(nn,2)=New_coordinates(nn,2);
    draw_coordinate=center_coordinatelast(nn,:);
    DrawAirplane1(draw_coordinate);
    hold on
    colormap winter;
end
xlabel('X');
ylabel('Y');
title('无人机调度前与调度后位置对比');
toc
%% 调度剩余无人机飞向目标位置
figure(2)
plot(distance);
xlabel('迭代次数');
ylabel('距离误差');
title('调度坐标与目标坐标距离误差');
hold on