return {
    player = { -- 道具配置
        data = {
            "player : ${pre_tag}PlayerEntity"
        },
        tag = { tag.User }
    },
    prop  = {  --道具信息
        data ={
            "value : ${pre_tag}PropEntity",
        },
        tag = { tag.User }
    },
    dress  = {  --衣服信息
        data ={
            "value : ${pre_tag}DressEntity",
        },
        tag = { tag.User }
    },
    stage  = {  --关卡信息
        data ={
            "value : ${pre_tag}StageEntity",
        },
        tag = { tag.User }
    },
    task  = {  --任务信息
        data ={
            "value : ${pre_tag}TaskEntity",
        },
        tag = { tag.User }
    }
}