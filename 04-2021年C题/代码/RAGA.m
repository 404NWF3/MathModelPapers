function [a,b]=RAGA(xx,N,n,Pc,Pm,M,DaiNo,Ci,ads)
tic;
% N为种群规模,Pc为交叉概率,Pm为变异概率,DaiNo为了在进行两代进化之后加速一次而设定的限制数
% n优化变量数目，M变异方向所需要的随机数，Ci为加速次数
% ads为0是求最小值，为其它求最大值。

if ads==0
    ad='ascend';
else
    ad='descend';
end
% ======================step1 生成初始父代==================================
mm1=zeros(1,n);mm2=ones(1,n);
znum=0;
for z=1:Ci    %表示加速次数为20次
    z
    for i=1:N
        while 1==1
            for p=1:n                           %p为优化变量的数目,
                bb(p)=unifrnd(mm1(p),mm2(p));
            end
            temp=sum(bb.^2);
            a=sqrt(bb.^2/temp);
            y=Feasibility(a);
            if y==1
                v(i,:)=a;
                break;
            end
        end
    end
    % step1 end
    for s=1:DaiNo
        % step2 计算适应度
        for i=1:N
            fv(i)=Target(xx,v(i,:));
        end
        %按适应度排序
        [fv,i]=sort(fv,ad);
        v=v(i,:);
        %step2 end
        %step3 计算基于序的评价函数
        arfa=0.05;
        q(1)=0;
        for i=2:N+1
            q(i)=q(i-1)+arfa*(1-arfa)^(i-2);
        end
        %step3 end
        %step4 选择操作
        for i=1:N
            r=unifrnd(0,q(N+1));
            for j=2:N+1
                if r>q(j-1) & r<=q(j)
                    vtemp1(i,:)=v(j-1,:);
                end
            end
        end
        %step4 end
        %step5 交叉操作
        while 1==1
            CrossNo=0;
            v1=vtemp1;
            for i=1:N
                r1=unifrnd(0,1);
                if r1 < Pc
                    CrossNo=CrossNo+1;
                    vtemp2(CrossNo,:)=v1(i,:);
                    v1(i,:)=zeros(1,n);
                end
            end
            if CrossNo~=0 & mod(CrossNo,2)==0
                break;
            elseif CrossNo==0|mod(CrossNo,2)==1
                vtemp2=[];
            end
        end
        shengyuNo=0;
        for i=1:N
            if v1(i,:)~=zeros(1,n)
                shengyuNo=shengyuNo+1;
                vtemp3(shengyuNo,:)=v1(i,:);%vtemp3表示选择后剩余的父代
            end
        end
        %随机选择配对进行交叉操作
        for i=1:CrossNo
            r2=ceil(unifrnd(0,1)*(CrossNo-i+1));
            vtemp4(i,:)=vtemp2(r2,:);
            vtemp2(r2,:)=[];
        end
        %=====================随机配对结束，按顺序2数为一对==========================
        for i=1:2:(CrossNo-1)
            while 1==1
                r3=unifrnd(0,1);
                v20(i,:)=r3*vtemp4(i,:)+(1-r3)*vtemp4(i+1,:);
                v20(i+1,:)=(1-r3)*vtemp4(i,:)+r3*vtemp4(i+1,:);
                temp1=sum(v20(i,:).^2);
                temp2=sum(v20(i+1,:).^2);
                v2(i,:)=sqrt(v20(i,:).^2/temp1);
                v2(i+1,:)=sqrt(v20(i+1,:).^2/temp2);
                if Feasibility(v2(i,:))==1 && Feasibility(v2(i+1,:))==1
                    break;
                end
            end
        end
        %step5 end
        v3=[vtemp3;v2];                     %合并交叉部分和剩余部分
        %step6 变异操作
        while 1==1
            MutationNo=0;
            v4=v3;
            for i=1:N
                r4=unifrnd(0,1);
                if r4<Pm
                    MutationNo=MutationNo+1;
                    vtemp5(MutationNo,:)=v4(i,:);
                    v4(i,:)=zeros(1,n);
                end
            end
            if MutationNo~=0
                break;
            end
        end
        %选择进行变异操作的父代结束
        shengyuNo1=0;
        for i=1:N
            if v4(i,:)~=zeros(1,n)
                shengyuNo1=shengyuNo1+1;
                vtemp6(shengyuNo1,:)=v4(i,:);%vtemp6表示选择后剩余的父代
            end
        end
        %变异开始
        DirectionV=unifrnd(-1,1,1,n);
        for i=1:MutationNo
            tempNo=0;
            while 1==1
                tempNo=tempNo+1;
                v5(i,:)=sqrt(((vtemp5(i,:)+M*DirectionV).^2)/sum((vtemp5(i,:)+M*DirectionV).^2));
                y=Feasibility(v5(i,:));
                if tempNo==200
                    v5(i,:)=vtemp5(i,:);
                    break;
                elseif y==1
                    break;
                end
                M=unifrnd(0,M);
            end
        end
        %step6 end
        vk=[v5;vtemp6];
        v=vk;
    end
    %进行两代进化后再进行适应度评价
    for i=1:N
        fv(i)=Target(xx,v(i,:));
    end
    %根据适应度排序
    [fv,i]=sort(fv,ad);
    v=v(i,:);
    vk=v;
    vv=vk(1:50,:); %选取前20个为优秀个体
    t=1:n;
    mm1(t)=min(vv(:,t));
    mm2(t)=max(vv(:,t));
    fv1(z)=fv(1);
    znum=znum+1;
    if abs(mm1-mm2)<=0.00001
        break;
    end
end
a=fv(1);   %最大函数值
b=vv(1,:);  %最大函数值对应的变量值
index=1:znum;
plot(index,fv1,'b-');
hold on;
title('最优函数值变化趋势');
xlabel('迭代次数');
ylabel('目标函数值');
grid on;
toc

end