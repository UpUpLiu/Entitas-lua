<%
    ContextName=_context.name.Name
    Contextname=_context.name.name
    components = _context.components.value
    _source = _context.source.value
    import json
%>\
local EntityIndex = require("${_source}.EntityIndex")
local PrimaryEntityIndex = require("${_source}.PrimaryEntityIndex")
local Matcher = require("${_source}.Matcher")
local ${ContextName}_comps = require('.${ContextName}Components')

---@class ${ContextName}Context : entitas.Context
%for comp  in components:
<%
    Name = comp.name.Name
    name =  comp.name.name
%>\
    %if comp.hasIsSingle():
        %if not comp.hasIsSimple():
---@field ${name}Entity ${ContextName}Entity
---@field ${name} ${ContextName}.${Name}Component
        %endif
    %endif
%endfor
---@field createEntity fun():${ContextName}Entity
local ${ContextName}Context = {}

function ${ContextName}Context:Ctor(...)
    self.__base.Ctor(self, ...)
end

%for comp in components:
    %if comp.hasIsSimple():
<%
    Name = comp.name.Name
    name =  comp.name.name
    if comp.hasDates():
        properties = comp.dates.value
    else:
        properties = []
%>\

        %if comp.hasIsSingle():
${comp.get_properties_define()}
---@returns ${ContextName}Entity
function ${ContextName}Context:set${Name}(${comp.get_params()})
    if self:has_unique_component(${ContextName}_comps.${Name}) then
        error('${Name}Component already have')
    end
    return self:set_unique_component('${name}', ${ContextName}_comps.${Name}, ${comp.get_params()})
end

${comp.get_properties_define()}
---@returns ${ContextName}Entity
function ${ContextName}Context:replace${Name}(${comp.get_params()})
    local entity = self.${name}Entity
    if entity == nil then
        self:set${Name}(${comp.get_params()})
    else
        self.${name} = entity:replace(${ContextName}_comps.${Name}, ${comp.get_params()})
    end
    return entity
end

        %else:
---@return Context
---@parm value boolean
function ${ContextName}Context:set${Name}(value)
    if (value ~= self:has${Name}()) then
        if (value) then
            self:set_unique_component('${name}',${ContextName}_comps.${Name}, true)
        else
            self:remove_unique_component('${name}')
        end
    end
    return self
end
---@return bool
function ${ContextName}Context:has${Name}()
    return self:has_unique_component(${ContextName}_comps.${Name})
end
        %endif
---@return bool
function ${ContextName}Context:remove${Name}()
    self:remove_unique_component('${name}')
end
    %endif
%endfor

---@return ${ContextName}Entity
---@private
function ${ContextName}Context:_create_entity()
    return self._entity_class:new()
end

---@return ${ContextName}Entity
function ${ContextName}Context:CreateEntity()
    return self:create_entity()
end

---@return ${ContextName}Context
function ${ContextName}Context.${ContextName}Context()
    return classMap.${ContextName}Context:new(classMap.${ContextName}Entity)
end





return ${ContextName}Context
