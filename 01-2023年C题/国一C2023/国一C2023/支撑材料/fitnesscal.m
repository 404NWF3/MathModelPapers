function profit=fitnesscal(chrom,label,ch,dis,rate,x_up,x_dw,choice,sale)
m=length(label);
[n,~]=size(chrom);
profit=zeros(n,1);
for i=1:n
    income=0;
    discount=0;
    for j=1:m
        if label(j)==1
            income=income+obj_fun1(chrom(i,j))*sale(j);
            discount=discount+(chrom(i,j+m)-chrom(i,j))*rate(choice(j))*dis(choice(j));
        elseif label(j)==2
            income=income+obj_fun2(chrom(i,j))*sale(j);
            discount=discount+(chrom(i,j+m)-chrom(i,j))*rate(choice(j))*dis(choice(j));
        elseif label(j)==3
            income=income+obj_fun3(chrom(i,j))*sale(j);
            discount=discount+(chrom(i,j+m)-chrom(i,j))*rate(choice(j))*dis(choice(j));
        elseif label(j)==4
            income=income+obj_fun4(chrom(i,j))*sale(j);
            discount=discount+(chrom(i,j+m)-chrom(i,j))*rate(choice(j))*dis(choice(j));
        elseif label(j)==5
            income=income+obj_fun5(chrom(i,j))*sale(j);
            discount=discount+(chrom(i,j+m)-chrom(i,j))*rate(choice(j))*dis(choice(j));
        elseif label(j)==6
            income=income+obj_fun6(chrom(i,j))*sale(j);
            discount=discount+(chrom(i,j+m)-chrom(i,j))*rate(choice(j))*dis(choice(j));
        end
    end
    cheng=chrom(i,m+1:2*m)*ch(choice);
    profit(i)=income-cheng+discount;
end