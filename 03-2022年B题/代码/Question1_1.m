%% 求解第一问中的第一小问程序代码
% R 无人机编队所围圆周半径
% Q 无人机接收到的方向信息
% 程序运行时间约为7秒
%% 清除
clc
clear 
tic
%% 程序求解
R=1;                                             %人为假定无人机编队圆周（可根据实际情况改变）
n=9;                                             %圆周上无人机编队数目
for i=1:n                                        %初始化无人机编队极径、极角
    Airplane(i,1)=R;                            
    Airplane(i,2)=(i*40-40);
end
Rm=Airplane(9,1);
Qm=Airplane(9,2);
Rn=Airplane(2,1);
Qn=Airplane(2,2);
sort=perms([1,2,3]);
a(1)=47.3;a(2)=12.84;a(3)=55.7;
g=size(sort,1);
BC=sqrt((Rm*cos(Qm)-Rn*cos(Qn))^2+(Rm*sin(Qm)-Rn*sin(Qn))^2);
%% 方程求解
for j=1:g
x1=a(sort(j,1));
x2=a(sort(j,2));
x3=a(sort(j,3));
syms  RA AB AC QA                                                        %变量
eq1 = AB==sqrt((RA*cos(QA)-Rm*cos(Qm))^2+(RA*sin(QA)-Rm*sin(Qm))^2);     %方程组求解
eq2 = AC==sqrt((RA*cos(QA)-Rn*cos(Qn))^2+(RA*sin(QA)-Rn*sin(Qn))^2);
eq3 = 2*RA*AB*cos(x1)==AB^2+RA^2-R^2;
eq4 = 2*RA*AC*cos(x2)==AC^2+RA^2-R^2;
[RA,AB,AC,QA] = vpasolve(eq1, eq2, eq3,eq4,RA,AB,AC,QA);
RA=double(RA);
AB=double(AB);
AC=double(AC);
QA=double(QA);
result(j,1)=QA;
result(j,2)=RA;
ans1(j,1)=(AB^2+AC^2-BC^2)/(2*AB*AC);
ans1(j,2)=cos(x3);
if(abs(result(j,2)-1.1)<0.05)                                       %验证条件结束迭代
    result(j,1)=QA/pi*180;
    finally_result.Q=result(j,1);               
    finally_result.RA=result(j,2);
    break;
end
end
%% 求解无人机编号
QA=finally_result.Q;                                                
RA=finally_result.RA;
for k=1:n
   distance(k)=sqrt((RA*cos(QA)-Airplane(k,1)*cos(Airplane(k,2))^2+(RA*sin(QA)-Airplane(k,1)*sin(Airplane(k,2))))^2);
end
[x,y]=min(distance);
numberplane=y;
fprintf('无人机的型号为：FY0%d\n',numberplane);
fprintf('无人机所在偏角为：%f°\n',finally_result.Q);
fprintf('无人机有偏差极径为：%f\n',finally_result.RA);
toc