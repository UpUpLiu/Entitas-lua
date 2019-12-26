local EntityIndex = require("Common.entitas.EntityIndex")local PrimaryEntityIndex = require("Common.entitas.PrimaryEntityIndex")local Matcher = require("Common.entitas.Matcher")local User_comps = require('.UserComponents')---@class UserContext : entitas.Context---@field createEntity fun():UserEntitylocal UserContext = {}function UserContext:Ctor(...)    self.__base.Ctor(self, ...)end---@return boolfunction UserContext:removeDestroy()    self:remove_unique_component('destroy')end---@return boolfunction UserContext:removeDress()    self:remove_unique_component('dress')end---@return boolfunction UserContext:removePlayer()    self:remove_unique_component('player')end---@return boolfunction UserContext:removeProp()    self:remove_unique_component('prop')end---@return boolfunction UserContext:removeStage()    self:remove_unique_component('stage')end---@return boolfunction UserContext:removeTask()    self:remove_unique_component('task')end---@return boolfunction UserContext:removeUid()    self:remove_unique_component('uid')end---@return UserEntity---@privatefunction UserContext:_create_entity()    return self._entity_class:new()end---@return UserEntityfunction UserContext:CreateEntity()    return self:create_entity()end---@return UserContextfunction UserContext.UserContext()    return classMap.UserContext:new(classMap.UserEntity)endfunction UserContext:initGenerateEntityIndexes()    local group = self:get_group(Matcher({User_comps.Uid}))    self._UidvaluePrimaryIndex = PrimaryEntityIndex:new(User_comps.Uid, group, 'value')    self:add_entity_index(self._UidvaluePrimaryIndex)end---@return UserEntityfunction UserContext:GetEntityByUidvalue(value)    return self._UidvaluePrimaryIndex:get_entity(value)endreturn UserContext