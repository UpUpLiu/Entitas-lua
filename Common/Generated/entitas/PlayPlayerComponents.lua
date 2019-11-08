local make_component = require("Common.entitas.MakeComponent")local Components = {}---@class PlayPlayer.DestroyComponentComponents.Destroy = make_component('destroy')---@class PlayPlayer.WaistComponent---@param value  numberComponents.Waist = make_component('waist',  "value")---@class PlayPlayer.NecklaceComponent---@param value  numberComponents.Necklace = make_component('necklace',  "value")---@class PlayPlayer.HeadComponent---@param value  numberComponents.Head = make_component('head',  "value")---@class PlayPlayer.TopComponent---@param value  numberComponents.Top = make_component('top',  "value")---@class PlayPlayer.HairComponent---@param value  numberComponents.Hair = make_component('hair',  "value")---@class PlayPlayer.BagComponent---@param value  numberComponents.Bag = make_component('bag',  "value")---@class PlayPlayer.GlovesComponent---@param value  numberComponents.Gloves = make_component('gloves',  "value")---@class PlayPlayer.ShoeComponent---@param value  numberComponents.Shoe = make_component('shoe',  "value")---@class PlayPlayer.RighthandComponent---@param value  numberComponents.Righthand = make_component('righthand',  "value")---@class PlayPlayer.EarComponent---@param value  numberComponents.Ear = make_component('ear',  "value")---@class PlayPlayer.SocksComponent---@param value  numberComponents.Socks = make_component('socks',  "value")---@class PlayPlayer.SkillsComponent---@param values  number[]Components.Skills = make_component('skills',  "values")---@class PlayPlayer.StageIdComponent---@param value  numberComponents.StageId = make_component('stageId',  "value")---@class PlayPlayer.BraceletComponent---@param value  numberComponents.Bracelet = make_component('bracelet',  "value")---@class PlayPlayer.DressComponent---@param value  numberComponents.Dress = make_component('dress',  "value")---@class PlayPlayer.ShoulderComponent---@param value  numberComponents.Shoulder = make_component('shoulder',  "value")---@class PlayPlayer.SockdecoComponent---@param value  numberComponents.Sockdeco = make_component('sockdeco',  "value")---@class PlayPlayer.CoatComponent---@param value  numberComponents.Coat = make_component('coat',  "value")return Components