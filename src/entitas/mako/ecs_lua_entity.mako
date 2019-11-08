<%
    Context_name = context_name[0].upper() + context_name[1:]
    components = contexts.components
    event_comps = contexts.event_comps
    import json
    def params(a, sep = ', ' , b = []):
        b = []
        for item in a:
            b.append(item[0])
        return sep.join(b)

    def params_str(a, sep = ', ' , b = []):
        b = []
        for item in a:
            b.append('"' + item[0] + '"')
        return sep.join(b)
%>\
local ${Context_name}_comps = require('.${context_name}Components')
local set = require('Common.container.set')

---@class ${Context_name}Entity
% for comp in components:
<%
    Name = comp.Name
    name =  comp.name
    Context_name = context_name[0].upper() + context_name[1:]
    properties = comp.data
%>\
        %if not comp.simple:
---@field ${name} ${Context_name}.${Name}Component
        %endif
% endfor
local ${Context_name}Entity = {}

%for comp in components:
<%
    Name = comp.Name
    name =  comp.name
    Context_name = context_name[0].upper() + context_name[1:]
    properties = comp.data
%>
    %if not comp.simple:
---@return boolean
function ${Context_name}Entity:has${Name}()
  return self:has(${Context_name}_comps.${Name}) ~= nil
end

        %for i in range(len(properties)):
---@param ${properties[i][0]} ${comp.get_property(i, contexts)}
        %endfor
---@returns ${Context_name}Entity
function ${Context_name}Entity:add${Name} (${params(properties)})
    self:add(${Context_name}_comps.${Name}, ${params(properties)})
    return self
end

function ${Context_name}Entity:replace${Name} (${params(properties)})
    self:replace(${Context_name}_comps.${Name}, ${params(properties)})
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
            self:add(${Context_name}_comps.${Name})
        else
            self:remove(${Context_name}_comps.${Name})
        end
    end
    return self
end
    %endif
%endfor
%if event_comps:
    %for comp in event_comps:
        <%
            print(comp.name)
            print(Name)
        %>
function ${Context_name}Entity:Add${comp.Name}CallBack(callback)
    local list
    if not self:has${comp.Name}() then
        list = set.new(false)
    else
        list = self.${comp.name}.value
    end
    list:insert(callback)
    self:replace${comp.Name}(list)
end

function ${Context_name}Entity:Remove${comp.Name}CallBack(callback, removeComponentWhenEmpty)
    if removeComponentWhenEmpty == nil then
        removeComponentWhenEmpty = true
    end
    local listeners = self.${comp.name}.value
    listeners:remove(callback)
    if removeComponentWhenEmpty and listeners:size() == 0 then
        self:remove${comp.Name}()
    else
        self:replace${comp.Name}(listeners)
    end
end
    %endfor
%endif



return ${Context_name}Entity