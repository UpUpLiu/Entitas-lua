<%
    Context_name = _context.name.Name
    context_name =_context.name.name
    components = _context.components.value
%>\
local ${Context_name}_comps = require('.${context_name}Components')
local set = require('Common.container.set')

---@class ${Context_name}Entity
% for comp in components:
<%
    Name = comp.name.Name
    name =  comp.name.name
    properties = comp.get_properties()
%>\
        %if not comp.hasIsSimple():
---@field ${name} ${Context_name}.${Name}Component
        %endif
% endfor
local ${Context_name}Entity = {}

function ${Context_name}Entity:Ctor(...)
    self.__base.Ctor(self, ...)
end

%for comp in components:
<%
    Name = comp.name.Name
    name =  comp.name.name
    properties = comp.get_properties()
%>
    %if not comp.hasIsSimple():
---@return boolean
function ${Context_name}Entity:has${Name}()
  return self:has(${Context_name}_comps.${Name}) ~= nil
end

${comp.get_properties_define()}
---@returns ${Context_name}Entity
function ${Context_name}Entity:add${Name} (${comp.get_params()})
    self:add(${Context_name}_comps.${Name}, ${comp.get_params()})
    return self
end

function ${Context_name}Entity:replace${Name} (${comp.get_params()})
    self:replace(${Context_name}_comps.${Name}, ${comp.get_params()})
    return self
end

function ${Context_name}Entity:remove${Name} ()
    self:remove(${Context_name}_comps.${Name})
    return self
end
    %else:
---@return boolean
function ${Context_name}Entity:has${Name}()
  return self:has(${Context_name}_comps.${Name}) ~= nil
end

---@return ${Context_name}Entity
function ${Context_name}Entity:set${Name}(v)
    if (v ~= self:has${Name}()) then
        if (v) then
            self:add(${Context_name}_comps.${Name}, true)
        else
            self:remove(${Context_name}_comps.${Name})
        end
    end
    return self
end
    %endif
%endfor


return ${Context_name}Entity