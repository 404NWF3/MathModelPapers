%% 附录1：第一遗传程序
clc,clear;
% 数据读取
plant2023 = importdata("2023 种植方案.mat");
output2023 = importdata("2023 种植统计.mat");
Sale = importdata("各作物各季度售价.mat");
Stastic = importdata("种植相关统计数据.mat");
Data1 = importdata("1.xlsx");
Data2 = importdata("2.xlsx");
Data3 = importdata("3.xlsx");
Area = Data1.data.Sheet1;

nPop = 50; % 种群数量
maxIt = 500;
nPc = 0.8;
nC = round(nPop * nPc/2) *2 ;
crossover_rate = 0.1; %交叉概率
mutation_rate = 0.01; %变异概率

% 参数定义
num_years = 8; %2023 到 2030
num_plots = 54; % 地块数量
num_crops = 41; % 作物总数

% 耕地编号
land_types = [ones(1,6),2*ones(1,14),3*ones(1,6),4*ones(1,8),5*ones(1,16),6*ones(1,4)];

% 根据种植划分,共5 种作物
crop_massif.a = [];
crop_massif(1).a = [1:15]; %平早地,梯田,山坡地
crop_massif(2).a = [16]; %水淹地单季
crop_massif(3).a = [17:34]; %水淹地第一季 普通大棚第一季 智慧大棚一二季
crop_massif(4).a = [35:37]; %水淹地第二季
crop_massif(5).a = [38:41]; %普通大棚第二季

% 季节能够大小，根据地块类型定义
% 1=一个季节种作物, 2=两季单作物, 2 两季 2 作物, 普通大棚和智慧大棚
season_matrix_sizes = {
    [1, 1];     % 平早地，一个季节种一个作物
    [1, 1];     % 梯田，一个季节种一个作物
    [1, 1];     % 山坡地，一个季节种一个作物
    [1, 1];     % 水淹地，一个季节最多种一两个作物
    [2, 2];     % 普通大棚，每季最多种两作物
    [2, 2];     % 智慧大棚，每季最多种两作物
};

template.x = [];
template.y = [];

Parent = repmat(template,nPop,1);

R = []; %用于存储最优解
%初始化种群
for i=1:nPop
    Parent(i).x = spe_createPop(crop_massif, land_types, season_matrix_sizes, num_years, num_plots, plant2023, output2023, Area, Stastic);
    Parent(i).y = fun(Parent(i).x,Data1,output2023,Sale,Stastic);
end

for It = 1:maxIt
    Offspring = repmat(template,nC/2,2);
    
    for j = 1:nC/2
        parent1 = selectPop(Parent);
        parent2 = selectPop(Parent);
        [Offspring(j,1).x,Offspring(j,2).x] = crossPop(parent1, parent2, crossover_rate, season_matrix_sizes, num_years, num_plots, crop_massif, land_types, output2023, Area, Stastic);
    end
    
    Offspring=Offspring(:);
    A = Offspring;
    
    %进行变异
    for k=1:nC
        Offspring(k).x = mutatePop(Offspring(k).x, mutation_rate, crop_massif, land_types, season_matrix_sizes, num_years, num_plots, output2023, Area, Stastic);
        Offspring(k).y = fun(Offspring(k).x,Data1,output2023,Sale,Stastic);
    end
    
    newPop=[Parent,Offspring];
    [~,so]=sort([newPop.y],'ascend');
    newPop=newPop(so);
    Parent=newPop(1:nPop);
    disp(['迭代次数:',num2str(It),'最小值为:',num2str(Parent(1).y)])
    R=[R,Parent(1).y];
end
figure
plot(R)
xlabel('种群进化次数')

