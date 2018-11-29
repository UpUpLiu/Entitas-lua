local _Pool
<%
    import json
    components = config['components']
    namespace = config['namespace']
    entities = config['entities']
    extensions = config['extensions']
    i = 0
    def params(a, sep = ', '):
      b = []
      for item in a:
        b.append(item.split(':')[0])
      return sep.join(b)

%>\
local CoreComponentIds = {
<%
    i = 0
%>\
    %for Name in components:
<%
    i = i + 1
%>\
    ${Name} = ${i},
    %endfor
}

${namespace}.CoreComponentIds = CoreComponentIds
local Bag = ${namespace}.Bag

----------------------------Entity     start---------------------------------------------
---@class Entity
% for Name in components:
<%
        name =  Name[0].lower() + Name[1:]
%>\
    %if components[Name] != False:
---@field ${name} ${Name}Component
    %endif
% endfor
local Entity = ${namespace}.Entity

% for Name in components:
    %if components[Name] == False:
local ${Name}Component = {}
    %endif
% endfor

## property, getter, setter
local boolEntityPropertyMt = {
%for Name in components:
<%
    properties = components[Name]
%>\
    %if properties == False:
        is${Name} = function(self)
            return self:hasComponent(CoreComponentIds.${Name})
        end,
        set${Name} = function(self, v)
            if (v ~= self.is${Name}) then
                if (v) then
                    self:addComponent(CoreComponentIds.${Name}, ${Name}Component, '${Name}')
                else
                    self:removeComponent(CoreComponentIds.${Name})
                end
            end
            return self
        end,
    %endif
%endfor
}

local entity_component_getters = {
    %for Name in components:
        %if components[Name] == False:
        is${Name} = boolEntityPropertyMt['is${Name}'],
        %endif
    %endfor
}


local entity_component_setters = {
    %for Name in components:
        %if components[Name] == False:
        is${Name} = boolEntityPropertyMt['set${Name}'],
        %endif
    %endfor
}
Entity.Init(boolEntityPropertyMt, entity_component_getters, entity_component_setters)

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
local ${Name}Component = {}

---@private
function ${Name}Component:new()
    return setmetatable({}, {__index = ${Name}Component})
end

---@type ${namespace}.Bag
local _${Name}ComponentPool = Bag:new()
for i=1,${config['alloc']['components']} do
  _${Name}ComponentPool:add(${Name}Component:new())
end

function Entity:clear${Name}ComponentPool()
    _${Name}ComponentPool:clear()
end

---@return boolean
function Entity:has${Name}()
  return self:hasComponent(CoreComponentIds.${Name})
end

        %for p in properties:
---@param ${p.split(':')[0]} ${p.split(':')[1]}
        %endfor
---@returns ${namespace}.Entity
function Entity:add${Name} (${params(properties)})
    local component
    if _${Name}ComponentPool:size() > 0 then
        component = _${Name}ComponentPool:removeLast()
    else
        component = ${Name}Component:new()
    end
        %for p in properties:
    component.${p.split(':')[0]} = ${p.split(':')[0]};
        %endfor
    self.${name} = component
    self:addComponent(CoreComponentIds.${Name}, component, '${Name}')
    return self
end

function Entity:replace${Name} (${params(properties)})
    local pool = _${Name}ComponentPool
    local previousComponent
    if self:has${Name}() then
        previousComponent = self.${name}
    end
    local component
    if _${Name}ComponentPool:size() > 0 then
        component = pool:removeLast()
    else
        component = ${Name}Component():new()
    end
    %for p in properties:
    component.${p.split(':')[0]} = ${p.split(':')[0]}
    %endfor
    self:replaceComponent(CoreComponentIds.${Name}, component, '${Name}')
    if (previousComponent ~= nil) then
        pool:add(previousComponent)
    end
    return self
end

function Entity:remove${Name} (${params(properties)})
    local component = self.${Name}
    self:removeComponent(CoreComponentIds.${Name})
    ${namespace}._${Name}ComponentPool:add(component)
    return self
