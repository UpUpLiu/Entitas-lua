local EntityIndex = require("Common.entitas.EntityIndex")local PrimaryEntityIndex = require("Common.entitas.PrimaryEntityIndex")local Matcher = require("Common.entitas.Matcher")local Prop_comps = require('.PropComponents')---@class PropContext : entitas.Context---@field createEntity fun():PropEntitylocal PropContext = {}function PropContext:Ctor(...)    self.__base.Ctor(self, ...)end---@return Context---@parm value booleanfunction PropContext:setDestroy(value)    if (value ~= self:hasDestroy()) then        if (value) then            self:set_unique_component('destroy',Prop_comps.Destroy, true)        else            self:remove_unique_component('destroy')        end    end    return selfend---@return boolfunction PropContext:hasDestroy()    return self:has_unique_component(Prop_comps.Destroy)end---@return boolfunction PropContext:removeDestroy()    self:remove_unique_component('destroy')end---@return PropEntity---@privatefunction PropContext:_create_entity()    return self._entity_class:new()end---@return PropEntityfunction PropContext:CreateEntity()    return self:create_entity()end---@return PropContextfunction PropContext.PropContext()    return classMap.PropContext:new(classMap.PropEntity)endreturn PropContext