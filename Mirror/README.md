# Mirror

简易镜面效果。

1. 创建一个Camera，调整Camera使其面对想要展示的镜面对象，其视野范围内内容即镜面呈现内容
2. 创建一个RendererTexture，调整其大小使符合镜面大小，并将其添加到新建Camera上
3. 创建一个Quad（或者其他作为镜面的模型），添加shader，添加RendererTexture作为贴图