%% 附录2：目标函数
function y = fun(x,Data1,output2023,Sale,Stastic)
Area = Data1.data.Sheet1;
Crop = Data1.data.Sheet2;
% 第一列作物 第二列时地 第三列季度
for year = 2:8
    Plan = zeros(150, 4); % 可分配 Plan 数组, 假设最大行数为 150，后续再调整
    planCounter = 1; % 用于跟踪 Plan 数组中的行数
    for i = 1:size(Area,1)
        plan = x{year,i};
        %单季度
        if size(plan,2) == 1
            land = plan.land;
            season = plan.season;
            crop = plan.crop;
            % 第一列作物 第二列耕地 第三列季度 第四列种植面积
            Plan(planCounter, :) = [crop, land, season, Area(i)];
            planCounter = planCounter + 1;
        %双季度
        else
            for j = 1:2
                crop = plan(j).crop;
                land = plan(j).land;
                season = plan(j).season;
                for k = crop
                    Plan(planCounter, :) = [k, land, season, Area(i) / length(crop)];
                    planCounter = planCounter + 1;
                end
            end
        end
    end
    Plan = Plan(1:planCounter - 1, :); % 调整 Plan 数组大小
    Output = zeros(size(Crop,1),2);
    Cost = 0;
    for i = 1:size(Plan,1)
        crop = Plan(i,1);
        land = Plan(i,2);
        season = Plan(i,3);
        
        %亩产量/斤 并得到产量
        yield_permu = Stastic(1,land,crop,season);
        %种植成本/(元/亩)
        plant_cost = Stastic(2,land,crop,season);
        %每个作物每个季度的产量
        Output(crop,season) = Output(crop,season) + Plan(i,4) * yield_permu;
        Cost = Cost + Plan(i,4) * plant_cost;
    end
    y1 = -Cost;
    %第一种 多出的直接备养
    for i = 1:size(Output,1)
        for j = 1:size(Output,2)
            y1 = y1 + min(Output(i,j),output2023(i,j)) * Sale(i,j);
        end
    end
    y2 = -Cost;
    %第二种 多出的按一半价格出售
    for i = 1:size(Output,1)
        for j = 1:size(Output,2)
            if Output(i,j) > output2023(i,j)
                y2 = y2 + output2023(i,j) * Sale(i,j) + (Output(i,j)-output2023(i,j)) * Sale(i,j) * 0.5;
            else
                y2 = y2 + Output(i,j) * Sale(i,j);
            end
        end
    end
    Y(year-1) = -y1;
end
y = sum(Y);

%% 附录3：锦标赛选择函数
function selected = selectPop(Parent)
%锦标赛选择法
population_size = numel(Parent);
fitness = [Parent.y];
tournament_size = 5;
selected_indices = zeros(population_size, 1);
for i = 1:population_size
    candidates = randsample(1:population_size, tournament_size);
    [~, best_candidate_idx] = max(fitness(candidates));
    selected_indices(i) = candidates(best_candidate_idx);
end
% 统计每个个体被选择的次数
counts = histc(selected_indices, 1:population_size);
[max_count, ~] = max(counts);

most_selected_indices = find(counts == max_count);

% 如果有多个出现次数相同的个体，随机选择一个
if length(most_selected_indices) > 1
    parent_idx = most_selected_indices(randi(length(most_selected_indices)));
else
    parent_idx = most_selected_indices;
end
selected = Parent(parent_idx).x;

