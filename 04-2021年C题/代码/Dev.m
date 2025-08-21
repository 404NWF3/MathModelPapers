function fdev= Dev(r)
% 订供偏差函数
% 反映订>供、订<供对企业的影响变化程度不同
if r>=0
    fdev=exp(r)-1;
else
    fdev=exp(-2*r)-1;
end
end