local midasMirror = Action()

-- Weights out of 1000 rolls. They currently sum to 1000, so every use gives a reward;
-- if they ever sum to less, the remainder is the chance to destroy the item without one.
local rewards = {
	{ itemId = 6548, weight = 120 }, -- energy
	{ itemId = 6550, weight = 120 }, -- fire
	{ itemId = 6551, weight = 120 }, -- ice
	{ itemId = 6549, weight = 120 }, -- earth
	{ itemId = 6547, weight = 120 }, -- holy
	{ itemId = 21837, weight = 120 }, -- death
	{ itemId = 30188, weight = 80 }, -- health
	{ itemId = 30191, weight = 80 }, -- mana
	{ itemId = 30268, weight = 40 }, -- crit
	{ itemId = 30189, weight = 40 }, -- speed
	{ itemId = 30269, weight = 30 }, -- skill
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

local function describeItem(itemId)
	local itemType = ItemType(itemId)
	local article = itemType:getArticle()
	if article == "" then
		return itemType:getName()
	end
	return string.format("%s %s", article, itemType:getName())
end

function midasMirror.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	-- Only items carried by the player; Tile() resolves for map positions only
	if not target or not target:isItem() or Tile(toPosition) then
		player:sendCancelMessage("You can only use this on items.")
		return true
	end

	if target:isContainer() then
		player:sendCancelMessage("You cannot transmute this.")
		return true
	end

	local targetPos = target:getPosition()
	if not target:remove(1) then
		return true
	end
	targetPos:sendMagicEffect(CONST_ME_YELLOWENERGY)

	local rewardId = rollReward()
	if not rewardId then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "The mirror cracked. The item turned to dust.")
		targetPos:sendMagicEffect(CONST_ME_POFF)
		return true
	end

	player:addItem(rewardId, 1)
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format("The mirror reflected a light. You gained %s.", describeItem(rewardId)))
	return true
end

midasMirror:id(9596) -- squeezing gear of girlpower, used as the silver hand mirror
midasMirror:register()