%% 附录4：变异函数
function mutated_offspring = mutatePop(offspring, mutation_rate, crop_massif, land_types, season_matrix_sizes, num_years, num_plots, output2023, Area, Stastic)
% 初始化变异后的个体矩阵
mutated_offspring = offspring;
if rand(1) < mutation_rate
    plot= randi([2, num_plots]); % 从第二年开始进行变异，第一年的值保持不变
    for year = 2:num_years
        output = zeros(41,2);
        for i = 1:num_plots
            land_type = land_types(i);
            if i== plot
                num_season = size(mutated_offspring{year, i}, 2);
                for season = 1:num_season
                    crops = mutated_offspring{year, i}(season).crop;
                    for crop = crops
                        output(crop,season) = output(crop,season) + Area(i) * Stastic(1,land_type,crop,season);
                    end
                end
            end
        end
        
        land_type = land_types(plot);
        sizes = season_matrix_sizes{land_type};
        if land_type==4
            num_seasons = randi([1,2]);
        else
            num_seasons = sizes(1);
        end
        max_crops_per_season = sizes(2);
        
        planting_plan = struct();
        % 针对水稻进行二层单独判断
        if land_type == 4 && num_seasons == 1 && size(mutated_offspring{year-1, plot}, 2) == 1
            num_seasons = 2;
        end
        for season = 1:num_seasons
            % 水淹地单季作物组
            if land_type == 4 && num_seasons == 1
                crops_group = 2;
                % 水淹地第一季 普通大棚第一季 智慧大棚一二季作物组
            elseif land_type == 6 || land_type == 4 && num_seasons == 2 && season == 1 || land_type == 5 && num_seasons == 2 && season == 1
                crops_group = 3;
                % 水淹地第二季作物组
            elseif land_type == 4 && num_seasons == 2 && season == 2
                crops_group = 4;
                % 普通大棚第二季作物组
            elseif land_type == 5 && num_seasons == 2 && season == 2
                crops_group = 5;
            else % 对应地块，平早地，梯田，山坡地
                crops_group = 1;
            end
            available_crops = crop_massif(crops_group).a;
            crops_per_season = randi([1, max_crops_per_season]); % 随机1到2种作物
            planting_plan(season).land = land_type;
            planting_plan(season).season = season;
            crops = generate_unique_crops(available_crops, crops_per_season, mutated_offspring, planting_plan, year, plot, season, output2023, output, Area, Stastic);
            if isempty(crops)
                available_crops = crop_massif(3).a;
                crops = generate_unique_crops(available_crops, crops_per_season, mutated_offspring, planting_plan, year, plot, season+1, output2023, output, Area, Stastic);
                planting_plan(season+1).crop = crops;
                output(crops, season + 1) = output(crops, season + 1) + Area(plot) * Stastic(1,land_type,crops,season + 1);
            end
            for k = 1:length(planting_plan(season).crop)
                crop = planting_plan(season).crop(k);
                output(crop, season) = output(planting_plan(season).crop(k), season) + Area(plot) * Stastic(1,land_type,crop,season);
            end
        end
        mutated_offspring{year, plot} = planting_plan;
    end
    
    land_type = land_types(plot);
    sizes = season_matrix_sizes{land_type};
    if land_type==4
        num_seasons = randi([1,2]);
    else
        num_seasons = sizes(1);
    end
    max_crops_per_season = sizes(2);
    
    planting_plan = struct();
    % 针对水稻进行二层单独判断
    if land_type == 4 && num_seasons == 1 && size(mutated_offspring{year-1, plot}, 2) == 1
        num_seasons = 2;
    end
    for season = 1:num_seasons
        % 水淹地单季作物组
        if land_type == 4 && num_seasons == 1
            crops_group = 2;
            % 水淹地第一季 普通大棚第一季 智慧大棚一二季作物组
        elseif land_type == 6 || land_type == 4 && num_seasons == 2 && season == 1 || land_type == 5 && num_seasons == 2 && season == 1
            crops_group = 3;
            % 水淹地第二季作物组
        elseif land_type == 4 && num_seasons == 2 && season == 2
            crops_group = 4;
            % 普通大棚第二季作物组
        elseif land_type == 5 && num_seasons == 2 && season == 2
            crops_group = 5;
        else % 对应地块，平早地，梯田，山坡地
            crops_group = 1;
        end
        available_crops = crop_massif(crops_group).a;
        crops_per_season = randi([1, max_crops_per_season]); % 随机1到2种作物
        planting_plan(season).land = land_type;
        planting_plan(season).season = season;
        crops = generate_unique_crops(available_crops, crops_per_season, mutated_offspring, planting_plan, year, plot, season, output2023, output, Area, Stastic);
        if isempty(crops)
            available_crops = crop_massif(3).a;
            crops = generate_unique_crops(available_crops, crops_per_season, mutated_offspring, planting_plan, year, plot, season+1, output2023, output, Area, Stastic);
            planting_plan(season+1).crop = crops;
            output(crops, season + 1) = output(crops, season + 1) + Area(plot) * Stastic(1,land_type,crops,season + 1);
        end
        for k = 1:length(planting_plan(season).crop)
            crop = planting_plan(season).crop(k);
            output(crop, season) = output(planting_plan(season).crop(k), season) + Area(plot) * Stastic(1,land_type,crop,season);
        end
    end
    mutated_offspring{year, plot} = planting_plan;
end
mutated_offspring = checkAndRepair(mutated_offspring, crop_massif, land_types, num_plots, season_matrix_sizes, output2023, Area, Stastic);

%% 附录5：生成不重复编号
function crops = repair(available_crops, crops_per_season, individual, planting_plan, year, plot, season, output2023, output, Area, Stastic)
num_attempts = 18; % 尝试次数限制，防止无限循环
land_types = [ones(1,6),2*ones(1,14),3*ones(1,6),4*ones(1,8),5*ones(1,16),6*ones(1,4)];
% 提前获取相关数据，减少重复内计算
if year > 1
    prev_year_plan = individual{year - 1, plot};
else
    prev_year_plan = [];
end

