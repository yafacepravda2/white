/datum/action/cooldown/spell/charge
	name = "Charge"
	desc = "This spell can be used to recharge a variety of things in your hands, \
		from magical artifacts to electrical components. A creative wizard can even use it \
		to grant magical power to a fellow magic user."
	button_icon_state = "charge"

	sound = 'sound/magic/charge.ogg'
	school = SCHOOL_TRANSMUTATION
	cooldown_time = 60 SECONDS
	cooldown_reduction_per_rank = 5 SECONDS

	invocation = "DIRI CEL"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC

/datum/action/cooldown/spell/charge/is_valid_target(atom/cast_on)
	return isliving(cast_on)

/datum/action/cooldown/spell/charge/cast(mob/living/cast_on)
	. = ..()

	// Charge people we're pulling first and foremost
	if(isliving(cast_on.pulling))
		var/mob/living/pulled_living = cast_on.pulling
		var/pulled_has_spells = FALSE

		for(var/datum/action/cooldown/spell/spell in pulled_living.actions)
			spell.reset_spell_cooldown()
			pulled_has_spells = TRUE

		if(pulled_has_spells)
			to_chat(pulled_living, "<span class='notice'>You feel raw magic flowing through you. It feels good!</span>")
			to_chat(cast_on, "<span class='notice'>[pulled_living] suddenly feels very warm!</span>")
			return

		to_chat(pulled_living, "<span class='notice'>You feel very strange for a moment, but then it passes.</span>")

	// Then charge their main hand item, then charge their offhand item
	var/obj/item/to_charge = cast_on.get_active_held_item() || cast_on.get_inactive_held_item()
	if(!to_charge)
		to_chat(cast_on, "<span class='notice'>You feel magical power surging through your hands, but the feeling rapidly fades.</span>")
		return

	var/charge_return = SEND_SIGNAL(to_charge, COMSIG_ITEM_MAGICALLY_CHARGED, src, cast_on)

	if(QDELETED(to_charge))
		to_chat(cast_on, "<span class='warning'>[src] seems to react adversely with [to_charge]!</span>")
		return

	if(charge_return & COMPONENT_ITEM_BURNT_OUT)
		to_chat(cast_on, "<span class='warning'>[to_charge] seems to react negatively to [src], becoming uncomfortably warm!</span>")

	else if(charge_return & COMPONENT_ITEM_CHARGED)
		to_chat(cast_on, "<span class='notice'>[to_charge] suddenly feels very warm!</span>")

	else
		to_chat(cast_on, "<span class='notice'>[to_charge] doesn't seem to be react to [src].</span>")
