function Score= TOPSIS_score(data)
data1=data;
% %归一化
% for j=1:size(data1,2)
%     data1(:,j)= data(:,j)./sqrt(sum(data(:,j).^2));
% end
%得到信息熵
[m,n]=size(data1);
p=zeros(m,n);
for j=1:n
    p(:,j)=data1(:,j)/sum(data1(:,j));
end
for j=1:n
   E(j)=-1/log(m)*sum(p(:,j).*log(p(:,j)));
end
%计算权重
w=(1-E)/sum(1-E);
%得到加权重后的数据
% w=[0.3724, 0.1003,0.1991, 0.1991,0.0998,0.0485]; %使用求权重的方法求得
R=data1*w';
%得到最大值和最小值距离
r_max=max(R);  %每个指标的最大值
r_min=min(R);  %每个指标的最小值
d_z = sqrt(sum((R -repmat(r_max,size(R,1),1)).^2 ,2)) ;  %d+向量
d_f = sqrt(sum((R -repmat(r_min,size(R,1),1)).^2 ,2)); %d-向量  
%sum(data,2)对行求和 ，sum(data）默认对列求和
%得到得分
s=d_f./(d_z+d_f );
Score=s/max(s);
end