local poeCraft = Action()

-- CONFIGURATION
local POWDERS = {
    [6551] = {slot = 0, name = "Transmutation"},
    [6548] = {slot = 1, name = "Augmentation"},
    [6549] = {slot = 2, name = "Regal"}
}

local CAT_DATA = {
    ELEMENTAL_DMG = {1, 4, 7, 10, 13}, -- Scorch, Venom, Frost, Electrify, Reap
    LIFE_LEECH    = {16}, 
    MANA_LEECH    = {19}, 
    CRIT          = {22},
    PROT_DEATH    = {25},
    PROT_EARTH    = {28},
    PROT_FIRE     = {31},
    PROT_ICE      = {34},
    PROT_ENERGY   = {37},
    PROT_HOLY     = {40},
    SPEED         = {43},
    AXE           = {46},
    SWORD         = {49},
    CLUB          = {52},
    SHIELDING     = {58},
    DISTANCE      = {55},
    MAGIC_LVL     = {61},
    CAPACITY      = {64}
}

-- HELPER: Flatten IDs into a single list for uniform probability
local function addIdsToPool(pool, ids)
    for _, id in ipairs(ids) do
        table.insert(pool, id)
    end
end

local function getValidPool(target)
    local it = target:getType()
    local wType = it:getWeaponType()
    local slotPos = it:getSlotPosition()
    -- local attack = it:getAttack()
    local pool = {}
    
    -- 1. WEAPONS
    if (wType > 0 and wType ~= WEAPON_SHIELD) then
        addIdsToPool(pool, CAT_DATA.ELEMENTAL_DMG)
        addIdsToPool(pool, CAT_DATA.LIFE_LEECH)
        addIdsToPool(pool, CAT_DATA.MANA_LEECH)
        addIdsToPool(pool, CAT_DATA.CRIT)
        if wType == WEAPON_SWORD then addIdsToPool(pool, CAT_DATA.SWORD)
        elseif wType == WEAPON_AXE then addIdsToPool(pool, CAT_DATA.AXE)
        elseif wType == WEAPON_CLUB then addIdsToPool(pool, CAT_DATA.CLUB)
        elseif wType == WEAPON_DISTANCE then addIdsToPool(pool, CAT_DATA.DISTANCE)
        elseif wType == WEAPON_WAND then addIdsToPool(pool, CAT_DATA.MAGIC_LVL) end
        return pool
    end

    -- 2. DEFENSIVE / UTILITY
    local isDefensive = (bit.band(slotPos, 1) ~= 0 or bit.band(slotPos, 4) ~= 0 or 
                         bit.band(slotPos, 32) ~= 0 or bit.band(slotPos, 64) ~= 0 or 
                         wType == WEAPON_SHIELD or it:isContainer())

    if isDefensive then
        addIdsToPool(pool, CAT_DATA.PROT_DEATH)
        addIdsToPool(pool, CAT_DATA.PROT_EARTH)
        addIdsToPool(pool, CAT_DATA.PROT_FIRE)
        addIdsToPool(pool, CAT_DATA.PROT_ICE)
        addIdsToPool(pool, CAT_DATA.PROT_ENERGY)
        addIdsToPool(pool, CAT_DATA.PROT_HOLY)
        addIdsToPool(pool, CAT_DATA.LIFE_LEECH)
        addIdsToPool(pool, CAT_DATA.MANA_LEECH)
        addIdsToPool(pool, CAT_DATA.MAGIC_LVL)
        addIdsToPool(pool, CAT_DATA.SHIELDING)
        if not (wType == WEAPON_SHIELD) then
            addIdsToPool(pool, CAT_DATA.AXE)
            addIdsToPool(pool, CAT_DATA.SWORD)
            addIdsToPool(pool, CAT_DATA.CLUB)
            addIdsToPool(pool, CAT_DATA.DISTANCE)
        end
        if bit.band(slotPos, 64) ~= 0 then addIdsToPool(pool, CAT_DATA.SPEED) end
        if it:isContainer() then addIdsToPool(pool, CAT_DATA.CAPACITY) end
    end
    
    return pool
end

function poeCraft.onUse(player, item, fromPosition, target, toPosition, isHotkey)
    if not target or not target:isItem() then
        player:sendCancelMessage("You can only use this on equipment.")
        return true
    end

    local totalSlots = target:getImbuementSlot()
    if totalSlots == 0 then
        player:sendCancelMessage("This item cannot be crafted.")
        return true
    end

    local currentMods = 0
    local nextSlot = -1
    for i = 0, totalSlots - 1 do
        local attr = target:getCustomAttribute(tostring(500 + i))
        if attr and attr ~= 0 then
            currentMods = currentMods + 1
        else
            if nextSlot == -1 then nextSlot = i end
        end
    end

    if nextSlot == -1 then
        player:sendCancelMessage("This item is already fully crafted.")
        return true
    end

    local requiredPowder = 0
    local orbName = ""
    if currentMods == 0 then requiredPowder = 6551 orbName = "Transmutation"
    elseif currentMods == 1 then requiredPowder = 6548 orbName = "Augmentation"
    elseif currentMods == 2 then requiredPowder = 6549 orbName = "Regal"
    end

    if requiredPowder == 0 or player:getItemCount(requiredPowder) == 0 then
        player:sendCancelMessage(string.format("You need %s Powder.", orbName))
        return true
    end

    local pool = getValidPool(target)
    if #pool == 0 then return true end

    -- NEW UNIFORM ROLL: Pick one ID from the entire flattened list
    local rolledBaseId = pool[math.random(#pool)]
    
    local tierChance = math.random(1, 100)
    local tierOffset = 0
    local tierName = "Basic"
    if tierChance == 100 then tierOffset = 2 tierName = "Powerful"
    elseif tierChance >= 91 then tierOffset = 1 tierName = "Intricate"
    end

    local finalId = rolledBaseId + tierOffset
    local duration = -1 
    local imbuBitmask = bit.bor(bit.lshift(duration, 8), finalId)
    
    player:removeItem(requiredPowder, 1)
    target:setCustomAttribute(tostring(500 + nextSlot), imbuBitmask)

    target:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
    player:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format("[%s] Craft Success: Applied %s modifier.", orbName, tierName))
    
    -- target:sendUpdateToClient()
    return true
end

poeCraft:id(9598) -- jeweler's kit
poeCraft:register()