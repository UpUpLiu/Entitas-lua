--local fs = require("fs")

local loaded = package.loaded
local searchpath = package.searchpath

local tableinsert = table.insert
local oldrequire = require

local function split(input, delimiter)
    input = tostring(input)
    delimiter = tostring(delimiter)
    if (delimiter=='') then return false end
    local pos,arr = 0, {}
    -- for each divider found
    for st,sp in function() return string.find(input, delimiter, pos, true) end do
        tableinsert(arr, string.sub(input, pos, st - 1))
        pos = sp + 1
    end
    tableinsert(arr, string.sub(input, pos))
    return arr
end

function import(moduleName, currentModuleName)
    local currentModuleNameParts
    local moduleFullName = moduleName
    local offset = 1

    while true do
        if string.byte(moduleName, offset) ~= 46 then -- .
            moduleFullName = string.sub(moduleName, offset)
            if currentModuleNameParts and #currentModuleNameParts > 0 then
                moduleFullName = table.concat(currentModuleNameParts, ".") .. "." .. moduleFullName
            end
            break
        end
        offset = offset + 1

        if not currentModuleNameParts then
            if not currentModuleName then
                local n,v = debug.getlocal(3, 1)
                currentModuleName = v
            end

            currentModuleNameParts = split(currentModuleName, ".")
        end
        table.remove(currentModuleNameParts, #currentModuleNameParts)
    end
    return oldrequire(moduleFullName)
end
require = import
--local function import( name )
--    local info = debug.getinfo(2, "S")
--    local prefix = string.sub(info.source, 2, -1)
--    prefix = fs.parent_path(prefix)
--    prefix = fs.relative_work_path(prefix)
--    local fullname = string.gsub( prefix.."/"..name,"[/\\]","." )
--    local pos = 1
--    while true do
--        if fullname:byte(pos) ~= string.byte(".") then
--            if pos > 1 then
--                fullname = fullname:sub(pos)
--            end
--            break
--        end
--        pos = pos + 1
--    end
--    local m = loaded[fullname] or loaded[name]
--    if m then
--        return m
--    end
--    if searchpath(fullname, package.path) then
--        return require(fullname)
--    else
--        return require(name)
--    end
--end

return import
