<%
    Context_name = context_name[0].upper() + context_name[1:]
    components = contexts['components']
    import json
    def params(a, sep = ', ' , b = []):
        b = []
        for item in a:
            item = item.replace(' ', '')
            b.append(item.split(':')[0])
        return sep.join(b)

    def params_str(a, sep = ', ' , b = []):
        b = []
        for item in a:
            item = item.replace(' ', '')
            b.append('"' + item.split(':')[0] + '"')
        return sep.join(b)

    def init_comp_data(component):
        name =  Name[0].lower() + Name[1:]
        Context_name = context_name[0].upper() + context_name[1:]
        comp = component
        properties = None
        have_data = false
        if type(component) is not bool and 'data' in component :
            properties = component['data']
            have_data = true
%>\
local t_remove = table.remove
local entitas = require("./entitas")
local ${Context_name}_comps = require("./${Context_name}Components")
local Context = entitas.Context
local Systems = entitas.Systems
local Matcher = entitas.Matcher

----------------------------${Context_name}Entity     start---------------------------------------------


---@class ${Context_name}Entity
% for Name in components:
<%
        name =  Name[0].lower() + Name[1:]
%>\
        %if components[Name] != False:
---@field ${name} ${Name}Component
        %endif
% endfor
local ${Context_name}Entity = ${Context_name}Entity

%for Name in components:
<%
    init_comp_data(components[Name])
%>
    %if have_data:
---@class ${Name}Component : IComponent
        %for p in properties:
---@field ${p.split(':')[0]} ${p.split(':')[1]}
        %endfor
---@return boolean
function ${Context_name}Entity:has${Name}()
  return self:hasComponent(${Context_name}_comps.${Name})
end

        %for p in properties:
---@param ${p.split(':')[0]} ${p.split(':')[1]}
        %endfor
---@returns ${Context_name}Entity
function ${Context_name}Entity:add${Name} (${params(properties)})
    local component = getComponent(_${Name}CP, ${Name}Component, ${params(properties)})
    self:addComponent(${Context_name}_comps.${Name}, component, '${name}')
    return self
end

function ${Context_name}Entity:replace${Name} (${params(properties)})
    local component = getComponent(_${Name}CP, ${Name}Component, ${params(properties)})
    self:replaceComponent(${Context_name}_comps.${Name}, component, '${name}')
    return self
end

function ${Context_name}Entity:remove${Name} ()
    self:removeComponent(${Context_name}_comps.${Name}, '${name}')
    return self
end
    %else:
---@return boolean
function ${Context_name}Entity:has${Name}()
  return self:hasComponent(${Context_name}_comps.${Name})
end

---@return ${Context_name}Entity
function ${Context_name}Entity:set${Name}(v)
    if (v ~= self:has${Name}()) then
        if (v) then
            self:addComponent(${Context_name}_comps.${Name}, ${Name}Component, '${name}')
        else
            self:removeComponent(${Context_name}_comps.${Name})
        end
    end
    return self
end
    %endif
%endfor
----------------------------Entity      end---------------------------------------------

----------------------------Matcher     start-------------------------------------------
---@class ${Context_name}Matcher
---@field AnyOf fun(...) : GenerateMatcher
---@field AllOf fun(...) : GenerateMatcher
---@field noneOf fun(...) : GenerateMatcher
%for Name in components:
---@field ${Name} : GenerateMatcher
%endfor
${Context_name}Matcher = Entitas.Matcher
%for Name in components:
${Context_name}Matcher.${Name} = ${Context_name}Matcher.AllOf(${Context_name}_comps.${Name})
%endfor
----------------------------Matcher     end---------------------------------------------


----------------------------Context   start---------------------------------------------
\
###\
## * Contexted Entities\
###\

---@class ${Context_name}Context : entitas.Context
%for Name in components:
 <%
    init_comp_data(components[Name])
    %>\
    %if have_data and 'single' in comp:
---@field ${Context_name}${Name}Entity Entity
---@field ${name} ${Name}Component
    %else:
---@field is${Name}Entity bool
    %endif
%endfor
---@field createEntity fun():${Context_name}Entity
local ${Context_name}Context = {}


%for Name in components:
    <%
    init_comp_data(components[Name])
    %>\
    %if have_data and single in comp:
        %if comp.data is not None:
            %for p in properties:
---@param {${p.split(':')[1]}} ${p.split(':')[0]}"
            %endfor
---@returns ${Context_name}Entity
function ${Context_name}Context:set${Name}(${params(properties)})
    if (self:has${Name}()) then
        error('${Name}Component already have')
    end
    local entity = self:createEntity('${name}')
    self.${name}Entity = entity
    local component = getComponent(_${Name}CP, ${Name}Component, ${params(properties)})
    self.${name} = component
    self.${name}Entity = entity
    entity:addComponent(${Context_name}_comps.${Name}, component, '${name}')
    return entity
end
                %for p in properties:
---@param {${p.split(':')[1]}} ${p.split(':')[0]}"
                %endfor
---@returns ${Context_name}Entity
function ${Context_name}Context:replace${Name}(${params(properties)})
    local entity = self.${name}Entity
    if (entity == nil) then
        entity = self:set${Name}(${params(properties)})
    else
        local component = getComponent(_${Name}CP, ${Name}Component, ${params(properties)})
        self.${name} = component
        self.${name}Entity = entity
        entity:replaceComponent(${Context_name}_comps.${Name}, component, component)
    end
    return entity
end

---@return bool
function ${Context_name}Context:has${Name}()
    return self:getGroup(${Context_name}Matcher.${Name}):getSingleEntity() ~= nil
end

function ${Context_name}Context:remove${Name}()
    local old = self.${name}Entity
    self.${name}Entity = nil
    self.${name} = nil
    self:destroyEntity(old)
end
        %else:
---@return bool
function ${Context_name}Context:has${Name}()
    return self:getGroup(${Context_name}Matcher.${Name}):single_entity() ~= nil
end

---@return Context
function ${Context_name}Context:set${Name}(value)
    if (v ~= self:has${Name}()) then
        if (v) then
            self:addComponent(${Context_name}_comps.${Name}, ${Name}Component, '${name}')
        else
            self:removeComponent(${Name}Component)
        end
    end
    return self
end
        %endif
    %endif
%endfor

----------------------------${Context_name}Indexes     start---------------------------------------------
function ${Context_name}Context:initGenerateEntityIndexes()

%for Name in components:
    <%
    init_comp_data(components[Name])
    %>\
    %if have_data and 'attr' in comp:
    <%
        attrs = comp['attr']
    %>\
        %for attr_name in  attrs:
        <%
            attr = comp['attr']
        %>\
            %if attr_name== "primaryIndex":
##                 <%
##                 for p in attr:
##                     p_name = p.split(':')[0].replace(" ","")
##                 %>
##     local ${cmp}PrimaryIndex = Entitas.PrimaryEntityIndex:new(${cmp}, ${cmp}Group, ${really_values[cmp]})
##     self:addEntityIndex(${cmp}PrimaryIndex)

            %elif attr_name == "indexs":
##     local ${cmp}EntityIndex = Entitas.EntityIndex.new(${Context_name}_comps.${cmp}, ${cmp}Group, ${really_values[cmp]})
##     self:addEntityIndex(${cmp}EntityIndex)
            %endif
        %endfor
    %endif
%endfor
end

----------------------------Context    end---------------------------------------------

return ${Context_name}Context