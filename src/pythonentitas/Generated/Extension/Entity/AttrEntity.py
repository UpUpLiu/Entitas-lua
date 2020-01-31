
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
            ret_str = ""
            if self.eventType.value == 'ADDED':
                ret_str = 'GroupEvent.ADDED'
            elif self.eventType.value == "REMOVED":
                ret_str = 'GroupEvent.REMOVED'
            elif self.eventType.value == "ALL":
                ret_str = 'GroupEvent.ADDED | GroupEvent.REMOVED'
            self.replaceEventTypeGroupStr(ret_str)

        self.replaceDates(data)
        return

    def get_event_target_is_self(self):
        if self.hasEventTarget() and self.eventTarget.value == "Self":
            return True
        return False

    def get_attr_system_name(self):

        return