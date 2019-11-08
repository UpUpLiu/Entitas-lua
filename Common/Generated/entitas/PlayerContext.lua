local EntityIndex = require("Common.entitas.EntityIndex")local PrimaryEntityIndex = require("Common.entitas.PrimaryEntityIndex")local Matcher = require("Common.entitas.Matcher")local Player_comps = require('.PlayerComponents')---@class PlayerContext : entitas.Context---@field PlayerExpEntity PlayerEntity---@field exp ExpComponent---@field createEntity fun():PlayerEntitylocal PlayerContext = {}---@return boolfunction PlayerContext:removeDestroy()    self:remove_unique_component('destroy')end---@return boolfunction PlayerContext:removeUid()    self:remove_unique_component('uid')end---@return boolfunction PlayerContext:removeElement()    self:remove_unique_component('element')end---@return boolfunction PlayerContext:removeCoin()    self:remove_unique_component('coin')end---@param value  number---@returns PlayerEntityfunction PlayerContext:setExp(value)    if self:has_unique_component(Player_comps.Exp) then        error('ExpComponent already have')    end    return self:set_unique_component('exp', Player_comps.Exp, value)end---@param value  number---@returns PlayerEntityfunction PlayerContext:replaceExp(value)    local entity = self.expEntity    if entity == nil then        self:setExp(value)    else        self.exp = entity:replace(Player_comps.Exp, value)    end    return entityend---@return boolfunction PlayerContext:hasExp()    return self:has_unique_component(Player_comps.Exp) ~= nilend---@return boolfunction PlayerContext:removeExp()    self:remove_unique_component('exp')end---@return boolfunction PlayerContext:removeAsset()    self:remove_unique_component('asset')end---@return boolfunction PlayerContext:removeEnergy()    self:remove_unique_component('energy')end---@return boolfunction PlayerContext:removeName()    self:remove_unique_component('name')end---@return boolfunction PlayerContext:removeLvl()    self:remove_unique_component('lvl')end---@return boolfunction PlayerContext:removeGem()    self:remove_unique_component('gem')end---@return boolfunction PlayerContext:removeAnyNameListener()    self:remove_unique_component('anyNameListener')end---@return boolfunction PlayerContext:removeNameListener()    self:remove_unique_component('nameListener')end---@return PlayerEntity---@privatefunction PlayerContext:_create_entity()    return self._entity_class:new()end---@return PlayerEntityfunction PlayerContext:CreateEntity()    return self:create_entity()end---@return PlayerContextfunction PlayerContext.PlayerContext()    return classMap.PlayerContext:new(classMap.PlayerEntity)endfunction PlayerContext:initGenerateEntityIndexes()    local group = self:get_group(Matcher({Player_comps.Uid}))    self._UidvaluePrimaryIndex = PrimaryEntityIndex:new(Player_comps.Uid, group, 'value')    self:add_entity_index(self._UidvaluePrimaryIndex)    local group = self:get_group(Matcher({Player_comps.Name}))    self._NamevalueIndex = EntityIndex:new(Player_comps.Name, group, 'value')    self:add_entity_index(self._NamevalueIndex)end---@return PlayerEntityfunction PlayerContext:GetEntityByUidvalue(value)    return self._UidvaluePrimaryIndex:get_entity(value)end---@return PlayerEntity[]function PlayerContext:GetEntitiesByNamevalue(value)    return self._NamevalueIndex:get_entities(value)endreturn PlayerContext