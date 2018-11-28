# Entitas-lua
起因是因为用Entitas写游戏逻辑感觉舒服，但是发现没有lua版本， 这是一个Entitas_Lua实现。


# 如何安装：
1. 需要Python3.x环境
2. 安装python模板引擎Mako
3. python EcsTools.py 可以执行生成



# 简单说明:
entitas.json为Ecs的生成配置，  这是一个简单的示例。

配合使用Emmlylua插件为最佳体验， 感谢阿唐为我们提供如此好用的lua插件。（没有Emmlylua插件。。Ecs_lua使用体验会差很多)

原版本参照Entitas-csharp 和 Entias-ts

与Entitas-csharp 最大的不同为 lua中没有getter， setter的功能， 我有一个老版本的使用 metatable 的方式模拟了getter和setter的操作。 
这个版本已经是可以正常使用。 
但是后面放弃了模拟getter，setter的方式， 因为这样会严重拖慢性能。 所以就在易用性上面做了一些妥协。
然后没有csharp中不同Contexts的概念  和  打标签生成唯一键值索引的方法。

这2个都是可以通过代码生成达到效果。 但是我可能没有时间进行这个优化。


# 最后

我自己的项目是会持续使用， 并且会在之后的上传简单的Unity例子工程
