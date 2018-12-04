local setmetatable = setmetatable
local Signal = require("entitas.Signal")

---@class _Entity
---@field onEntityReleased  Signal
---@field onComponentAdded Signal
---@field onComponentRemoved Signal
---@field onComponentReplaced Signal
local Entity = {
    instanceIndex = 0;
    alloc = {},
    size = 0,
    instanceIndex = 0,
    componentsEnum = {},
    totalComponents = 0,
    __property = nil,
    __getproperty = nil,
    __setproperty = nil
}

Entity.__index = Entity

function Entity.new(...)
    local tb = setmetatable({},Entity)
    tb:ctor(...)
    return tb
end

function Entity:CreationIndex()
    return self.id;
end

function Entity:ctor(componentsEnum, totalComponents)
    self.id = 0
    self.name = ""
    self._toStringCache = ""

    self.onEntityReleased = Signal.new()
    self.onComponentAdded = Signal.new()
    self.onComponentRemoved = Signal.new()
    self.onComponentReplaced = Signal.new()

    totalComponents = totalComponents or 16
    self._componentsEnum = componentsEnum
    self._components =  self:initialize(totalComponents)
    self._refCount = 0
    self._isEnabled = true
    --self._pool = Entitas.Pool.instance
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
        self:_replaceComponent(index, component, key)
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
        self[previousComponent.__prop] = replacement
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
    if not self:hasComponent(index) then
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
        local _components = self._components
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

function Entity:_destroy()
    self._isEnabled = false
    self:removeAllComponents()
    self.onComponentAdded:clear()
    self.onComponentRemoved:clear()
    self.onComponentReplaced:clear()
    --print("我被标记为enable false", self)
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
        --error("Entity is Released")
    end
end


function Entity.Dim(count , size)
    Entity.alloc = {}
    for j = 1, size do
        Entity.alloc[j] = {}
    end
end

return Entity