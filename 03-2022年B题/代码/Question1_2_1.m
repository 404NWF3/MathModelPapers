%% �����������ź����˻���Ŀn=1���������������˻������źţ������
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
result={};                                       %ģ��������н��
%% ѡ�����ӷ����ź����˻�λ��
for k=1:8                                        
    RA=1;                                        
    QQ=[40/180*pi,80/180*pi,120/180*pi,160/180*pi,200/180*pi,240/180*pi,280/180*pi,320/180*pi];
    select=QQ(k);
    qq=QQ;
    qq(k)=[];
    rest=qq;
%% ʣ������ź����˻�λ��
for ii=1:7
    QA=rest(ii);
    j=1;
%% �����������Լ����10000��ģ���
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
%% ���ݶ��������ϣ�ȷ�������ź����˻��Լ������ź����˻���ģ��10000�ο�ʼ
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
    X(j,1)=(abs(x(1,1)-9.8)+abs(x(1,2)-20.58)+abs(x(1,3)-30.68))/3;      %������ģ��ȷ���Ƕ���ʵ��ֵ����
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