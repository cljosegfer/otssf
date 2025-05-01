local spell = Spell("instant")

function spell.onCastSpell(creature, variant)
	return creature:conjureItem(0, 7365, 100, CONST_ME_MAGIC_BLUE) -- change arrow id
end

spell:name("Conjure Onyx Arrow") -- change arrow name
spell:words("exevo con mas hur") -- change word
spell:group("support")
-- spell:vocation("paladin;true", "royal paladin;true")
spell:castSound(SOUND_EFFECT_TYPE_SPELL_CONJURE_ARROW)
-- spell:id(49) -- change spell id
spell:cooldown(2 * 1000)
spell:groupCooldown(2 * 1000)
spell:level(40)
spell:mana(490)
spell:soul(50)
spell:isSelfTarget(true)
spell:isAggressive(false)
spell:needLearn(false)
spell:register()