for attempt = 1:num_attempts
    valid = false;
    if length(available_crops) > 1
        crops = randsample(available_crops, crops_per_season, false);
    elseif length(available_crops) == 1
        crops = available_crops(1);
    elseif isempty(available_crops)
        crops = [];
        return
    end
    
    for i = 1:crops_per_season
        % 检查当前季节内部作物是否重复
        if length(unique(crops)) < crops_per_season
            valid = true;
            continue;
        end
    end
    
    % 检查与上季重复情况
    if season > 1 && isfield(planting_plan(season - 1), 'crop')
        if hasOverlap(crops(), planting_plan(season - 1).crop)
            available_crops(available_crops==crops(i)) = [];
            valid = true;
            continue;
        end
    end
    
    % 检查与上年所有季节重复情况
    if hasYearOverlap(crops(), prev_year_plan)
        available_crops(available_crops==crops(i)) = [];
        valid = true;
        continue;
    end
    
    % 检查三年内种植豆类作物要求
    if year >= 3 && ~checkLegumesInThreeYears(crops(), individual,planting_plan, year, plot, season) && ~ismember(crops(),[1:5,17:19])
        % 水淹地或者普通大棚第一季
        if plot > 26 && season == 1 && plot < 51
            legume_crops = [17:19]; % 第一季豆类作物编号
            crops(i) = randsample(legume_crops, 1, false);
            % 单季度
        elseif plot <= 26
            legume_crops = [1:5]; % 第一季豆类作物编号
            crops(i) = randsample(legume_crops, 1, false);
        elseif plot >= 51
            legume_crops = [17:19]; % 第一季豆类作物编号
            crops(i) = randsample(legume_crops, 1, false);
        end
    end
    
    if ~ismember(crops(),[1:5,17:19,35:41])
        %检查是否超过预期销售量太多
        refer_sale = output2023(crops(), season);
        cur_sale = output(crops(), season);
        will_sale = Area(plot) * Stastic(1,land_types(plot),crops(),season);
        
        if cur_sale + will_sale > refer_sale + 50000
            available_crops(available_crops==crops(i)) = [];
            valid = true;
            continue;
        end
    end
    % 如果没有发现重复且符合豆类作物种植要求且没有超出预期销售量返回生成的作物
    if ~valid
        return
    end
end

%% 附录6：个体生成函数
function individual = spe_createPop(crop_massif, land_types, season_matrix_sizes, num_years, num_plots, plant2023, output2023, Area, Stastic)

% 初始化种群为结构的体数组
individual = cell(num_years, num_plots); % 初始化每个个体的 cell 矩阵

% 给出 2023 的种植数据
individual(1, :) = plant2023;
for year = 2:num_years
    % 用来存储年当前的输出 不能超出太多预期销售量
    output = zeros(41,2);
    for plot = 1:num_plots
        % 根据地块类型生成策略方案
        land_type = land_types(plot);
        sizes = season_matrix_sizes{land_type};
        if land_type==4
            num_seasons = randi([1,2]);
        else
            num_seasons = sizes(1);
        end
        max_crops_per_season = sizes(2);
        
        planting_plan = struct();
        % 针对水稻进行二层单独判断
        if land_type == 4 && num_seasons == 1 && size(individual{year-1, plot}, 2) == 1
            num_seasons = 2;
        end
        for season = 1:num_seasons
            % 水淹地单季作物组
            if land_type == 4 && num_seasons == 1
                crops_group = 2;
                % 水淹地第一季 普通大棚第一季 智慧大棚一二季作物组
            elseif land_type == 6 || land_type == 4 && num_seasons == 2 && season == 1 || land_type == 5 && num_seasons == 2 && season == 1
                crops_group = 3;
                % 水淹地第二季作物组
            elseif land_type == 4 && num_seasons == 2 && season == 2
                crops_group = 4;
                % 普通大棚第二季作物组
            elseif land_type == 5 && num_seasons == 2 && season == 2
                crops_group = 5;
            else % 对应地块，平早地，梯田，山坡地
                crops_group = 1;
            end
            available_crops = crop_massif(crops_group).a;
            crops_per_season = randi([1, max_crops_per_season]); % 随机1到2种作物
            planting_plan(season).land = land_type;
            planting_plan(season).season = season;
            crops = generate_unique_crops(available_crops, crops_per_season, individual, planting_plan, year, plot, season, output2023, output, Area, Stastic);
            planting_plan(season).crop = crops;
            %设明此时不能种小麦或者没有满足条件的农作物,这里种第一季度,第二季度由
            %下面的代码得到
            if isempty(crops)
                available_crops = crop_massif(3).a;
                %available_crops = crop_massif(1).a;
                crops = generate_unique_crops(available_crops, crops_per_season, individual, planting_plan, year, plot, season, output2023, output, Area, Stastic);
            end
            planting_plan(season).crop = crops;
            %设明此时普遍成两季度作物用来重新
            if crops_group == 2 && ~ismember(16,planting_plan(season).crop)
                available_crops = crop_massif(4).a;
                planting_plan(season+1).land = land_type;
                planting_plan(season+1).season = season+1;
                crops = generate_unique_crops(available_crops, crops_per_season, individual, planting_plan, year, plot, season+1, output2023, output, Area, Stastic);
                planting_plan(season+1).crop = crops;
                output(crops, season + 1) = output(crops, season + 1) + Area(plot) * Stastic(1,land_type,crops,season + 1);
            end
            for k = 1:length(planting_plan(season).crop)
                crop = planting_plan(season).crop(k);
                output(crop, season) = output(planting_plan(season).crop(k), season) + Area(plot) * Stastic(1,land_type,crop,season);
            end
        end
        % 存储种植计划到个体矩阵
        individual{year, plot} = planting_plan;
    end