end
    %endif

%endfor
----------------------------Entity      end---------------------------------------------


----------------------------Matcher     start---------------------------------------------
---@class Matcher : _Matcher
%for Name in components:
---@field ${Name} _Matcher
%endfor
local Matcher = ${namespace}.Matcher
Matcher.Init(CoreComponentIds)

----------------------------Matcher      end---------------------------------------------

----------------------------Pool   start---------------------------------------------
\
###\
## * Pooled Entities\
###\
\

---@class Pool : _Pool
%for Name in entities:
<%
        name =  Name[0].lower() + Name[1:]
    %>\
    %if components[Name] != False:
---@field ${Name}Entity Entity
---@field ${name} ${Name}Component
    %else:
---@field is${Name}Entity bool
    %endif
%endfor
local Pool = ${namespace}.Pool


## Pooled, getter, setter\
local Pool_Mt = {
%for Name in entities:
<%
    properties = components[Name]
%>
    get${Name} = function(self)
        return _Pool:getGroup(Matcher.${Name}):getSingleEntity()
    end,
    get${Name}Component = function(self)
        return _Pool:getGroup(Matcher.${Name}):getSingleEntity().${Name}
    end,
    has${Name} = function(self)
        return _Pool:getGroup(Matcher.${Name}):getSingleEntity() ~= nil
    end,
    set${Name} = function(self, v)
        local entity = self.${Name}
        if (v ~= (entity ~= nil)) then
            if (v) then
                _Pool:createEntity(${Name}).is${Name} = true
            else
                _Pool:destroyEntity(entity)
            end
        end
        return self
    end,
%endfor
}

local pool_component_getters = {
    %for Name in entities:
        <%
            name =  Name[0].lower() + Name[1:]
        %>
        %if components[Name] == False:
        is${Name} = Pool_Mt['has${Name}'],
        %else:
        ${Name}Entity = Pool_Mt['get${Name}'],
        ${name} = Pool_Mt['get${Name}Component'],
        %endif
    %endfor
}


local pool_component_setters = {
    %for Name in entities:
        %if components[Name] == False:
        is${Name} = Pool_Mt['set${Name}'],
        %else:
        ${Name}Entity = Pool_Mt['set${Name}'],
        %endif
    %endfor
}

Pool.Init(Pool_Mt, pool_component_getters, pool_component_setters)

%for Name in entities:
<%
pooled = entities[Name]
%>
    %if pooled:
<%
    properties = components[Name]
%>
        %if components[Name] is not False:
            %for p in properties:
---@param {${p.split(':')[1]}} ${p.split(':')[0]}"
            %endfor
---@returns ${namespace}.Entity
function Pool:set${Name}(${params(properties)})
    if (self:has${Name}()) then
        error(Matcher.${Name})
    end
    local entity = self:createEntity('${Name}')
    entity:add${Name}(${params(properties)})
    return entity
end
                %for p in properties:
---@param {${p.split(':')[1]}} ${p.split(':')[0]}"
                %endfor
---@returns ${namespace}.Entity
function Pool:replace${Name}(${params(properties)})
    local entity = self.${Name}Entity
    if (entity == nil) then
        entity = self:set${Name}(${params(properties)})
    else
        entity:replace${Name}(${params(properties)})
        return entity
    end
end

function Pool:has${Name}()
    return self:getGroup(Matcher.${Name}):getSingleEntity() ~= nil
end

---@returns ${namespace}.Entity
function Pool:remove${Name}()
    self:destroyEntity(self.${Name}Entity)
end
        %endif
    %endif
%endfor

---@return Pool
function PoolIns()
    if _Pool == nil then
        _Pool = Pool:new(CoreComponentIds, CoreComponentIds.TotalComponents, nil)
    end
    return _Pool
end

function ReleasePool()
    if _Pool ~= nil then
        _Pool = Pool:new(CoreComponentIds, CoreComponentIds.TotalComponents, nil)
    end
    return _Pool
end


----------------------------Pool    end---------------------------------------------
