# 附录1: 蒙特卡洛模拟函数的相关python代码
# 蒙特卡罗模拟函数
def monte_carlo_simulation(result):
    cost = 0
    money = 0
    L = [[] for _ in range(8)]
    H = [[] for _ in range(3)]
    H_L = [[] for _ in range(3)]

    for j in range(8):
        L[j] = [0 if random.random() < M1[j, 0] else 1 for _ in range(number)]
        L[j], cost = test(j, L, cost, result)

    # 半成品组装
    cost, H[0] = assemble_product([L[0], L[1], L[2], H[0], H_L[0], 0, cost, result])
    cost, H[1] = assemble_product([L[3], L[4], L[5], H[1], H_L[1], 1, cost, result])
    cost, H[2] = assemble_product([L[6], L[7], H[2], H_L[2], 2, cost, result])

    # 成品组装
    while len(H[0]) > 0 and len(H[1]) > 0 and len(H[2]) > 0:
        index0 = random.randint(0, len(H[0]) - 1)
        index1 = random.randint(0, len(H[1]) - 1)
        index2 = random.randint(0, len(H[2]) - 1)
        index = [index0, index1, index2]
        sum_result = H[0][index0] + H[1][index1] + H[2][index2]
        cost += M3[1]
        success = 0 if random.random() < M3[0] else 1

        if result[1]:  # 成品检测
            cost += M2[2]
            if sum_result < 3 or not success:
                cost = destroy2(cost, result, index, H, H_L, L)
                continue

        if sum_result < 3 or not success:
            cost += loss
            cost = destroy2(cost, result, index, H, H_L, L)
        else:
            money += sell
            del H[0][index0]
            del H_L[0][index0]
            del H[1][index1]
            del H_L[1][index1]
            del H[2][index2]
            del H_L[2][index2]

    total_profit = money - cost - buy_cost
    return total_profit


# 并行计算适应度函数
def fitness_parallel(population):
    with Pool(processes=cpu_count()) as pool:
        fitness_scores = list(tqdm(pool.imap(monte_carlo_simulation, population),
                                   total=len(population), desc="Evaluating Population"))
    return fitness_scores


# 附录2: 使用蚁群算法求解问题二中最优决策的python代码
# 蚁群算法主循环
for iteration in tqdm(range(num_iterations), desc="Ant Colony Optimization"):
    all_solutions = []
    all_objective_values = []

    for ant in range(num_ants):
        result = [random.randint(0, 1) for _ in range(4)]  # 随机生成策略
        obj_value = objective_function(result)
        all_solutions.append(result)
        all_objective_values.append(obj_value)

    # 更新信息素
    pheromone *= (1 - rho)
    for idx, solution in enumerate(all_solutions):
        obj_value = all_objective_values[idx]
        for i in range(len(solution) - 1):
            pheromone[solution[i], solution[i + 1]] += Q / (obj_value + 1)  # 避免除以0

    # 记录当前迭代中的最佳利润和对应路径
    combined = list(zip(all_objective_values, all_solutions))
    sorted_combined = sorted(combined, key=lambda x: x[0], reverse=True)


# 附录3: 使用遗传算法求解问题三中最优决策的python代码
# 遗传算法函数，加入精英策略体
def genetic_algorithm(pop_size=100, generations=30, mutation_rate=0.09,
                      crossover_rate=0.65, elite_size=4):
    def create_individual():
        return [random.randint(0, 1) for _ in range(16)]  # 个体是长度为16的数组

    def mutate(individual):
        index = random.randint(0, 15)
        individual[index] = 1 - individual[index]  # 0变1，1变0

    def crossover(parent1, parent2):
        point = random.randint(1, 14)
        child1 = parent1[:point] + parent2[point:]
        child2 = parent2[:point] + parent1[point:]
        return child1, child2

    # 初始种群
    population = [create_individual() for _ in range(pop_size)]

    # 记录每一代的最佳适应度
    best_fitness_per_gen = []

    # 记录每代种群的适应度分布
    all_fitness = []

    for gen in tqdm(range(generations), desc="Generations"):
        # 计算适应度 (并行)
        fitness_scores = fitness_parallel(population)

        # 按适应度对种群进行排序
        sorted_population = [x for _, x in sorted(zip(fitness_scores, population),
                                                  reverse=True)]

        # 获取当前种群中的最佳适应度
        best_fitness = max(fitness_scores)
        best_fitness_per_gen.append(best_fitness)

        # 记录每代种群的适应度分布
        all_fitness.append(fitness_scores)

        # 保留最好的精英个体
        elites = sorted_population[:elite_size]

        # 其余个体通过交叉与变异生成
        new_population = elites[:]
        while len(new_population) < pop_size:
            if random.random() < crossover_rate:
                parent1, parent2 = random.sample(sorted_population[:pop_size // 2],
                                                 2)
                child1, child2 = crossover(parent1, parent2)
                new_population.extend([child1, child2])
            else:
                new_population.append(random.choice(sorted_population[:pop_size
                                                                       // 2]))

        # 变异
        for individual in new_population[elite_size:]:  # 精英个体不参与变异
            if random.random() < mutation_rate:
                mutate(individual)

        population = new_population

    # 计算最终种群的适应度
    final_fitness_scores = fitness_parallel(population)

    # 按适应度对最终种群排序
    top_individuals = sorted(zip(final_fitness_scores, population), reverse=True)[:10]