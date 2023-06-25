%{ 
根据pid参数计算适应度
即测试的输出(角度)误差随时间的IATE积分
并对结果取倒数，表明误差越大，适应度越小

Parameters:
 k - 代测试pid参数，array，[kp, ki, kd]
 sys - 状态空间模型, ss
 u - 闭环系统输入值, zeros()
 t - 仿真时间, [::]
 x0 - 系统初始值, array, [2; 10; -5; 0; 0; 0]

Returns:
 fitness - 返回该组pid参数对应的适应度，double

%}

function fitness = get_fitness(k, sys, u, t, x0)
    % create system feedback model
    Gc = pid(k(1), k(2), k(3), 0.01); % pid
    
    sys_fb = feedback(sys*Gc, 1);
    
    y = lsim(sys_fb, u, t, x0);

    IATE_error = 0;

    for i = 2: length(t)
        IATE_error = IATE_error + t(i)*abs(y(i)); % error integral
    end
            
    fitness = 1 / IATE_error;
end