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
	ALL = 'ALL',
}

tag = {
	Component = 'Component',
	Context = 'Context',
	Attr = 'Attr'
}
local entitas = {
	namespace ="Entitas",
	source ="Common.entitas",
	output ="../",
    extension_path = "../Extension",
	component_path = ".",
	service_path = "../",
	context_index = "ContextIndex",
	parse = "lua",
	tag = tag
}

return entitas