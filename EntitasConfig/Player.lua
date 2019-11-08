return {
    name ={  --名字
        data = {
            "value : string @ index"
        },
        tag = { tag.Player},
        event = {
            {
                target = EventTarget.Any
            },
            {
                target = EventTarget.self
            }
        }
    },
    exp = { --经验
        data = {
            "value : number"
        },
        tag = { tag.Player},
        single = true,

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
    },
    element = { --测试
        tag = { tag.Player}

    },
    asset = { --测试
        data = {
            'value : number'
        },
        tag = { tag.Player}
    }
}