end

%% 附录7：检查与上年所有季节重复情况
function overlap = hasYearOverlap(crops, prev_year_plan)
overlap = false;
if ~isempty(prev_year_plan)
    for prev_season = 1:length(prev_year_plan)
        if isfield(prev_year_plan(prev_season), 'crop')
            if hasOverlap(crops, prev_year_plan(prev_season).crop)
                overlap = true;
                break;
            end
        end
    end
end

%% 附录8：检查与上季重复情况
function overlap = hasOverlap(crops1, crops2)
overlap = any(ismember(crops1, crops2));

%% 附录9：生成不重复作物编号
function crops = generate_unique_crops(available_crops, crops_per_season, individual, planting_plan, year, plot, season, output2023, output, Area, Stastic)
num_attempts = 18; % 尝试次数限制，防止无限循环
land_types = [ones(1,6),2*ones(1,14),3*ones(1,6),4*ones(1,8),5*ones(1,16),6*ones(1,4)];
% 提前获取相关数据，减少重复内计算
if year > 1
    prev_year_plan = individual{year - 1, plot};
else
    prev_year_plan = [];
end

for attempt = 1:num_attempts
    valid = false;
    if length(available_crops) > 1
        crops = randsample(available_crops, crops_per_season, false);
    elseif length(available_crops) == 1
        crops = available_crops(1);
    elseif isempty(available_crops)
        crops = [];
        return
    end
    
    for i = 1:crops_per_season
        % 检查当前季节内部作物是否重复
        if length(unique(crops)) < crops_per_season
            valid = true;
            continue;
        end
    end
    
    % 检查与上季重复情况
    if season > 1 && isfield(planting_plan(season - 1), 'crop')
        if hasOverlap(crops(), planting_plan(season - 1).crop)
            available_crops(available_crops==crops(i)) = [];
            valid = true;
            continue;
        end
    end
    
    % 检查与上年所有季节重复情况
    if hasYearOverlap(crops(), prev_year_plan)
        available_crops(available_crops==crops(i)) = [];
        valid = true;
        continue;
    end
    
    % 检查三年内种植豆类作物要求
    if year >= 3 && ~checkLegumesInThreeYears(crops(), individual,planting_plan, year, plot, season) && ~ismember(crops(),[1:5,17:19])
        % 水淹地或者普通大棚第一季
        if plot > 26 && season == 1 && plot < 51
            legume_crops = [17:19]; % 第一季豆类作物编号
            crops(i) = randsample(legume_crops, 1, false);
            % 单季度
        elseif plot <= 26
            legume_crops = [1:5]; % 第一季豆类作物编号
            crops(i) = randsample(legume_crops, 1, false);
        elseif plot >= 51
            legume_crops = [17:19]; % 第一季豆类作物编号
            crops(i) = randsample(legume_crops, 1, false);
        end
    end
    
    if ~ismember(crops(),[1:5,17:19,35:41])
        %检查是否超过预期销售量太多
        refer_sale = output2023(crops(), season);
        cur_sale = output(crops(), season);
        will_sale = Area(plot) * Stastic(1,land_types(plot),crops(),season);
        
        if cur_sale + will_sale > refer_sale + 50000
            available_crops(available_crops==crops(i)) = [];
            valid = true;
            continue;
        end
    end
    % 如果没有发现重复且符合豆类作物种植要求且没有超出预期销售量返回生成的作物
    if ~valid
        return
    end
