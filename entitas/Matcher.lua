local table_insert = table.insert
local table_sort = table.sort
local tostring = tostring
local utils = require("entitas.util")
local GroupEventType = require("entitas.GroupEventType")
local table_unpack = table.unpack

---@class _Matcher
local Matcher = {
    uniqueId = 0,
    __eq = function()
    end
}
Matcher.__index = Matcher

function Matcher.new(...)
    local tb = setmetatable({}, Matcher)
    tb:ctor(...)
    return tb
end

function Matcher._getSortKey(prefix,components)
    if not components then
        return ""
    end
    local str = ""
    local temp = {}
    for i, v in pairs(components) do
        table_insert(temp, v)
    end
    table_sort(temp)

    for i, v in ipairs(temp) do
        str = str .. tostring(v)
    end
    return prefix..str
end

function Matcher.Init(MaxComponent)
    Matcher.__CoreComponentIds = MaxComponent
end

function Matcher:ctor()
    self.id = Matcher.uniqueId
    self._indices = nil
    Matcher.uniqueId = Matcher.uniqueId + 1
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
        matchesNoneOf = not entity:hasAnyComponent(self._noneOfIndices)
    end
    return matchesAllOf and matchesAnyOf and matchesNoneOf
end

---@private
function Matcher:mergeIndices()
    local indicesList = {}
    if (self._allOfIndices ~= nil) then
        indicesList = utils.connectTable(indicesList,self._allOfIndices)
    end
    if (self._anyOfIndices ~= nil) then
        indicesList = utils.connectTable(indicesList, self._anyOfIndices)
    end
    if (self._noneOfIndices ~= nil) then
        indicesList = utils.connectTable(indicesList, self._noneOfIndices)
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
                table_insert(sb, '.')
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

function Matcher:getUniqueKey()
    if (self.uniqueKey == nil) then
        local allstr = ""
        if self._allOfIndices ~= nil then
            allstr = Matcher._getSortKey("al", self._allOfIndices )
        end

        local anystr = ""
        if self._anyOfIndices ~= nil then
            anystr = Matcher._getSortKey("an", self._anyOfIndices )
        end
        local noneof = ""
        if self._noneOfIndices ~= nil then
            noneof = Matcher._getSortKey("n", self._noneOfIndices )
        end
        self.uniqueKey = allstr .. anystr..noneof
    end
    return self.uniqueKey
end



---@private
function Matcher.distinctIndices(indices)
    local indicesSet = {}
    local len =  #indices
    for i=1 ,len  do
        local k = indices[i]
        indicesSet[k]=i
    end
    return utils.keys(indicesSet)
end

---@private
function Matcher.MergeIndices(matchers)
    local indices = {}
    local len = #matchers
    for  i = 1, len do
        local matcher = matchers[i]
        local tempindices = matcher:getIndices()
        if (#tempindices~= 1) then
            error("matcher.indices.length must be 1 but was" .. #tempindices)
        end
        indices[i] = tempindices[1]
    end
    return indices
end

---@return _Matcher
---@private
function Matcher:anyOf(...)
    local args = {...}
    if ('number' == type(args[1] ) or 'string' == type(args[1])) then
        local matcher =  Matcher.new()
        matcher._anyOfIndices = Matcher.distinctIndices(args)
        matcher._noneOfIndices = self._noneOfIndices
        matcher._allOfIndices = self._allOfIndices
        return matcher
    else
        return self:anyOf(table_unpack(Matcher.MergeIndices(args)))
    end
end

---@return _Matcher
function Matcher:noneOf(...)
    local args = {...}
    if ('number' == type(args[1] ) or 'string' == type(args[1])) then
        local matcher =  Matcher.new()
        matcher._noneOfIndices = Matcher.distinctIndices(args)
        matcher._anyOfIndices = self._anyOfIndices
        matcher._allOfIndices = self._allOfIndices
        return matcher
    else
        return self:noneOf(table_unpack(Matcher.MergeIndices(args)))
    end
end

---@return _Matcher
function Matcher.AllOf(...)
    local args = {...}
    if ('number' == type(args[1]) or 'string' == type(args[1])) then
        local matcher =  Matcher.new()
        matcher._allOfIndices = Matcher.distinctIndices(args)
        return matcher
    else
        return Matcher.AllOf(table_unpack(Matcher.MergeIndices(args)))
    end

end

---@return _Matcher
function Matcher.AnyOf(...)
    local args = {...}
    if ('number' == type(args[1]) or 'string' == type(args[1])) then
        local matcher = Matcher.new()
        matcher._anyOfIndices = Matcher.distinctIndices(args)
        return matcher
    else
        return Matcher.AnyOf(table_unpack(Matcher.MergeIndices(args)))
    end
end

---@private
function Matcher.appendIndices(sb, prefix, indexArray)
    local SEPERATOR = ", "
    local j = #sb

    sb[j] = prefix
    j = j + 1
    sb[j] = '('
    j = j + 1
    local lastSeperator = #indexArray - 1
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

return Matcher