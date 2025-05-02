local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_FIREDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_FIREAREA)
combat:setParameter(COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_FIRE)
combat:setArea(createCombatArea(AREA_CIRCLE3X3))

function onGetFormulaValues(player, level, maglevel)
	return -dmg * 0.5, -dmg * 1.5
end

combat:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

local rune = Spell("rune")

function rune.onCastSpell(creature, var, isHotkey)
	local position = var:getPosition()
	local tile = Tile(position)
	if tile then
		local corpse = tile:getTopDownItem()
		if corpse then
			local itemType = corpse:getType()
			if itemType:isCorpse() then
				local monsterName = corpse:getName()
				local monsterType = MonsterType(monsterName.sub(monsterName, 6)) -- remove "dead "
				dmg = monsterType:getHealth()
				corpse:remove()
				return combat:execute(creature, var)
			end
		end
	end
	creature:sendCancelMessage("something is wrong")
	creature:getPosition():sendMagicEffect(CONST_ME_POFF)
	return false
end

rune:id(78)
rune:group("attack")
rune:name("desintegrate rune")
rune:castSound(SOUND_EFFECT_TYPE_SPELL_OR_RUNE)
rune:impactSound(SOUND_EFFECT_TYPE_SPELL_GREAT_FIREBALL_RUNE)
rune:runeId(3197)
rune:allowFarUse(true)
rune:charges(3)
rune:level(21)
rune:magicLevel(4)
rune:cooldown(2 * 1000)
rune:groupCooldown(2 * 1000)
rune:isBlocking(false) -- True = Solid / False = Creature
rune:register()
