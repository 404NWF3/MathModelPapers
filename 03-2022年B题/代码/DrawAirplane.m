function []=DrawAirplane(center_coordinate)
% �ú��������ڶ�ά����ƽ���ϻ��Ʒɻ�
%Plane_coordinates����ɻ������꼯��
% center_coordinate=[0,0];
Plane_coordinate(1).x=center_coordinate(1,1);%�ɻ���ʼx����
Plane_coordinate(1).y=center_coordinate(1,2);%�ɻ���ʼy����
%% �ɻ���ͷ����
Plane_coordinate(2).x=Plane_coordinate(1).x+8;
Plane_coordinate(2).y=Plane_coordinate(1).y;

%% �ɻ���������
Plane_coordinate(3).x=Plane_coordinate(1).x+7;
Plane_coordinate(3).y=Plane_coordinate(1).y+1;

%% �ɻ���������
Plane_coordinate(4).x=Plane_coordinate(1).x+1;
Plane_coordinate(4).y=Plane_coordinate(1).y+1;
Plane_coordinate(5).x=Plane_coordinate(1).x-4;
Plane_coordinate(5).y=Plane_coordinate(1).y+8;
Plane_coordinate(6).x=Plane_coordinate(1).x-5;
Plane_coordinate(6).y=Plane_coordinate(1).y+8;
%% �ɻ���β����
Plane_coordinate(7).x=Plane_coordinate(1).x-2;
Plane_coordinate(7).y=Plane_coordinate(1).y+1;
Plane_coordinate(8).x=Plane_coordinate(1).x-7;
Plane_coordinate(8).y=Plane_coordinate(1).y+1;
Plane_coordinate(9).x=Plane_coordinate(1).x-9;
Plane_coordinate(9).y=Plane_coordinate(1).y+4;
Plane_coordinate(10).x=Plane_coordinate(1).x-9;
Plane_coordinate(10).y=Plane_coordinate(1).y;
%% ��һ��ɻ�����
Plane_coordinate(11).x=Plane_coordinate(1).x-9;
Plane_coordinate(11).y=Plane_coordinate(1).y-4;
Plane_coordinate(12).x=Plane_coordinate(1).x-7;
Plane_coordinate(12).y=Plane_coordinate(1).y-1;
Plane_coordinate(13).x=Plane_coordinate(1).x-2;
Plane_coordinate(13).y=Plane_coordinate(1).y-1;
Plane_coordinate(14).x=Plane_coordinate(1).x-5;
Plane_coordinate(14).y=Plane_coordinate(1).y-8;
Plane_coordinate(15).x=Plane_coordinate(1).x-4;
Plane_coordinate(15).y=Plane_coordinate(1).y-8;
Plane_coordinate(16).x=Plane_coordinate(1).x+1;
Plane_coordinate(16).y=Plane_coordinate(1).y-1;
Plane_coordinate(17).x=Plane_coordinate(1).x+7;
Plane_coordinate(17).y=Plane_coordinate(1).y-1;
Plane_coordinate(18).x=Plane_coordinate(1).x+8;
Plane_coordinate(18).y=Plane_coordinate(1).y;
for i=2:17
    line([Plane_coordinate(i).x,Plane_coordinate(i+1).x],[Plane_coordinate(i).y,Plane_coordinate(i+1).y],'Color','red','LineWidth',2);
end
%% 
% axis([-120,120 -120,120]);
% h=plot(Plane_coordinate.x,Plane_coordinate.y);
% for i=1:0.1:5
%     center_coordinate(1,1)=center_coordinate(1,1)+i;
%     center_coordinate(1,2)=center_coordinate(1,2)+i;
%     set(h,'xData',Plane_coordinate.x,'yData',Plane_coordinate.y);
%     drawnow;
% end