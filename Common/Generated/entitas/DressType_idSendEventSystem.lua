local Matcher = require("Common.entitas.Matcher")local GroupEvent = require("Common.entitas.GroupEvent")local Dress_comps = require('.dressComponents')local DressMatcher = require('.dressMatchers')local tabledeepcopy = table.deepcopy---@class Type_idSendEventSystem : entitas.ReactiveSystemlocal M = class({},'Type_idSendEventSystem', classMap.ReactiveSystem)function M:Ctor(context)    M.__base.Ctor(self, context)endfunction M:get_trigger()    return {        {            Matcher({Dress_comps.Type_id}),            GroupEvent.ADDED | GroupEvent.REMOVED        }    }endfunction M:filter(entity)    return entity:hasType_id()endfunction M:execute(es)    es:foreach( function( e  )        local comp = e.Type_id        EntitasEvent.Dress:DispatchEvent(EntitasEventConst.Dress.type_id, e)    end)endreturn M