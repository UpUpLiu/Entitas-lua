<%
    _contextName = _context.name.Name
    _contextname = _context.name.name
%>
local ${_contextName}Context = classMap.${_contextName}Context
function ${_contextName}Context:initGenerateEntityIndexes()
%for attr in _attrs:
<%
    comp = attr.component.value
    Name = comp.name.Name
    name = comp.name.name
    attr_name = attr.name.value
    parse_attr = attr.parseAttr.value
%>\
    %if attr_name == "primaryIndex":
    local group = self:get_group(Matcher({${_contextName}_comps.${Name}}))
    self._${Name}${parse_attr}PrimaryIndex = PrimaryEntityIndex:new(${_contextName}_comps.${Name}, group, '${parse_attr}')
    self:add_entity_index(self._${Name}${parse_attr}PrimaryIndex)
    %elif attr_name == "index":
    local group = self:get_group(Matcher({${_contextName}_comps.${Name}}))
    self._${Name}${parse_attr}Index = EntityIndex:new(${_contextName}_comps.${Name}, group, '${parse_attr}')
    self:add_entity_index(self._${Name}${parse_attr}Index)
    %endif
%endfor
end

%for attr in _attrs:
<%
    Name = comp.name.Name
    name =  comp.name.name
    attr_name = attr.name.value
    parse_attr = attr.parseAttr.value
%>\
        %if attr_name == "primaryIndex":
---@return ${_contextName}Entity
function ${_contextName}_context:GetEntityBy${Name}${parse_attr}(${parse_attr})
    return self._${Name}${parse_attr}PrimaryIndex:get_entity(${parse_attr})
end
            %elif attr_name == "index":
---@return ${_contextName}Entity[]
function ${_contextName}_context:GetEntitiesBy${Name}${parse_attr}(${parse_attr})
    return self._${Name}${parse_attr}Index:get_entities(${parse_attr})
end
        %endif
%endfor

## <%
##     i = 0
## %>
## %for index in _context.muIndex:
## <%
##     matcher_parm = []
##     call_parm = []
##     i += 1
##     for index_data in index.index_data:
##         Name = index_data.k
##         Name = Name[0].upper() + Name[1:]
##         matcher_parm.append(_contextName + "_comps." + Name)
##         value = index_data.v
##         call_parm.append('{' + 'comp_type={0},  key =  "{1}"'.format(_contextName + "_comps." + Name, value) + '}')
##     print(','.join(matcher_parm))
## %>\
##     local group = self:get_group(Matcher({${','.join(matcher_parm)}}))
##     self.__contextIndex${i} = classMap.EntityMuIndex:new(group, {
##         ${','.join(call_parm)}
##     })
## %endfor
##
## end
##

##
##
## <%
##     i = 0
## %>
## %for index in _context.muIndex:
## <%
##     call_parm = []
##     i += 1
##     name_parm = []
##     for index_data in index.index_data:
##         Name = index_data.k
##         Name = Name[0].upper() + Name[1:]
##         name_parm.append(Name)
##         name_parm.append(index_data.v)
##         call_parm.append(Name+'_'+value)
## %>\
## ---@return ${_contextName}Entity[]
## function ${_contextName}_context:${index.funcName}(${','.join(call_parm)})
##     return self.__contextIndex${i}:get_entities(${','.join(call_parm)})
## end
## %endfor