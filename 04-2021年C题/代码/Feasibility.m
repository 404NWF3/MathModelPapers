function y=Feasibility(a)
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here
b=sum(a.^2);
if abs(b-1)<=0.00001
    y=1;
else
    y=0;
end

end