end

%% 附录10：检查函数
clc,clear,clc,clear;

% 用来判断是否有问题
x = importdata("情况 1.mat");
plant2023 = importdata("2023 种植方案.mat");
output2023 = importdata("2023 种植统计.mat");
landoutput2023 = importdata("2023 预期销售量.mat");
Sale = importdata("各作物各季度售价.mat");
Stastic = importdata("种植相关统计数据.mat");
Data1 = importdata("1.xlsx");
Data2 = importdata("2.xlsx");
Data3 = importdata("3.xlsx");
Area = Data1.data.Sheet1;
% 参数定义
num_years = 8; %2023 到 2030
num_plots = 54; % 地块数量
num_crops = 41; % 作物总数

% 根据种植划分,共5 种作物
crop_massif.a = [];
crop_massif(1).a = [1:15]; %平早地,梯田,山坡地
crop_massif(2).a = [16]; %水淹地单季
crop_massif(3).a = [17:34]; %水淹地第一季 普通大棚第一季 智慧大棚一二季
crop_massif(4).a = [35:37]; %水淹地第二季
crop_massif(5).a = [38:41]; %普通大棚第二季

% 季节能够大小，根据地块类型定义
% 1=一个季节种作物, 2=两季单作物, 2 两季 2 作物, 普通大棚和智慧大棚
season_matrix_sizes = {
    [1, 1];     % 平早地，一个季节种一个作物
    [1, 1];     % 梯田，一个季节种一个作物
    [1, 1];     % 山坡地，一个季节种一个作物
    [1, 1];     % 水淹地，一个季节最多种一两个作物
    [2, 2];     % 普通大棚，每季最多种两作物
    [2, 2];     % 智慧大棚，每季最多种两作物
};

% 第一列作物 第二列耕地 第三列季度
land_types = [ones(1,6),2*ones(1,14),3*ones(1,6),4*ones(1,8),5*ones(1,16),6*ones(1,4)];
sale = Data3.data;
valid = check(x, crop_massif, land_types, num_years, num_plots, Area, Stastic);

%% 附录11：交叉
function [offspring1, offspring2] = crossPop(parent1, parent2, crossover_rate, season_matrix_sizes, num_years, num_plots, crop_massif, land_types, output2023, Area, Stastic)

% 初始化子代个体矩阵
offspring1 = parent1;
offspring2 = parent2;

% 用子减少 rand 调用
% 用子减少 rand 调用
crossover_matrix = rand(num_years, num_plots) < crossover_rate;
crossover_year = randi([2,num_years]);

for plot = 1:num_plots
    if crossover_matrix(crossover_year, plot)
        offspring1(:, plot) = parent2(:, plot);
        offspring2(:, plot) = parent1(:, plot);
    end
end

% 约束检测和修复存在一起
offspring1 = checkAndRepair(offspring1, crop_massif, land_types, num_plots, season_matrix_sizes, output2023, Area, Stastic);
offspring2 = checkAndRepair(offspring2, crop_massif, land_types, num_plots, season_matrix_sizes, output2023, Area, Stastic);

%% 附录12：生成个体
function individual = createPop(crop_massif, land_types, season_matrix_sizes, num_years, num_plots, plant2023)
% 初始化种群为结构的体数组
individual = cell(num_years, num_plots); % 初始化每个个体的 cell 矩阵

