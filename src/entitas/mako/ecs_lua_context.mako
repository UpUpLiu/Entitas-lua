<%
    Context_name = context_name[0].upper() + context_name[1:]
    components = contexts.components
    import json
    def params_str(a, sep = ', ' , b = []):
        b = []
        for item in a:
            b.append('"' + item[0] + '"')
        return sep.join(b)
    def params(a, sep = ', ' , b = []):
        b = []
        for item in a:
            b.append(item[0])
        return sep.join(b)
%>\
local EntityIndex = require("${contexts.source}.EntityIndex")
local PrimaryEntityIndex = require("${contexts.source}.PrimaryEntityIndex")
local Matcher = require("${contexts.source}.Matcher")
local ${Context_name}_comps = require('.${context_name}Components')

---@class ${Context_name}Context : entitas.Context
%for comp in components:
<%
    Name = comp.Name
    name =  comp.name
    Context_name = context_name[0].upper() + context_name[1:]
    properties = comp.data
%>\
    %if comp.single:
        %if not comp.simple and comp.single:
---@field ${name}Entity ${Context_name}Entity
---@field ${name} ${Context_name}.${Name}Component
        %endif
    %endif
%endfor
---@field createEntity fun():${Context_name}Entity
local ${Context_name}Context = {}

%for comp in components:
<%
    Name = comp.Name
    name =  comp.name
    Context_name = context_name[0].upper() + context_name[1:]
    properties = comp.data
%>\
    %if comp.single:
        %if not comp.simple:
            %for i in range(len(properties)):
---@param ${properties[i][0]} ${comp.get_property(i, contexts)}
            %endfor
---@returns ${Context_name}Entity
function ${Context_name}Context:set${Name}(${params(properties)})
    if self:has_unique_component(${Context_name}_comps.${Name}) then
        error('${Name}Component already have')
    end
    return self:set_unique_component('${name}', ${Context_name}_comps.${Name}, ${params(properties)})
end
        %for i in range(len(properties)):
---@param ${properties[i][0]} ${comp.get_property(i, contexts)}
        %endfor
---@returns ${Context_name}Entity
function ${Context_name}Context:replace${Name}(${params(properties)})
    local entity = self.${name}Entity
    if entity == nil then
        self:set${Name}(${params(properties)})
    else
        self.${name} = entity:replace(${Context_name}_comps.${Name}, ${params(properties)})
    end
    return entity
end

        %else:
---@return Context
---@parm value boolean
function ${Context_name}Context:set${Name}(value)
    if (value ~= self:has${Name}()) then
        if (value) then
            self:set_unique_component('${name}',${Context_name}_comps.${Name}, true)
        else
            self:remove_unique_component('${name}')
        end
    end
    return self
end
        %endif
---@return bool
function ${Context_name}Context:has${Name}()
    return self:has_unique_component(${Context_name}_comps.${Name})
end
    %endif
---@return bool
function ${Context_name}Context:remove${Name}()
    self:remove_unique_component('${name}')
end
%endfor

---@return ${Context_name}Entity
---@private
function ${Context_name}Context:_create_entity()
    return self._entity_class:new()
end

---@return ${Context_name}Entity
function ${Context_name}Context:CreateEntity()
    return self:create_entity()
end

---@return ${Context_name}Context
function ${Context_name}Context.${Context_name}Context()
    return classMap.${Context_name}Context:new(classMap.${Context_name}Entity)
end


function ${Context_name}Context:initGenerateEntityIndexes()
%for comp in components:
<%
    Name = comp.Name
    name =  comp.name
    Context_name = context_name[0].upper() + context_name[1:]
    properties = comp.data
%>\
        %for attr in  comp.attr:
            %if attr.class_name == "primaryindex":
    local group = self:get_group(Matcher({${Context_name}_comps.${Name}}))
    self._${Name}${attr.p_name}PrimaryIndex = PrimaryEntityIndex:new(${Context_name}_comps.${Name}, group, '${attr.p_name}')
    self:add_entity_index(self._${Name}${attr.p_name}PrimaryIndex)
            %elif attr.class_name == "index":
    local group = self:get_group(Matcher({${Context_name}_comps.${Name}}))
    self._${Name}${attr.p_name}Index = EntityIndex:new(${Context_name}_comps.${Name}, group, '${attr.p_name}')
    self:add_entity_index(self._${Name}${attr.p_name}Index)
            %endif
        %endfor
%endfor
end

%for comp in components:
<%
    Name = comp.Name
    name =  comp.name
    Context_name = context_name[0].upper() + context_name[1:]
    properties = comp.data
%>\
        %for attr in  comp.attr:
            %if attr.class_name == "primaryindex":
---@return ${Context_name}Entity
function ${Context_name}Context:GetEntityBy${Name}${attr.p_name}(${attr.p_name})
    return self._${Name}${attr.p_name}PrimaryIndex:get_entity(${attr.p_name})
end
            %elif attr.class_name == "index":
---@return ${Context_name}Entity[]
function ${Context_name}Context:GetEntitiesBy${Name}${attr.p_name}(${attr.p_name})
    return self._${Name}${attr.p_name}Index:get_entities(${attr.p_name})
end
            %endif
        %endfor
%endfor

return ${Context_name}Context