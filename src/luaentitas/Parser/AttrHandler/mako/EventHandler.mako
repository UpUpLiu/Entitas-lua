<%
    comp = _attr.component.value
    Name = comp.name.Name
    name =  comp.name.name
    attr_name = _attr.name.value
    source = _context.source.value
    Context_name = _context.name.Name
    context_name = _context.name.name
    properties = comp.get_properties()

    gen_Name = _attr.generateCompName.name
    Gen_Name = _attr.generateCompName.Name
%>\

local Matcher = require("${source}.Matcher")
local GroupEvent = require("${source}.GroupEvent")
local ${Context_name}_comps = require('.${context_name}Components')
local ${Context_name}Matcher = require('.${context_name}Matchers')

---@class ${_attr.generateCompName.Name}EventSystem : entitas.ReactiveSystem
local M = class({},'${_attr.generateCompName.Name}EventSystem', classMap.ReactiveSystem)

function M:Ctor(context)
    M.__base.Ctor(self, context)
end

function M:get_trigger()
    return {
        {
            Matcher({${Context_name}_comps.${Name}}),
            ${_attr.eventTypeGroupStr.value}
        }
    }
end

%if _attr.get_event_target_is_self():
function M:filter(entity)
    return entity:has${Name}() and entity:has${_attr.generateCompName.Name}()
end

function M:execute(es)
    es:foreach( function( e  )
        local comp = e.${name}
        local list = entity.${_attr.generateCompName.name}.value:get_bufferkv()
        for k ,v in pairs(list) do
            k(v, e ${comp.get_params_str()} );
        end
    end)
end
%else:
function M:filter(entity)
    return entity:has${Name}()
end

function M:execute(es)
    local buffer = self._listeners:get_entity_buffer()
    es:foreach( function( e  )
        local comp = e.${name}
        for _, entity in pairs(buffer) do
            local list = entity.${name}.value:get_bufferkv()
            for k ,v in pairs(list) do
                k(v, e ${comp.get_params_str()} );
            end
        end
    end)
end
%endif


local ${Context_name}Entity = class.${Context_name}Entity

%if not comp.hasIsSimple():
---@return boolean
function ${Context_name}Entity:has${Gen_Name}()
  return self:has(${Context_name}_comps.${Gen_Name}) ~= nil
end

${comp.get_properties_define()}
---@returns ${Context_name}Entity
function ${Context_name}Entity:add${Gen_Name} (${comp.get_params()})
    self:add(${Context_name}_comps.${Gen_Name}, ${comp.get_params()})
    return self
end

function ${Context_name}Entity:replace${Gen_Name} (${comp.get_params()})
    self:replace(${Context_name}_comps.${Gen_Name}, ${comp.get_params()})
    return self
end

function ${Context_name}Entity:remove${Gen_Name} ()
    self:remove(${Context_name}_comps.${Gen_Name})
    return self
end
    %else:
---@return boolean
function ${Context_name}Entity:has${Gen_Name}()
  return self:has(${Context_name}_comps.${Gen_Name}) ~= nil
end

---@return ${Context_name}Entity
function ${Context_name}Entity:set${Gen_Name}(v)
    if (v ~= self:has${Gen_Name}()) then
        if (v) then
            self:add(${Context_name}_comps.${Gen_Name}, true)
        else
            self:remove(${Context_name}_comps.${Gen_Name})
        end
    end
    return self
end
%endif

function ${Context_name}Entity:


return M
