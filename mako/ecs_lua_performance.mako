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


local function getComponent(pool, componentClass)
    local component
    if pool:size() > 0 then
        component = pool:removeLast()
    else
        component = componentClass:new()
    end
    return component
end



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
local _${Name}CP = Bag:new()
for i=1,${config['alloc']['components']} do
  _${Name}CP:add(${Name}Component:new())
end

function Entity:clear${Name}CP()
    _${Name}CP:clear()
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
    local component = getComponent(_${Name}CP, ${Name}Component)
        %for p in properties:
    component.${p.split(':')[0]} = ${p.split(':')[0]};
        %endfor
    self.${name} = component
    self:addComponent(CoreComponentIds.${Name}, component, '${Name}')
    return self
end

function Entity:replace${Name} (${params(properties)})
    local previousComponent
    if self:has${Name}() then
        previousComponent = self.${name}
    end
    local component = getComponent(_${Name}CP, ${Name}Component)
    %for p in properties:
    component.${p.split(':')[0]} = ${p.split(':')[0]}
    %endfor
    self.${name} = component
    self:replaceComponent(CoreComponentIds.${Name}, component, '${Name}')
    if (previousComponent ~= nil) then
        _${Name}CP:add(previousComponent)
    end
    return self
end

function Entity:remove${Name} (${params(properties)})
    local component = self.${Name}
    self:removeComponent(CoreComponentIds.${Name})
    ${namespace}._${Name}CP:add(component)
    return self
end
    %else:
---@return Entity
function Entity:set${Name}(v)
    if (v ~= self:has${Name}()) then
        if (v) then
            self:addComponent(CoreComponentIds.${Name}, ${Name}Component, '${Name}')
        else
            self:removeComponent(CoreComponentIds.${Name})
        end
    end
    return self
end

---@return boolean
function Entity:has${Name}()
  return self:hasComponent(CoreComponentIds.${Name})
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

%for Name in entities:
<%
pooled = entities[Name]
%>
    %if pooled:
<%
    properties = components[Name]
    name =  Name[0].lower() + Name[1:]

%>
        %if components[Name] is not False:
            %for p in properties:
---@param {${p.split(':')[1]}} ${p.split(':')[0]}"
            %endfor
---@returns Entity
function Pool:set${Name}(${params(properties)})
    if (self:has${Name}()) then
        error(Matcher.${Name})
    end
    local entity = self:createEntity('${Name}')
    self.${name}Entity = entity
    local component = getComponent(_${Name}CP, ${Name}Component)
        %for p in properties:
    component.${p.split(':')[0]} = ${p.split(':')[0]};
        %endfor
    self.${name} = component
    entity.${name} = component
    entity:addComponent(CoreComponentIds.${Name}, component, '${Name}')
    return entity
end
                %for p in properties:
---@param {${p.split(':')[1]}} ${p.split(':')[0]}"
                %endfor
---@returns Entity
function Pool:replace${Name}(${params(properties)})
    local entity = self.${name}Entity
    if (entity == nil) then
        entity = self:set${Name}(${params(properties)})
    else
        local previousComponent = entity.${name}
        local component = getComponent(_${Name}CP, ${Name}Component)
        %for p in properties:
        component.${p.split(':')[0]} = ${p.split(':')[0]}
        %endfor
        entity.${name} = component
        self.${name} = component
        entity:replaceComponent(CoreComponentIds.${Name}, component, '${Name}')
        _${Name}CP:add(previousComponent)

    end
    return entity
end

---@return bool
function Pool:has${Name}()
    return self:getGroup(Matcher.${Name}):getSingleEntity() ~= nil
end

function Pool:remove${Name}()
    local old = self.${name}Entity
    self.${name}Entity = nil
    self.${name} = nil
    self:destroyEntity(old)
end
        %else:
---@return bool
function Pool:has${Name}()
    return self:getGroup(Matcher.${Name}):getSingleEntity() ~= nil
end

---@return Pool
function Pool:set${Name}(value)
    if (v ~= self:has${Name}()) then
        if (v) then
            self:addComponent(CoreComponentIds.${Name}, ${Name}Component, '${Name}')
        else
            self:removeComponent(CoreComponentIds.${Name})
        end
    end
    return self
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
