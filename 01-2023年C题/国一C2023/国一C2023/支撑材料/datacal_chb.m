%此处代码用于计算成本
clc,clear;
price_all=[];
mass_all=[];
for ii=1:6
    data=xlsread('附件3.xlsx');
    price=zeros(30,1);
    mass=zeros(30,1);
    [m,n]=size(data);
    flag=1;
    for i=1:m
        if data(i,1)==flag
            price(flag,1)=data(i,2)+price(flag,1);
            mass(flag,1)=data(i,3)+mass(flag,1);
        else
            while data(i,1)~=flag
                flag=flag+1;
                if data(i,1)==flag
                    price(flag,1)=data(i,2)+price(flag,1);
                    mass(flag,1)=data(i,3)+mass(flag,1);
                    break;
                end
            end
        end
    end
    price_all=[price_all,price];
    mass_all=[mass_all,mass];
end
chb_all=price_all./mass_all;