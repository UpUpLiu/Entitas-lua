local make_component = require("Common.entitas.MakeComponent")local Components = {}---@class Stage.AppraiseComponentComponents.Appraise = make_component('appraise')---@class Stage.ConfigComponentComponents.Config = make_component('config')---@class Stage.DestroyComponentComponents.Destroy = make_component('destroy',  )---@class Stage.NumComponentComponents.Num = make_component('num')---@class Stage.SourceComponentComponents.Source = make_component('source')---@class Stage.Type_idComponentComponents.Type_id = make_component('type_id')return Components