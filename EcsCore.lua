---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Administrator.
--- DateTime: 2018-11-26 3:03
---
local Entitas = {}

GroupEventType  = {
    OnEntityAdded = 1,
    OnEntityRemoved = 2,
    OnEntityAddedOrRemoved = 3
}

local Utils = {}

function Utils.Keys(t)
    local keys = {}
    for k, v in pairs(t) do
        table.insert(keys,k)
    end
    return keys
end

function Utils.as(obj, method1)
    if obj[method1] then
        return obj
    end
    return nil
end

function Utils.ConnectTable(t1, t2)
    for i, v in pairs(t2) do
        t1[i] = v
    end
    return t1
end



local ClassDefineMt = {}
function ClassDefineMt.__index( tbl, key )
    local tBaseClass = tbl.__tbl_Baseclass__
    for i = 1, #tBaseClass do
        local xValue = rawget(tBaseClass[i],key)
        if xValue then
            rawset( tbl, key, xValue )
            return xValue
        end
    end
end


function Utils.class( tDerived, ... )
    local arg = {...}
    --local tDerived = tDerived
    --tDerived.__className = className
    -- 这里是把所有的基类放到 tDerived.__tbl_Bseclass__ 里面
    tDerived.__tbl_Baseclass__ =  {}
    tDerived.__base = arg[1]
    for index = 1, #arg do
        local tBaseClass = arg[index]
        table.insert(tDerived.__tbl_Baseclass__, tBaseClass)
        for i = 1, #tBaseClass.__tbl_Baseclass__ do
            table.insert(tDerived.__tbl_Baseclass__, tBaseClass.__tbl_Baseclass__[i])
        end
        --for key, value in pairs(tBaseClass.__cname) do
        --    tDerived.__cname[tostring(key)] = value
        --end
    end

    -- 所有对实例对象的访问都会访问转到tDerived上
    local InstanceMt =  { __index = tDerived }

    --构造函数参数的传递，只支持一层, 出于动态语言的特性以及性能的考虑
    tDerived.new = function( self, ... )
        local NewInstance = {}
        NewInstance.__ClassDefine__ = self    -- IsType 函数的支持由此来

        NewInstance.IsClass = function( self, classtype )
            return self.__ClassDefine__:IsClass(classtype)
        end

        -- 这里要放到调用构造函数之前，因为构造函数里面，可能调用基类的成员函数或者成员变量
        setmetatable( NewInstance, InstanceMt )
        NewInstance.__index = tDerived
        local funcCtor = rawget(self, "Ctor")
        if funcCtor then
            funcCtor(NewInstance, ...)
        end
        return NewInstance
    end

    setmetatable( tDerived, ClassDefineMt )
    return tDerived
end


function Utils.split( str,reps )
    local resultStrList = {}
    string.gsub(str,'[^'..reps..']+',function ( w )
        table.insert(resultStrList,w)
    end)
    return resultStrList
end



local UUID = {}
local id = 0

function UUID.randomUUID()
    id = id + 1
    return id
end


---@class Bag
local Bag = Utils.class({})

function Bag:Ctor(capacity)
    self.size_ = 0
    self.length = capacity
end


function Bag:removeAt(index)
    local e = self[index];
    self[index] = self[self.size_]
    self[self.size_] = nil
    self.size_ = self.size_ - 1
    return e
end


function Bag:remove(e)
    local i
    local e2
    local size = self.size_

    for i = 1, size do
        e2 = self[i]
        if (e == e2) then
            self[i] = self[self.size_]
            self[self.size_] = nil
            self.size_ = self.size_ - 1
            return true
        end
    end



    return false
end



function Bag:removeLast()
    if (self.size_ > 0) then
        local e = self[self.size_]
        self[self.size_] = nil
        self.size_ = self.size_ - 1
        return e
    end
    return nil
end

function Bag:contains(e)
    for i = 1, self.size_ do
        if (e == self[i]) then
            return true

        end
        return false

    end
end


function Bag:removeAll(bag)
    local modified= false
    local l = bag:size()
    local e1
    local e2

    for i = 1, l do
        e1 = bag:get(i)

        for j = 1, self.size_ do
            e2 = self[j]

            if (e1 == e2) then
                self:removeAt(j)
                j = j - 1
                modified = true
                break

            end

        end

    end

    return modified
end


function Bag:get(index)
    if (index >= self.length) then
        error('ArrayIndexOutOfBoundsException')
    end
    return self[index]

end

function Bag:safeGet(index)
    if (index >= self.length) then
        self:grow((index * 7) / 4 + 1)
    end
    return self[index]

end

function Bag:size()
    return self.size_

end

function Bag:getCapacity()
    return self.length
end



function Bag:isEmpty()
    return self.size_ == 0

end


function Bag:add(e)
    -- is size greater than capacity increase capacity
    if (self.size_ == self.length) then
        self:grow()
    end
    self.size_ = self.size_ + 1
    self[self.size_] = e
