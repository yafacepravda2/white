/**
 * Component that hooks into the client, listens for COMSIG_MOVABLE_Z_CHANGED, and depending on whether or not the
 * Z-level has ZTRAIT_NOPARALLAX enabled, disable or reenable parallax.
 */

/datum/component/zparallax
	dupe_mode = COMPONENT_DUPE_UNIQUE

	var/client/tracked
	var/mob/client_mob

/datum/component/zparallax/Initialize(client/tracked)
	. = ..()
	if(!istype(tracked))
		stack_trace("Component zparallax has been initialized outside of a client. Deleting.")
		return COMPONENT_INCOMPATIBLE

	src.tracked = tracked
	client_mob = tracked.mob

	RegisterSignal(client_mob, COMSIG_MOB_LOGOUT, PROC_REF(mob_change))
	RegisterSignal(client_mob, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(ztrait_checks))
	RegisterSignal(client_mob, COMSIG_MOB_LOGIN, PROC_REF(refresh_client))

/datum/component/zparallax/Destroy()
	. = ..()
	unregister_signals()

	tracked = null
	client_mob = null

/datum/component/zparallax/proc/unregister_signals()
	if(!client_mob)
		return

	UnregisterSignal(client_mob, list(COMSIG_MOB_LOGOUT, COMSIG_MOVABLE_Z_CHANGED))

/datum/component/zparallax/proc/refresh_client()
	tracked = client_mob.client

/datum/component/zparallax/proc/mob_change()
	SIGNAL_HANDLER

	if(client_mob.key)
		return

	unregister_signals()

	client_mob = tracked.mob

	RegisterSignal(client_mob, COMSIG_MOB_LOGOUT, PROC_REF(mob_change))
	RegisterSignal(client_mob, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(ztrait_checks))
	RegisterSignal(client_mob, COMSIG_MOB_LOGIN, PROC_REF(refresh_client), override = TRUE)

/datum/component/zparallax/proc/ztrait_checks(datum/source, old_z, new_z)
	SIGNAL_HANDLER

	var/datum/hud/hud = client_mob.hud_used

	if(is_station_level(old_z) && is_station_level(new_z))
		return
	hud.update_parallax_pref(client_mob)
