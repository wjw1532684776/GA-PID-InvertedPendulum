%{ 
将基因型解码为对应表现型

Parameters:
 gene - 基因型参数，1x3 cell，{'01', '10', '11'}
 prec - pid参数精度，float, 0.1

Returns:
 k - 返回解码后的pid参数，array，[kp, ki, kd]

%}

function k = decoding(gene, prec)
    
    kp = bin2dec(gene{1}) * prec;
    ki = bin2dec(gene{2}) * prec;
    kd = bin2dec(gene{3}) * prec;
 
    k = [kp, ki, kd];
end