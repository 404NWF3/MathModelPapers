%% �����������ź����˻���Ŀn=2���������ļ����˻������źţ������
% R ���˻������ΧԲ�ܰ뾶
% Q ���˻����յ��ķ�����Ϣ
% ���������ʱ��ԼΪ1����
%% ���
clc
clear 
tic
%% ��������ʼ��
R=1;                                             %��Ϊ�ٶ����˻����Բ�ܣ��ɸ���ʵ������ı䣩
n=9;                                             %Բ�������˻������Ŀ
RA=1;
% QQ=[40,80,120,160,200,240,280,320];
QQ=[40/180*pi,80/180*pi,120/180*pi,160/180*pi,200/180*pi,240/180*pi,280/180*pi,320/180*pi];
result={};                                       %ģ��������н��
allselect=nchoosek(QQ,2);
for l=1:28
    allselect(28+l,1)=allselect(l,2);
    allselect(28+l,2)=allselect(l,1);
end
%% ѡ�����ӷ����ź����˻�λ��
for k=1:56
qq=QQ;
% m=find(QQ==allselect(k,1));
% n=find(QQ==allselect(k,2));
select(1,1)=allselect(k,1);
select(1,2)=allselect(k,2);
qq(qq==(allselect(k,1)))=[];
qq(qq==(allselect(k,2)))=[];
rest=qq;
%% ʣ������ź����˻�λ��
for ii=1:6
    QA=rest(ii);
    j=1;
%% �����������Լ����1000��ģ���
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
%% ���ݶ��������ϣ�ȷ�������ź����˻��Լ������ź����˻���ģ��10000�ο�ʼ
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
    X(j,1)=(abs(x(1,1)-9.8)+abs(x(1,2)-20.58)+abs(x(1,3)-20.96)+abs(x(1,4)-30.68)+abs(x(1,5)-41.54)+abs(x(1,6)-51.34))/6;      %������ģ��ȷ���Ƕ���ʵ��ֵ����
    min_X=min(X);
    [row,column]=find(X==min_X);                                       %Ѱ����ӽ�ʵ��ֵ��ȡ�㼫����
    X=sort(X);
end
    result{k,ii}=X;
    minresult(k,ii)=min(result{k,ii});                                 %�����С�������
    minresult_coordinateR=coordinate(row,1);                           %�����С����
    minresult_coordinateQ=coordinate(row,2);                           %�����С����
    minresult_coordinate{k,ii}=[coordinate(row,1),coordinate(row,2)/pi*180];
    end
end
toc