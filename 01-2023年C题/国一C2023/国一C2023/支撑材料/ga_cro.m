function new_chrom=ga_cro(chrom,cro,n,narvs,x_up,x_dw,relation)
for i=1:n
        pcro=rand;
        if pcro<cro    %若随机数小于交叉率，进行交叉，否则不交叉
            x=chrom(i,:);
            %随机选取需要进行交叉的点位
            d=ceil(rand(narvs/2,1)*(narvs/2));
            e=ceil(rand(narvs/2,1)*(narvs/2));
            %对点位进行修正
            for j=1:narvs/2
                if d(j)==0
                    d(j)=1;
                elseif e(j)==0
                    e(j)=1;
                end
            end
            index=[d,e];
            text=zeros(narvs/2,1);
            %导入每一组相关系数
            for j=1:length(index)
                text(j)=relation(d(j),e(j));
            end
            table=[text,index];
            table=sortrows(table,'descend');
            %依据覆盖率按照相关系数进行由大到小的排序
            cover=rand;
            while cover<0.7
                cover=rand;
            end
            range=round(narvs*cover/2);
            table=table(1:range,:);
            for k=1:range
                pick=rand;
                v1=x(table(k,2));
                v2=x(table(k,2));
                x(table(k,2))=pick*v2+(1-pick)*v1;  
                x(table(k,3))=pick*v1+(1-pick)*v2;
            end
            x=check(x,x_up,x_dw);
            chrom(i,:)=x;
%对后半段染色体进行相同操作
            x=chrom(i,:);
            d=ceil(rand(narvs/2,1)*(narvs/2)+narvs/2);
            e=ceil(rand(narvs/2,1)*(narvs/2)+narvs/2);
            for j=1:narvs/2
                if d(j)==0
                    d(j)=1;
                elseif e(j)==0
                    e(j)=1;
                end
            end
            index=[d,e];
            text=zeros(narvs/2,1);
            d=d-narvs/2;
            e=e-narvs/2;
            for j=1:narvs/2
                if d(j)==0
                    d(j)=1;
                elseif e(j)==0
                    e(j)=1;
                end
            end
            for j=1:length(index)
                text(j)=relation(d(j),e(j));
            end
            table=[text,index];
            table=sortrows(table,'descend');
            cover=rand;
            while cover<0.7
                cover=rand;
            end
            range=round(narvs*cover/2);
            table=table(1:range,:);
            for k=1:range
                pick=rand;
                v1=x(table(k,2));
                v2=x(table(k,2));
                x(table(k,2))=pick*v2+(1-pick)*v1;  
                x(table(k,3))=pick*v1+(1-pick)*v2;
            end
            x=check(x,x_up,x_dw);
            chrom(i,:)=x; 
        else
            continue;
        end
     new_chrom=chrom;
end     
end

    
    
   
            