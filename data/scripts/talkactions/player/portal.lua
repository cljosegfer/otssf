local portal = TalkAction("!portal")

function portal.onSay(player, words, param)
    -- 1. Check if the player is in combat
    -- In Canary, checking for the "In Fight" condition is the standard way
    if player:getCondition(CONDITION_INFIGHT) then
        player:sendCancelMessage("You cannot use the portal while in combat!")
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return true
    end

    -- 2. Get the player's home town
    local town = player:getTown()
    if not town then
        player:sendCancelMessage("You do not have a home town set.")
        return true
    end

    -- 3. Get the temple position
    local templePos = town:getTemplePosition()
    if not templePos then
        player:sendCancelMessage("Temple position not found for your town.")
        return true
    end

    -- 4. Visual effects (to make it feel like a modded "portal")
    -- Effect at current position before leaving
    player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
    
    -- Teleport the player
    player:teleportTo(templePos)
    
    -- Effect at destination
    templePos:sendMagicEffect(CONST_ME_TELEPORT)
    player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You have been pulled back to " .. town:getName() .. ".")

    return true
end

-- Set groupType to "normal" so everyone can use it
portal:groupType("normal")
portal:register()