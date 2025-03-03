/datum/surgery_step
	var/name
	var/list/implements = list()	//format is path = probability of success. alternatively
	var/implement_type = null		//the current type of implement used. This has to be stored, as the actual typepath of the tool may not match the list type.
	var/accept_hand = FALSE				//does the surgery step require an open hand? If true, ignores implements. Compatible with accept_any_item.
	var/accept_any_item = FALSE			//does the surgery step accept any item? If true, ignores implements. Compatible with require_hand.
	var/time = 10					//how long does the step take?
	var/repeatable = FALSE				//can this step be repeated? Make shure it isn't last step, or it used in surgery with `can_cancel = 1`. Or surgion will be stuck in the loop
	var/list/chems_needed = list()  //list of chems needed to complete the step. Even on success, the step will have no effect if there aren't the chems required in the mob.
	var/require_all_chems = TRUE    //any on the list or all on the list?
	var/silicons_obey_prob = FALSE

/datum/surgery_step/proc/try_op(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery, try_to_fail = FALSE)
	var/success = FALSE
	if(accept_hand)
		if(!tool)
			success = TRUE
		if(iscyborg(user))
			success = TRUE

	if(accept_any_item)
		if(tool && tool_check(user, tool))
			success = TRUE

	else if(tool)
		for(var/key in implements)
			var/match = FALSE

			if(ispath(key) && istype(tool, key))
				match = TRUE
			else if(tool.tool_behaviour == key)
				match = TRUE

			if(match)
				implement_type = key
				if(tool_check(user, tool))
					success = TRUE
					break

	if(success)
		if(target_zone == surgery.location)
			if(get_location_accessible(target, target_zone) || surgery.ignore_clothes)
				initiate(user, target, target_zone, tool, surgery, try_to_fail)
			else
				to_chat(user, span_warning("Мне нужно иметь доступ к [parse_zone(target_zone)] <b>[skloname(target.name, DATELNI, target.gender)]</b> для проведения хирургической операции!"))
			return TRUE	//returns TRUE so we don't stab the guy in the dick or wherever.

	if(repeatable)
		var/datum/surgery_step/next_step = surgery.get_surgery_next_step()
		if(next_step)
			surgery.status++
			if(next_step.try_op(user, target, user.zone_selected, user.get_active_held_item(), surgery))
				return TRUE
			else
				surgery.status--

	return FALSE

#define SURGERY_SLOWDOWN_CAP_MULTIPLIER 2 //increase to make surgery slower but fail less, and decrease to make surgery faster but fail more

/datum/surgery_step/proc/initiate(mob/living/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery, try_to_fail = FALSE)
	// Only followers of Asclepius have the ability to use Healing Touch and perform miracle feats of surgery.
	// Prevents people from performing multiple simultaneous surgeries unless they're holding a Rod of Asclepius.

	surgery.step_in_progress = TRUE
	var/speed_mod = 1
	var/fail_prob = 0//100 - fail_prob = success_prob
	var/advance = FALSE

	if(preop(user, target, target_zone, tool, surgery) == -1)
		surgery.step_in_progress = FALSE
		return FALSE

	if(tool)
		speed_mod = tool.toolspeed

	if(user.mind)
		speed_mod = speed_mod * user.mind.get_skill_modifier(/datum/skill/surgery, SKILL_SPEED_MODIFIER)

	var/implement_speed_mod = 1
	if(implement_type)	//this means it isn't a require hand or any item step.
		implement_speed_mod = implements[implement_type] / 100.0

	speed_mod /= (get_location_modifier(target) * (1 + surgery.speed_modifier) * implement_speed_mod) * target.mob_surgery_speed_mod
	var/modded_time = time * speed_mod


	fail_prob = min(max(0, modded_time - (time * SURGERY_SLOWDOWN_CAP_MULTIPLIER)),99)//if modded_time > time * modifier, then fail_prob = modded_time - time*modifier. starts at 0, caps at 99
	modded_time = min(modded_time, time * SURGERY_SLOWDOWN_CAP_MULTIPLIER)//also if that, then cap modded_time at time*modifier

	if(iscyborg(user))//any immunities to surgery slowdown should go in this check.
		modded_time = time

	var/was_sleeping = (target.stat != DEAD && target.IsSleeping())

	if(do_after(user, modded_time, target = target, interaction_key = user.has_status_effect(STATUS_EFFECT_HIPPOCRATIC_OATH) ? target : DOAFTER_SOURCE_SURGERY)) //If we have the hippocratic oath, we can perform one surgery on each target, otherwise we can only do one surgery in total.

		var/chem_check_result = chem_check(target)
		if((prob(100-fail_prob) || (iscyborg(user) && !silicons_obey_prob)) && chem_check_result && !try_to_fail)

			if(success(user, target, target_zone, tool, surgery))
				if(user.mind)
					var/total_experience_gain = 10 + fail_prob
					if(repeatable)
						total_experience_gain *= 0.5
					user.mind.adjust_experience(/datum/skill/surgery, total_experience_gain)
				advance = TRUE
		else
			if(failure(user, target, target_zone, tool, surgery, fail_prob))
				advance = TRUE
			if(chem_check_result)
				return .(user, target, target_zone, tool, surgery, try_to_fail) //automatically re-attempt if failed for reason other than lack of required chemical
		if(advance && !repeatable)
			surgery.status++
			if(surgery.status > surgery.steps.len)
				surgery.complete()

	if(target.stat == DEAD && was_sleeping && user.client)
		user.client.give_award(/datum/award/achievement/misc/sandman, user)

	surgery.step_in_progress = FALSE
	return advance

