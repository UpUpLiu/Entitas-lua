local make_component = require("Common.entitas.MakeComponent")local Components = {}---@class PlayPlayer.DestroyComponentComponents.Destroy = make_component('destroy')---@class PlayPlayer.RighthandComponent---@field value  numberComponents.Righthand = make_component('righthand',  "value")---@class PlayPlayer.SockdecoComponent---@field value  numberComponents.Sockdeco = make_component('sockdeco',  "value")---@class PlayPlayer.EarComponent---@field value  numberComponents.Ear = make_component('ear',  "value")---@class PlayPlayer.GlovesComponent---@field value  numberComponents.Gloves = make_component('gloves',  "value")---@class PlayPlayer.TopComponent---@field value  numberComponents.Top = make_component('top',  "value")---@class PlayPlayer.ShoeComponent---@field value  numberComponents.Shoe = make_component('shoe',  "value")---@class PlayPlayer.BagComponent---@field value  numberComponents.Bag = make_component('bag',  "value")---@class PlayPlayer.BraceletComponent---@field value  numberComponents.Bracelet = make_component('bracelet',  "value")---@class PlayPlayer.CoatComponent---@field value  numberComponents.Coat = make_component('coat',  "value")---@class PlayPlayer.WaistComponent---@field value  numberComponents.Waist = make_component('waist',  "value")---@class PlayPlayer.StageIdComponent---@field value  numberComponents.StageId = make_component('stageId',  "value")---@class PlayPlayer.ShoulderComponent---@field value  numberComponents.Shoulder = make_component('shoulder',  "value")---@class PlayPlayer.SocksComponent---@field value  numberComponents.Socks = make_component('socks',  "value")---@class PlayPlayer.SkillsComponent---@field values  number[]Components.Skills = make_component('skills',  "values")---@class PlayPlayer.HairComponent---@field value  numberComponents.Hair = make_component('hair',  "value")---@class PlayPlayer.NecklaceComponent---@field value  numberComponents.Necklace = make_component('necklace',  "value")---@class PlayPlayer.HeadComponent---@field value  numberComponents.Head = make_component('head',  "value")---@class PlayPlayer.DressComponent---@field value  numberComponents.Dress = make_component('dress',  "value")return Components