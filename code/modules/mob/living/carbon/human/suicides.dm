/mob/living/carbon/human/proc/delayed_suicide()
	suicide_log()
	adjustBruteLoss(max(200 - getToxLoss() - getFireLoss() - getBruteLoss() - getOxyLoss(), 0))
	death(FALSE)
	ghostize(FALSE)	// Disallows reentering body and disassociates mind

/mob/living/carbon/human/proc/disarm_suicide()
	var/suicide_message = "[src] is ripping [ru_ego()] own arms off! It looks like [p_theyre()] trying to commit suicide." //heheh get it?
	visible_message(span_danger("[suicide_message]") , span_userdanger("[suicide_message]"))

	var/timer = 15
	for(var/obj/item/bodypart/thing in bodyparts)
		if(thing.body_part == ARM_LEFT || thing.body_part == ARM_RIGHT)
			addtimer(CALLBACK(thing, TYPE_PROC_REF(/obj/item/bodypart, dismember)), timer)
			addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), src, 'sound/effects/cartoon_pop.ogg', 70), timer)
			timer += 15
	addtimer(CALLBACK(src, TYPE_PROC_REF(/mob/living/carbon/human, delayed_suicide), FALSE), timer-10)
