local make_component = require("Common.entitas.MakeComponent")local Components = {}---@class Prop.DestroyComponentComponents.Destroy = make_component('destroy')---@class Prop.ConfigComponent---@field value  ItemTemplateComponents.Config = make_component('config',  "value")---@class Prop.Type_idComponent---@field value  numberComponents.Type_id = make_component('type_id',  "value")---@class Prop.ItemInfoComponent---@field value  ItemInfoComponents.ItemInfo = make_component('itemInfo',  "value")---@class Prop.NumComponent---@field value  numberComponents.Num = make_component('num',  "value")return Components