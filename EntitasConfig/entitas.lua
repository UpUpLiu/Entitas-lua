---@class Event
---@field eventTarget entitas.gen.EventTarget
---@field eventType entitas.gen.EventType
---@field priority number

---@class entitas.gen.EventTarget
EventTarget = {
	Any = 'Any',
	Self = 'Self'
}

---@class entitas.gen.EventType
EventType = {
	ADDED = 'ADDED',
	REMOVED = 'REMOVED',
	ALL = 'ALL',
}

ExtensionTarget = {
	Context = "Context",
	Entity = "Entity",
}

AttrDefine = {
	Index = {
		attrList = {
			'index', 'primaryIndex', 'muIndex'
		},
		handleTogether = true
	},

	Event = {
	},

	SendMsg = {
	},
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
	service_path = "../src/Entitas",
	context_index = "ContextIndex",
	parse = "lua",
	tag = tag,
	AttrDefine = AttrDefine
}

return entitas