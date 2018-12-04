local table_insert = table.insert
local string_format = string.format
---@class utils
local utils = {}

function utils.keys(t)
    local keys = {}
    for k, v in pairs(t) do
        table_insert(keys,k)
    end
    return keys
end

function utils.as(obj, method1)
    if obj[method1] then
        return obj
    end
    return nil
end

function utils.connectTable(t1, t2)
    for i, v in pairs(t2) do
        table_insert(t1, v)
    end
    return t1
end

function utils.class(classname, super)
    assert(type(classname) == "string", string_format("class() - invalid class name \"%s\"", tostring(classname)))
    local superType = type(super)
    local cls
    if not super or superType == "table" then
        if super then
            cls = {}
            setmetatable(cls, {__index = super})
            cls.super = super
        else
            cls = {ctor = function() end,__gc = true}
        end

        cls.__cname = classname
        cls.__index = cls

        function cls.new(...)
            local instance = setmetatable({}, cls)
            instance.class = cls
            instance:ctor(...)
            return instance
        end
    else
        error(string.format("class() - create class \"%s\" with invalid super type",classname), 0)
    end
    if classMap then
        classMap[classname] = cls
    end
    return cls
end

function utils.isInstance(a, b)
    if a.__cname == b.__cname then
        return true
    end

    while a and a.super do
        if a.super.__cname == b.__cname then
            return true
        end
        a = a.super
    end

    return false
end

return utils