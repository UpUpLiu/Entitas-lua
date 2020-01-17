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
	ADDED = 'ADDED',
	REMOVED = 'REMOVED',
}

tag = {
	Component = 'Component',
	Context = 'Context',
	Attr = 'Attr'
}
local entitas = {
	namespace ="Entitas",
	source ="Common.entitas",
	output ="../Common/Generated/entitas",
	service_path = "../src/Entitas",
	context_index = "ContextIndex",
	parse = "lua",
	tag = tag
}

return entitas