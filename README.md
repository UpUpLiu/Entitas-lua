# Entitas-lua
起因是因为用Entitas写游戏逻辑感觉舒服，但是发现没有lua版本（但其实后来才发现原来是有的， 不过基本都没有做代码生成）， 这是一个Entitas_Lua实现。


# 如何安装：
1. 需要Python3.x环境   (配置环境变量)
2. 安装python模板引擎Mako, lupa, pathlib
   pip install mako
   pip install lupa
   pip install pathlib
3. cd src
   python build.py 可以执行生成




# 简单说明:
EntitasConfig路径下的文件为Ecs的生成配置，  这是一个简单的示例。

配合使用Emmlylua插件为最佳体验， 感谢阿唐为我们提供如此好用的lua插件。（没有EmmyLua插件。。Ecs_lua使用体验会差很多)

原版本参照Entitas-csharp 和 [entitas-lua](https://github.com/sniper00/entitas-lua). 

因为以前的版本参照ts实现较为复杂, 所以使用别人已经写好的简单版本.

与Entitas-csharp 最大的不同为 lua中没有getter， setter的功能， 对于getter, setter,  直接使用函数替代. 
如 以前的 e.isDestroy 变为 e:hasDestroy() (之前有实现一个版本 使用__index和__newindex 模拟get, set的处理, 考虑复杂度和性能, 放弃了)

如果需要查看一些使用文档， 建议查看原始版本[Entitas C# Wiki](https://github.com/sschmid/Entitas-CSharp/wiki)，因为该实现与原始实现基本是一致的


# 配置说明:  
   首先是 配置根文件  entitas.lua  用于全局配置:
   ---@class entitas.gen.EventTarget
      EventTarget = {  --事件目标类型
         Any = 'Any',
         self = 'self'
      }

      ---@class entitas.gen.EventType
      EventType = {  -- 事件类型
         ADDED = 'ADDED',
         REMOVED = 'REMOVED',
      }

      tag = {    --Context 标记
         Player = 'Player',
         Prop = 'Prop',
         Dress = 'Dress',
         User = 'User',
         PlayPlayer = 'PlayPlayer',
         Stage = 'Stage'
      }
      local entitas = {
         namespace ="Entitas",  --命名空间,  暂时无用
         source ="Common.entitas", -- entita的源文件位置(用于require)
         output ="../Common/Generated/entitas",  输出位置
         parse = "lua",  -- 解析方式  目前只有lua  (因为之前有打算支持多种配置  最开始的配置用的是json  因为我有用于开发 h5)
         tag = tag       -- contexts的tag组
      }

  工具会自动获取与entitas.lua 同路径下的lua文件, 运行 并检查返回值的Component:
  return {
    name ={  --名字
        data = {          如果Component不是标记Component, 那么需要定义data 用于说明变量
            "value : string @ index"  格式为:  变量名 : 注释名字 @ attr | attr .. (目前字段的 attr仅支持 index 和 primaryIndex)
        },
        tag = { tag.Player},   --标记这个Component 属于那个 Context, 可以配置多个
        event = {             -- 标记这个Compoent 需要自动生成 事件System
            {
                target = EventTarget.Any, -- 目标类型
                type = EventType.ADDED,   -- 事件类型  默认ADDED
                priority = --0,  --优先级 (这个暂未实现) 默认0
            },
            {
                target = EventTarget.self
            }
        }
    },
    uid = {
		data ={
			"value : long @ primaryIndex"
		},
        Events = {

        },
        tag = { tag.Player, tag.User }  --支持多个Context配置
    },
    exp = { --经验
        data = {
            "value : number"
        },
        tag = { tag.Player},

    },
    coin = {  --金币
        data ={
            "value : number",
        },
        tag = { tag.Player}

    },
    gem = { --钻石
        data = {
            "value : number"
        },
        tag = { tag.Player}
    },
    lvl = { --等级
        data = {
            'value : number'
        },
        tag = { tag.Player}
    },
    energy = { --体力
        data = {
            'value : number'
        },
        tag = { tag.Player}
    }
}



# 简单展示
生成代码之后得使用体验
![image](https://github.com/UpUpLiu/Entitas-lua/blob/master/document/tips.gif)

不生成代码得使用体验
![image](https://github.com/UpUpLiu/Entitas-lua/blob/master/document/noTips.gif)



# 测试
测试环境: lua5.3.4, windows
测试方法: bash: ./luaexe/lua.exe test.lua (需要先进行生成)

# TODO:
1. 与Unity Inspector显示的连接，与监测
2. 生成API优化 （目前有一些参数传递可能是多余的， 然后所有的ComponentIndex，其实可以全部直接使用数字， 因为既然是生成的API，也不用去考虑可读性）已完成
3. 考虑实现C#版本Event的标签   已完成
4. 支持index和primaryindex标签 已完成
6. 配置文件优化, 支持以tag方式区分不同的Context 已完成
7. 增加sync类型,  用于双端架构, 用于对客户端和服务器自动同步数据使用
8. 提供统一的 attr 自定义 方式
9. 简单的Demo
