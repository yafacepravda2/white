/*
Immovable rod random event.
The rod will spawn at some location outside the station, and travel in a straight line to the opposite side of the station
Everything solid in the way will be ex_act()'d
In my current plan for it, 'solid' will be defined as anything with density == 1

--NEOFite
*/

/datum/round_event_control/immovable_rod
	name = "недвижимый стержень"
	typepath = /datum/round_event/immovable_rod
	min_players = 15
	max_occurrences = 5
	var/atom/special_target
	var/force_looping = FALSE

/datum/round_event_control/immovable_rod/admin_setup()
	if(!check_rights(R_FUN))
		return

	var/aimed = tgui_alert(usr,"Целимся прямо сюда?", "Цельсь", list("Да", "Нет"))
	if(aimed == "Да")
		special_target = get_turf(usr)
	var/looper = tgui_alert(usr,"Зацикливаем по Z уровню?", "Готовьсь", list("Да", "Нет"))
	if(looper == "Да")
		force_looping = TRUE
	message_admins("[key_name_admin(usr)] запустил недвижимый стержень [force_looping ? "(цикличный)" : ""] в [AREACOORD(special_target)].")
	log_admin("[key_name_admin(usr)] запустил недвижимый стержень [force_looping ? "(цикличный)" : ""] в [AREACOORD(special_target)].")

/datum/round_event/immovable_rod
	announceWhen = 5

/datum/round_event/immovable_rod/announce(fake)
	priority_announce("Что это блять было?!", "Общая тревога")

/datum/round_event/immovable_rod/start()
	var/datum/round_event_control/immovable_rod/C = control
	var/startside = pick(GLOB.cardinals)
	var/turf/endT = get_edge_target_turf(get_random_station_turf(), turn(startside, 180))
	var/turf/startT = spaceDebrisStartLoc(startside, endT.z)
	var/atom/rod = new /obj/effect/immovablerod(startT, endT, C.special_target, C.force_looping)
	C.special_target = null //Cleanup for future event rolls.
	announce_to_ghosts(rod)

/obj/effect/immovablerod
	name = "недвижимый стержень"
	desc = "Что это блять было?!"
	icon = 'icons/obj/objects.dmi'
	icon_state = "immrod"
	throwforce = 100
	move_force = INFINITY
	move_resist = INFINITY
	pull_force = INFINITY
	density = TRUE
	anchored = TRUE
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1
	movement_type = PHASING | FLYING
	var/mob/living/wizard
	var/z_original = 0
	var/destination
	var/notify = TRUE
	///We can designate a specific target to aim for, in which case we'll try to snipe them rather than just flying in a random direction
	var/atom/special_target
	///How many mobs we've penetrated one way or another
	var/num_mobs_hit = 0
	///How many mobs we've hit with clients
	var/num_sentient_mobs_hit = 0
	///How many people we've hit with clients
	var/num_sentient_people_hit = 0
	/// The rod levels up with each kill, increasing in size and auto-renaming itself.
	var/dnd_style_level_up = TRUE
	/// Whether the rod can loop across other z-levels. The rod will still loop when the z-level is self-looping even if this is FALSE.
	var/loopy_rod = FALSE

/obj/effect/immovablerod/New(atom/start, atom/end, aimed_at, force_looping)
	. = ..()
	SSaugury.register_doom(src, 2000)

	destination = end
	special_target = aimed_at
	loopy_rod = force_looping

	SSpoints_of_interest.make_point_of_interest(src)

	RegisterSignal(src, COMSIG_ATOM_ENTERING, PROC_REF(on_entering_atom))

	if(special_target)
		SSmove_manager.home_onto(src, special_target)
	else
		SSmove_manager.move_towards(src, destination)

/obj/effect/immovablerod/Destroy(force)
	UnregisterSignal(src, COMSIG_ATOM_ENTERING)
	SSaugury.unregister_doom(src)

	return ..()

/obj/effect/immovablerod/examine(mob/user)
	. = ..()
	if(!isobserver(user))
		return

	if(!num_mobs_hit)
		. += span_notice("Пока ни в кого не попал...")
		return

	. += "\t<span class='notice'>На данный момент стержень пронзил: \n\
		\t\t[num_mobs_hit] мобов всего, \n\
		\t\t[num_sentient_mobs_hit] из них были управляемыми, \n\
		\t\t[num_sentient_people_hit] из них были людьми.</span>"