% 给出 2023 的种植数据
individual(1, :) = plant2023;
for year = 2:num_years
    % 用来存储年当前的输出 不能超出太多预期销售量
    output = zeros(41,2);
    for plot = 1:num_plots
        % 根据地块类型生成策略方案
        land_type = land_types(plot);
        sizes = season_matrix_sizes{land_type};
        if land_type==4
            num_seasons = randi([1,2]);
        else
            num_seasons = sizes(1);
        end
        max_crops_per_season = sizes(2);
        
        planting_plan = struct();
        % 针对水稻进行二层单独判断
        if land_type == 4 && num_seasons == 1 && size(individual{year-1, plot}, 2) == 1
            num_seasons = 2;
        end
        for season = 1:num_seasons
            % 水淹地单季作物组
            if land_type == 4 && num_seasons == 1
                crops_group = 2;
                % 水淹地第一季 普通大棚第一季 智慧大棚一二季作物组
            elseif land_type == 6 || land_type == 4 && num_seasons == 2 && season == 1 || land_type == 5 && num_seasons == 2 && season == 1
                crops_group = 3;
                % 水淹地第二季作物组
            elseif land_type == 4 && num_seasons == 2 && season == 2
                crops_group = 4;
                % 普通大棚第二季作物组
            elseif land_type == 5 && num_seasons == 2 && season == 2
                crops_group = 5;
            else % 对应地块，平早地，梯田，山坡地
                crops_group = 1;
            end
            available_crops = crop_massif(crops_group).a;
            crops_per_season = randi([1, max_crops_per_season]); % 随机1到2种作物
            planting_plan(season).land = land_type;
            planting_plan(season).season = season;
            crops = generate_unique_crops(available_crops, crops_per_season, individual, planting_plan, year, plot, season, output2023, output, Area, Stastic);
            %设明此时不能种小麦或者没有满足条件的农作物,这里种第一季度,第二季度由
            %下面的代码得到
            if isempty(crops)
                available_crops = crop_massif(3).a;
                %available_crops = crop_massif(1).a;
                crops = generate_unique_crops(available_crops, crops_per_season, individual, planting_plan, year, plot, season, output2023, output, Area, Stastic);
            end
            planting_plan(season).crop = crops;
            %设明此时普遍成两季度作物用来重新
            if crops_group == 2 && ~ismember(16,planting_plan(season).crop)
                available_crops = crop_massif(4).a;
                planting_plan(season+1).land = land_type;
                planting_plan(season+1).season = season+1;
                crops = generate_unique_crops(available_crops, crops_per_season, individual, planting_plan, year, plot, season+1, output2023, output, Area, Stastic);
                planting_plan(season+1).crop = crops;
                output(crops, season + 1) = output(crops, season + 1) + Area(plot) * Stastic(1,land_type,crops,season + 1);
            end
            for k = 1:length(planting_plan(season).crop)
                crop = planting_plan(season).crop(k);
                output(crop, season) = output(planting_plan(season).crop(k), season) + Area(plot) * Stastic(1,land_type,crop,season);
            end
        end
        % 存储种植计划到个体矩阵
        individual{year, plot} = planting_plan;
    end
end
offspring2 = checkAndRepair(offspring2, crop_massif, land_types, num_plots, season_matrix_sizes, output2023, Area, Stastic);

%% 附录13：检查三年内种植豆类作物要求
function in_three_years = checkLegumesInThreeYears(crops, individual, planting_plan, year, plot, season)
legumes = [1:5, 17:19];
in_three_years = false;

for past_year = max(1, year-2):year-1
    prev_year_plan = individual{past_year, plot};
    if ~isempty(prev_year_plan)
        for prev_season = 1:length(prev_year_plan)
            if isfield(prev_year_plan(prev_season), 'crop')
                prev_crops = prev_year_plan(prev_season).crop;
                if any(ismember(prev_crops, legumes))
                    in_three_years = true;
                    return;
                end
            end
        end
    end
end
if season == 2
    if isfield(planting_plan(season-1), 'crop')
        prev_crops = planting_plan(season-1).crop;
        if any(ismember(prev_crops, legumes))
            in_three_years = true;
            return
        end
    end
end
if ~in_three_years && ~any(ismember(crops, legumes))
    in_three_years = false;
else
    in_three_years = true;
end

