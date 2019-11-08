local Player_comps = require('.PlayerComponents')local set = require('Common.container.set')---@class PlayerEntity---@field uid Player.UidComponent---@field lvl Player.LvlComponent---@field coin Player.CoinComponent---@field name Player.NameComponent---@field energy Player.EnergyComponent---@field gem Player.GemComponent---@field position Player.PositionComponent---@field asset Player.AssetComponent---@field exp Player.ExpComponent---@field anyNameListener Player.AnyNameListenerComponent---@field nameListener Player.NameListenerComponentlocal PlayerEntity = {}---@return booleanfunction PlayerEntity:hasUid()  return self:has(Player_comps.Uid) ~= nilend---@param value  long ---@returns PlayerEntityfunction PlayerEntity:addUid (value)    self:add(Player_comps.Uid, value)    return selfendfunction PlayerEntity:replaceUid (value)    self:replace(Player_comps.Uid, value)    return selfendfunction PlayerEntity:removeUid ()    self:remove(Player_comps.Uid)    return selfend---@return booleanfunction PlayerEntity:hasDestroy()  return self:has(Player_comps.Destroy) ~= nilend---@return PlayerEntityfunction PlayerEntity:setDestroy(v)    if (v ~= self:hasDestroy()) then        if (v) then            self:add(Player_comps.Destroy, true)        else            self:remove(Player_comps.Destroy)        end    end    return selfend---@return booleanfunction PlayerEntity:hasElement()  return self:has(Player_comps.Element) ~= nilend---@return PlayerEntityfunction PlayerEntity:setElement(v)    if (v ~= self:hasElement()) then        if (v) then            self:add(Player_comps.Element, true)        else            self:remove(Player_comps.Element)        end    end    return selfend---@return booleanfunction PlayerEntity:hasLvl()  return self:has(Player_comps.Lvl) ~= nilend---@param value  number---@returns PlayerEntityfunction PlayerEntity:addLvl (value)    self:add(Player_comps.Lvl, value)    return selfendfunction PlayerEntity:replaceLvl (value)    self:replace(Player_comps.Lvl, value)    return selfendfunction PlayerEntity:removeLvl ()    self:remove(Player_comps.Lvl)    return selfend---@return booleanfunction PlayerEntity:hasCoin()  return self:has(Player_comps.Coin) ~= nilend---@param value  number---@returns PlayerEntityfunction PlayerEntity:addCoin (value)    self:add(Player_comps.Coin, value)    return selfendfunction PlayerEntity:replaceCoin (value)    self:replace(Player_comps.Coin, value)    return selfendfunction PlayerEntity:removeCoin ()    self:remove(Player_comps.Coin)    return selfend---@return booleanfunction PlayerEntity:hasName()  return self:has(Player_comps.Name) ~= nilend---@param value  string ---@returns PlayerEntityfunction PlayerEntity:addName (value)    self:add(Player_comps.Name, value)    return selfendfunction PlayerEntity:replaceName (value)    self:replace(Player_comps.Name, value)    return selfendfunction PlayerEntity:removeName ()    self:remove(Player_comps.Name)    return selfend---@return booleanfunction PlayerEntity:hasEnergy()  return self:has(Player_comps.Energy) ~= nilend---@param value  number---@returns PlayerEntityfunction PlayerEntity:addEnergy (value)    self:add(Player_comps.Energy, value)    return selfendfunction PlayerEntity:replaceEnergy (value)    self:replace(Player_comps.Energy, value)    return selfendfunction PlayerEntity:removeEnergy ()    self:remove(Player_comps.Energy)    return selfend---@return booleanfunction PlayerEntity:hasGem()  return self:has(Player_comps.Gem) ~= nilend---@param value  number---@returns PlayerEntityfunction PlayerEntity:addGem (value)    self:add(Player_comps.Gem, value)    return selfendfunction PlayerEntity:replaceGem (value)    self:replace(Player_comps.Gem, value)    return selfendfunction PlayerEntity:removeGem ()    self:remove(Player_comps.Gem)    return selfend---@return booleanfunction PlayerEntity:hasPosition()  return self:has(Player_comps.Position) ~= nilend---@param value  Vector3---@returns PlayerEntityfunction PlayerEntity:addPosition (value)    self:add(Player_comps.Position, value)    return selfendfunction PlayerEntity:replacePosition (value)    self:replace(Player_comps.Position, value)    return selfendfunction PlayerEntity:removePosition ()    self:remove(Player_comps.Position)    return selfend---@return booleanfunction PlayerEntity:hasAsset()  return self:has(Player_comps.Asset) ~= nilend---@param value  number---@returns PlayerEntityfunction PlayerEntity:addAsset (value)    self:add(Player_comps.Asset, value)    return selfendfunction PlayerEntity:replaceAsset (value)    self:replace(Player_comps.Asset, value)    return selfendfunction PlayerEntity:removeAsset ()    self:remove(Player_comps.Asset)    return selfend---@return booleanfunction PlayerEntity:hasExp()  return self:has(Player_comps.Exp) ~= nilend---@param value  number---@returns PlayerEntityfunction PlayerEntity:addExp (value)    self:add(Player_comps.Exp, value)    return selfendfunction PlayerEntity:replaceExp (value)    self:replace(Player_comps.Exp, value)    return selfendfunction PlayerEntity:removeExp ()    self:remove(Player_comps.Exp)    return selfend---@return booleanfunction PlayerEntity:hasAnyNameListener()  return self:has(Player_comps.AnyNameListener) ~= nilend---@param value  callback[]---@returns PlayerEntityfunction PlayerEntity:addAnyNameListener (value)    self:add(Player_comps.AnyNameListener, value)    return selfendfunction PlayerEntity:replaceAnyNameListener (value)    self:replace(Player_comps.AnyNameListener, value)    return selfendfunction PlayerEntity:removeAnyNameListener ()    self:remove(Player_comps.AnyNameListener)    return selfend---@return booleanfunction PlayerEntity:hasNameListener()  return self:has(Player_comps.NameListener) ~= nilend---@param value  callback[]---@returns PlayerEntityfunction PlayerEntity:addNameListener (value)    self:add(Player_comps.NameListener, value)    return selfendfunction PlayerEntity:replaceNameListener (value)    self:replace(Player_comps.NameListener, value)    return selfendfunction PlayerEntity:removeNameListener ()    self:remove(Player_comps.NameListener)    return selfend        function PlayerEntity:AddAnyNameListenerCallBack(callback)    local list    if not self:hasAnyNameListener() then        list = set.new(false)    else        list = self.anyNameListener.value    end    list:insert(callback)    self:replaceAnyNameListener(list)endfunction PlayerEntity:RemoveAnyNameListenerCallBack(callback, removeComponentWhenEmpty)    if removeComponentWhenEmpty == nil then        removeComponentWhenEmpty = true    end    local listeners = self.anyNameListener.value    listeners:remove(callback)    if removeComponentWhenEmpty and listeners:size() == 0 then        self:removeAnyNameListener()    else        self:replaceAnyNameListener(listeners)    endend        function PlayerEntity:AddNameListenerCallBack(callback)    local list    if not self:hasNameListener() then        list = set.new(false)    else        list = self.nameListener.value    end    list:insert(callback)    self:replaceNameListener(list)endfunction PlayerEntity:RemoveNameListenerCallBack(callback, removeComponentWhenEmpty)    if removeComponentWhenEmpty == nil then        removeComponentWhenEmpty = true    end    local listeners = self.nameListener.value    listeners:remove(callback)    if removeComponentWhenEmpty and listeners:size() == 0 then        self:removeNameListener()    else        self:replaceNameListener(listeners)    endendreturn PlayerEntity