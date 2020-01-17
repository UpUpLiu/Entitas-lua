from pythonentitas.Generated.Entitas.AttrContext import AttrContext

if __name__ == "__main__":
    a = AttrContext()
    e = a.create_entity()
    e.activate(1)
    e.replaceAction(5)
    print(e.action.value)
    e.replaceAction(6)
    print(e.action.value)

