local PlayPlayer_comps = require('.PlayPlayerComponents')local Matcher = require('Common.entitas.Matcher')----------------------------Matcher     start----------------------------------------------@class PlayPlayerMatcher---@field Destroy  entitas.Matcher---@field Righthand  entitas.Matcher---@field Shoulder  entitas.Matcher---@field Top  entitas.Matcher---@field Bracelet  entitas.Matcher---@field Socks  entitas.Matcher---@field Dress  entitas.Matcher---@field Hair  entitas.Matcher---@field Gloves  entitas.Matcher---@field Shoe  entitas.Matcher---@field Coat  entitas.Matcher---@field Waist  entitas.Matcher---@field StageId  entitas.Matcher---@field Skills  entitas.Matcher---@field Head  entitas.Matcher---@field Bag  entitas.Matcher---@field Necklace  entitas.Matcher---@field Ear  entitas.Matcher---@field Sockdeco  entitas.Matcherlocal PlayPlayerMatcher = {}PlayPlayerMatcher.Destroy = Matcher({PlayPlayer_comps.Destroy})PlayPlayerMatcher.Righthand = Matcher({PlayPlayer_comps.Righthand})PlayPlayerMatcher.Shoulder = Matcher({PlayPlayer_comps.Shoulder})PlayPlayerMatcher.Top = Matcher({PlayPlayer_comps.Top})PlayPlayerMatcher.Bracelet = Matcher({PlayPlayer_comps.Bracelet})PlayPlayerMatcher.Socks = Matcher({PlayPlayer_comps.Socks})PlayPlayerMatcher.Dress = Matcher({PlayPlayer_comps.Dress})PlayPlayerMatcher.Hair = Matcher({PlayPlayer_comps.Hair})PlayPlayerMatcher.Gloves = Matcher({PlayPlayer_comps.Gloves})PlayPlayerMatcher.Shoe = Matcher({PlayPlayer_comps.Shoe})PlayPlayerMatcher.Coat = Matcher({PlayPlayer_comps.Coat})PlayPlayerMatcher.Waist = Matcher({PlayPlayer_comps.Waist})PlayPlayerMatcher.StageId = Matcher({PlayPlayer_comps.StageId})PlayPlayerMatcher.Skills = Matcher({PlayPlayer_comps.Skills})PlayPlayerMatcher.Head = Matcher({PlayPlayer_comps.Head})PlayPlayerMatcher.Bag = Matcher({PlayPlayer_comps.Bag})PlayPlayerMatcher.Necklace = Matcher({PlayPlayer_comps.Necklace})PlayPlayerMatcher.Ear = Matcher({PlayPlayer_comps.Ear})PlayPlayerMatcher.Sockdeco = Matcher({PlayPlayer_comps.Sockdeco})----------------------------Matcher     end---------------------------------------------return PlayPlayerMatcher