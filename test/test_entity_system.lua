package.path = "../;" .. package.path
local lu = require("test.luaunit")
require("Common.Generated.entitas.EntitasAutoInc")
Entitas = require("Common.entitas.entitas")
PlayerMatcher = require("Common.Generated.entitas.PlayerMatchers")
PlayerComponents = require("Common.Generated.entitas.PlayerComponents")

require("Data.DataInc")

local Systems = Entitas.Systems
local ReactiveSystem = Entitas.ReactiveSystem
local utils = Entitas.Utils
local GLOBAL = _G


GLOBAL.test_normal_entity = function()
    ---@type PlayerContext
    local context = require("Common.Generated.entitas.PlayerContext"):new(require("Common.Generated.entitas.PlayerEntity"))
    local e = context:CreateEntity()

    assert(e.name == nil, "before replace, this must be nil")
    e:replaceName(5)
    assert(e.name.value == 5 , "after replace, this must be 5, 10\n")
    assert(e.asset == nil, "before replace, this must be nil")
    e:addEnergy("123")
    assert(e.energy.value == "123", "after replace, this must be 123\n")
    assert(e:hasCoin() == false, "before set , this must be false")
    e:setDestroy(true)
    assert(e:hasDestroy() == true, "after set,this must true\n")
    context:destroy_entity(e)
end

GLOBAL.test_single_group = function()
    local singel_record = 0
    ---@type PlayerContext
    local context = require("Common.Generated.entitas.PlayerContext"):new(require("Common.Generated.entitas.PlayerEntity"))
    local e = context:CreateEntity()
    local testGroup = context:get_group(PlayerMatcher.Exp)

    testGroup.on_entity_added:add(function ()
        singel_record = singel_record + 1
    end)
    testGroup.on_entity_removed:add(function ()
        singel_record = singel_record + 2
    end)
    testGroup.on_entity_updated:add(function ()
        singel_record = singel_record + 3
    end)

    e:replaceExp(1)
    assert(singel_record == 1, "after add, add event must call")

    e:removeExp()
    assert(singel_record == 3, "after remove, remove event must call")

    e:replaceExp(1)
    assert(singel_record == 4,"after add, add event must call")

    e:replaceExp(1)
    assert(singel_record == 10, "after replace, add, remove, update event must call")
end

GLOBAL.test_multi_group = function()
    local multi_group_record = 0
    -----@type PlayerContext
    local context = require("Common.Generated.entitas.PlayerContext"):new(require("Common.Generated.entitas.PlayerEntity"))
    local mu = context:CreateEntity()

    local multi = context:get_group(Matcher( {PlayerComponents.Element, PlayerComponents.Asset}) )
    multi.on_entity_added:add(function ()
        multi_group_record = multi_group_record + 1
    end)
    multi.on_entity_removed:add(function ()
        multi_group_record = multi_group_record + 2
    end)
    multi.on_entity_updated:add(function ()
        multi_group_record = multi_group_record + 3
    end)

    mu:setElement(true)
    assert(multi_group_record == 0, "after add Element, must no log, multi_group_record 0, now:" .. tostring(multi_group_record))

    mu:addAsset("123")
    assert(multi_group_record == 1, "after add Asset, our group must receive add event, multi_group_record 1")

    mu:replaceAsset("321")
    assert(multi_group_record == 7, "after replace Asset, our group must receive add, remove, update event, multi_group_record 7")

    mu:removeAsset()
    assert(multi_group_record == 9, "after remove Asset, our group must receive remove event, multi_group_record 9")

    mu:setDestroy(true)
    assert(multi_group_record == 9, "after destroy Entity, must no log, multi_group_record 9")
end

GLOBAL.test_anyof_group = function()
    local anyof_group_record = 0
    ---@type PlayerContext
    local context = require("Common.Generated.entitas.PlayerContext"):new(require("Common.Generated.entitas.PlayerEntity"))

    local AnyOf = context:get_group(Matcher(nil,{PlayerComponents.Element, PlayerComponents.Asset}))
    AnyOf.on_entity_added:add(function ()
        anyof_group_record = anyof_group_record + 1
    end)
    AnyOf.on_entity_removed:add(function ()
        anyof_group_record = anyof_group_record + 2
    end)
    AnyOf.on_entity_updated:add(function ()
        anyof_group_record = anyof_group_record + 3
    end)
    local any_e = context:CreateEntity()

    any_e:addAsset("addAngle")
    assert(anyof_group_record == 1)
    any_e:setElement(true)
    assert(anyof_group_record == 1)

    any_e:replaceAsset("new asset1")
    assert(anyof_group_record == 7, 'after replaceAsset, add remove update must call')

    any_e:setElement(false)
    print(anyof_group_record)
    assert(anyof_group_record == 7, 'no call')

    any_e:replaceAsset("new asset2")
    assert(anyof_group_record == 13)

    any_e:removeAsset()
    assert(anyof_group_record == 15)
end


GLOBAL.test_noneof_group = function()
    ---@type PlayerContext
    local context = require("Common.Generated.entitas.PlayerContext"):new(require("Common.Generated.entitas.PlayerEntity"))

    local noneof_group_record = 0
    local noneof = context:get_group(Matcher( nil,{PlayerComponents.Element, PlayerComponents.Asset}, {PlayerComponents.Position}))

    local noneof_add = function ()
        noneof_group_record = noneof_group_record + 1
    end

    local noneof_remove = function ()
        noneof_group_record = noneof_group_record + 2
    end

    local noneof_update = function ()
        noneof_group_record = noneof_group_record + 3
    end
    noneof.on_entity_added:add(noneof_add)
    noneof.on_entity_removed:add(noneof_remove)
    noneof.on_entity_updated:add(noneof_update)

    local none_e = context:CreateEntity()
    assert(noneof_group_record == 0 )

    none_e:setElement(true)
    assert(noneof_group_record == 1)

    none_e:addPosition(1,2,3)
    assert(noneof_group_record == 3)

    none_e:addAsset("123")
    assert(noneof_group_record == 3)

    none_e:replacePosition(1,2,3)
    assert(noneof_group_record == 3)

    none_e:removePosition()
    assert(noneof_group_record == 4)
