from .Source import Context, Entity, PrimaryEntityIndex, EntityIndex, Matcherfrom .AttrComponents import AttrComponents as Attr_compsclass AttrGenerateEntity(Entity):    def __init__(self):        super().__init__()        self.event = None        self.priority = None        self.eventTarget = None        self.eventType = None        self.action = None        self.component = None        self.context = None        self.name = None        self.eventTypeGroupStr = None        self.handleTogether = None        self.generateCompName = None        self.parseAttr = None        self.dates = None        return    def hasEvent(self):        return self.has(Attr_comps.Event)    def addEvent (self, value):        self.add(Attr_comps.Event, value)        return self    def replaceEvent (self,value):        self.replace(Attr_comps.Event, value)        return self    def removeEvent (self):        self.remove(Attr_comps.Event)        return self    def hasPriority(self):        return self.has(Attr_comps.Priority)    def addPriority (self, value):        self.add(Attr_comps.Priority, value)        return self    def replacePriority (self,value):        self.replace(Attr_comps.Priority, value)        return self    def removePriority (self):        self.remove(Attr_comps.Priority)        return self    def hasEventTarget(self):        return self.has(Attr_comps.EventTarget)    def addEventTarget (self, value):        self.add(Attr_comps.EventTarget, value)        return self    def replaceEventTarget (self,value):        self.replace(Attr_comps.EventTarget, value)        return self    def removeEventTarget (self):        self.remove(Attr_comps.EventTarget)        return self    def hasEventType(self):        return self.has(Attr_comps.EventType)    def addEventType (self, value):        self.add(Attr_comps.EventType, value)        return self    def replaceEventType (self,value):        self.replace(Attr_comps.EventType, value)        return self    def removeEventType (self):        self.remove(Attr_comps.EventType)        return self    def hasAction(self):        return self.has(Attr_comps.Action)    def addAction (self, value):        self.add(Attr_comps.Action, value)        return self    def replaceAction (self,value):        self.replace(Attr_comps.Action, value)        return self    def removeAction (self):        self.remove(Attr_comps.Action)        return self    def hasComponent(self):        return self.has(Attr_comps.Component)    def addComponent (self, value):        self.add(Attr_comps.Component, value)        return self    def replaceComponent (self,value):        self.replace(Attr_comps.Component, value)        return self    def removeComponent (self):        self.remove(Attr_comps.Component)        return self    def hasContext(self):        return self.has(Attr_comps.Context)    def addContext (self, data):        self.add(Attr_comps.Context, data)        return self    def replaceContext (self,data):        self.replace(Attr_comps.Context, data)        return self    def removeContext (self):        self.remove(Attr_comps.Context)        return self    def hasName(self):        return self.has(Attr_comps.Name)    def addName (self, value):        self.add(Attr_comps.Name, value)        return self    def replaceName (self,value):        self.replace(Attr_comps.Name, value)        return self    def removeName (self):        self.remove(Attr_comps.Name)        return self    def hasEventTypeGroupStr(self):        return self.has(Attr_comps.EventTypeGroupStr)    def addEventTypeGroupStr (self, value):        self.add(Attr_comps.EventTypeGroupStr, value)        return self    def replaceEventTypeGroupStr (self,value):        self.replace(Attr_comps.EventTypeGroupStr, value)        return self    def removeEventTypeGroupStr (self):        self.remove(Attr_comps.EventTypeGroupStr)        return self    def hasHandleTogether(self):        return self.has(Attr_comps.HandleTogether)    def setHandleTogether(self, v):        if (v != self.hasHandleTogether()):            if (v):                self.add(Attr_comps.HandleTogether)            else:                self.remove(Attr_comps.HandleTogether)        return self    def hasGenerateCompName(self):        return self.has(Attr_comps.GenerateCompName)    def addGenerateCompName (self, name, Name):        self.add(Attr_comps.GenerateCompName, name, Name)        return self    def replaceGenerateCompName (self,name, Name):        self.replace(Attr_comps.GenerateCompName, name, Name)        return self    def removeGenerateCompName (self):        self.remove(Attr_comps.GenerateCompName)        return self    def hasParseAttr(self):        return self.has(Attr_comps.ParseAttr)    def addParseAttr (self, value):        self.add(Attr_comps.ParseAttr, value)        return self    def replaceParseAttr (self,value):        self.replace(Attr_comps.ParseAttr, value)        return self    def removeParseAttr (self):        self.remove(Attr_comps.ParseAttr)        return self    def hasDates(self):        return self.has(Attr_comps.Dates)    def addDates (self, value):        self.add(Attr_comps.Dates, value)        return self    def replaceDates (self,value):        self.replace(Attr_comps.Dates, value)        return self    def removeDates (self):        self.remove(Attr_comps.Dates)        return self