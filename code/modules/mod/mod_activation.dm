#define MOD_ACTIVATION_STEP_FLAGS IGNORE_USER_LOC_CHANGE|IGNORE_TARGET_LOC_CHANGE|IGNORE_HELD_ITEM|IGNORE_INCAPACITATED|IGNORE_SLOWDOWNS

/// Creates a radial menu from which the user chooses parts of the suit to deploy/retract. Repeats until all parts are extended or retracted.
/obj/item/mod/control/proc/choose_deploy(mob/user)
	if(!length(mod_parts))
		return
	var/list/display_names = list()
	var/list/items = list()
	for(var/obj/item/part as anything in mod_parts)
		display_names[part.name] = REF(part)
		var/image/part_image = image(icon = part.icon, icon_state = part.icon_state)
		if(part.loc != src)
			part_image.underlays += image(icon = 'icons/hud/radial.dmi', icon_state = "module_active")
		items += list(part.name = part_image)
	var/pick = show_radial_menu(user, src, items, custom_check = FALSE, require_near = TRUE, tooltips = TRUE)
	if(!pick)
		return
	var/part_reference = display_names[pick]
	var/obj/item/part = locate(part_reference) in mod_parts
	if(!istype(part) || user.incapacitated())
		return
	if(active || activating)
		balloon_alert(user, "Сначала деактивируйте скафандр!")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return
	var/parts_to_check = mod_parts - part
	if(part.loc == src)
		deploy(user, part)
		for(var/obj/item/checking_part as anything in parts_to_check)
			if(checking_part.loc != src)
				continue
			choose_deploy(user)
			break
	else
		retract(user, part)
		for(var/obj/item/checking_part as anything in parts_to_check)
			if(checking_part.loc == src)
				continue
			choose_deploy(user)
			break

