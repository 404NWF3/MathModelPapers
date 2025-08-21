function new_chrom=ga_mut(chrom,mu,m,narvs,x_up,x_dw)
for i=1:m
    for j=1:narvs
        %低于设定变异率则进行交叉
        if rand(1)<mu
            chrom(i,j)=x_dw(j)+(x_up(j)-x_dw(j))*rand(1);
        end
    end
end
chrom=check(chrom,x_up,x_dw);
new_chrom=chrom;
end