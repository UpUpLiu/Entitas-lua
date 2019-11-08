local EntityIndex = require("Common.entitas.EntityIndex")local PrimaryEntityIndex = require("Common.entitas.PrimaryEntityIndex")local Matcher = require("Common.entitas.Matcher")local Prop_comps = require('.PropComponents')---@class PropContext : entitas.Context---@field createEntity fun():PropEntitylocal PropContext = {}---@return boolfunction PropContext:removeDestroy()    self:remove_unique_component('destroy')end---@return boolfunction PropContext:removeConfig()    self:remove_unique_component('config')end---@return boolfunction PropContext:removeType_id()    self:remove_unique_component('type_id')end---@return boolfunction PropContext:removeItemInfo()    self:remove_unique_component('itemInfo')end---@return boolfunction PropContext:removeNum()    self:remove_unique_component('num')end---@return PropEntity---@privatefunction PropContext:_create_entity()    return self._entity_class:new()end---@return PropEntityfunction PropContext:CreateEntity()    return self:create_entity()end---@return PropContextfunction PropContext.PropContext()    return classMap.PropContext:new(classMap.PropEntity)endfunction PropContext:initGenerateEntityIndexes()endreturn PropContext