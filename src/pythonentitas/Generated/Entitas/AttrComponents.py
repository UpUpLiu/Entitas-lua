from ...entitas.MakeComponents import namedtupleclass AttrComponents:    class ParseAttr:        _name = 'parseAttr'        _Name = 'ParseAttr'        def __init__(self, value):            self.value = value    class Dates:        _name = 'dates'        _Name = 'Dates'        def __init__(self, value):            self.value = value    class EventType:        _name = 'eventType'        _Name = 'EventType'        def __init__(self, value):            self.value = value    class HandleTogether:        _name = 'handleTogether'        _Name = 'HandleTogether'    class Component:        _name = 'component'        _Name = 'Component'        def __init__(self, value):            self.value = value    class Action:        _name = 'action'        _Name = 'Action'        def __init__(self, value):            self.value = value    class Priority:        _name = 'priority'        _Name = 'Priority'        def __init__(self, value):            self.value = value    class Context:        _name = 'context'        _Name = 'Context'        def __init__(self, data):            self.data = data    class Event:        _name = 'event'        _Name = 'Event'        def __init__(self, value):            self.value = value    class Name:        _name = 'name'        _Name = 'Name'        def __init__(self, value):            self.value = value