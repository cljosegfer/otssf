local midasMirror = Action()

-- Weights out of 1000 rolls. They currently sum to 1000, so every use gives a reward;
-- if they ever sum to less, the remainder is the chance to destroy the item without one.
local rewards = {
	{ itemId = 6548, weight = 80 }, -- energy
	{ itemId = 6550, weight = 80 }, -- fire
	{ itemId = 6551, weight = 80 }, -- ice
	{ itemId = 6549, weight = 80 }, -- earth
	{ itemId = 6547, weight = 80 }, -- holy
	{ itemId = 21837, weight = 80 }, -- death
	{ itemId = 30188, weight = 30 }, -- health
	{ itemId = 30191, weight = 30 }, -- mana
	{ itemId = 30268, weight = 20 }, -- crit
	{ itemId = 30189, weight = 20 }, -- speed
	{ itemId = 30269, weight = 10 }, -- skill
	{ itemId = 30187, weight = 9 }, -- intricate
	{ itemId = 22660, weight = 1 }, -- powerful
}

local function rollReward()
	local roll = math.random(1, 1000)
	for _, reward in ipairs(rewards) do
		if roll <= reward.weight then
			return reward.itemId
		end
		roll = roll - reward.weight
	end
	return nil
end

local blockedItems = {
	[ITEM_GOLD_COIN] = true,
	[ITEM_PLATINUM_COIN] = true,
	[ITEM_CRYSTAL_COIN] = true,
	[ITEM_STORE_COIN] = true,
}

function midasMirror.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	-- Only items carried by the player; Tile() resolves for map positions only
	if not target or not target:isItem() or Tile(toPosition) then
		player:sendCancelMessage("You can only use this on items.")
		return true
	end

	if target:isContainer() or blockedItems[target:getId()] then
		player:sendCancelMessage("You cannot transmute this.")
		return true
	end

	-- The whole stack is transmuted at once; it is removed before any reward is given
	local count = math.max(1, target:getCount())
	local targetPos = target:getPosition()
	if not target:remove(count) then
		return true
	end
	targetPos:sendMagicEffect(CONST_ME_YELLOWENERGY)

	local gained = {}
	local failed = 0
	for _ = 1, count do
		local rewardId = rollReward()
		if rewardId then
			gained[rewardId] = (gained[rewardId] or 0) + 1
		else
			failed = failed + 1
		end
	end

	-- addItem drops whatever does not fit (slots or capacity) at the player's feet
	local parts = {}
	local droppedOnFloor = false
	for _, reward in ipairs(rewards) do
		local amount = gained[reward.itemId]
		if amount then
			-- Stackable rewards can merge into an existing stack, which leaves the returned item without a parent,
			-- so compare what the player carries before and after instead of inspecting the returned items
			local carriedBefore = player:getItemCount(reward.itemId)
			player:addItem(reward.itemId, amount)
			if player:getItemCount(reward.itemId) - carriedBefore < amount then
				droppedOnFloor = true
			end
			parts[#parts + 1] = string.format("%dx %s", amount, ItemType(reward.itemId):getName())
		end
	end

	if failed > 0 then
		parts[#parts + 1] = string.format("%dx turned to dust", failed)
		targetPos:sendMagicEffect(CONST_ME_POFF)
	end

	local message = string.format("The mirror transmuted %d item%s: %s.", count, count == 1 and "" or "s", table.concat(parts, ", "))
	if droppedOnFloor then
		message = message .. " Some of it did not fit and was dropped at your feet."
	end
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, message)
	return true
end

midasMirror:id(9596) -- squeezing gear of girlpower, used as the silver hand mirror
midasMirror:register()
