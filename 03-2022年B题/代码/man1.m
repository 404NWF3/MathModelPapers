Polar_coordinates=[0,0;100,0;98,40.10;112,80.21;105,119.75;98,159.86;112,199.96;105,240.07;98,280.17;112,320.28];
axis([-120,120 -120,120]);
for i=1:10
    center_coordinate(i,1)=Polar_coordinates(i,1)*cos((Polar_coordinates(i,2))/180*pi);
    center_coordinate(i,2)=Polar_coordinates(i,1)*sin((Polar_coordinates(i,2))/180*pi);
    draw_coordinate=center_coordinate(i,:);
    DrawAirplane(draw_coordinate);
    hold on
end
hold on
% for i=1:n
%     
% center_coordinate(i)=[0,0];
% DrawAirplane(center_coordinate)
% 
% end
 for j=1:0.1:20
   draw_coordinate(1,1)=draw_coordinate(1,1)+j;
   draw_coordinate(1,2)=draw_coordinate(1,2)+j;
%     DrawAirplane(draw_coordinate);
    DrawAirplane(draw_coordinate);
    hold on
     pause(1);
     ln.XDataSource = 'draw_coordinate(1,1)';
ln.YDataSource = 'draw_coordinate(1,1)';
     refreshdata
    end
axis equal
% axis([-120,120 -120,120]);
% for i=1:0.1:20
%   
%     clf reset
%    axis([-120,120 -120,120]);
%    center_coordinate(1,1)=center_coordinate(1,1)+i;
%    center_coordinate(1,2)=center_coordinate(1,2)+i;
%     pause(0.11);
% %     delete(DrawAirplane(center_coordinate));
% %     DrawAirplane(center_coordinate)
% %      pause(1);
% end
    