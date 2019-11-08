--[[
lua class
特性：
支持继承及多重继承 (去除多重继承实现)
支持类型检测
支持构造函数
符合面向对象的的编程思维模式
继承关系复杂不再影响性能，但是失去了reload
]]
local __classMap = {}
local classFile
if CS then
    require("AppLuaConfig")
    if AppLuaConfig.isEditor then
        classFile = io.open (___LuaPath .. "../luaexe/classMap.lua",'w')
        classFile:write('---@class classMap\n')
    end
end

local mt = {
    __newindex = function(t, k, v)
        local val = rawget(__classMap, k)
        if val then
            print("Class Name must Unique, Please Check, Class Name: " .. k)
        end
        if CS and  AppLuaConfig.isEditor then
            classFile:write(string.format( '---@field %s %s\n', k , k))
        end
        rawset(__classMap, k, v)
        v.__className = k
    end,
    __index = __classMap
}

---@type classMap
classMap = {}
setmetatable(classMap, mt)

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
---@generic T : LuaBase
---@return T
function class( tDerived,className, ... )
    assert(type(tDerived) == 'table')
    assert(type(className) == "string", "类型名字不是String")
    --if __is_reload and classMap[className] then
    --    return  classMap[className]
    --end
    local arg = {...}
    tDerived.__cname = className
    -- 这里是把所有的基类放到 tDerived.__tbl_Bseclass__ 里面
    tDerived.__tbl_Baseclass__ =  {}
    tDerived.__super = arg[1]
    classMap[className] = tDerived
    --print(className, classMap[className], tDerived)

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
        else
            local baseClassList = tDerived.__tbl_Baseclass__
            for i, v in ipairs(baseClassList) do
                funcCtor = rawget(v, "Ctor")
                if funcCtor then
                    funcCtor(NewInstance, ...)
                    break
                end
            end
        end
        return NewInstance
    end

    setmetatable( tDerived, ClassDefineMt )
    return tDerived
end


local bTestClass = false

if bTestClass then

    -- test case
    --baseclass = class({})
    --
    --function baseclass:Ctor(a,b,c)
    --    print( "in baseclass Ctor : ", a, b, c)
    --
    --    self.m_test = "baseclass member m_test"
    --end
    --function baseclass:print()
    --    print "baseclass function print"
    --end
    --
    --function baseclass:basseprint()
    --		print "basseprint"
    --end
    --
    ----aaa = baseclass:new()
    --
    --dclass = class({},baseclass)
    --function dclass:Ctor(a,b,c)
    --		baseclass.Ctor(self, a,b,c)
    --    print( "in dclass Ctor : ", a, b, c,d)
    --
    --
    --    self:print()
    --end
    --
    --function dclass:print()
    --    print "dclass function print"
    --end
    --
    --
    -----obj = dclass:new(1,2,3)
    --
    --bclass2 = class({})
    --
    --function bclass2:Ctor()
    --    print "bclass2:Ctor()"
    --end
    --
    --function bclass2:print()
    --    print "bclass2 function print"
    --end
    --
    --dclass2 = class({},bclass2,dclass)
    --
    --function dclass2:Ctor()
    --	bclass2.Ctor(self)
    --  dclass.Ctor(self)
    --end
    --
    ----[[function dclass2:Ctor()
    --    print "dclass2:Ctor"
    --
    --    self:print()
    --end]]
    --
    --ooo = dclass2:new()
    ----ccc = class()
    --ddd = bclass2:new()
    --eee = dclass:new()
    --
    ----print("ooo is  dclass2", ooo:IsClass(dclass2))
    ----print("ooo is bclass2", ooo:IsClass(bclass2))
    ----print("ooo is dclass", ooo:IsClass(dclass))
    ----print("ooo is baseclass", ooo:IsClass(baseclass))
    ----print("ooo is ccc", ooo:IsClass(ccc))
    ----print("ddd is baseclass", ddd:IsClass(baseclass))
    ----print("eee is dclass2", eee:IsClass(dclass2))
    --
    --print("cp test begine1")
    --ooo:basseprint()
    --print("cp test end1")
    --
    --print("cp test begine2")
    --ooo:basseprint()
    --print("cp test end2")

end

return classMap