/// Quickly deploys all parts (or retracts if all are on the wearer)
/obj/item/mod/control/proc/quick_deploy(mob/user)
	if(active || activating)
		balloon_alert(user, "Сначала деактивируйте скафандр!")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return FALSE
	var/deploy = FALSE
	for(var/obj/item/part as anything in mod_parts)
		if(part.loc != src)
			continue
		deploy = TRUE
	for(var/obj/item/part as anything in mod_parts)
		if(deploy && part.loc == src)
			deploy(null, part)
		else if(!deploy && part.loc != src)
			retract(null, part)
	wearer.visible_message(span_notice("[wearer] [deploy ? "развёртывает" : "свёртывает"] [src] с механическим шипением."),
		span_notice("[src] [deploy ? "развертывает" : "свёртывает"] свои части с механическим шипением."),
		span_hear("Где-то раздаётся механическое шипение."))
	playsound(src, 'sound/mecha/mechmove03.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	return TRUE

/// Deploys a part of the suit onto the user.
/obj/item/mod/control/proc/deploy(mob/user, obj/item/part)
	if(part.loc != src)
		if(!user)
			return FALSE
		balloon_alert(user, "[part.name] уже развёрнуто!")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
	if(part in overslotting_parts)
		var/obj/item/overslot = wearer.get_item_by_slot(part.slot_flags)
		if(overslot)
			overslotting_parts[part] = overslot
			wearer.transferItemToLoc(overslot, part, force = TRUE)
			RegisterSignal(part, COMSIG_ATOM_EXITED, PROC_REF(on_overslot_exit))
	if(wearer.equip_to_slot_if_possible(part, part.slot_flags, qdel_on_fail = FALSE, disable_warning = TRUE))
		ADD_TRAIT(part, TRAIT_NODROP, MOD_TRAIT)
		if(!user)
			return TRUE
		wearer.visible_message(span_notice("[wearer] развёртывает [part.name] с механическим шипением."),
			span_notice("[part] развёртывается с механическим шипением."),
			span_hear("Где-то раздаётся механическое шипение."))
		playsound(src, 'sound/mecha/mechmove03.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		return TRUE
	else
		if(!user)
			return FALSE
		balloon_alert(user, "Часть тела закрыта одеждой!")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
	return FALSE

/// Retract a part of the suit from the user.
/obj/item/mod/control/proc/retract(mob/user, obj/item/part)
	if(part.loc == src)
		if(!user)
			return FALSE
		balloon_alert(user, "[part.name] уже свёрнуто!")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
	REMOVE_TRAIT(part, TRAIT_NODROP, MOD_TRAIT)
	wearer.transferItemToLoc(part, src, force = TRUE)
	if(overslotting_parts[part])
		UnregisterSignal(part, COMSIG_ATOM_EXITED)
		var/obj/item/overslot = overslotting_parts[part]
		if(!wearer.equip_to_slot_if_possible(overslot, overslot.slot_flags, qdel_on_fail = FALSE, disable_warning = TRUE))
			wearer.dropItemToGround(overslot, force = TRUE, silent = TRUE)
		overslotting_parts[part] = null
	if(!user)
		return
	wearer.visible_message(span_notice("[wearer] сворачивает [part.name] обратно в [src] с механическим шипением."),
		span_notice("[part] сворачивается обратно в [src] с механическим шипением."),
		span_hear("Где-то раздаётся механическое шипение."))
	playsound(src, 'sound/mecha/mechmove03.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)

/// Starts the activation sequence, where parts of the suit activate one by one until the whole suit is on
/obj/item/mod/control/proc/toggle_activate(mob/user, force_deactivate = FALSE)
	if(!wearer)
		if(!force_deactivate)
			balloon_alert(user, "Сначала экипируйте скафандр!")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return FALSE
	if(!force_deactivate && (SEND_SIGNAL(src, COMSIG_MOD_ACTIVATE, user) & MOD_CANCEL_ACTIVATE))
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return FALSE
	for(var/obj/item/part as anything in mod_parts)
		if(!force_deactivate && part.loc == src)
			balloon_alert(user, "Сначала разверните части!")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
			return FALSE
	if(locked && !active && !allowed(user) && !force_deactivate)
		balloon_alert(user, "Доступ запрещён!")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return FALSE
	if(!get_charge() && !force_deactivate)
		balloon_alert(user, "Скафандр обесточен!")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return FALSE
	if(open && !force_deactivate)
		balloon_alert(user, "Закройте техническую панель скафандра!")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return FALSE
	if(activating)
		if(!force_deactivate)
			balloon_alert(user, "Скафандр [active ? "выключается" : "включается"]!")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return FALSE
	for(var/obj/item/mod/module/module as anything in modules)
		if(!module.active || module.allowed_inactive)
			continue
		module.on_deactivation(display_message = FALSE)
	activating = TRUE
	to_chat(wearer, span_notice("MOD-Скафандр [active ? "выключается" : "включается"]."))
	if(do_after(wearer, activation_step_time, wearer, MOD_ACTIVATION_STEP_FLAGS, extra_checks = CALLBACK(src, PROC_REF(has_wearer))))
		to_chat(wearer, span_notice("[boots] [active ? "расслабляют крепление с ногами" : "закрепляются вокруг ваших ног"]."))
		playsound(src, 'sound/mecha/mechmove03.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		seal_part(boots, seal = !active)
	if(do_after(wearer, activation_step_time, wearer, MOD_ACTIVATION_STEP_FLAGS, extra_checks = CALLBACK(src, PROC_REF(has_wearer))))
		to_chat(wearer, span_notice("[gauntlets] [active ? "становятся свободнее вокруг ваших запястий" : "затягиваются вокруг ваших запястий"]."))
		playsound(src, 'sound/mecha/mechmove03.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		seal_part(gauntlets, seal = !active)
	if(do_after(wearer, activation_step_time, wearer, MOD_ACTIVATION_STEP_FLAGS, extra_checks = CALLBACK(src, PROC_REF(has_wearer))))
		to_chat(wearer, span_notice("[chestplate] [active ? "освобождает вашу грудь" : "плотно приживается к вашей груди"]."))
		playsound(src, 'sound/mecha/mechmove03.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		seal_part(chestplate, seal = !active)
	if(do_after(wearer, activation_step_time, wearer, MOD_ACTIVATION_STEP_FLAGS, extra_checks = CALLBACK(src, PROC_REF(has_wearer))))
		to_chat(wearer, span_notice("[helmet] шипит, [active ? "открываясь" : "закрываясь"]."))
		playsound(src, 'sound/mecha/mechmove03.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		seal_part(helmet, seal = !active)
	if(do_after(wearer, activation_step_time, wearer, MOD_ACTIVATION_STEP_FLAGS, extra_checks = CALLBACK(src, PROC_REF(has_wearer))))
		to_chat(wearer, span_notice("Системы [active ? "отключены. Части откреплены. Удачного вам дня" : "запущены. Части зафиксированны. Добро пожаловать"], [wearer]."))
		if(ai)
			to_chat(ai, span_notice("<b>СИСТЕМЫ [active ? "ДЕАКТИВИРОВАНЫ. ЗАВЕРШЕНИЕ" : "СИНХРОНИЗАЦИЯ ПРОТОКОЛА УДАЛЕННОГО ДОСТУПА С \"[ai]\""]"))
		finish_activation(on = !active)
		if(active)
			playsound(src, 'sound/machines/synth_yes.ogg', 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE, frequency = 6000)
			if(!malfunctioning)
				wearer.playsound_local(get_turf(src), 'sound/mecha/nominal.ogg', 50)
		else
			playsound(src, 'sound/machines/synth_no.ogg', 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE, frequency = 6000)
	activating = FALSE
	return TRUE

///Seals or unseals the given part
/obj/item/mod/control/proc/seal_part(obj/item/clothing/part, seal)
	if(seal)
		part.clothing_flags |= part.visor_flags
		part.flags_inv |= part.visor_flags_inv
		part.flags_cover |= part.visor_flags_cover
		part.heat_protection = initial(part.heat_protection)
		part.cold_protection = initial(part.cold_protection)
		part.alternate_worn_layer = null
	else
		part.flags_cover &= ~part.visor_flags_cover
		part.flags_inv &= ~part.visor_flags_inv
		part.clothing_flags &= ~part.visor_flags
		part.heat_protection = NONE
		part.cold_protection = NONE
		part.alternate_worn_layer = mod_parts[part]
	if(part == boots)
		boots.icon_state = "[skin]-boots[seal ? "-sealed" : ""]"
		wearer.update_inv_shoes()
	if(part == gauntlets)
		gauntlets.icon_state = "[skin]-gauntlets[seal ? "-sealed" : ""]"
		wearer.update_inv_gloves()
	if(part == chestplate)
		chestplate.icon_state = "[skin]-chestplate[seal ? "-sealed" : ""]"
		wearer.update_inv_wear_suit()
		wearer.update_inv_w_uniform()
	if(part == helmet)
		helmet.icon_state = "[skin]-helmet[seal ? "-sealed" : ""]"
		wearer.update_inv_head()
		wearer.update_inv_wear_mask()
		wearer.update_inv_glasses()
		wearer.update_hair()
		// Close internal air tank if MOD helmet is unsealed and was the only breathing apparatus.
		if (!seal && wearer?.invalid_internals())
			wearer.cutoff_internals()

/// Finishes the suit's activation, starts processing
/obj/item/mod/control/proc/finish_activation(on)
	active = on
	if(active)
		for(var/obj/item/mod/module/module as anything in modules)
			module.on_suit_activation()
		START_PROCESSING(SSobj, src)
	else
		for(var/obj/item/mod/module/module as anything in modules)
			module.on_suit_deactivation()
		STOP_PROCESSING(SSobj, src)
	update_speed()
	update_icon_state()
	wearer.update_clothing(slot_flags)

/// Quickly deploys all the suit parts and if successful, seals them and turns on the suit. Intended mostly for outfits.
/obj/item/mod/control/proc/quick_activation()
	var/seal = TRUE
	for(var/obj/item/part as anything in mod_parts)
		if(!deploy(null, part))
			seal = FALSE
	if(!seal)
		return
	for(var/obj/item/part as anything in mod_parts)
		seal_part(part, seal = TRUE)
	finish_activation(on = TRUE)

/obj/item/mod/control/proc/has_wearer()
	return wearer

#undef MOD_ACTIVATION_STEP_FLAGS
