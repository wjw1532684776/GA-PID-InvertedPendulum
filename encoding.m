%{ 
将表现型编码为对应基因型

Parameters:
 k - pid参数，array，[kp, ki, kd]
 prec - pid参数精度，float, 0.1

Returns:
 gene - 返回10位二进制编码后的基因型，1x3 cell，{'01', '10', '11'}

%}

function gene = encoding(k, prec)
    
    % 考虑精度，统一编码为10位二进制数
    kp = dec2bin(k(1)/prec, 10);
    ki = dec2bin(k(2)/prec, 10);
    kd = dec2bin(k(3)/prec, 10);
    
    gene = {kp, ki, kd};
end
