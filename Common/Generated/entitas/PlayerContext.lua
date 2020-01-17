local EntityIndex = require("Common.entitas.EntityIndex")local PrimaryEntityIndex = require("Common.entitas.PrimaryEntityIndex")local Matcher = require("Common.entitas.Matcher")local Player_comps = require('.PlayerComponents')---@class PlayerContext : entitas.Context---@field expEntity PlayerEntity---@field exp Player.ExpComponent---@field gemEntity PlayerEntity---@field gem Player.GemComponent---@field createEntity fun():PlayerEntitylocal PlayerContext = {}function PlayerContext:Ctor(...)    self.__base.Ctor(self, ...)end---@return Context---@parm value booleanfunction PlayerContext:setDestroy(value)    if (value ~= self:hasDestroy()) then        if (value) then            self:set_unique_component('destroy',Player_comps.Destroy, true)        else            self:remove_unique_component('destroy')        end    end    return selfend---@return boolfunction PlayerContext:hasDestroy()    return self:has_unique_component(Player_comps.Destroy)end---@return boolfunction PlayerContext:removeDestroy()    self:remove_unique_component('destroy')end---@return Context---@parm value booleanfunction PlayerContext:setElement(value)    if (value ~= self:hasElement()) then        if (value) then            self:set_unique_component('element',Player_comps.Element, true)        else            self:remove_unique_component('element')        end    end    return selfend---@return boolfunction PlayerContext:hasElement()    return self:has_unique_component(Player_comps.Element)end---@return boolfunction PlayerContext:removeElement()    self:remove_unique_component('element')end---@return PlayerEntity---@privatefunction PlayerContext:_create_entity()    return self._entity_class:new()end---@return PlayerEntityfunction PlayerContext:CreateEntity()    return self:create_entity()end---@return PlayerContextfunction PlayerContext.PlayerContext()    return classMap.PlayerContext:new(classMap.PlayerEntity)endreturn PlayerContext