local make_component = require("Common.entitas.MakeComponent")local Components = {}---@class Player.DestroyComponentComponents.Destroy = make_component('destroy')---@class Player.UidComponent---@param value  long Components.Uid = make_component('uid',  "value")---@class Player.ElementComponentComponents.Element = make_component('element')---@class Player.CoinComponent---@param value  numberComponents.Coin = make_component('coin',  "value")---@class Player.ExpComponent---@param value  numberComponents.Exp = make_component('exp',  "value")---@class Player.AssetComponent---@param value  numberComponents.Asset = make_component('asset',  "value")---@class Player.EnergyComponent---@param value  numberComponents.Energy = make_component('energy',  "value")---@class Player.NameComponent---@param value  string Components.Name = make_component('name',  "value")---@class Player.LvlComponent---@param value  numberComponents.Lvl = make_component('lvl',  "value")---@class Player.GemComponent---@param value  numberComponents.Gem = make_component('gem',  "value")---@class Player.AnyNameListenerComponent---@param value  callback[]Components.AnyNameListener = make_component('anyNameListener',  "value")---@class Player.NameListenerComponent---@param value  callback[]Components.NameListener = make_component('nameListener',  "value")return Components