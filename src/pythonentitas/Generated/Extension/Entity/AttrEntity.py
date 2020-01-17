
from pythonentitas.Generated.Entitas.AttrEntity import AttrEntity as Entity
class AttrEntity(Entity):
    def __init__(self):
        super().__init__()


    def get_group_event_out_str(self):
        if self.hasEventType():
            if self.eventType.value == 'ADDED':
                return 'GroupEvent.ADDED'
            elif self.eventType.value == "REMOVED":
                return 'GroupEvent.REMOVED'
            elif self.eventType.value == "ALL":
                return 'GroupEvent.ADDED | GroupEvent.REMOVED'
        return ''

    def set_attr_data(self, data):
        if self.name.value == 'SendMsg':
            self.replaceEventType(data)
        self.replaceDates(data)
        return