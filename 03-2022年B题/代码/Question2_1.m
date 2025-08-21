%% 求解第二问中无人机调度成锥形编队队形
%% 清除
clc
clear 
tic
%% 初始化
L=50;
C=0;
Target_location=[0,0;3.464*L,2*L;0,4*L;2.598*L,2.5*L;2.598*L,1.5*L;1.732*L,3*L;1.732*L,2*L;1.732*L,L;0.866*L,3.5*L;0.866*L,2.5*L;0.866*L,1.5*L;0.866*L,0.5*L;0,3*L;0,2*L;0,L];
Actual_coordinates=[-0.03,-0.04;3.532,1.98;-0.08,4.05;2.531,2.434;2.632,1.55;1.785,2.95;1.69,2.08;1.688,0.98;0.8891,3.62;0.894,2.43;0.98,1.48;0.89,0.61;0.05,2.94;0.08,1.87;0.05,0.9]*L;
deviation_location=[];
% for i=1:15
%     draw_coordinate=Target_location(i,:);
%     DrawAirplane1(draw_coordinate);
%     hold on
% end
% for N=1:1000
%% 调度外围三个顶点所在无人机飞向目标位置
for N=1:500
Vertex_position1=[0,0];
Vertex_position2=[0,4*L];
j=1;i=1;
while(1)
    a=-0.1*L;b=0.1*L;
    Simulate_pointsx1=Vertex_position1(1,1)+a+(b-a)*rand;
    Simulate_pointsy1=Vertex_position1(1,2)+a+(b-a)*rand;
    if((Simulate_pointsx1-Vertex_position1(1,1))^2+(Simulate_pointsy1-Vertex_position1(1,2))^2)<(0.2*L)
    Simulate_points1(j,1)=Simulate_pointsx1;
    Simulate_points1(j,2)=Simulate_pointsy1;
    j=j+1;
    end
    if j==2001
        break;
    end
end
    while(1)
    a=-0.1*L;b=0.1*L;
    Simulate_pointsx2=Vertex_position2(1,1)+a+(b-a)*rand;
    Simulate_pointsy2=Vertex_position2(1,2)+a+(b-a)*rand;
    if((Simulate_pointsx2-Vertex_position2(1,1))^2+(Simulate_pointsy2-Vertex_position2(1,2))^2)<(0.2*L)
    Simulate_points2(i,1)=Simulate_pointsx2;
    Simulate_points2(i,2)=Simulate_pointsy2;
    i=i+1;
    end
    if i==2001
        break;
    end
    end
    for ii=1:2000
    eq1=(Simulate_points2(ii,1)-Vertex_position1(1,1))^2;
    eq2=(Simulate_points2(ii,2)-Vertex_position1(1,2))^2;
    eq3=(Simulate_points2(ii,1)-3.464*L)^2;
    eq4=(Simulate_points2(ii,2)-2*L)^2;
    eq5=(3.464*L-Vertex_position1(1,1))^2;
    eq6=(2*L-Vertex_position1(1,2))^2;
    eq7=sqrt(eq1+eq2);
    eq8=sqrt(eq3+eq4);
    Q1=acos((eq1+eq2+eq3+eq4-eq5-eq6)/(2*eq7*eq8));
    Q1=Q1/pi*180;
    deviationQ1(1,ii)=abs(Q1-60); %计算其与领航与另一顶点的夹交，使其无限逼近60°保留其优结果
    eq1=(Simulate_points1(ii,1)-Vertex_position2(1,1))^2;
    eq2=(Simulate_points1(ii,2)-Vertex_position2(1,2))^2;
    eq3=(Simulate_points1(ii,1)-3.464*L)^2;
    eq4=(Simulate_points1(ii,2)-2*L)^2;
    eq5=(3.464*L-Vertex_position2(1,1))^2;
    eq6=(2*L-Vertex_position2(1,2))^2;
    eq7=sqrt(eq1+eq2);
    eq8=sqrt(eq3+eq4);
    Q2=acos((eq1+eq2+eq3+eq4-eq5-eq6)/(2*eq7*eq8));
    Q2=Q2/pi*180;
    deviationQ2(1,ii)=abs(Q2-60);%计算其与领航与另一顶点的夹交，使其无限逼近60°保留其优结果
    Q(1,ii)=deviationQ1(1,ii)+deviationQ2(1,ii);
    end
    [x,y]=min(Q);
    Determine_vertices1(1,1)=Simulate_points1(y,1);
    Determine_vertices1(1,2)=Simulate_points1(y,2);
    Determine_vertices2(1,1)=Simulate_points2(y,1);
    Determine_vertices2(1,2)=Simulate_points2(y,2);
for i=4:15
    x=Target_location(i,1);
    y=Target_location(i,2); 
    j=1;
    while(1)
    a=-0.1*L;b=0.1*L;
    Simulate_coordinates1=Actual_coordinates(i,1)+a+(b-a)*rand;
    Simulate_coordinates2=Actual_coordinates(i,2)+a+(b-a)*rand;
    if((Simulate_coordinates1-Actual_coordinates(i,1))^2+(Simulate_coordinates2-Actual_coordinates(i,2))^2)<(0.2*L)
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
     New_coordinates(1,1)=Determine_vertices1(1,1);
     New_coordinates(1,1)=Determine_vertices1(1,2);
     New_coordinates(2,1)=3.464*L;
     New_coordinates(2,2)=2*L;
     New_coordinates(3,1)=Determine_vertices2(1,1);
     New_coordinates(3,2)=Determine_vertices2(1,2);
     New_coordinates(i,1)=Simulate_collections(g,1);
     New_coordinates(i,2)=Simulate_collections(g,2);
end
 distance1=0;distance2=0;
for kk=1:15
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
for mm=1:15
    center_coordinate(mm,1)=Actual_coordinates(mm,1);
    center_coordinate(mm,2)=Actual_coordinates(mm,2);
    draw_coordinate=center_coordinate(mm,:);
    DrawAirplane(draw_coordinate);
    hold on
end
for nn=1:15
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