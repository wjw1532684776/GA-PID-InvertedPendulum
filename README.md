# README

## 层级结构

```
优化大作业
├─ check_range.m
├─ decoding.m
├─ encoding.m
├─ get_fitness.m
├─ main.m
├─ model.slx
├─ MyFirstPaper.pdf
├─ README.md
```

`main.m`文件为项目主入口文件
`encoding.m`为编码函数
`decoding.m`为解码函数
`get_fitness.m`为计算适应度函数
`check_range.m`为约束优化函数

`model.slx`为**Simulink**仿真模型

`MyFirstPaper.pdf`为项目论文

## 运行

将文件夹加载至MATLAB工作区

直接运行,如果运行过程中遇到错误，请忽略，重新运行直至出现正确结果即可

运行无误，应出现两张Figure图

1张为各代误差积分

1张为最后一代最优响应

**详情参照`MyFirstPaper.pdf`文末示意**