%% 附录14：该年各作物的产出
function offspring = checkAndRepair(offspring, crop_massif, land_types, num_plots,season_matrix_sizes, output2023, Area, Stastic)
num_years = 8;
vaild5 = check(offspring, crop_massif, land_types, num_years, num_plots);
while ~isempty(vaild5)
    for i = 1:size(vaild5)
        output = zeros(41,2);
        % 获得地块类型和当前节数
        year = vaild5(i,1);
        plot = vaild5(i,2);
        num_season = size(offspring{year, plot}, 2);
        land_type = land_types(plot);
        for k = 1:plot
            for season = 1:num_season
                crops = offspring{year, plot}(season).crop;
                for crop = crops
                    output(crop,season) = output(crop,season) + Area(plot) * Stastic(1,land_type,crop,season);
                end
            end
        end
        num_seasons = size(offspring{year, plot}, 2);
        vaild = offspring{year, plot};
        % 修复个体以确保约束 其 land_type = land_types(plot);
        sizes = season_matrix_sizes{land_type};
        max_crops_per_season = sizes(2);
        planting_plan = struct();
        % 针对水稻进行二层单独判断
        if (land_type == 4 && num_seasons == 1 && size(offspring{year-1, plot}, 2) == 1) || (land_type == 4 && num_seasons == 1 && size(offspring{min(year+1,size(offspring,1)), plot}, 2) == 1)
            num_seasons = 2;
        end
        offspring{year, plot} = [];
        for season = 1:num_seasons
            % 水淹地单季作物组
            if land_type == 4 && num_seasons == 1
                crops_group = 2;
                % 水淹地第一季 普通大棚第一季 智慧大棚一二季作物组
            elseif land_type == 6 || land_type == 4 && num_seasons == 2 && season == 1 || land_type == 5 && num_seasons == 2 && season == 1
                crops_group = 3;
                % 水淹地第二季作物组
            elseif land_type == 4 && num_seasons == 2 && season == 2
                crops_group = 4;
                % 普通大棚第二季作物组
            elseif land_type == 5 && num_seasons == 2 && season == 2
                crops_group = 5;
            else % 对应地块，平早地，梯田，山坡地
                crops_group = 1;
            end
            available_crops = crop_massif(crops_group).a;
            crops_per_season = randi([1, max_crops_per_season]); % 随机1到2种作物
            planting_plan(season).land = land_type;
            planting_plan(season).season = season;
            crops = repair(available_crops, crops_per_season, offspring, planting_plan, year, plot,season, output2023, output, Area, Stastic);
            if isempty(crops)
                available_crops = crop_massif(3).a;
                crops = repair(available_crops, crops_per_season, offspring, planting_plan, year, plot, season, output2023, output, Area, Stastic);
            end
            planting_plan(season).crop = crops;
            %设明此时普遍成两季度作物用来重新
            if crops_group == 2 && ~ismember(16,planting_plan(season).crop)
                available_crops = crop_massif(4).a;
                planting_plan(season+1).land = land_type;
                planting_plan(season+1).season = season+1;
                crops = repair(available_crops, crops_per_season, offspring, planting_plan, year, plot, season+1, output2023, output, Area, Stastic);
                planting_plan(season+1).crop = crops;
            end
        end
        offspring{year, plot} = planting_plan;
    end
    vaild5 = check(offspring, crop_massif, land_types, num_years, num_plots);
end

%% 附录15：检查约束
function valid_combo = check(offspring, crop_massif, land_types, num_years, num_plots)
valid_combo = [];
for year = 1:num_years
    for plot = 1:num_plots
        % 获得地块类型和当前节数
        land_type = land_types(plot);
        num_seasons = size(offspring{year, plot}, 2);
        % 检验标志
        valid = true;
        % 检查每个季节的作物
        for season = 1:num_seasons
            crops = offspring{year, plot}(season).crop;
            
            if land_type == 4 && num_seasons == 1
                crops_group = 2;
            elseif land_type == 6 || (land_type == 4 && num_seasons == 2 && season == 1) || (land_type == 5 && num_seasons == 2 && season == 1)
                crops_group = 3;
            elseif land_type == 4 && num_seasons == 2 && season == 2
                crops_group = 4;
            elseif land_type == 5 && num_seasons == 2 && season == 2
                crops_group = 5;
            else
                crops_group = 1;
            end
            available_crops = crop_massif(crops_group).a;
            
            % 检查当前作物是否在允许的作物范围内
            if any(~ismember(crops, available_crops))
                valid = false;
                break;
            end
            
            % 检查季节内作物是否重复
            if length(unique(crops)) < length(crops)
                valid = false;
                break;
            end
            
            % 检查双季度是否存在水稻
            if num_seasons == 2 && ismember(16,offspring{year, plot}(season).crop)
                valid = false;
                break;
            end
            
            % 检查与前季作物是否重复
            if season > 1 && hasOverlap(crops, offspring{year, plot}(season-1).crop)
                valid = false;
                break;
            end
            
            % 检查与上一年作物是否重复
            if year > 1 && hasYearOverlap(crops, offspring{year-1, plot})
                valid = false;
                break;
            end
            
            % 检查三年内种植豆类作物要求
            if year >= 3 && ~checkLegumesInThreeYears(crops, offspring, offspring{year, plot}, year, plot, season)
                valid = false;
                break;
            end
        end
        if ~valid
            valid_combo = [valid_combo;[year,plot,season]];
        end
    end
end