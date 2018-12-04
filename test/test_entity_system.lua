local lu = require("test.luaunit")
Entitas = require("entitas")
require("Data.DataInc")
require("GenerateEcsCore")

local Systems = Entitas.Systems
local ReactiveSystem = Entitas.ReactiveSystem
local utils = Entitas.Utils
local GLOBAL = _G


GLOBAL.test_normal_entity = function()
    local context = GameContext
    context:destroyAllEntities()
    local e = context:createEntity()
    assert(e.position == nil, "before replace, this must be nil")
    e:replacePosition(5)
    assert(e.position.value == 5 , "after replace, this must be 5, 10\n")
    assert(e.asset == nil, "before replace, this must be nil")
    e:addAsset("123")
    assert(e.asset.value == "123", "after replace, this must be 123\n")
    assert(e:hasElement() == false, "before set , this must be false")
    e:setElement(true)
    assert(e:hasElement() == true, "after set,this must true\n")
    context:destroyEntity(e)
end

GLOBAL.test_single_group = function()
    local singel_record = 0
    local context = GameContext
    context:destroyAllEntities()
    local testGroup = context:getGroup(GameMatcher.GameBoard)
    testGroup.onEntityAdded:add(function ()
        singel_record = singel_record + 1
    end)
    testGroup.onEntityRemoved:add(function ()
        singel_record = singel_record + 2
    end)
    testGroup.onEntityUpdated:add(function ()
        singel_record = singel_record + 3
    end)
    context:setGameBoard(1,2,3,4)
    assert(singel_record == 1, "after add, add event must call")
    context:removeGameBoard()
    assert(singel_record == 3, "after remove, remove event must call")

    context:setGameBoard(1,2,3,4)
    assert(singel_record == 4,"after add, add event must call")

    context:replaceGameBoard(1,2,3,4)
    assert(singel_record == 10,"after replace, add, remove, update event must call")
end

GLOBAL.test_multi_group = function()
    local multi_group_record = 0
    local context = GameContext
    context:destroyAllEntities()
    local mu = context:createEntity()

    local multi = context:getGroup(GameMatcher.AllOf( GameMatcher.Element, GameMatcher.Asset))
    multi.onEntityAdded:add(function ()
        multi_group_record = multi_group_record + 1
    end)
    multi.onEntityRemoved:add(function ()
        multi_group_record = multi_group_record + 2
    end)
    multi.onEntityUpdated:add(function ()
        multi_group_record = multi_group_record + 3
    end)

    mu:setElement(true)
    assert(multi_group_record == 0, "after add Element, must no log, multi_group_record 0")

    mu:addAsset("123")
    assert(multi_group_record == 1, "after add Asset, our group must receive add event, multi_group_record 1")

    mu:replaceAsset("321")
    assert(multi_group_record == 7, "after replace Asset, our group must receive add , remove , update event, multi_group_record 7")

    mu:removeAsset()
    assert(multi_group_record == 9, "after remove Asset, our group must receive remove  event, multi_group_record 8")

    mu:setDestroy(true)
    assert(multi_group_record == 9, "after destroy Entity, must no log, multi_group_record 8")

    context:destroyAllEntities()
end

GLOBAL.test_anyof_group = function()
    local anyof_group_record = 0
    local context = GameContext
    context:destroyAllEntities()
    local AnyOf = context:getGroup(GameMatcher.AnyOf( GameMatcher.Angle, GameMatcher.AssetObject))
    AnyOf.onEntityAdded:add(function ()
        anyof_group_record = anyof_group_record + 1
    end)
    AnyOf.onEntityRemoved:add(function ()
        anyof_group_record = anyof_group_record + 2
    end)
    AnyOf.onEntityUpdated:add(function ()
        anyof_group_record = anyof_group_record + 3
    end)
    local any_e = context:createEntity()
    any_e:addAngle("addAngle")
    assert(anyof_group_record == 1)
    any_e:addAssetObject("addAssetObject")
    assert(anyof_group_record == 1)
    any_e:replaceAssetObject("new asset1")
    assert(anyof_group_record == 7)

    any_e:removeAngle()
    assert(anyof_group_record == 7)

    any_e:replaceAssetObject("new asset2")
    assert(anyof_group_record == 13)

    any_e:removeAssetObject()
    assert(anyof_group_record == 15)
end


