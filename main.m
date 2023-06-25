clc
clear

%% inverted pendulum system's parameters
M = 1.5;
m = 0.5;
l = 1;
g = 9.8;

%% state space
A = [0 1 0 0; 0 0 m*g/M 0; 0 0 0 1; 0 0 g/(M*l)*(M+m) 0];
B = [0; 1/M; 0; 1/(M*l)];
C = [0 0 1 0];
D = 0;
sys = ss(A, B, C, D);


%% simulation setting
t = 0: 0.01: 10; % simulation time
u = zeros(1, length(t)); % pid reference value
x0 = [2; 0; -5; 0; 0; 0]; % system's initial condition

%% pid parameters
kp_range = 100;
ki_range = 10;
kd_range = 50;
prec = 0.1; % 参数精度

%% GA parameters
gene_num = 30; % pid参数用二进制编码后总长度，各占1/3
popu_num = 30; % 种群各代维持数目
max_iter = 50; % 最大迭代次数

mutate_prob = 0.01; % 基因突变概率

history = {1, max_iter+1}; % store optimal individual

%% plot 
x = 0: 1: max_iter; % generation number
y = zeros(1, length(x));  % optimal error of each generation

%% Genetic Algorithm
% individual's data structure
indiv.k = []; % pid参数[kp, ki, kd]
indiv.gene = {}; % 对应二进制基因型 {'01001', '', ''}
indiv.fitness = []; % 个体适应度

% initialize parent population
parent_popu = repmat(indiv, popu_num, 1);

for i = 1: popu_num

    % 随机生成一组pid参数, 精确到0.1
    parent_popu(i).k = [randi([1, kp_range-1])+randi([0, 9])*prec, ... 
                        randi([1, ki_range-1])+randi([0, 9])*prec, ...
                        randi([1, kd_range-1])+randi([0, 9])*prec];
    
    % 将pid参数编码为基因型
    parent_popu(i).gene = encoding(parent_popu(i).k, prec);

    % 计算个体适应度
    parent_popu(i).fitness = get_fitness(parent_popu(i).k, sys, u, t, x0);
    
end

% start iteration
for iter = 1: max_iter
    
    % sort by fitness
    [~, idx] = sort([parent_popu.fitness]);
    parent_popu = parent_popu(idx);
    
    history{iter} = parent_popu(30);
    y(iter) = 1 / parent_popu(30).fitness; % optimal error
    
    % SELECT PART
    % create Wheel Roulette
    fits = [parent_popu.fitness]; % 种群适应度集合(已排序)
    normal_fits = fits / sum(fits);
    probs = cumsum(normal_fits); % 个体被选中概率占比
    
    % start
    select_indices = zeros(1, 30); % 轮盘赌选中的个体序号集合
    for j = 1: popu_num
        select = find(probs > rand);
        select_indices(j) = select(1); 
    end
    
    % CROSSOVER PART
    % selected parent to crossover
    offspring_popu = parent_popu(select_indices);

    % start
    for j = 1: popu_num / 2

        k1 = offspring_popu(j).gene;
        k2 = offspring_popu(popu_num-j).gene;
        
        % 随机生成kp, ki, kd三个交叉点
        po = [randi([2, gene_num/3]), randi([2, gene_num/3]), randi([2, gene_num/3])]; 
        
        offspring_popu(j).gene = {[k1{1}(1:po(1)-1), k2{1}(po(1):end)], ... 
                                  [k1{2}(1:po(2)-1), k2{2}(po(2):end)], ...
                                  [k1{3}(1:po(3)-1), k2{3}(po(3):end)]};

        offspring_popu(popu_num-j+1).gene = {[k2{1}(1:po(1)-1), k1{1}(po(1):end)], ... 
                                           [k2{2}(1:po(2)-1), k1{2}(po(2):end)], ...
                                           [k2{3}(1:po(3)-1), k1{3}(po(3):end)]};
        
    end
    
    % MUTATE PART
    for j = 1: popu_num
        if rand <= mutate_prob 
            % mutate position 
            % e.g.[2, 6] means parameter ki  6th bit 
            s1 = randi([1, 3]);
            s2 = randi([1, gene_num/3]);
        
            m = offspring_popu(j).gene{s1}(s2);       
            m = num2str(1 - str2num(m));
            offspring_popu(j).gene{s1}(s2) = m;           
        end
        
        % finish all operations including select, crossover, mutate
        % calculate pid 
        offspring_popu(j).k = decoding(offspring_popu(j).gene, prec);
        
        % check pid range
        [offspring_popu(j).k, offspring_popu(j).gene] = check_range(offspring_popu(j).k, ...
                                                                    offspring_popu(j).gene,...
                                                                    kp_range,...
                                                                    ki_range,...
                                                                    kd_range,...
                                                                    prec);

        % calculate fitness
        offspring_popu(j).fitness = get_fitness(offspring_popu(j).k, sys, u, t, x0);
    end

    % next population
    parent_popu = offspring_popu;
  
end

% last generation 
[~, idx] = sort([parent_popu.fitness]);
parent_popu = parent_popu(idx);
y(length(x)) = 1 / parent_popu(30).fitness;
history{max_iter+1} = parent_popu(30);

% plot optimal error
figure
plot(x,y)

title('各代误差积分最优解')
xlabel('Generation')
ylabel('IATE Error Integral')

% optimal simulink response
Kp = parent_popu(30).k(1);
Ki = parent_popu(30).k(2);
Kd = parent_popu(30).k(3);

x_0 = x0(1:4);

simOut = sim("model.slx", t);
y = simOut.yout{1}.Values.Data;

figure
plot(t, y);

title('系统最优响应')
xlabel('time')
ylabel('angel_pendulum')
