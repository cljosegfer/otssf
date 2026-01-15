local spell = Spell("instant")

function spell.onCastSpell(player, variant)
    local steps = tonumber(variant:getString())
    
    -- Default to 1 step if no parameter or invalid parameter is provided
    if not steps or steps <= 0 then
        steps = 1
    end

    -- Cap the distance to avoid map errors
    local maxDistance = 7
    if steps > maxDistance then
        steps = maxDistance
    end

    local currentPos = player:getPosition()
    local direction = player:getDirection()
    
    -- Calculate destination based on direction and steps
    local destination = Position(currentPos)
    destination:getNextPosition(direction, steps)

    -- -- Use the GM '/a' logic to find the closest valid landing spot
    -- local targetPos = player:getClosestFreePosition(destination, true)
    local targetTile = Tile(destination)
    if not targetTile then
        player:sendCancelMessage("You cannot blink into the void.")
        currentPos:sendMagicEffect(CONST_ME_POFF)
        return false
    end

    if targetTile:hasProperty(CONST_PROP_BLOCKSOLID) then
        player:sendCancelMessage("That destination is solid rock.")
        currentPos:sendMagicEffect(CONST_ME_POFF)
        return false
    end

    -- -- Safety Check: Cannot teleport to an invalid position or across Z-axis
    -- if targetPos.x == 0 then
    --     player:sendCancelMessage(RETURNVALUE_NOTENOUGHROOM)
    --     currentPos:sendMagicEffect(CONST_ME_POFF)
    --     return false
    -- end

    -- -- Optional: Line of Sight check
    -- if not currentPos:isSightClear(targetPos) then
    --     player:sendCancelMessage("You cannot blink through that obstacle.")
    --     currentPos:sendMagicEffect(CONST_ME_POFF)
    --     return false
    -- end

    -- The 'true' parameter here is the 'pushFree' flag
    local success = player:teleportTo(destination, true)
    if not success then
        player:sendCancelMessage("The area is protected by a strong magical barrier.")
        currentPos:sendMagicEffect(CONST_ME_POFF)
        return false
    end

    -- Mana Cost Logic: 50 mana per tile traveled
    local totalManaCost = steps * 50
    if player:getMana() < totalManaCost then
        player:sendCancelMessage(RETURNVALUE_NOTENOUGHMANA)
        currentPos:sendMagicEffect(CONST_ME_POFF)
        return false
    end

    -- Deduct Mana
    player:addMana(-totalManaCost)
    player:addManaSpent(totalManaCost)

    -- Visual Effects (Start and End)
    currentPos:sendMagicEffect(CONST_ME_TELEPORT)
    
    -- Teleport the player
    -- player:teleportTo(targetPos)
    
    -- Visual Effect at arrival
    destination:sendMagicEffect(CONST_ME_TELEPORT)

    return true
end

spell:name("Blink")
spell:words("exani lux") -- Example: "exani lux 5"
spell:group("support")
spell:id(1000) -- Ensure this ID is unique in your spells
spell:level(7)
spell:mana(0) -- Mana is handled inside the script dynamically
spell:hasParams(true) -- Crucial to receive the number
spell:cooldown(2 * 1000)
spell:groupCooldown(2 * 1000)
spell:needLearn(false)
spell:vocation("sorcerer;true", "master sorcerer;true", "druid;true", "elder druid;true", "paladin;true", "royal paladin;true")
spell:register()