end


function Bag:set(index, e)
    if (index >= self.length) then
        self:grow(index * 2)
    end
    self.size_ = index + 1
    self[index] = e

end

function Bag:grow(newCapacity)
    newCapacity = newCapacity or ~~((self.length * 3) / 2) + 1
    self.length = ~~newCapacity
end

function Bag:ensureCapacity(index)
    if (index >= self.length) then
        self:grow(index * 2)

    end

end

function Bag:clear()
    local i
    local size
    -- nil all elements so gc can clean up
    for i = 1, self.size_ do
        self[i] = nil
    end

    self.size_ = 0

end


function Bag:addAll(items)
    local i
    local len = items:size()
    for i = 1, len do
        self:add(items:get(i))
    end
end


---@class Signal
local Signal = Utils.class({})
function Signal:Ctor(context, alloc)
    alloc = alloc or 16
    self._listeners = Bag:new()
    self._context = context
    self._alloc = alloc
    self.active = false
end


function Signal:dispatch(...)
    local listeners = self._listeners
    local size = listeners:size()
    if (size <= 0) then
        return
    end
    for i = 1, size do
        listeners[i](...)
    end

end

---@param listener function
function Signal:add(listener)
    self._listeners:add(listener)
    self.active = true

end

---@param listener function
function Signal:remove(listener)
    local listeners = self._listeners
    listeners:remove(listener)
    self.active = listeners:size() > 0
end

--------
-- Clear and reset to original alloc
------
function Signal:clear()
    self._listeners:clear()
    self.active = false
end


---@class _Entity
---@field onEntityReleased  Signal
---@field onComponentAdded Signal
---@field onComponentRemoved Signal
---@field onComponentReplaced Signal
local Entity = Utils.class({
    instanceIndex = 0;
    alloc = {},
    size = 0,
    instanceIndex = 0,
    componentsEnum = {},
    totalComponents = 0,
    __property = nil,
    __getproperty = nil,
    __setproperty = nil
})

function Entity.Init(property, getproperty, setproperty)
    Entity.__property = property
    Entity.__getproperty = getproperty
    Entity.__setproperty = setproperty
end

---@return _Entity
function Entity:new(...)
    local __getproperty = Entity.__getproperty
    local __setproperty = Entity.__setproperty
    local property = setmetatable({}, {__index = Entity.__property})
    local mt = {
        __index = Entity
    }
    local Ins = setmetatable({}, mt)
    Ins:Ctor(...)
    local ids = Ins._componentsEnum
    if Entity.__property then
        mt.__index = function(t,k)
            local val =  rawget(t, k)
            if val then
                return val
            end

            if __getproperty[k] then
                local ret = __getproperty[k]
                if ret then
                    return ret(Ins)
                end
            end
            --print("get not prop", k, v )
            return Entity[k]
        end

        mt.__newindex = function(t,k,v)
            local setfun =__setproperty[k]
            if setfun then
                --print("set prop", k, v )
                setfun(Ins,v)
            else
                --print("set not prop", k, v )
                rawset(Ins, k,v)
            end
        end
    end

    return Ins
end

function Entity:CreationIndex()
    return self._creationIndex;
end

function Entity:Ctor(componentsEnum, totalComponents)
    self.id = ""
    self.name = ""
    self._toStringCache = ""

    self.onEntityReleased = Signal:new()
    self.onComponentAdded = Signal:new()
    self.onComponentRemoved = Signal:new()
    self.onComponentReplaced = Signal:new()

    totalComponents = totalComponents or 16
    self._componentsEnum = componentsEnum
    self._components =  self:initialize(totalComponents)
    self._creationIndex = 0
    self._refCount = 0
    self._isEnabled = true
    self._pool = Entitas.Pool.instance
    self.__prop = {}
end

function Entity:initialize(totalComponents)
    local mem
    local size = Entity.size
    if Entity.alloc == nil then
        Entity.Dim(totalComponents, size)
    end
    local alloc = Entity.alloc
    self.instanceIndex = Entity.instanceIndex
    Entity.instanceIndex = Entity.instanceIndex + 1
    mem = alloc[self.instanceIndex]
    if mem then
        return mem
    end
    -- print('Insufficient memory allocation at ', self.instanceIndex, '. Allocating ', size, ' entities.')
    local len = self.instanceIndex + size
    for  i=self.instanceIndex, len do
        alloc[i] = {}
        for  k=0, totalComponents do
            alloc[i][k] = nil
        end
    end
    mem = alloc[self.instanceIndex]
    return mem
end

