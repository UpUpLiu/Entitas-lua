local Stage_comps = require('.StageComponents')local Matcher = require('Common.entitas.Matcher')----------------------------Matcher     start----------------------------------------------@class StageMatcher---@field Destroy  entitas.Matcher---@field Type_id  entitas.Matcher---@field Source  entitas.Matcher---@field Appraise  entitas.Matcher---@field Config  entitas.Matcher---@field Num  entitas.Matcherlocal StageMatcher = {}StageMatcher.Destroy = Matcher({Stage_comps.Destroy})StageMatcher.Type_id = Matcher({Stage_comps.Type_id})StageMatcher.Source = Matcher({Stage_comps.Source})StageMatcher.Appraise = Matcher({Stage_comps.Appraise})StageMatcher.Config = Matcher({Stage_comps.Config})StageMatcher.Num = Matcher({Stage_comps.Num})----------------------------Matcher     end---------------------------------------------return StageMatcher