---@class Bag
local Bag = {}
Bag.__index = Bag
function Bag.new(...)
    local tb = setmetatable({},Bag)
    tb:ctor(...)
    return tb
end

function Bag:ctor(capacity)
    self.size_ = 0
    self.length = capacity
end


function Bag:removeAt(index)
    local e = self[index];
    self[index] = self[self.size_]
    self[self.size_] = nil
    self.size_ = self.size_ - 1
    return e
end


function Bag:remove(e)
    local i
    local e2
    local size = self.size_

    for i = 1, size do
        e2 = self[i]
        if (e == e2) then
            self[i] = self[self.size_]
            self[self.size_] = nil
            self.size_ = self.size_ - 1
            return true
        end
    end



    return false
end



function Bag:removeLast()
    if (self.size_ > 0) then
        local e = self[self.size_]
        self[self.size_] = nil
        self.size_ = self.size_ - 1
        return e
    end
    return nil
end

function Bag:contains(e)
    for i = 1, self.size_ do
        if (e == self[i]) then
            return true

        end
        return false

    end
end


function Bag:removeAll(bag)
    local modified= false
    local l = bag:size()
    local e1
    local e2

    for i = 1, l do
        e1 = bag:get(i)

        for j = 1, self.size_ do
            e2 = self[j]

            if (e1 == e2) then
                self:removeAt(j)
                j = j - 1
                modified = true
                break

            end

        end

    end

    return modified
end


function Bag:get(index)
    if (index >= self.length) then
        error('ArrayIndexOutOfBoundsException')
    end
    return self[index]

end

function Bag:safeGet(index)
    if (index >= self.length) then
        self:grow((index * 7) / 4 + 1)
    end
    return self[index]

end

function Bag:size()
    return self.size_

end

function Bag:getCapacity()
    return self.length
end



function Bag:isEmpty()
    return self.size_ == 0

end


function Bag:add(e)
    -- is size greater than capacity increase capacity
    if (self.size_ == self.length) then
        self:grow()
    end
    self.size_ = self.size_ + 1
    self[self.size_] = e
end


function Bag:set(index, e)
    if (index >= self.length) then
        self:grow(index * 2)
    end
    self.size_ = index + 1
    self[index] = e

end

function Bag:grow(newCapacity)
    newCapacity = newCapacity or ~~((self.length * 3) / 2) + 1
    self.length = ~~newCapacity
end

function Bag:ensureCapacity(index)
    if (index >= self.length) then
        self:grow(index * 2)

    end

end

function Bag:clear()
    local i
    local size
    -- nil all elements so gc can clean up
    for i = 1, self.size_ do
        self[i] = nil
    end

    self.size_ = 0

end


function Bag:addAll(items)
    local i
    local len = items:size()
    for i = 1, len do
        self:add(items:get(i))
    end
end

return Bag