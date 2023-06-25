%{
检查pid参数有无越界，若超出最大范围，则将参数自动修改为范围允许最大值

Parameters:
 k - 待检验pid参数, array
 gene - 待检验pid参数对应二进制编码, cell
 kp_range - Kp允许范围最大值(不含)
 ki_range - Ki允许范围最大值(不含)
 kd_range - Kd允许范围最大值(不含)
 prec - pid参数精度

Returns:
 tested_k - 返回检查后pid参数, array
 tested_gene - 返回检查后pid参数对应二进制编码, cell

%}

function [tested_k, tested_gene] = check_range(k, gene, kp_range, ki_range, kd_range, prec)
    
    % encoding the maximum pid parameters
    max_gene = encoding([kp_range-prec, ki_range-prec, kd_range-prec], prec);
    
    tested_k = k;
    tested_gene = gene;
    
    if k(1) >= kp_range
        tested_k(1) = kp_range - prec;
        tested_gene{1} = max_gene{1}; 
    end

    if k(2) >= ki_range
        tested_k(2) = ki_range - prec;
        tested_gene{2} = max_gene{2};
    end

    if k(3) >= kd_range
        tested_k(3) = kd_range - prec;
        tested_gene{3} = max_gene{3};
    end

end