end


GLOBAL.test_singel_entity = function()
        ---@type PlayerContext
    local context = require("Common.Generated.entitas.PlayerContext"):new(require("Common.Generated.entitas.PlayerEntity"))

    assert(context.gameBoard == nil, "before set , this must be nil")
    context:setGem({a = 1, b =2})
    assert(context.gemEntity and context:hasGem() == true, "after set, this must not nil")
    assert(context.gem.value.a == 1 and context.gem.value.b == 2
            and context.gemEntity.gem.value.a == 1 and context.gemEntity.gem.value.b == 2, "after set , this must be a = 1, b=2")
    context:removeGem()
    assert(context.gem == nil and context.gemEntity == nil and  context:hasGem() == false)
end

GLOBAL.test_index = function()
    ---@type PlayerContext
    local context = require("Common.Generated.entitas.PlayerContext"):new(require("Common.Generated.entitas.PlayerEntity"))
    context:initGenerateEntityIndexes()
    local pre_e = context:CreateEntity()
    local record = 0
    pre_e:addName("123")
    local next_e = context:CreateEntity()
    next_e:addName("123")
    local ret = context:GetEntitiesByNamevalue("123")
    record = 0
    for i, v in pairs(ret) do
        record = record + 1
    end
    assert(record == 2)
end

GLOBAL.test_primary_index = function()
    ---@type PlayerContext
    local context = require("Common.Generated.entitas.PlayerContext"):new(require("Common.Generated.entitas.PlayerEntity"))
    context:initGenerateEntityIndexes()
    local pre_e = context:CreateEntity()
    local record = 0
    pre_e:addUid(1)
    local next_e = context:CreateEntity()
    assert(context:GetEntityByUidvalue(1) == pre_e, "entity must equal")
    xpcall(function ()
        next_e:addUid(1)
    end, function ()
        record = record + 1
    end)
    assert(record == 1, 'after add two uid 1,  xpcall error func must call')
end

GLOBAL.test_reactivesystem = function()
    ---@type PlayerContext
    local Context = require("Common.Generated.entitas.PlayerContext"):new(require("Common.Generated.entitas.PlayerEntity"))
    local ReactiveSystem_record = 0
    local entity_count = 0
    local e = Context:CreateEntity("123")

    local positionAdd = class({},"positionAdd", ReactiveSystem)
    function positionAdd:get_trigger()
        return {
            {
                Matcher({PlayerComponents.Position}),
                GroupEvent.ADDED
            }
        }
    end

    function positionAdd:filter(entity)
        return true
    end

    function positionAdd:execute(es)
        entity_count = es:size()
        ReactiveSystem_record = ReactiveSystem_record + 1
    end
    local ss = Systems:new(Context):add(positionAdd:new(Context))
    ss:initialize()
    ss:execute()
    assert(ReactiveSystem_record == 0)
    e:replacePosition(1)
    ss:execute()
    assert(entity_count == 1)
    assert(ReactiveSystem_record == 1)
    e:replacePosition(1)
    ss:execute()
    assert(entity_count == 1)
    assert(ReactiveSystem_record == 2)
    local c = Context:CreateEntity()
    c:addPosition(1)
    ss:execute()
    assert(entity_count == 1, "只有一个改变得单位, 所以应该只有1个")
    e:replacePosition(1)
    c:replacePosition(1)
    ss:execute()
    assert(entity_count == 2)
end


GLOBAL.test_reactivesystem = function()
    local anyrecord = 0
    local selfRecord = 0
    ---@type PlayerContext
    local Context = require("Common.Generated.entitas.PlayerContext"):new(require("Common.Generated.entitas.PlayerEntity"))

    ---@type entitas.Systems
    local eventSystem = require("Common.Generated.entitas.PlayerEventSystems"):new(Context)
    local p = Context:CreateEntity()
    local ccc = {}
    function ccc:OnAnyNameListener(e)
        anyrecord = anyrecord + 1
    end
    function ccc:OnNameListener(e)
        selfRecord = selfRecord + 1
    end

    local systems = classMap.Systems:new()
    systems:add(eventSystem)
    p:AddNameListenerCallBack(ccc)
    p:AddAnyNameListenerCallBack(ccc)
    systems:initialize()
    p:replaceName("123123")
    systems:execute()
    assert(selfRecord == 1, 'self must 1')
    assert(anyrecord == 1, 'any must 1')
    p:replaceName("456")
    systems:execute()
    assert(selfRecord == 2, 'self must 1')
    assert(anyrecord == 2, 'any must 1')
    local c = Context:CreateEntity()
    c:replaceName("55555")
    systems:execute()
    assert(selfRecord == 2)
    assert(anyrecord == 3)
    c:replaceName("55555")
    systems:execute()
    assert(selfRecord == 2)
    assert(anyrecord == 4)
end


local runner = lu.LuaUnit.new()
runner:setOutputType("tap")
local ret = runner:runSuite()
if 0 == ret then
    print("test_entity_system success with result " .. ret)
else
    print("test_entity_system failed with result " .. ret)
end