GLOBAL.test_noneof_group = function()
    local context = GameContext
    context:destroyAllEntities()
    local noneof_group_record = 0
    local noneof = context:getGroup(GameMatcher.AnyOf( GameMatcher.Element, GameMatcher.Asset):noneOf(GameMatcher.Position))
    local noneof_add = function ()
        noneof_group_record = noneof_group_record + 1
    end

    local noneof_remove = function ()
        noneof_group_record = noneof_group_record + 2
    end

    local noneof_update = function ()
        noneof_group_record = noneof_group_record + 3
    end
    noneof.onEntityAdded:add(noneof_add)
    noneof.onEntityRemoved:add(noneof_remove)
    noneof.onEntityUpdated:add(noneof_update)
    local none_e = context:createEntity()
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

    noneof.onEntityAdded:remove(noneof_add)
    noneof.onEntityRemoved:remove(noneof_remove)
    noneof.onEntityUpdated:remove(noneof_update)
end


GLOBAL.test_singel_entity = function()
    local context = GameContext
    context:destroyAllEntities()
    assert(context.gameBoard == nil, "before set , this must be nil")
    context:setGameBoard(1,2,3,4)
    assert(context.gameBoardEntity and context:hasGameBoard() == true, "after set, this must not nil")
    assert(context.gameBoardEntity.gameBoard.width == 3 and context.gameBoardEntity.gameBoard.height == 2
            and context.gameBoardEntity.gameBoard.levelConfig == 4 and context.gameBoardEntity.gameBoard.levelName == 1, "after set , this must be 3")
    context:removeGameBoard()
    assert(context.gameBoard == nil and context:hasGameBoard() == false)
end

GLOBAL.test_index = function()
    local Context = GameContext
    local pre_e = Context:createEntity("test")
    local record = 0
    pre_e:addViewPos(PosV2(1,2))
    local next_e = Context:createEntity("test2")
    next_e:addViewPos(PosV2(1,2))
    local ret = Context:GetEntitiesByViewPosvalue(PosV2(1,2))
    record = 0
    for i, v in pairs(ret) do
        record = record + 1
    end
    assert(record == 2)
    Context:destroyAllEntities()
end

GLOBAL.test_primary_index = function()
    local Context = GameContext
    local pre_e = Context:createEntity("test")
    local record = 0
    pre_e:addPosition(PosV3(1,2,3))
    local next_e = Context:createEntity("test2")
    xpcall(function ()
        next_e:addPosition(PosV3(1,2,3))
    end, function ()
        record = record + 1
    end)
    assert(record == 1)
    Context:destroyAllEntities()

end

GLOBAL.test_reactivesystem = function()
    local Context = GameContext
    local ReactiveSystem_record = 0
    local entity_count = 0
    local e = Context:createEntity("123")

    local positionAdd = utils.class("positionAdd", ReactiveSystem)
    function positionAdd:getTriggers()
        return {GameMatcher.AllOf(GameMatcher.Position):onEntityAdded()}
    end

    --在这里处理一些筛选得工作, 如果去掉会提升性能
    function positionAdd:filter(entity)
        return true
    end

    function positionAdd:react(entities)
        entity_count = #entities
        ReactiveSystem_record = ReactiveSystem_record + 1
    end
    local ss = Systems.new():add(Context:createSystem(positionAdd))
    ss:initialize()
    ss:execute()
    assert(ReactiveSystem_record == 0)
    e:replacePosition(PosV3(1,1,3))
    ss:execute()
    assert(entity_count == 1)
    assert(ReactiveSystem_record == 1)
    e:replacePosition(PosV3(3,2,2))
    ss:execute()
    assert(entity_count == 1)
    assert(ReactiveSystem_record == 2)
    local c = Context:createEntity("123")
    c:addPosition(PosV3(1,2,2))
    ss:execute()
    assert(entity_count == 1, "只有一个改变得单位, 所以应该只有1个")
    e:replacePosition(PosV3(3,2,2))
    c:replacePosition(PosV3(1,2,2))
    ss:execute()
    assert(entity_count == 2)
    Context:destroyEntity(e)

end

GLOBAL.test_10000_entities = function()

end






local runner = lu.LuaUnit.new()
runner:setOutputType("tap")
local ret = runner:runSuite()
if 0 == ret then
    print("test_entity_system success with result " .. ret)
else
    print("test_entity_system failed with result " .. ret)
end
