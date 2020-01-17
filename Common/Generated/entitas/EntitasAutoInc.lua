require("Common.base.import")require("Common.entitas.entitas")Components = {}class(require(".DressEntity"),'DressEntity',classMap.Entity)class(require(".DressMatchers"),'DressMatchers',classMap.Matchers)Components.Dress = require(".DressComponents")class(require(".DressContext"),'DressContext',classMap.Context)require('.DressType_idSendEventSystem')require('.DressIndex')class(require(".PlayPlayerEntity"),'PlayPlayerEntity',classMap.Entity)class(require(".PlayPlayerMatchers"),'PlayPlayerMatchers',classMap.Matchers)Components.PlayPlayer = require(".PlayPlayerComponents")class(require(".PlayPlayerContext"),'PlayPlayerContext',classMap.Context)require('.PlayPlayerIndex')class(require(".PlayerEntity"),'PlayerEntity',classMap.Entity)class(require(".PlayerMatchers"),'PlayerMatchers',classMap.Matchers)Components.Player = require(".PlayerComponents")class(require(".PlayerContext"),'PlayerContext',classMap.Context)require('.PlayerIndex')class(require(".PropEntity"),'PropEntity',classMap.Entity)class(require(".PropMatchers"),'PropMatchers',classMap.Matchers)Components.Prop = require(".PropComponents")class(require(".PropContext"),'PropContext',classMap.Context)require('.PropIndex')class(require(".StageEntity"),'StageEntity',classMap.Entity)class(require(".StageMatchers"),'StageMatchers',classMap.Matchers)Components.Stage = require(".StageComponents")class(require(".StageContext"),'StageContext',classMap.Context)require('.StageIndex')class(require(".UserEntity"),'UserEntity',classMap.Entity)class(require(".UserMatchers"),'UserMatchers',classMap.Matchers)Components.User = require(".UserComponents")class(require(".UserContext"),'UserContext',classMap.Context)require('.UserIndex')---@class Contexts---@field dress DressContext---@field playPlayer PlayPlayerContext---@field player PlayerContext---@field prop PropContext---@field stage StageContext---@field user UserContextlocal Contextsreturn function()    Contexts = {}    Contexts.Dress = classMap.DressContext:new(classMap.DressEntity)    Contexts.Dress:initGenerateEntityIndexes()    Contexts.PlayPlayer = classMap.PlayPlayerContext:new(classMap.PlayPlayerEntity)    Contexts.PlayPlayer:initGenerateEntityIndexes()    Contexts.Player = classMap.PlayerContext:new(classMap.PlayerEntity)    Contexts.Player:initGenerateEntityIndexes()    Contexts.Prop = classMap.PropContext:new(classMap.PropEntity)    Contexts.Prop:initGenerateEntityIndexes()    Contexts.Stage = classMap.StageContext:new(classMap.StageEntity)    Contexts.Stage:initGenerateEntityIndexes()    Contexts.User = classMap.UserContext:new(classMap.UserEntity)    Contexts.User:initGenerateEntityIndexes()    return Contextsend