function Entity:addComponent(index, component, key)
    if not self._isEnabled then
        error("Cannot add component!")
    end
    if self:hasComponent(index) then
        error( "Cannot add component at index " .. tostring(index) .. " to " .. tostring(self) )
    end
    self._components[index] = component
    self[key] = component
    self._componentsCache = {}
    self._componentIndicesCache = {}
    self._toStringCache = {}
    local onAdd = self.onComponentAdded
    if onAdd.active then
        onAdd:dispatch(self, index, component)
    end
    return self
end

function Entity:removeComponent(index)
    if not self._isEnabled then
        error("Cannot remove component!")
    end
    if not self:hasComponent(index) then
        error( "Cannot remove component at index " .. tostring(index) .. " to " .. tostring(self) )
    end
    self:_replaceComponent(index, nil)
    return self
end

function Entity:replaceComponent(index, component, key)
    if not self._isEnabled then
        error("Cannot replace component!")
    end

    if self:hasComponent(index) then
        self:_replaceComponent(index, component)
    elseif component ~= nil then
        self:addComponent(index, component, key)
    end
    return self
end

function Entity:_replaceComponent(index, replacement)
    local components = self._components
    local previousComponent = components[index]
    if (previousComponent == replacement) then
        local onComponentReplaced = self.onComponentReplaced
        if onComponentReplaced.active then
            onComponentReplaced:dispatch(self, index, previousComponent, replacement)
        end
    else
        components[index] = replacement
        self._componentsCache = nil
        if (replacement == nil) then
            components[index] = nil
            self._componentIndicesCache = nil
            self._toStringCache = nil
            local onComponentRemoved = self.onComponentRemoved
            if onComponentRemoved.active then
                onComponentRemoved:dispatch(self, index, previousComponent, replacement)
            end
        else
            local onComponentReplaced = self.onComponentReplaced
            if onComponentReplaced.active then
                onComponentReplaced:dispatch(self, index, previousComponent, replacement)
            end
        end
    end
end

function Entity:getComponent(index)
    if not self.hasComponent(index) then
        error("Cannot get component at index " .. tostring(index ) .. " from " .. tostring(self))
    end
    return self._components[index]
end

function Entity:getComponents()
    if self._componentsCache == nil then
        local components = {}
        local _components = self._components
        local j = 0
        for i = 0, #_components do
            local component = _components[i]
            if component then
                component[j] = component
                j = j + 1
            end
        end
        self._componentsCache = components
    end
    return self._componentsCache
end

function Entity:getComponentIndices()
    if self._componentsCache == nil then
        local indices = {}
        local _components = this._components
        local j = 0
        for i = 0, #_components do
            local component = _components[i]
            if component then
                indices[j] = i
                j = j + 1
            end
        end
        self._componentIndicesCache  = indices
    end
    return self._componentIndicesCache
end

function Entity:hasComponent(index)
    return self._components[index] ~= nil
end

function Entity:hasComponents(indices)
    local _components = self._components
    local indicesLength = #indices
    for i = 1,  indicesLength do
        if(_components[indices[i]] == nil) then
            return false
        end
    end
    return true
end

function Entity:hasAnyComponent(indices)
    local _components = self._components
    local indicesLength = #indices
    for i = 1,  indicesLength do
        if(_components[indices[i]]) then
            return true
        end
    end
    return false
end

function Entity:removeAllComponents()
    self._toStringCache = nil
    local _components = self._components
    for k, v in pairs(_components) do
        self:_replaceComponent(k, nil)
    end
end

function Entity:destroy()
    self:removeAllComponents()
    self.onComponentAdded:clear()
    self.onComponentRemoved:clear()
    self.onComponentReplaced:clear()
    self._isEnabled = false
end

function Entity:tostring()

end

function Entity:addRef()
    self._refCount = self._refCount + 1
    return self
end

function Entity:release()
    self._refCount = self._refCount - 1
    if self._refCount == 0 then
        local onEntityReleased = self.onEntityReleased
        if onEntityReleased.active then
            onEntityReleased:dispatch(self)
        end
        self.onEntityReleased:clear()
    elseif self._refCount < 0 then
        error("Entity is Released")
    end
end


function Entity.Dim(count , size)
    Entity.alloc = {}
    for j = 1, size do
        Entity.alloc[j] = {}
        for i = 1, count do
            Entity.alloc[e][k] = nil
        end
    end
end


---@class GroupObserver
local GroupObserver = Utils.class({
})

