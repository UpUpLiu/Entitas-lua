# Entitas-lua
起因是因为用Entitas写游戏逻辑感觉舒服，但是发现没有lua版本（但其实后来才发现原来是有的， 不过基本都没有做代码生成）， 这是一个Entitas_Lua实现。


# 如何安装：
1. 需要Python3.x环境   (配置环境变量)
2. 安装python模板引擎Mako
   pip install mako
3. python EcsTools.py 可以执行生成




# 简单说明:
entitas.json为Ecs的生成配置，  这是一个简单的示例。

配合使用Emmlylua插件为最佳体验， 感谢阿唐为我们提供如此好用的lua插件。（没有EmmyLua插件。。Ecs_lua使用体验会差很多)

原版本参照Entitas-csharp 和 Entias-ts

与Entitas-csharp 最大的不同为 lua中没有getter， setter的功能， 我有一个老版本的使用 metatable 的方式模拟了getter和setter的操作。 
这个版本已经是可以正常使用。 
但是后面放弃了模拟getter，setter的方式， 因为这样会严重拖慢性能。 所以就在易用性上面做了一些妥协。


配置说明:
~~~
  "contexts":{    每一个contexts代表一个上下文。（和C#版本的新增一个Attribute一样）
		"game":{      context的名字
			"components":{    该context的组件列表
				"IdComponent":[   组件的名字
					"value:number"  组件的属性名：组件的属性的类型（类型会用于代码提示）
				],
				"Movable":false,  组件名字：false  如果该组件没有属性， 那么就是一个简单的falg属性， 固定写法 false
        "GameBoard":[     组件名字
					"levelName:string",    组件的属性名：组件的属性的类型（组件属性可以有多个）
					"height:number",       组件的属性名：组件的属性的类型
					"width:number",
					"levelConfig:Config.LevelMapConfig"
				],
        "ElementType":[
              "value:ElementType"
        ],
      "entities":{    唯一组件列表， 组件必须要线进行预先配置才能当作唯一组件
        "GameBoard":true,   组件名字：true（固定写法）   标识这个组件会是一个唯一组件.会在Context下生成API
      },
      "indexes":{     组件索引列表， 组件必须要线进行预先配置才能当作索引（建立索引的时机是实时的）
        "primary":{   唯一键值索引     框架会自动生成以该值为唯一键值索引的代码， 如果重复添加会报错
          "IdComponent":[
            "value:number"
          ]
        },
        "index":{    不唯一键值索引    框架会自动生成以该值作为键值索引的代码， 会提供通过键值获取列表的API
          "ElementType":[
            "value:ElementType"
          ],
          "ViewPos":[
            "value:PosV2"
          ]
        }
      }
    ],
    "gameState":{
      ...     其他Context
    }
}
~~~

生成出来的lua文件是GenerateEcsCore.lua， 配合使用EmmyLua插件，你会有飞一般的体验， 基本和写静态的语言的感觉是差不多的

# 最后

我自己的项目是会持续使用， 并且会在之后的上传简单的Unity例子工程


# 测试
测试环境: lua5.3.4, windows
测试方法: lua53.exe test_runtime.lua (需要先进行生成)


# TODO:
1. 与Unity Inspector显示的连接，与监测
2. 生成API优化 （目前有一些参数传递可能是多余的， 然后所有的ComponentIndex，其实可以全部直接使用数字， 因为既然是生成的API，也不用去考虑可读性）
3. 考虑实现C#版本Event的标签
4. 简单的Demo