/obj/effect/immovablerod/Topic(href, href_list)
	if(href_list["orbit"])
		var/mob/dead/observer/ghost = usr
		if(istype(ghost))
			ghost.ManualFollow(src)

/obj/effect/immovablerod/proc/on_entered_over_movable(datum/source, atom/movable/atom_crossed_over)
	SIGNAL_HANDLER
	if((atom_crossed_over.density || isliving(atom_crossed_over)) && !QDELETED(atom_crossed_over))
		Bump(atom_crossed_over)

/obj/effect/immovablerod/proc/on_entering_atom(datum/source, atom/destination, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER
	if(destination.density && isturf(destination))
		Bump(destination)

/obj/effect/immovablerod/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	if(!loc)
		return ..()

	for(var/atom/movable/to_bump in loc)
		if((to_bump != src) && !QDELETED(to_bump) && (to_bump.density || isliving(to_bump)))
			Bump(to_bump)

	// If we have a special target, we should definitely make an effort to go find them.
	if(special_target)
		var/turf/target_turf = get_turf(special_target)

		// Did they escape the z-level? Let's see if we can chase them down!
		var/z_diff = target_turf.z - z

		if(z_diff)
			var/direction = z_diff > 0 ? UP : DOWN
			var/turf/target_z_turf = get_step_multiz(src, direction)

			visible_message(span_danger("[src] исчезает из реальности!"))

			if(!do_teleport(src, target_z_turf))
				// We failed to teleport. Might as well admit defeat.
				qdel(src)
				return

			visible_message(span_danger("[src] появляется из ниоткуда!"))
			SSmove_manager.home_onto(src, special_target)

		if(loc == target_turf)
			complete_trajectory()

		return ..()

	// If we have a destination turf, let's make sure it's also still valid.
	if(destination)
		var/turf/target_turf = get_turf(destination)

		// If the rod is a loopy_rod, run complete_trajectory() to get a new edge turf to fly to.
		// Otherwise, qdel the rod.
		if(target_turf.z != z)
			if(loopy_rod)
				complete_trajectory()
				return ..()

			qdel(src)
			return

		// Did we reach our destination? We're probably on Icebox. Let's get rid of ourselves.
		// Ordinarily this won't happen as the average destination is the edge of the map and
		// the rod will auto transition to a new z-level.
		if(loc == get_turf(destination))
			qdel(src)
			return

	return ..()

/obj/effect/immovablerod/proc/complete_trajectory()
	// We hit what we wanted to hit, time to go.
	special_target = null
	walk_in_direction(dir)

/obj/effect/immovablerod/singularity_act()
	return

/obj/effect/immovablerod/singularity_pull()
	return

/obj/effect/immovablerod/Process_Spacemove(movement_dir = 0, continuous_move = FALSE)
	return TRUE

/obj/effect/immovablerod/Bump(atom/clong)
	if(prob(10))
		playsound(src, 'sound/effects/bang.ogg', 50, TRUE)
		audible_message(span_danger("БАМ!"))

	if(special_target && clong == special_target)
		complete_trajectory()

	// If rod meets rod, they collapse into a singularity. Yes, this means that if two wizard rods collide,
	// they ALSO collapse into a singulo.
	if(istype(clong, /obj/effect/immovablerod))
		visible_message(span_danger("[src] сталкивается с [clong]! Это не может закончиться хорошо..."))
		var/datum/effect_system/fluid_spread/smoke/smoke = new
		smoke.set_up(2, holder = src, location = get_turf(src))
		smoke.start()
		var/obj/singularity/bad_luck = new(get_turf(src))
		bad_luck.energy = 800
		qdel(clong)
		qdel(src)
		return

	// If we Bump into a turf, turf go boom.
	if(isturf(clong))
		SSexplosions.highturf += clong
		return ..()

	if(isobj(clong))
		var/obj/clong_obj = clong
		clong_obj.take_damage(INFINITY, BRUTE, NONE, TRUE, dir, INFINITY)
		return ..()

	// If we Bump into a living thing, living thing goes splat.
	if(isliving(clong))
		var/mob/living/carbon/archimedes = clong
		if((HAS_TRAIT(archimedes, TRAIT_ROD_SUPLEX) || (archimedes.mind && HAS_TRAIT(archimedes.mind, TRAIT_ROD_SUPLEX))))
			if(archimedes.throw_mode)
				INVOKE_ASYNC(src, TYPE_PROC_REF(/atom, attack_hand), clong)
				return
		penetrate(clong)
		return ..()

	// If we Bump into anything else, anything goes boom.
	if(isatom(clong))
		SSexplosions.high_mov_atom += clong
		return ..()

	CRASH("[src] Bump()ed into non-atom thing [clong] ([clong.type])")

/obj/effect/immovablerod/proc/penetrate(mob/living/smeared_mob)
	smeared_mob.visible_message(span_danger("[smeared_mob] пронзен недвижимым стержнем!") , span_userdanger("Недвижимый стержень пронзает меня!") , span_danger("БАМ!"))

	if(smeared_mob.stat != DEAD)
		num_mobs_hit++
		if(smeared_mob.client)
			num_sentient_mobs_hit++
			if(iscarbon(smeared_mob))
				num_sentient_people_hit++
			if(dnd_style_level_up)
				transform = transform.Scale(1.005, 1.005)
				name = "[initial(name)] древней мощи +[num_sentient_mobs_hit]"

	if(iscarbon(smeared_mob))
		var/mob/living/carbon/smeared_carbon = smeared_mob
		smeared_carbon.adjustBruteLoss(100)
		var/obj/item/bodypart/penetrated_chest = smeared_carbon.get_bodypart(BODY_ZONE_CHEST)
		penetrated_chest?.receive_damage(60, wound_bonus = 20, sharpness=SHARP_POINTY)

	if(smeared_mob.density || prob(10))
		smeared_mob.ex_act(EXPLODE_HEAVY)

/obj/effect/immovablerod/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return

	if(!(HAS_TRAIT(user, TRAIT_ROD_SUPLEX) || (user.mind && HAS_TRAIT(user.mind, TRAIT_ROD_SUPLEX))))
		return

	playsound(src, 'sound/effects/meteorimpact.ogg', 100, TRUE)
	for(var/mob/living/nearby_mob in urange(8, src))
		if(nearby_mob.stat != CONSCIOUS)
			continue
		shake_camera(nearby_mob, 2, 3)

	return suplex_rod(user)

/**
 * Called when someone manages to suplex the rod.
 *
 * Arguments
 * * strongman - the suplexer of the rod.
 */
/obj/effect/immovablerod/proc/suplex_rod(mob/living/strongman)
	strongman.client?.give_award(/datum/award/achievement/misc/feat_of_strength, strongman)
	strongman.visible_message(
		span_boldwarning("[strongman] заземляет [src] прямо в пол!"),
		span_warning("Перехватываю [src] и перенаправляю его в пол!")
		)
	new /obj/structure/festivus/anchored(drop_location())
	new /obj/effect/anomaly/flux(drop_location())
	qdel(src)
	return TRUE

/* Below are a couple of admin helper procs when dealing with immovable rod memes. */
/**
 * Stops your rod's automated movement. Sit... Stay... Good rod!
 */
/obj/effect/immovablerod/proc/sit_stay_good_rod()
	SSmove_manager.stop_looping(src)

/**
 * Allows your rod to release restraint level zero and go for a walk.
 *
 * If walkies_location is set, rod will walk_towards the location, chasing it across z-levels if necessary.
 * If walkies_location is not set, rod will call complete_trajectory() and follow the logic from that proc.
 *
 * Arguments:
 * * walkies_location - Any atom that the immovable rod will now chase down as a special target.
 */
/obj/effect/immovablerod/proc/go_for_a_walk(walkies_location = null)
	if(walkies_location)
		special_target = walkies_location
		SSmove_manager.home_onto(src, special_target)
		return

	complete_trajectory()

/obj/effect/immovablerod/deadchat_plays(mode = DEMOCRACY_MODE, cooldown = 6 SECONDS)
	return AddComponent(/datum/component/deadchat_control/immovable_rod, mode, list(), cooldown)

/**
 * Rod will walk towards edge turf in the specified direction.
 *
 * Arguments:
 * * direction - The direction to walk the rod towards: NORTH, SOUTH, EAST, WEST.
 */
/obj/effect/immovablerod/proc/walk_in_direction(direction)
	destination = get_edge_target_turf(src, direction)
	SSmove_manager.move_towards(src, destination)
