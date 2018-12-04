local t_remove = table.remove
<%
    import json
    contexts = config['contexts']
    namespace = config['namespace']

    i = 0
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
    CmpIds = {}
%>\



local Bag = ${namespace}.Bag
local Entity = Entitas.Entity
local Context = Entitas.Context


local function com_tostring(obj)
    local lua = ""
    local t = type(obj)
    if t == "number" then
        lua = lua .. obj
    elseif t == "boolean" then
        lua = lua .. tostring(obj)
    elseif t == "string" then
        lua = lua .. string.format("%q", obj)
    elseif t == "table" then
        lua = lua .. "{"

        local first = true
        for k, v in pairs(obj) do
            if not first  then
                lua = lua .. ","
            end
            lua = lua .. com_tostring(k) .. "=" .. com_tostring(v)
            first = false
        end
        lua = lua .. "}"
    elseif t == "nil" then
        return nil
    else
        lua = lua .. "userdata"
    end
    return lua
end

local function make_component(name, prop, ...)
    local tmp = {}
    tmp.__keys = {...}
    tmp.__comp_name = name
    --tmp.__comp_index = comp_index
    tmp.__prop = prop
    tmp.__tostring = function(t) return "\t" .. t.__comp_name .. com_tostring(t) end
    tmp.__index = tmp
    tmp.__set_value = function(tb,...)
        local values = {...}
        for k, v in pairs(tmp.__keys) do
            if k <= #values then
                tb[v] = values[k]
            end
        end
    end
    tmp.new = function(...)
        local tb = {}
        tmp.__set_value(tb,...)
        return setmetatable(tb, tmp)
    end
    return tmp
end

local function getComponent(Context, componentClass, ...)
    local component
    if Context:size() > 0 then
        component = Context:removeLast()
        component.__set_value(component, ...)
    else
        component = componentClass.new(...)
    end
    return component
end

local Components = {
%for Context_name in contexts:
<%
components = contexts[Context_name]['components']
%>\
    %for Name in components:
    ${Name}Component = "${Name}Component",
    %endfor
%endfor
}

local Cp_Types = {
%for Context_name in contexts:
<%
components = contexts[Context_name]['components']
%>\
    %for Name in components:
<%
        name =  Name[0].lower() + Name[1:]
        properties = components[Name]
%>\
    %if components[Name] != False:
    ${Name}Component = make_component('${Name}', '${name}',  ${params_str(properties)}),
    %else:
    ${Name}Component = make_component('${Name}', '${name}'),
    %endif
    %endfor
%endfor
}

local Cp_TypePools = {
%for Context_name in contexts:
<%
components = contexts[Context_name]['components']
%>\
    %for Name in components:
    ${Name} = Bag.new(16),
    %endfor
%endfor
}

%for Context_name in contexts:
<%
components = contexts[Context_name]['components']
%>\
    %for Name in components:
local _${Name}CP = Cp_TypePools.${Name}
    %endfor
%endfor

for i=1,${config['alloc']['components']} do
%for Context_name in contexts:
<%
components = contexts[Context_name]['components']
%>\
    %for Name in components:
  _${Name}CP:add(Cp_Types.${Name}Component.new())
    %endfor
%endfor
end



%for context_name in contexts:
<%
Context_name = context_name[0].upper() + context_name[1:]
components = contexts[context_name]['components']
entities = contexts[context_name]['entities']
CmpIds[context_name] = {}
i = 0
%>\
----------------------------${Context_name}Entity     start---------------------------------------------
    %for Name in components:
local ${Name}Component = Cp_Types.${Name}Component
    %endfor

local ${Context_name}CmpIds = {
    %for Name in components:
<%
        name =  Name[0].lower() + Name[1:]
        properties = components[Name]
        i = i+ 1
        CmpIds[context_name][Name] = i
%>\
    ${Name} = ${i},
    %endfor
}


---@class ${Context_name}Entity
    % for Name in components:
<%
        name =  Name[0].lower() + Name[1:]
%>\
        %if components[Name] != False:
---@field ${name} ${Name}Component
        %endif
    % endfor
local ${Context_name}Entity = ${namespace}.Entity

##     % for Name in components:
##         %if components[Name] == False:
## local ${Name}Component = {}
##         %endif
##     % endfor

    %for Name in components:
<%
properties = components[Name]
name = Name[0].lower() + Name[1:]
%>
        %if properties != False:
---@class ${Name}Component : IComponent
            %for p in properties:
---@field ${p.split(':')[0]} ${p.split(':')[1]}
            %endfor
function ${Context_name}Entity:clear${Name}CP()
    _${Name}CP:clear()
end

