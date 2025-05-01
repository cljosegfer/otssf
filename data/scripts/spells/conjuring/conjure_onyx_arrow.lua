local spell = Spell("instant")

function spell.onCastSpell(creature, variant)
	return creature:conjureItem(0, 14251, 100, CONST_ME_MAGIC_BLUE) -- change arrow id
end

spell:name("Conjure Tarsal Arrow") -- change arrow name
spell:words("exevo con gran hur") -- change word
spell:group("support")
-- spell:vocation("paladin;true", "royal paladin;true")
spell:castSound(SOUND_EFFECT_TYPE_SPELL_CONJURE_ARROW)
-- spell:id(49) -- change spell id
spell:cooldown(2 * 1000)
spell:groupCooldown(2 * 1000)
spell:level(30)
spell:mana(390)
spell:soul(40)
spell:isSelfTarget(true)
spell:isAggressive(false)
spell:needLearn(false)
spell:register()
