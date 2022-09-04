/obj/item/paperplane
	name = "paper plane"
	desc = "Paper, folded in the shape of a plane."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paperplane"
	custom_fire_overlay = "paperplane_onfire"
	throw_range = 7
	throw_speed = 1
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE
	max_integrity = 50

	var/hit_probability = 2 //%
	var/obj/item/paper/internalPaper

/obj/item/paperplane/syndicate
	desc = "Paper, masterfully folded in the shape of a plane."
	throwforce = 20 //same as throwing stars, but no chance of embedding.
	hit_probability = 100 //guaranteed to cause eye damage when it hits a mob.

/obj/item/paperplane/Initialize(mapload, obj/item/paper/newPaper)
	. = ..()
	pixel_x = base_pixel_x + rand(-9, 9)
	pixel_y = base_pixel_y + rand(-8, 8)
	if(newPaper)
		internalPaper = newPaper
		flags_1 = newPaper.flags_1
		color = newPaper.color
		newPaper.forceMove(src)
	else
		internalPaper = new(src)
	update_icon()

/obj/item/paperplane/Exited(atom/movable/AM, atom/newLoc)
	. = ..()
	if (AM == internalPaper)
		internalPaper = null
		if(!QDELETED(src))
			qdel(src)

/obj/item/paperplane/Destroy()
	internalPaper = null
	return ..()

/obj/item/paperplane/suicide_act(mob/living/user)
	var/obj/item/organ/eyes/eyes = user.getorganslot(ORGAN_SLOT_EYES)
	user.Stun(200)
	user.visible_message("<span class='suicide'>[user] jams [src] in [user.ru_ego()] nose. It looks like [user.p_theyre()] trying to commit suicide!</span>")
	user.adjust_blurriness(6)
	if(eyes)
		eyes.applyOrganDamage(rand(6,8))
	sleep(10)
	return (BRUTELOSS)

/obj/item/paperplane/update_overlays()
	. = ..()
	var/list/stamped = internalPaper.stamped
	if(stamped)
		for(var/S in stamped)
			. += "paperplane_[S]"

/obj/item/paperplane/attack_self(mob/user)
	to_chat(user, "<span class='notice'>You unfold [src].</span>")
	// We don't have to qdel the paperplane here; it shall be done once the internal paper object is moved out of src anyway.
	if(user.Adjacent(internalPaper))
		user.put_in_hands(internalPaper)
	else
		internalPaper.forceMove(loc)

/obj/item/paperplane/attackby(obj/item/P, mob/living/carbon/human/user, params)
	if(burn_paper_product_attackby_check(P, user))
		return
	if(istype(P, /obj/item/pen) || istype(P, /obj/item/toy/crayon))
		to_chat(user, "<span class='warning'>You should unfold [src] before changing it!</span>")
		return

	else if(istype(P, /obj/item/stamp)) 	//we don't randomize stamps on a paperplane
		internalPaper.attackby(P, user) //spoofed attack to update internal paper.
		update_icon()
		add_fingerprint(user)
		return

	return ..()


/obj/item/paperplane/throw_at(atom/target, range, speed, mob/thrower, spin=FALSE, diagonals_first = FALSE, datum/callback/callback, quickstart = TRUE, params)
	. = ..(target, range, speed, thrower, FALSE, diagonals_first, callback, quickstart = quickstart, params = params)

/obj/item/paperplane/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(iscarbon(hit_atom))
		var/mob/living/carbon/C = hit_atom
		if(C.can_catch_item(TRUE))
			var/datum/action/innate/origami/origami_action = locate() in C.actions
			if(origami_action?.active) //if they're a master of origami and have the ability turned on, force throwmode on so they'll automatically catch the plane.
				C.throw_mode_on(THROW_MODE_TOGGLE)

	if(..() || !ishuman(hit_atom))//if the plane is caught or it hits a nonhuman
		return
	var/mob/living/carbon/human/H = hit_atom
	var/obj/item/organ/eyes/eyes = H.getorganslot(ORGAN_SLOT_EYES)
	if(prob(hit_probability))
		if(H.is_eyes_covered())
			return
		visible_message("<span class='danger'><b>[src.name]</b> hits [H] in the eye[eyes ? "" : " socket"]!</span>")
		H.adjust_blurriness(6)
		eyes?.applyOrganDamage(rand(6,8))
		H.Paralyze(40)
		H.emote("agony")

/obj/item/paper/examine(mob/user)
	. = ..()
	. += "<hr><span class='notice'>ПКМ [src] to fold it into a paper plane.</span>"

/obj/item/paper/AltClick(mob/living/user, obj/item/I)
	if(!user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, FALSE, TRUE))
		return
	if(istype(src, /obj/item/paper/carbon))
		var/obj/item/paper/carbon/Carbon = src
		if(!Carbon.iscopy && !Carbon.copied)
			to_chat(user, "<span class='notice'>Take off the carbon copy first.</span>")
			return
	to_chat(user, "<span class='notice'>You fold [src] into the shape of a plane!</span>")
	user.temporarilyRemoveItemFromInventory(src)
	var/obj/item/paperplane/plane_type = /obj/item/paperplane
	//Origami Master
	var/datum/action/innate/origami/origami_action = locate() in user.actions
	if(origami_action?.active)
		plane_type = /obj/item/paperplane/syndicate

	I = new plane_type(loc, src)
	if(user.Adjacent(I))
		user.put_in_hands(I)