---@return boolean
function ${Context_name}Entity:has${Name}()
  return self:hasComponent(${Context_name}CmpIds.${Name})
end

            %for p in properties:
---@param ${p.split(':')[0]} ${p.split(':')[1]}
            %endfor
---@returns ${namespace}.Entity
function ${Context_name}Entity:add${Name} (${params(properties)})
    local component = getComponent(_${Name}CP, ${Name}Component, ${params(properties)})
    self:addComponent(${Context_name}CmpIds.${Name}, component, '${name}')
    return self
end

function ${Context_name}Entity:replace${Name} (${params(properties)})
    local component = getComponent(_${Name}CP, ${Name}Component, ${params(properties)})
    self:replaceComponent(${Context_name}CmpIds.${Name}, component, '${name}')
    return self
end

function ${Context_name}Entity:remove${Name} ()
    self:removeComponent(${Context_name}CmpIds.${Name}, '${name}')
    return self
end
        %else:
---@return boolean
function ${Context_name}Entity:has${Name}()
  return self:hasComponent(${Context_name}CmpIds.${Name})
end

---@return ${Context_name}Entity
function ${Context_name}Entity:set${Name}(v)
    if (v ~= self:has${Name}()) then
        if (v) then
            self:addComponent(${Context_name}CmpIds.${Name}, ${Name}Component, '${name}')
        else
            self:removeComponent(${Context_name}CmpIds.${Name})
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
${Context_name}Matcher.${Name} = ${Context_name}Matcher.AllOf(${Context_name}CmpIds.${Name})
    %endfor
----------------------------Matcher     end---------------------------------------------


----------------------------Context   start---------------------------------------------
\
###\
## * Contexted Entities\
###\
---@class ${Context_name}Context : _Context
    %for Name in entities:
<%
name =  Name[0].lower() + Name[1:]
Context_name = context_name[0].upper() + context_name[1:]
%>\
        %if components[Name] != False:
---@field ${Context_name}${Name}Entity Entity
---@field ${name} ${Name}Component
        %else:
---@field is${Name}Entity bool
        %endif
    %endfor
