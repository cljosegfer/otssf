local doorIds = {}
for index, value in ipairs(LevelDoorTable) do
	if not table.contains(doorIds, value.openDoor) then
		table.insert(doorIds, value.openDoor)
	end

	if not table.contains(doorIds, value.closedDoor) then
		table.insert(doorIds, value.closedDoor)
	end
end

local levelDoor = Action()
function levelDoor.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	for index, value in ipairs(LevelDoorTable) do
		if value.closedDoor == item.itemid then
			-- Standard Tibia logic: ActionID 1000 = Level 0, 1100 = Level 100
			local requiredLevel = item.actionid - 1000

			if item.actionid > 0 and player:getLevel() >= requiredLevel then
				item:transform(value.openDoor)
				item:getPosition():sendSingleSoundEffect(SOUND_EFFECT_TYPE_ACTION_OPEN_DOOR)
				player:teleportTo(toPosition, true)
				return true
			else
				-- If the ActionID is valid, show the level. Otherwise, show generic message.
				if requiredLevel > 0 then
					player:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format("Only the worthy of level %d or higher may pass.", requiredLevel))
				else
					player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Only the worthy may pass.")
				end
				return true
			end
		end
	end

	if Creature.checkCreatureInsideDoor(player, toPosition) then
		return true
	end
	return true
end

for index, value in ipairs(doorIds) do
	levelDoor:id(value)
end

levelDoor:register()