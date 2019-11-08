---@class Event
---@field eventTarget entitas.gen.EventTarget
---@field eventType entitas.gen.EventType
---@field priority number

---@class entitas.gen.EventTarget
EventTarget = {
	Any = 'Any',
	self = 'self'
}

---@class entitas.gen.EventType
EventType = {
	Added = 'Added',
	Removed = 'Removed',
}

tag = {
	Player = 'Player',
	Prop = 'Prop',
	Dress = 'Dress',
	User = 'User',
	PlayPlayer = 'PlayPlayer',
	Stage = 'Stage'
}
local entitas = {
	namespace ="Entitas",
	source ="Common.entitas",
	output ="../Common/Generated/entitas",
	parse = "lua",
	tag = tag
}

return entitas