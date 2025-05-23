local spell = Spell("instant")

function spell.onCastSpell(creature, variant)
	return creature:conjureItem(0, 3446, 5, CONST_ME_MAGIC_BLUE)
end

spell:name("Conjure Bolt")
spell:words("exevo con min")
spell:group("support")
spell:vocation("paladin;true", "royal paladin;true")
spell:castSound(SOUND_EFFECT_TYPE_SPELL_CONJURE_ARROW)
spell:id(79)
spell:cooldown(2 * 1000)
spell:groupCooldown(2 * 1000)
spell:level(17)
spell:mana(140)
spell:soul(2)
spell:isSelfTarget(true)
spell:isAggressive(false)
spell:isPremium(true)
spell:needLearn(false)
spell:register()