function GroupObserver:Ctor(groups, eventTypes)
    if type(groups) == "table" and #groups >= 1 then
        self._groups = groups
    else
        self._groups = {groups}
    end

    if type(eventTypes) == "table" then
        self._eventTypes = eventTypes
    else
        self._eventTypes = {eventTypes}
    end
    if #self._groups ~= #self._eventTypes then
        --error("Unbalanced count with groups (" .. tostring(#self._groups ) ..
        --        ") and event types (" .. tostring(#self._eventTypes ).. ")")
        error("Unbalanced count with groups and event types ")
    end
    self._collectedEntities = {}
    self._addEntityCache = function(...) self:addEntity(...) end
    self:activate()
end

function GroupObserver:activate()

    local len = #self._groups
    for i = 1, len do
        local group = self._groups[i]
        local eventType = self._eventTypes[i]

        if (eventType == GroupEventType.OnEntityAdded) then
            group.onEntityAdded:remove(self._addEntityCache)
            group.onEntityAdded:add(self._addEntityCache)
        elseif (eventType == GroupEventType.OnEntityRemoved) then
            group.onEntityRemoved:remove(self._addEntityCache)
            group.onEntityRemoved:add(self._addEntityCache)
        elseif (eventType == GroupEventType.OnEntityAddedOrRemoved) then
            group.onEntityAdded:remove(self._addEntityCache)
            group.onEntityAdded:add(self._addEntityCache)
            group.onEntityRemoved:remove(self._addEntityCache)
            group.onEntityRemoved:add(self._addEntityCache)
        else
            --throw `Invalid eventType [${typeof eventType}:${eventType}] in GroupObserver::activate`
        end
    end
end

function GroupObserver:deactivate()
    local len = #self._groups
    for i = 0, len do
        local group = self._groups[i]
        group.onEntityAdded.remove(self._addEntityCache)
        group.onEntityRemoved.remove(self._addEntityCache)
        self.clearCollectedEntities()
    end
end

function GroupObserver:clearCollectedEntities()
    for i, v in pairs(self._collectedEntities) do
        v:release()
    end
    self._collectedEntities = {}
end

function GroupObserver:addEntity(group, entity, index, component)
    if not self._collectedEntities[entity.id] then
        self._collectedEntities[entity.id] = entity
        entity:addRef()
    end
end

function GroupObserver:collectedEntities()
    return self._collectedEntities
end


---@class Group
---@field onEntityAdded Signal
---@field onEntityRemoved Signal
---@field onEntityUpdated Signal
local Group = Utils.class({
    _entitiesCache = nil,
    _SignalEntityCache = nil,
    _toStringCache = '',
})

function Group:Ctor(matcher)
    self.onEntityAdded = Signal:new()
    self.onEntityRemoved = Signal:new()
    self.onEntityUpdated = Signal:new()
    self._entities = {}
    self._matcher = matcher
end

function Group:createObserver(eventType)
    eventType = eventType or GroupEventType.OnEntityAdded
    return GroupObserver:new(self, eventType)
end

function Group:handleEntitySilently(entity)
    if (self._matcher:matches(entity)) then
        self:addEntitySilently(entity)
    else
        self:removeEntitySilently(entity)
    end
end

function Group:handleEntity(entity, index, component)
    if (self._matcher:matches(entity)) then
        self:addEntity(entity, index, component)
    else
        self:removeEntity(entity, index, component)
    end
end

function Group:updateEntity(entity, index, previousComponent, newComponent)
    if (self._entities[entity.id ]) then

        local onEntityRemoved= self.onEntityRemoved
        if (onEntityRemoved.active) then
            onEntityRemoved:dispatch(self, entity, index, previousComponent)
        end
        local onEntityAdded= self.onEntityAdded
        if (onEntityAdded.active) then
            onEntityAdded:dispatch(self, entity, index, newComponent)
        end
        local onEntityUpdated= self.onEntityUpdated
        if (onEntityUpdated.active) then
            onEntityUpdated:dispatch(self, entity, index, previousComponent, newComponent)
        end
    end
end

function Group:addEntitySilently(entity)
    if not self._entities[entity.id ] then
        self._entities[entity.id] = entity
        self._entitiesCache = nil
        self._SignalEntityCache = nil
        entity:addRef()
    end
end

function Group: addEntity(entity, index, component)
    if not self._entities[entity.id ] then
        self._entities[entity.id] = entity
        self._entitiesCache = nil
        self._SignalEntityCache = nil
        entity:addRef()
        local onEntityAdded= self.onEntityAdded
        if (onEntityAdded.active)then
            onEntityAdded:dispatch(self, entity, index, component)
        end
    end
end

function Group: removeEntitySilently(entity)
    if self._entities[entity.id ] then
        self._entities[entity.id] = nil
        self._entitiesCache = nil
        self._SignalEntityCache = nil
        entity:release()
    end
end

function Group: removeEntity(entity, index, component)
    if self._entities[entity.id ] then

        self._entities[entity.id] = nil
        self._entitiesCache = nil
        self._SignalEntityCache = nil
        local onEntityRemoved= self.onEntityRemoved
        if (onEntityRemoved.active)then
            onEntityRemoved:dispatch(self, entity, index, component)
        end
        entity:release()
    end
end

function Group: containsEntity(entity)
    return self._entities[entity.id ]
end

---@return Entity[]
function Group:getEntities()
    if (self._entitiesCache == nil) then
        local entities = self._entities
        self._entitiesCache = {}
        local entitiesCache = self._entitiesCache
        local i = 1
        for k, v in pairs(entities) do
            entitiesCache[i] = v
            i = i + 1
        end
    end
    return self._entitiesCache
end

function Group:getSingleEntity()
    if (self._SignalEntityCache == nil) then
        local enumerator = Utils.Keys(self._entities)
        local c = #enumerator
        if (c == 1) then
            self._SignalEntityCache = self._entities[enumerator[1]]
        elseif (c == 0) then
            return nil
        else
            --throw new SignalEntityException(self._matcher)
        end
    end
    return self._SignalEntityCache
end

function Group:toString()
    if (self._toStringCache == nil) then
        self._toStringCache = "Group(" .. tostring(self._matcher) .. ")"
    end
    return self._toStringCache
end


---@class Ecs.ReactiveSystem
---@field _pool Pool
local ReactiveSystem  = Utils.class({
})

function ReactiveSystem:initialize()
    if self._subsystem and self._subsystem.initialize then
        self._subsystem:initialize()
    end
end

function ReactiveSystem:Ctor(pool, subSystem)
    local triggers
    if subSystem['triggers'] then
        triggers =  subSystem['triggers']
    else
        triggers = {subSystem['trigger']}
    end
    self._subsystem = subSystem

    local ensureComponents = Utils.as(subSystem, 'ensureComponents')
    if (ensureComponents ~= nil) then
        self._ensureComponents = ensureComponents.ensureComponents
    end
    local excludeComponents = Utils.as(subSystem, 'excludeComponents')
    if (excludeComponents ~= nil) then
        self._excludeComponents = excludeComponents.excludeComponents
    end

    self._clearAfterExecute = (Utils.as(subSystem, 'clearAfterExecute') ~= nil)

    local triggersLength = #triggers
    ---@type Group[]
    local groups = {}
    local eventTypes = {}
    for i= 1, triggersLength do
        local trigger = triggers[i]
        local matcher ,eventType = trigger()
        groups[i] = pool:getGroup(matcher)
        eventTypes[i] = eventType
    end
    self._observer = GroupObserver:new(groups, eventTypes)
    self._buffer = {}
end

function ReactiveSystem:activate()
    self._observer:activate()
end

function ReactiveSystem:deactivate()
    self._observer:deactivate()
end

function ReactiveSystem:clear()
    self._observer:clearCollectedEntities()
end

function ReactiveSystem:execute()

    local collectedEntities = self._observer:collectedEntities()
    local ensureComponents = self._ensureComponents
    local excludeComponents = self._excludeComponents
    local buffer = self._buffer


    if (#Utils.Keys(collectedEntities) ~= 0) then
        if (ensureComponents) then
            if (excludeComponents) then
                for i, e in pairs(collectedEntities) do
                    if (ensureComponents:matches(e) and not excludeComponents:matches(e)) then
                        table.insert(buffer, e:addRef())
                    end
                end
            else
                for i, e in pairs(collectedEntities) do
                    if (ensureComponents:matches(e)) then
                        table.insert(buffer, e:addRef())
                    end
                end
            end
        elseif (excludeComponents) then
            for i,e in pairs(collectedEntities) do
                if (not excludeComponents:matches(e)) then
                    table.insert(buffer, e:addRef())
                end
            end
        else
            for i,e in pairs(collectedEntities) do
                table.insert(buffer, e:addRef())
            end
        end

        self._observer:clearCollectedEntities()
        if (#buffer > 0) then
            self._subsystem:execute(buffer)
            local len = #buffer
            for i = 1, len do
                buffer[i]:release()
                buffer[i] = nil
            end
            if (self._clearAfterExecute) then
                self._observer:clearCollectedEntities()
            end
        end
    end
end

function ReactiveSystem:getSubsystem()
    return self._subsystem
end






---@class _Pool
---@field _reusableEntities Bag
local Pool = {
    _entities = {},
    _groups = {},
    _debug = false,
    totalComponents = 0,
    name = '',
    __property = nil,
    __getproperty= nil,
    __setproperty = nil,
}
---@private
function Pool.Init(property, getproperty, setproperty)
    Pool.__property = property
    Pool.__getproperty = getproperty
    Pool.__setproperty = setproperty
end

---@private
function Pool:new(...)
    local get = Pool.__getproperty
    local set = Pool.__setproperty
    local property = setmetatable({}, {__index = Pool.__property})
    local mt = {
        __index = Pool
    }
    local Ins = setmetatable({}, mt)
    Ins:Ctor(...)
    local ids = Ins._componentsEnum

    if Pool.__property then

        mt.__index = function(t,k)
            local val =  rawget(t, k)
            if val then
                return val
            end

            if get[k] then
                local ret = get[k]
                if ret then
                    return ret(property)
                end
            end
            --print("get not prop", k, v )
            return Pool[k]
        end

        mt.__newindex = function(t,k,v)
            if ids[k] then
                --print("set prop", k, v )
                set(property,v)
            else
                --print("set not prop", k, v )
                rawset(t, k,v)
            end
        end
    end

    return Ins
end

---@private
function Pool:Ctor(components, totalComponents, debug, startCreationIndex)
    startCreationIndex = startCreationIndex or 0
    Pool.instance = this
    self.onGroupCreated = Signal:new()
    self.onEntityCreated = Signal:new()
    self.onEntityDestroyed = Signal:new()
    self.onEntityWillBeDestroyed = Signal:new()

    self._reusableEntities = Bag:new()
    self._debug = debug
    self._componentsEnum = components
    self._totalComponents = totalComponents
    self._creationIndex = startCreationIndex
    self._groupsForIndex = {}
    self._cachedUpdateGroupsComponentAddedOrRemoved =  function(...) self:updateGroupsComponentAddedOrRemoved(...)  end
    self._cachedUpdateGroupsComponentReplaced = function(...) self:updateGroupsComponentReplaced(...)  end
    self._cachedOnEntityReleased = function(...) self:onEntityReleased(...) end
    Pool.componentsEnum = components
    Pool.totalComponents = totalComponents
end

---@return Entity
function Pool:createEntity(name)
    ---@type _Entity
    local entity
    if self._reusableEntities:size() > 0 then
        entity = self._reusableEntities:removeLast()
        --print("GetEntity From Pool")
    else
        entity = Entity:new(self._componentsEnum, self._totalComponents)
    end
    entity._isEnabled = true
    entity.name = name
    entity._creationIndex = self._creationIndex
    self._creationIndex = self._creationIndex + 1
    entity.id = UUID.randomUUID()
    entity:addRef()
    self._entities[entity.id] = entity
    self._entitiesCache = nil
    entity.onComponentAdded:add(self._cachedUpdateGroupsComponentAddedOrRemoved)
    entity.onComponentRemoved:add(self._cachedUpdateGroupsComponentAddedOrRemoved)
    entity.onComponentReplaced:add(self._cachedUpdateGroupsComponentReplaced)
    entity.onEntityReleased:add(self._cachedOnEntityReleased)

    local onEntityCreated = self.onEntityCreated
    if (onEntityCreated.active) then
        onEntityCreated:dispatch(self. entity)
    end
    return entity
end

---@param entity Entity
function Pool:destroyEntity(entity)
    if (not(self._entities[entity.id])) then
        error("Could not destroy entity~")
    end
    self._entities[entity.id] = nil
    self._entitiesCache = nil
    local onEntityWillBeDestroyed = self.onEntityWillBeDestroyed
    if (onEntityWillBeDestroyed.active) then
        onEntityWillBeDestroyed:dispatch(self. entity)
    end
    entity:destroy()
    --print(entity._refCount, " !!!!!!!!!!!!!!!!!!!")
    local onEntityDestroyed = self.onEntityDestroyed
    if (onEntityDestroyed.active) then
        onEntityDestroyed:dispatch(self. entity)
    end

    if (entity._refCount == 1) then
        entity.onEntityReleased:remove(self._cachedOnEntityReleased)
        self._reusableEntities:add(entity)
    else
        self._reusableEntities[entity.id] = entity
    end
    entity:release()
end

---@private
function Pool: destroyAllEntities()
    local entities = self.getEntities()
    local len = #entities
    for i= 1, len  do
        self.destroyEntity(entities[i])
    end
end

---@private
function Pool: hasEntity(entity)
    return self._entities[entity.id]
end

---@private
function Pool:getEntities(matcher)
    if (matcher) then
        return self:getGroup(matcher).getEntities()
    else
        if (self._entitiesCache == nil) then
            local entities = self._entities
            local keys = Utils.Keys(entities)
            local length = #keys
            self._entitiesCache = {}
            local entitiesCache = self._entitiesCache
            for i = 1, length do
                entitiesCache[i] = entities[keys[i]]
            end
        end
        return self._entitiesCache
    end
end

---@param system Class
function Pool: createSystem(system)
    if ('function' == type(system)) then
        local Klass = system
        system = Klass:new()
    end

    Pool.setPool(system, self)
    local reactiveSystem = Utils.as(system, 'trigger')
    if (reactiveSystem ~= nil) then
        return ReactiveSystem:new(self, reactiveSystem)
    end
    local multiReactiveSystem = Utils.as(system, 'triggers')
    if (multiReactiveSystem ~= nil) then

        return ReactiveSystem:new(self, multiReactiveSystem)
    end

    return system:new()
end

---@return Group
---@param matcher _Matcher
function Pool:getGroup(matcher)
    local group
    if ( self._groups[matcher.id ]) then
        group = self._groups[matcher.id]
    else
        group = Group:new(matcher)
    end

    local entities = self:getEntities()
    local len = #entities
    for i = 1, len do
        group:handleEntitySilently(entities[i])
    end
    self._groups[matcher.id] = group
    local Indices = matcher:getIndices()
    local inLen = #Indices
    for i = 1 , inLen do
        local index = Indices[i]
        if (self._groupsForIndex[index] == nil) then
            self._groupsForIndex[index] = Bag:new()
        end
        self._groupsForIndex[index]:add(group)
    end

    local onGroupCreated = self.onGroupCreated
    if (onGroupCreated.active) then
        onGroupCreated:dispatch(self. group)
    end

    return group
end

---@private
function Pool:updateGroupsComponentAddedOrRemoved  (entity, index, component)
    local groups = self._groupsForIndex[index]
    if (groups ~= nil) then
        local count = groups:size()
        for i = 1, count do
            groups[i]:handleEntity(entity, index, component)

        end
    end
end

---@private
function Pool:updateGroupsComponentReplaced(entity, index, previousComponent, newComponent)
    local groups = self._groupsForIndex[index]
    if (groups ~= nil) then
        local len = groups:size()
        for i = 1, len do
            groups[i]:updateEntity(entity, index, previousComponent, newComponent)
        end
    end
end

---@private
---@param entity _Entity
function Pool:onEntityReleased(entity)
    if (entity._isEnabled) then
        error("Cannot release entity.")
    end
    entity.onEntityReleased:remove(self._cachedOnEntityReleased)
    self._reusableEntities[entity.id] = nil
    self._reusableEntities:add(entity)
end

---@private
function Pool.setPool(system, pool)
    local poolSystem = Utils.as(system, 'setPool')
    if (poolSystem ~= nil) then
        poolSystem:setPool(pool)
    end
end

---@class _Matcher
local Matcher = Utils.class({
    uniqueId = 0
})

function Matcher.Init(CoreComponentIds)
    setmetatable(Matcher, {
        __index = function(t, k )
            local ret = rawget(Matcher, k)
            if ret then
                return ret
            end

            if CoreComponentIds[k] then
                local v = Matcher.AllOf(Entitas.CoreComponentIds[k])
                rawset(Matcher, k ,v)
                ret = v
            end
            return ret
        end
    })
end

function Matcher:Ctor()
    self.id = Matcher.uniqueId
    self._indices = nil
    Matcher.uniqueId = Matcher.uniqueId + 1
end

---@return _Matcher
---@private
function Matcher:anyOf(...)
    local args = {...}
    if ('number' == type(args[1] ) or 'string' == type(args[1])) then
        self._anyOfIndices = Matcher.distinctIndices(args)
        self._indices = nil
        return self
    else
        return self.anyOf.apply(self. Matcher.mergeIndices(args))
    end
end

---@private
function Matcher:getIndices()
    if (not self._indices) then
        self._indices = self:mergeIndices()
    end
    return self._indices
end

---@private
function Matcher:matches(entity)
    local matchesAllOf = true
    local matchesAnyOf = true
    local matchesNoneOf = true
    if self._allOfIndices ~= nil then
        matchesAllOf = entity:hasComponents(self._allOfIndices)
    end
    if self._anyOfIndices ~= nil then
        matchesAnyOf = entity:hasAnyComponent(self._anyOfIndices)
    end
    if self._noneOfIndices ~= nil then
        matchesNoneOf = not entity.hasAnyComponent(self._noneOfIndices)
    end
    return matchesAllOf and matchesAnyOf and matchesNoneOf
end

---@private
function Matcher:mergeIndices()
    local indicesList = {}
    if (self._allOfIndices ~= nil) then
        indicesList = Utils.ConnectTable(indicesList,self._allOfIndices)
    end
    if (self._anyOfIndices ~= nil) then
        indicesList = Utils.ConnectTable(indicesList, self._anyOfIndices)
    end
    if (self._noneOfIndices ~= nil) then
        indicesList = Utils.ConnectTable(indicesList, self._noneOfIndices)
    end

    return Matcher.distinctIndices(indicesList)
end

---@private
function Matcher:toString()
    if (self._toStringCache == nil) then
        local sb = {}
        if (self._allOfIndices ~= nil) then
            Matcher.appendIndices(sb, "AllOf", self._allOfIndices)
        end
        if (self._anyOfIndices ~= nil) then
            if (self._allOfIndices ~= nil) then
                sb[sb.length] = '.'
            end
            Matcher.appendIndices(sb, "AnyOf", self._anyOfIndices)
        end
        if (self._noneOfIndices ~= nil) then
            Matcher.appendIndices(sb, ".NoneOf", self._noneOfIndices)
        end
        self._toStringCache = sb.join('')
    end
    return self._toStringCache
end

---@private
function Matcher.distinctIndices(indices)
    local indicesSet = {}
    local len =  #indices
    for i=1 ,len  do
        local k = indices[i]
        indicesSet[k]=i
    end
    return Utils.Keys(indicesSet)
end

---@private
function Matcher.MergeIndices(matchers)

    local indices = {}
    local len = #matchers
    for  i = 1, len do
        local matcher = matchers[i]
        local tempindices = matcher:getIndices()
        if (#tempindices~= 1) then
            --throw new MatcherException(matcher)
        end
        indices[i] = tempindices[1]
    end
    return indices

end

---@return _Matcher
function Matcher:noneOf(...)
    local args = {...}
    if ('number' == type(args[1] ) or 'string' == typeof(args[1])) then
        self._noneOfIndices = Matcher.distinctIndices(args)
        self._indices = nil
        return self
    else
        return self:noneOf(table.unpack(Matcher.mergeIndices(args)))
    end
end

---@return _Matcher
function Matcher.AllOf(...)
    local args = {...}

    if ('number' == type(args[1]) or 'string' == type(args[1])) then
        local matcher =  Matcher:new()
        matcher._allOfIndices = Matcher.distinctIndices(args)
        return matcher
    else
        return Matcher.AllOf(table.unpack(Matcher.MergeIndices(args)))
    end

end

---@return _Matcher
function Matcher.AnyOf(...)
    local args = {...}
    if ('number' == type(args[1]) or 'string' == type(args[1])) then
        local matcher = Matcher:new()
        matcher._anyOfIndices = Matcher.distinctIndices(args)
        return matcher
    else
        return Matcher.AnyOf(table.unpack(Matcher.MergeIndices(args)))
    end
end

---@private
function Matcher.appendIndices(sb, prefix, indexArray)
    local SEPERATOR = ", "
    local j = sb.length
    sb[j] = prefix
    j = j + 1
    sb[j] = '('
    j = j + 1
    local lastSeperator = indexArray.length - 1
    local len = #indexArray
    for i = 1, len do
        sb[j] = ''+indexArray[i]
        j = j + 1
        if (i < lastSeperator) then
            sb[j] = SEPERATOR
            j = j + 1
        end
    end
    sb[j] = ')'
    j = j + 1
end

---@return _Matcher, number
function Matcher:onEntityAdded()
    return  self, GroupEventType.OnEntityAdded
end

---@return _Matcher, number
function Matcher:onEntityRemoved()
    return self, GroupEventType.OnEntityRemoved
end
---@return _Matcher, number
function Matcher:onEntityAddedOrRemoved()
    return self, GroupEventType.OnEntityAddedOrRemoved
end



---@class Ecs.Systems
local Systems = Utils.class({

})

function Systems:Ctor()
    self._initializeSystems = {}
    self._executeSystems = {}
end

---@return Ecs.Systems
function Systems:add(system)
    if ('function' ==  type(system)) then
        local Klass = system
        system = Klass:new()
    end

    local reactiveSystem = Utils.as(system, 'subsystem')

    local initializeSystem
    if reactiveSystem ~= nil then
        initializeSystem = Utils.as(reactiveSystem:getSubsystem(), 'initialize')
    else
        initializeSystem = Utils.as(system, 'initialize')
    end

    if (initializeSystem ~= nil) then
        table.insert(self._initializeSystems, initializeSystem)
    end

    local executeSystem = Utils.as(system, 'execute')
    if (executeSystem ~= nil) then
        local _executeSystems = self._executeSystems
        table.insert(_executeSystems,executeSystem )
    end

    return self
end

---@public
function Systems:initialize()
    local len = #self._initializeSystems
    for i = 1, len do
        self._initializeSystems[i]:initialize()
    end
end


function Systems:execute()
    local executeSystems = self._executeSystems
    local len = #executeSystems
    for i = 1, len do
        executeSystems[i]:execute()
    end
end

---@private
function Systems:clearReactiveSystems()
    local len = #self._executeSystems
    for i= 1, len do
        local reactiveSystem = Utils.as(self._executeSystems[i], 'subsystem')
        if (reactiveSystem ~= nil) then
            reactiveSystem:clear()

        end
        local nestedSystems = Utils.as(self._executeSystems[i], 'clearReactiveSystems')
        if (nestedSystems ~= nil) then
            nestedSystems:clearReactiveSystems()
        end
    end
end


Entitas.Utils = Utils
Entitas.UUID = UUID

---@type Signal
Entitas.Signal = Signal

---@type _Entity
Entitas.Entity = Entity

---@type Group
Entitas.Group = Group

---@type GroupObserver
Entitas.GroupObserver = GroupObserver

---@type Bag
Entitas.Bag =Bag

---@type Ecs.ReactiveSystem
Entitas.ReactiveSystem = ReactiveSystem

---@type _Pool
Entitas.Pool = Pool

---@type _Matcher
Entitas.Matcher = Matcher

---@type Ecs.Systems
Entitas.Systems = Systems

Entitas.TriggerOnEvent = TriggerOnEvent

return Entitas