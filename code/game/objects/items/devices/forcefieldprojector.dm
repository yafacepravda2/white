/obj/item/forcefield_projector
	name = "forcefield projector"
	desc = "An experimental device that can create several forcefields at a distance."
	icon = 'icons/obj/device.dmi'
	icon_state = "signmaker_forcefield"
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	item_flags = NOBLUDGEON
	inhand_icon_state = "electronic"
	worn_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	custom_materials = list(/datum/material/iron=250, /datum/material/glass=500)
	var/max_shield_integrity = 250
	var/shield_integrity = 250
	var/max_fields = 3
	var/list/current_fields
	var/field_distance_limit = 7

/obj/item/forcefield_projector/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	if(!check_allowed_items(target, 1))
		return
	if(istype(target, /obj/structure/projected_forcefield))
		var/obj/structure/projected_forcefield/F = target
		if(F.generator == src)
			to_chat(user, span_notice("You deactivate [F]."))
			qdel(F)
			return
	var/turf/T = get_turf(target)
	var/obj/structure/projected_forcefield/found_field = locate() in T
	if(found_field)
		to_chat(user, span_warning("There is already a forcefield in that location!"))
		return
	if(T.density)
		return
	if(get_dist(T,src) > field_distance_limit)
		return
	if (get_turf(src) == T)
		to_chat(user, span_warning("Target is too close, aborting!"))
		return
	if(LAZYLEN(current_fields) >= max_fields)
		to_chat(user, span_warning("[capitalize(src.name)] cannot sustain any more forcefields!"))
		return

	playsound(src,'sound/weapons/resonator_fire.ogg',50,TRUE)
	user.visible_message(span_warning("[user] projects a forcefield!") ,span_notice("You project a forcefield."))
	var/obj/structure/projected_forcefield/F = new(T, src)
	current_fields += F
	user.changeNext_move(CLICK_CD_MELEE)

/obj/item/forcefield_projector/attack_self(mob/user)
	if(LAZYLEN(current_fields))
		to_chat(user, span_notice("You deactivate [src], disabling all active forcefields."))
		for(var/obj/structure/projected_forcefield/F in current_fields)
			qdel(F)

/obj/item/forcefield_projector/examine(mob/user)
	. = ..()
	. += "<hr><span class='notice'>It is currently sustaining [LAZYLEN(current_fields)]/[max_fields] fields, and it's [round((shield_integrity/max_shield_integrity)*100)]% charged.</span>"

/obj/item/forcefield_projector/Initialize(mapload)
	. = ..()
	current_fields = list()
	START_PROCESSING(SSobj, src)

/obj/item/forcefield_projector/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/forcefield_projector/process(delta_time)
	if(!LAZYLEN(current_fields))
		shield_integrity = min(shield_integrity + delta_time * 2, max_shield_integrity)
	else
		shield_integrity = max(shield_integrity - LAZYLEN(current_fields) * delta_time * 0.5, 0) //fields degrade slowly over time
	for(var/obj/structure/projected_forcefield/F in current_fields)
		if(shield_integrity <= 0 || get_dist(F,src) > field_distance_limit)
			qdel(F)

/obj/structure/projected_forcefield
	name = "forcefield"
	desc = "A glowing barrier, generated by a projector nearby. It could be overloaded if hit enough times."
	icon = 'icons/effects/effects.dmi'
	icon_state = "forcefield"
	layer = ABOVE_ALL_MOB_LAYER
	plane = ABOVE_GAME_PLANE
	anchored = TRUE
	pass_flags_self = PASSGLASS
	density = TRUE
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	resistance_flags = INDESTRUCTIBLE
	CanAtmosPass = ATMOS_PASS_DENSITY
	armor = list(MELEE = 0, BULLET = 25, LASER = 50, ENERGY = 50, BOMB = 25, BIO = 100, RAD = 100, FIRE = 100, ACID = 100)
	var/obj/item/forcefield_projector/generator

/obj/structure/projected_forcefield/Initialize(mapload, obj/item/forcefield_projector/origin)
	. = ..()
	generator = origin

/obj/structure/projected_forcefield/Destroy()
	visible_message(span_warning("[capitalize(src.name)] flickers and disappears!"))
	playsound(src,'sound/weapons/resonator_blast.ogg',25,TRUE)
	generator.current_fields -= src
	generator = null
	return ..()

/obj/structure/projected_forcefield/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	playsound(loc, 'sound/weapons/egloves.ogg', 80, TRUE)

/obj/structure/projected_forcefield/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	if(sound_effect)
		play_attack_sound(damage_amount, damage_type, damage_flag)
	generator.shield_integrity = max(generator.shield_integrity - damage_amount, 0)
