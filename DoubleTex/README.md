# Double Texture

一个World Position shader应用。可能很适合解密游戏？ [文章](https://llapuras.top/World-Position-Shader/)

添加shader到场景模型，使用两种贴图，第二章贴图根据目标物体的位置显示。

将代码``ShaderPosition.cs``挂到目标物体上，将目标物体的位置传入LapuDouble进行距离计算。

### LapuDouble_step1.shader

借助世界坐标形成球形区域，类似点光源。

### LapuDouble_step2.shader

全场dissolve效果。