/datum/surgery_step/proc/preop(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, span_notice("Начинаю выполнять операцию на <b>[skloname(target.name, PREDLOZHNI, target.gender)]</b>...") ,
		span_notice("<b>[user]</b> начинает выполнять операцию на <b>[skloname(target.name, PREDLOZHNI, target.gender)]</b>.") ,
		span_notice("<b>[user]</b> начинает выполнять операцию на <b>[skloname(target.name, PREDLOZHNI, target.gender)]</b>."))

/datum/surgery_step/proc/success(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = TRUE)
	if(default_display_results)
		display_results(user, target, span_notice("Успех.") ,
				span_notice("<b>[user]</b> имеет успех!") ,
				span_notice("<b>[user]</b> заканчивает."))
	return TRUE

/datum/surgery_step/proc/failure(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery, fail_prob = 0)
	var/screwedmessage = ""
	switch(fail_prob)
		if(0 to 24)
			screwedmessage = " Почти получилось."
		if(50 to 74)//25 to 49 = no extra text
			screwedmessage = " Будет сложновато в данных условиях..."
		if(75 to 99)
			screwedmessage = " Это практически невозможно в данных условиях..."

	display_results(user, target, span_warning("Не вышло![screwedmessage]") ,
		span_warning("<b>[user]</b> делает неправильно!") ,
		span_notice("<b>[user]</b> заканчивает.") , TRUE) //By default the patient will notice if the wrong thing has been cut
	return FALSE

/datum/surgery_step/proc/tool_check(mob/user, obj/item/tool)
	return TRUE

/datum/surgery_step/proc/chem_check(mob/living/target)
	if(!LAZYLEN(chems_needed))
		return TRUE

	if(require_all_chems)
		. = TRUE
		for(var/R in chems_needed)
			if(!target.reagents.has_reagent(R))
				return FALSE
	else
		. = FALSE
		for(var/R in chems_needed)
			if(target.reagents.has_reagent(R))
				return TRUE

/datum/surgery_step/proc/get_chem_list()
	if(!LAZYLEN(chems_needed))
		return
	var/list/chems = list()
	for(var/R in chems_needed)
		var/datum/reagent/temp = GLOB.chemical_reagents_list[R]
		if(temp)
			var/chemname = temp.name
			chems += chemname
	return english_list(chems, and_text = require_all_chems ? " и " : " или ")

//Replaces visible_message during operations so only people looking over the surgeon can see them.
/datum/surgery_step/proc/display_results(mob/user, mob/living/target, self_message, detailed_message, vague_message, target_detailed = FALSE)
	user.visible_message(detailed_message, self_message, vision_distance = 1, ignored_mobs = target_detailed ? null : target)
	if(!target_detailed)
		var/you_feel = pick("a brief pain", "your body tense up", "an unnerving sensation")
		target.show_message(vague_message, MSG_VISUAL, span_notice("You feel [you_feel] as you are operated on."))
/**
 * Sends a pain message to the target, including a chance of screaming.
 *
 * Arguments:
 * * target - Who the message will be sent to
 * * pain_message - The message to be displayed
 * * mechanical_surgery - Boolean flag that represents if a surgery step is done on a mechanical limb (therefore does not force scream)
 */
/datum/surgery_step/proc/display_pain(mob/living/target, pain_message, mechanical_surgery = FALSE)
	if(mechanical_surgery)
		return

	if(HAS_TRAIT(target, TRAIT_PAINKILLER))
		if(target.stat > UNCONSCIOUS)
			return
		if(prob(90))
			return
		if(prob(50))
			target.emote("giggle")
		else
			target.emote("laugh")
		to_chat(target, span_warning(pick("Щекотно!", "Ай-ай-ай!", "Ахахаха!", "Хихихи!", "Щекотится!")))
		return

	if(target.stat > UNCONSCIOUS)
		return

	target.flash_pain(4)
	to_chat(target, span_warning(pain_message))

	if(prob(35))
		target.emote("agony")
	else if(prob(65))
		target.emote("moan")
