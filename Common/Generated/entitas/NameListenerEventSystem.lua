local Matcher = require("Common.entitas.Matcher")local GroupEvent = require("Common.entitas.GroupEvent")local Player_comps = require('.PlayerComponents')local PlayerMatcher = require('.PlayerMatchers')local tabledeepcopy = table.deepcopy---@class NameListenerEventSystem : entitas.ReactiveSystemlocal M = class({},'NameListenerEventSystem', classMap.ReactiveSystem)function M:Ctor(context)    M.__super.Ctor(self, context)endfunction M:get_trigger()    return {        {            Matcher({Player_comps.Name}),            GroupEvent.ADDED        }    }endfunction M:filter(entity)    return entity:hasName() and entity:hasNameListener()endfunction M:execute(es)    es:foreach( function( e  )        local comp = e.name        local list = tabledeepcopy(e.nameListener.value:get_buffer())        for i = 1, #list do            list[i]:OnNameListener(e , comp.value );        end    end)endreturn M