---@field createEntity fun():${Context_name}Entity
local _${Context_name}Context = Context.new(${Context_name}CmpIds, #${Context_name}CmpIds)


    %for Name in entities:
    <%
    Contexted = entities[Name]
    %>
        %if Contexted:
    <%
        properties = components[Name]
        name =  Name[0].lower() + Name[1:]

    %>
            %if components[Name] is not False:
                %for p in properties:
---@param {${p.split(':')[1]}} ${p.split(':')[0]}"
                %endfor
---@returns ${Context_name}Entity
function _${Context_name}Context:set${Name}(${params(properties)})
    if (self:has${Name}()) then
        error('${Name}Component already have')
    end
    local entity = self:createEntity('${name}')
    self.${name}Entity = entity
    local component = getComponent(_${Name}CP, ${Name}Component, ${params(properties)})
    self.${name} = component
    self.${name}Entity = entity
    entity:addComponent(${Context_name}CmpIds.${Name}, component, '${name}')
    return entity
end
                    %for p in properties:
---@param {${p.split(':')[1]}} ${p.split(':')[0]}"
                    %endfor
---@returns ${Context_name}Entity
function _${Context_name}Context:replace${Name}(${params(properties)})
    local entity = self.${name}Entity
    if (entity == nil) then
        entity = self:set${Name}(${params(properties)})
    else
        local component = getComponent(_${Name}CP, ${Name}Component, ${params(properties)})
        self.${name} = component
        self.${name}Entity = entity
        entity:replaceComponent(${Context_name}CmpIds.${Name}, component, component)
    end
    return entity
end

---@return bool
function _${Context_name}Context:has${Name}()
    return self:getGroup(${Context_name}Matcher.${Name}):getSingleEntity() ~= nil
end

function _${Context_name}Context:remove${Name}()
    local old = self.${name}Entity
    self.${name}Entity = nil
    self.${name} = nil
    self:destroyEntity(old)
end
            %else:
---@return bool
function _${Context_name}Context:has${Name}()
    return self:getGroup(${Context_name}Matcher.${Name}):single_entity() ~= nil
end

---@return Context
function _${Context_name}Context:set${Name}(value)
    if (v ~= self:has${Name}()) then
        if (v) then
            self:addComponent(${Context_name}CmpIds.${Name}, ${Name}Component, '${name}')
        else
            self:removeComponent(${Name}Component)
        end
    end
    return self
end
            %endif
        %endif
    %endfor

%if 'indexes' in contexts[context_name]:
----------------------------${Context_name}Indexes     start---------------------------------------------
function _${Context_name}Context:initGenerateEntityIndexes()
<%
    indexes = contexts[context_name]['indexes']
%>\
    %for name in indexes:
<%
    cmps = indexes[name]
    really_values = {}
    for cmp in cmps:
        if cmp not in components:
            raise (cmp, "not in components")
        full_cmp = components[cmp]
        parm_str_list = []
        cmpValues = {}
        for value in full_cmp:
            value = value.replace(' ','')
            sp_list = value.split(':')
            if len(sp_list) <= 1:
                raise Exception(cmp, value, "have no value Type")
            cmpValues[sp_list[0]] = sp_list[1]

        values = cmps[cmp]
        for value in values:
            value = value.replace(' ', '')
            sp_list = value.split(':')
            if len(sp_list) <= 1:
                raise Exception("index ",cmp, value, "have no value Type")

            if sp_list[0] not in cmpValues:
                raise Exception(cmp, "have no value", sp_list[0])
            parm_str_list.append(value)
        really_values[cmp] = params_str(parm_str_list)
%>\
        %for cmp in cmps:
    local ${cmp}Group = _${Context_name}Context:getGroup(${Context_name}Matcher.${cmp})
            %if name == "primary":
    local ${cmp}PrimaryIndex = Entitas.PrimaryEntityIndex.new(${Context_name}CmpIds.${cmp}, ${cmp}Group, ${really_values[cmp]})
    _${Context_name}Context:addEntityIndex(${cmp}PrimaryIndex)
            %elif name == "index":
    local ${cmp}EntityIndex = Entitas.EntityIndex.new(${Context_name}CmpIds.${cmp}, ${cmp}Group, ${really_values[cmp]})
    _${Context_name}Context:addEntityIndex(${cmp}EntityIndex)
            %endif
        %endfor
    %endfor
end


    %for name in indexes:
<%
    cmps = indexes[name]
    really_values = {}
    single_values = {}
    for cmp in cmps:
        if cmp not in components:
            raise (cmp, "not in components")
        full_cmp = components[cmp]
        parm_str_list = []
        single_value_list = []
        cmpValues = {}
        for value in full_cmp:
            value = value.replace(' ','')
            sp_list = value.split(':')
            if len(sp_list) <= 1:
                raise Exception(cmp, value, "have no value Type")
            cmpValues[sp_list[0]] = sp_list[1]

        values = cmps[cmp]
        for value in values:
            value = value.replace(' ', '')
            sp_list = value.split(':')
            if len(sp_list) <= 1:
                raise Exception("index ",cmp, value, "have no value Type")

            if sp_list[0] not in cmpValues:
                raise Exception(cmp, "have no value", sp_list[0])
            parm_str_list.append(value)
            single_value_list.append(sp_list[0])
        really_values[cmp] = params_str(parm_str_list)
        single_values = single_value_list
%>\
        %for cmp in cmps:
            %for single_value in single_values:
                %if name == "primary":
---@return ${Context_name}Entity
function _${Context_name}Context:GetEntityBy${cmp}${single_value}(${single_value})
    return self:getEntityIndex(${Context_name}CmpIds.${cmp}):getEntity(${single_value})
end
                %elif name == "index":
---@return ${Context_name}Entity
function _${Context_name}Context:GetEntitiesBy${cmp}${single_value}(${single_value})
    return self:getEntityIndex(${Context_name}CmpIds.${cmp}):getEntities(${single_value})
end
                %endif
            %endfor
        %endfor
    %endfor


_${Context_name}Context:initGenerateEntityIndexes()
----------------------------${Context_name}Indexes     end---------------------------------------------
%endif
${Context_name}Context = _${Context_name}Context

%endfor

----------------------------Context    end---------------------------------------------

Contexts = {
%for context_name in contexts:
<%
    Context_name = context_name[0].upper() + context_name[1:]
%>\
    ---@type ${Context_name}Context
    ${context_name}Context = _${Context_name}Context,
%endfor
}
## %if ${Context_name} in extensions:
##         % for funName ,value in extensions['Context'].items():
## <%
##         name, ret_type = funName.split(':')
##     %>\
## ---@field ${name} fun(self:Context,${','.join(value)}):${ret_type}
##         % endfor
## %endif


---@class GenerateMatcher
---@field AnyOf fun(...) : GenerateMatcher
---@field AllOf fun(...) : GenerateMatcher
---@field noneOf fun(self:GenerateMatcher,...) : GenerateMatcher
---@field onEntityAdded fun(self:GenerateMatcher)
---@field onEntityRemoved fun(self:GenerateMatcher)
---@field onEntityAddedOrRemoved fun(self:GenerateMatcher)
local ___temp