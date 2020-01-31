return {
    type_id = {
        data ={
            "value : number"
        },

        attr = {
            {
                attr_define = 'Event',
                eventTarget = EventTarget.Self,
                eventType = EventType.ADDED,
            },
            {
                attr_define = 'SendMsg',
                eventType = EventType.ALL
            }
        },
        tag = { tag.Dress}
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