local portal = Spell("instant")

function portal.onCastSpell(player, variant)
    local position = player:getPosition()

    -- 1. Check if the player is in combat
    -- This prevents players from using it as an "emergency exit" during a fight
    if player:getCondition(CONDITION_INFIGHT) then
        player:sendCancelMessage("You cannot cast this spell while in combat!")
        position:sendMagicEffect(CONST_ME_POFF)
        return false -- Returning false prevents mana consumption and cooldown
    end

    -- 2. Get the player's home town
    local town = player:getTown()
    if not town then
        player:sendCancelMessage("You do not have a home town set.")
        position:sendMagicEffect(CONST_ME_POFF)
        return false
    end

    -- 3. Get the temple position
    local templePos = town:getTemplePosition()
    if not templePos then
        player:sendCancelMessage("Temple position not found.")
        return false
    end

    -- 4. Logic & Visuals
    -- Effect at current position
    position:sendMagicEffect(CONST_ME_TELEPORT)
    
    -- Teleport
    player:teleportTo(templePos)
    
    -- Effect at destination
    templePos:sendMagicEffect(CONST_ME_TELEPORT)
    player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You have been pulled back to " .. town:getName() .. ".")

    return true
end

portal:name("Town Portal")
portal:words("alani lux") -- magical words to trigger the spell
portal:group("support")
portal:id(1001) -- Unique ID
portal:level(7)
portal:mana(100) -- Significant mana cost for a teleport
portal:cooldown(60 * 1000) -- 1 minute cooldown (60,000ms)
portal:groupCooldown(2 * 1000)
portal:vocation("sorcerer;true", "master sorcerer;true", "druid;true", "elder druid;true", "paladin;true", "royal paladin;true", "knight;true", "elite knight;true")
portal:register()