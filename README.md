# Entitas-lua
起因是因为用Entitas写游戏逻辑感觉舒服，但是发现没有lua版本（但其实后来才发现原来是有的， 不过基本都没有做代码生成）， 这是一个Entitas_Lua实现。


# 如何安装：
1. 需要Python3.x环境   (配置环境变量)
2. 安装python模板引擎Mako, 用于解析lua代码的差距 lupa, 用于处理跨平台生成的 pathlib
   pip install mako
   pip install lupa
   pip install pathlib
3. cd src    
   python build.py 可以执行生成




# 简单说明:
EntitasConfig路径下的文件为Ecs的生成配置，  这是一个简单的示例。

配合使用Emmlylua插件为最佳体验， 感谢阿唐为我们提供如此好用的lua插件。（没有EmmyLua插件。。Ecs_lua使用体验会差很多)

原版本参照Entitas-csharp 和 [entitas-lua](https://github.com/sniper00/entitas-lua).  有较大修改.

因为以前的版本参照ts实现较为复杂, 所以使用别人已经写好的简单版本.

与Entitas-csharp 最大的不同为 lua中没有getter， setter的功能， 对于getter, setter,  直接使用函数替代. 
如 以前的 e.isDestroy 变为 e:hasDestroy() (之前有实现一个版本 使用__index和__newindex 模拟get, set的处理, 考虑复杂度和性能, 放弃了)

如果需要查看一些使用文档， 建议查看原始版本[Entitas C# Wiki](https://github.com/sschmid/Entitas-CSharp/wiki)，因为该实现与原始实现基本是一致的


# 配置说明:  
  ## 首先是 配置根文件  entitas.lua  用于全局配置:
```
---@class entitas.Event
---@field eventTarget entitas.gen.EventTarget
---@field eventType entitas.gen.EventType
---@field priority number

---@class entitas.EventTarget
EventTarget = {  -- 事件目标
	Any = 'Any',
	Self = 'Self'
}

---@class entitas.EventType
EventType = {    --事件目标类型
	ADDED = 'ADDED',
	REMOVED = 'REMOVED',
	ALL = 'ALL',
}



AttrDefine = {    --扩展定义
	Index = {     --属性扩展  对应IndexHandler
		attrList = {
			'index', 'primaryIndex', 'muIndex'
		},
		handleTogether = true
	},

	Event = {    -- 事件扩展, EventHandler
	},

	SendMsg = {  -- 发送事件类型扩展, 对应 SendMsgHandler
	},

	--其他你相遇扩展的自定义属性, 可以参考 SendMsg进行扩展处理 用户扩展生成的方式
}

tag = {    --tag 定义, 每个component 都必须有至少一个tag的定义
	Player = 'Player',
	Prop = 'Prop',
	Dress = 'Dress',
	User = 'User',
	PlayPlayer = 'PlayPlayer',
	Stage = 'Stage'
}

local entitas = {    --总配置     用于配置路径和一些其他设置
	namespace ="Entitas",   --生成的命令空间, 用emmylua插件的时候 对于class 的标记 有命名空间的需求(暂时没用上)
	source ="Common.entitas",  -- luaentitas 底层代码路径( 用于生成require路径)
	output ="../Common/Generated/entitas",   -- 生成代码输出位置
	service_path = "../src/Entitas",      -- 对于每一个context都会生成一个service, 这个是存放路径
	parse = "lua",                -- 解析后缀, 本意是可以提供不同的配置和生成器, 用于生成不同语言的版本, (我之前有做htm5), 但是json不能有注释, 所以放弃了对于json的支持
	tag = tag,     --tag组
	AttrDefine = AttrDefine  -- 属性扩展组
}
return entitas
```

## 工具会自动获取与entitas.lua 同路径下的lua文件, 运行 并检查返回值的
Component:
```

return {
    type_id = {   -- component名字
        data ={  -- component数据定义, 如果没有定义数据, 则默认为是标记component
            "value : number" 格式为:  变量名 : 注释名字 @ attr | attr .. (目前字段的 attr仅支持 index 和 primaryIndex 这个属于内置支持)
        },
		-- 对于标记类型, 不会生成replace方法, 相应的会生成一个 set方法, 用于区分
        attr = {  -- 扩展属性定义, 每一个扩展属性定义都是一个table, 且以数组形式排列
            { 
                attr_define = 'Event',  -- 属性名 会用名字 + Handler 找到用于处理这个属性的脚本, 并运行
                eventTarget = EventTarget.Self,  -- 属性参数 对于事件类型, 需要提供target参数( 详细请参照原版)
                eventType = EventType.ADDED,    -- 属性参数 对于事件类型, 需要提供target参数( 详细请参照原版)
            },
            {
                attr_define = 'SendMsg', -- 属性名 会用名字 + Handler 找到用于处理这个属性的脚本
                eventType = EventType.ALL  -- 对于sendmsg类型, 也需要关心事件类型.
            }
        },
        tag = { tag.Dress} --标记这个component 属于那个 context, 可以配置多个
    },
    num = {
        data = {
            "value : number"
        },
        tag = { tag.Dress}

    },
    config = { -- 衣服配置
        data = {
            "value : DressTemplateData"
        },
        tag = { tag.Dress}
    },
    itemInfo = {  --道具信息
        data ={
            "value : ItemInfo",
        },
        tag = { tag.Dress}
    }
}
```

# 简单展示
生成代码之后得使用体验
![image](https://github.com/UpUpLiu/Entitas-lua/blob/master/document/tips.gif)

不生成代码得使用体验
![image](https://github.com/UpUpLiu/Entitas-lua/blob/master/document/noTips.gif)



# 测试
测试环境: lua5.3.4, windows
测试方法: bash: ./luaexe/lua.exe test.lua (需要先进行生成)

# 更新与简单说明

## v1.0.1
1. 与Unity Inspector显示的连接，与监测
2. 生成API优化 （目前有一些参数传递可能是多余的， 然后所有的ComponentIndex，其实可以全部直接使用数字， 因为既然是生成的API，也不用去考虑可读性）已完成
3. 考虑实现C#版本Event的标签   已完成
4. 支持index和primaryindex标签 已完成
6. 配置文件优化, 支持以tag方式区分不同的Context 已完成
7. 增加sync类型,  用于双端架构, 用于对客户端和服务器自动同步数据使用
8. 提供统一的 attr 自定义 方式
9. 简单的Demo
1o. 生成代码 改为用python_Entitas实现
11. 优化matcher的匹配规则, 把字符串拼接拿掉

修改说明: 
    主要是因为当我们有扩展需求的时候, 需要写自己的属性扩展处理器.  对于正常的生成, 大家应该是没有扩展的需求, 但是有一些特定扩展, 是根据项目来的. 所以大家会有自己的扩展的需求. v1.0.1就是为了解决这个问题.  
    1. 主要是python那边 采用了 entitas 用于组织数据,  用生成的方式代替重写, 不过只有简单的支持, 没有对于attr 属性扩展支持. 未来可能会考虑扩展python部分的实现, 不过就目前来说已经够用了.  entitas的数据组织是高内聚的方式(所以也可以用其他方式, 只要是高内聚就可以, 同时使用代码生成的方法, 省去api编写的时间) , 对于扩展处理 需要数据的时候会特别方便.

## V1.0.0

1. 与Unity Inspector显示的连接，与监测
2. 生成API优化 （目前有一些参数传递可能是多余的， 然后所有的ComponentIndex，其实可以全部直接使用数字， 因为既然是生成的API，也不用去考虑可读性）已完成
3. 考虑实现C#版本Event的标签 已完成
4. 支持index和primaryindex标签 已完成
5. 配置文件优化, 支持以tag方式区分不同的Context 已完成
6. 增加sync类型, 用于双端架构, 用于对客户端和服务器自动同步数据使用
7. 提供统一的 attr 自定义 方式
8. 简单的Demo 1o. 生成代码 改为用python_Entitas实现
9. 优化matcher的匹配规则, 把字符串拼接拿掉
