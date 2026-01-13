local midasMirror = Action()

function midasMirror.onUse(player, item, fromPosition, target, toPosition, isHotkey)
    -- Canary uses 'target:isItem()' to check if the crosshair clicked an item
    if not target or not target:isItem() or Tile(toPosition) then
        player:sendCancelMessage("You can only use this on items.")
        return true
    end

    -- Prevent transmuting containers or yourself
    if target:isContainer() or target:isCreature() then
        player:sendCancelMessage("You cannot transmute this.")
        return true
    end

    -- The "Midas" Roll
    local chance = math.random(1, 1000)
    local targetPos = target:getPosition()
    
    -- Sound and Visual (Canary uses sendMagicEffect)
    targetPos:sendMagicEffect(CONST_ME_YELLOWENERGY)
    target:remove(1)

    -- Outcomes based on your odds
    if chance <= 125 then -- 0.125 (Regal)
        player:addItem(6549, 1) -- green powder
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "The mirror reflected a golden light! You gained a Regal Orb.")
    elseif chance <= 375 then -- 0.250 (Augmentation)
        player:addItem(6548, 1) -- purple powder
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "The mirror reflected a cold light. You gained an Augmentation Orb.")
    elseif chance <= 875 then -- 0.500 (Transmutation)
        player:addItem(6551, 1) -- blue powder
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "The mirror reflected a faint light. You gained a Transmutation Orb.")
    else -- 0.125 (Fail)
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "The mirror cracked. The item turned to dust.")
        targetPos:sendMagicEffect(CONST_ME_POFF)
    end

    return true
end

-- Register to the silver hand mirror ID
midasMirror:id(9596)
midasMirror:register()