function new_chrom=ga_sel(fitness,chrom,m)
        pro=fitness/sum(fitness);  %采用轮盘赌的方式进行选择
        pro_sum=zeros(m,1);
        index=[];
        for i=1:m
            pro_sum(i)=sum(pro(1:i));
        end
        for i=1:m
            p=rand(1);
            for j=1:m
                if p<pro_sum(1)
                    index=[index,j];
                    break;
                elseif p<pro_sum(j)&&p>pro_sum(j-1)
                    index=[index,j];
                end
            end
        end
        new_chrom=chrom(index,:);
end