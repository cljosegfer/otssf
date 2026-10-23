local pause = Spell("instant")

-- Toggles a personal protection zone: monsters drop and ignore you, you take no damage
-- and cannot attack, until you cast it again.
function pause.onCastSpell(player, variant)
	local position = player:getPosition()

	if player:isPaused() then
		player:setPaused(false)
		position:sendMagicEffect(CONST_ME_MAGIC_RED)
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You are no longer paused.")
	else
		player:setPaused(true)
		position:sendMagicEffect(CONST_ME_HOLYAREA)
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You are paused. Cast the spell again to resume.")
	end

	return true
end

pause:name("Pause")
pause:words("utamo pax")
pause:group("support")
pause:id(1002)
pause:level(1)
pause:mana(0)
pause:isAggressive(false) -- aggressive spells are blocked inside protection zones, which would prevent unpausing
pause:cooldown(2 * 1000)
pause:groupCooldown(0)
pause:vocation("sorcerer;true", "master sorcerer;true", "druid;true", "elder druid;true", "paladin;true", "royal paladin;true", "knight;true", "elite knight;true")
pause:register()
