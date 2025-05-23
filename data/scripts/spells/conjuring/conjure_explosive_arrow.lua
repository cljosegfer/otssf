local spell = Spell("instant")

function spell.onCastSpell(creature, variant)
	return creature:conjureItem(0, 3449, 100, CONST_ME_MAGIC_BLUE)
end

spell:name("Conjure Explosive Arrow")
spell:words("exevo con grav")
spell:group("support")
-- spell:vocation("paladin;true", "royal paladin;true")
spell:castSound(SOUND_EFFECT_TYPE_SPELL_CONJURE_EXPLOSIVE_ARROW)
spell:id(49)
spell:cooldown(2 * 1000)
spell:groupCooldown(2 * 1000)
spell:level(25)
spell:mana(290)
spell:soul(30)
spell:isSelfTarget(true)
spell:isAggressive(false)
spell:needLearn(false)
spell:register()