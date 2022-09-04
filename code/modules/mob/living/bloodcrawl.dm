/mob/living/proc/phaseout(obj/effect/decal/cleanable/B)
	if(iscarbon(src))
		var/mob/living/carbon/C = src
		for(var/obj/item/I in C.held_items)
			//TODO make it toggleable to either forcedrop the items, or deny
			//entry when holding them
			// literally only an option for carbons though
			to_chat(C, "<span class='warning'>You may not hold items while blood crawling!</span>")
			return FALSE
		var/obj/item/bloodcrawl/B1 = new(C)
		var/obj/item/bloodcrawl/B2 = new(C)
		B1.icon_state = "bloodhand_left"
		B2.icon_state = "bloodhand_right"
		C.put_in_hands(B1)
		C.put_in_hands(B2)
		C.regenerate_icons()

	notransform = TRUE
	INVOKE_ASYNC(src, .proc/bloodpool_sink, B)

	return TRUE

/mob/living/proc/bloodpool_sink(obj/effect/decal/cleanable/B)
	var/turf/mobloc = get_turf(loc)

	visible_message("<span class='warning'>[capitalize(src.name)] sinks into the pool of blood!</span>")
	playsound(get_turf(src), 'sound/magic/enter_blood.ogg', 50, TRUE, -1)
	// Extinguish, unbuckle, stop being pulled, set our location into the
	// dummy object
	var/obj/effect/dummy/phased_mob/holder = new /obj/effect/dummy/phased_mob(mobloc)
	extinguish_mob()

	// Keep a reference to whatever we're pulling, because forceMove()
	// makes us stop pulling
	var/pullee = pulling

	holder = holder
	forceMove(holder)

	// if we're not pulling anyone, or we can't eat anyone
	if(!pullee || !HAS_TRAIT(src, TRAIT_BLOODCRAWL_EAT))
		notransform = FALSE
		return

	// if the thing we're pulling isn't alive
	if(!isliving(pullee))
		notransform = FALSE
		return

	var/mob/living/victim = pullee
	var/kidnapped = FALSE

	if(victim.stat == CONSCIOUS)
		visible_message("<span class='warning'>[victim] kicks free of the blood pool just before entering it!</span>" , null, "<span class='notice'>You hear splashing and struggling.</span>")
	else if(victim.reagents?.has_reagent(/datum/reagent/consumable/ethanol/demonsblood, needs_metabolizing = TRUE))
		visible_message("<span class='warning'>Something prevents [victim] from entering the pool!</span>" , "<span class='warning'>A strange force is blocking [victim] from entering!</span>" , "<span class='notice'>You hear a splash and a thud.</span>")
	else
		victim.forceMove(src)
		victim.emote("agony")
		visible_message("<span class='warning'><b>[src] drags [victim] into the pool of blood!</b></span>" , null, "<span class='notice'>You hear a splash.</span>")
		kidnapped = TRUE

	if(kidnapped)
		var/success = bloodcrawl_consume(victim)
		if(!success)
			to_chat(src, "<span class='danger'>You happily devour... nothing? Your meal vanished at some point!</span>")

	notransform = FALSE
	return TRUE

/mob/living/proc/bloodcrawl_consume(mob/living/victim)
	to_chat(src, "<span class='danger'>You begin to feast on [victim]... You can not move while you are doing this.</span>")

	var/sound
	if(istype(src, /mob/living/simple_animal/hostile/imp/slaughter))
		var/mob/living/simple_animal/hostile/imp/slaughter/SD = src
		sound = SD.feast_sound
	else
		sound = 'sound/magic/demon_consume.ogg'

	for(var/i in 1 to 3)
		playsound(get_turf(src),sound, 50, TRUE)
		sleep(30)

	if(!victim)
		return FALSE

	if(victim.reagents?.has_reagent(/datum/reagent/consumable/ethanol/devilskiss, needs_metabolizing = TRUE))
		to_chat(src, "<span class='warning'><b>AAH! THEIR FLESH! IT BURNS!</b></span>")
		adjustBruteLoss(25) //I can't use adjustHealth() here because bloodcrawl affects /mob/living and adjustHealth() only affects simple mobs
		var/found_bloodpool = FALSE
		for(var/obj/effect/decal/cleanable/target in range(1,get_turf(victim)))
			if(target.can_bloodcrawl_in())
				victim.forceMove(get_turf(target))
				victim.visible_message("<span class='warning'>[target] violently expels [victim]!</span>")
				victim.exit_blood_effect(target)
				found_bloodpool = TRUE
				break

		if(!found_bloodpool)
			// Fuck it, just eject them, thanks to some split second cleaning
			victim.forceMove(get_turf(victim))
			victim.visible_message("<span class='warning'>[victim] appears from nowhere, covered in blood!</span>")
			victim.exit_blood_effect()
		return TRUE

	to_chat(src, "<span class='danger'>You devour [victim]. Your health is fully restored.</span>")
	revive(full_heal = TRUE, admin_revive = FALSE)

	// No defib possible after laughter
	victim.adjustBruteLoss(1000)
	victim.death()
	bloodcrawl_swallow(victim)
	return TRUE

/mob/living/proc/bloodcrawl_swallow(mob/living/victim)
	qdel(victim)

/obj/item/bloodcrawl
	name = "blood crawl"
	desc = "You are unable to hold anything while in this form."
	icon = 'icons/effects/blood.dmi'
	item_flags = ABSTRACT | DROPDEL

/obj/item/bloodcrawl/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)

/mob/living/proc/exit_blood_effect(obj/effect/decal/cleanable/B)
	playsound(get_turf(src), 'sound/magic/exit_blood.ogg', 50, TRUE, -1)
	//Makes the mob have the color of the blood pool it came out of
	var/newcolor = rgb(149, 10, 10)
	if(istype(B, /obj/effect/decal/cleanable/xenoblood))
		newcolor = rgb(43, 186, 0)
	add_atom_colour(newcolor, TEMPORARY_COLOUR_PRIORITY)
	// but only for a few seconds
	addtimer(CALLBACK(src, /atom/.proc/remove_atom_colour, TEMPORARY_COLOUR_PRIORITY, newcolor), 6 SECONDS)

/mob/living/proc/phasein(obj/effect/decal/cleanable/B)
	if(notransform)
		to_chat(src, "<span class='warning'>Finish eating first!</span>")
		return FALSE
	B.visible_message("<span class='warning'>[B] starts to bubble...</span>")
	if(!do_after(src, 20, target = B))
		return
	if(!B)
		return
	forceMove(B.loc)
	client.eye = src
	SEND_SIGNAL(src, COMSIG_LIVING_AFTERPHASEIN, B)
	visible_message("<span class='boldwarning'>[capitalize(src.name)] rises out of the pool of blood!</span>")
	exit_blood_effect(B)
	if(iscarbon(src))
		var/mob/living/carbon/C = src
		for(var/obj/item/bloodcrawl/BC in C)
			BC.flags_1 = null
			qdel(BC)
	return TRUE
