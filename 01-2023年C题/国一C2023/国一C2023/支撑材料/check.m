%次函数用于检查染色体范围是否越界
function result=check(x,x_up,x_dw)
[m,n]=size(x);
for i=1:m
    for j=1:n
        if x(i,j)>x_up(j)            %检查每个数是否越界
            x(i,j)=x_up(j);
        elseif x(i,j)<x_dw(j)  
            x(i,j)=x_dw(j);
        end
    end
result=x;
end