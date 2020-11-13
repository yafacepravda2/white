/obj/projectile/bullet/dart
	name = "дротик"
	icon_state = "cbbolt"
	damage = 6
	embedding = null
	var/piercing = FALSE
	speed = 0.9

/obj/projectile/bullet/dart/Initialize()
	. = ..()
	create_reagents(50, NO_REACT)

/obj/projectile/bullet/dart/on_hit(atom/target, blocked = FALSE)
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		if(blocked != 100) // not completely blocked
			if(M.can_inject(null, FALSE, def_zone, piercing)) // Pass the hit zone to see if it can inject by whether it hit the head or the body.
				..()
				reagents.trans_to(M, reagents.total_volume, methods = INJECT)
				return BULLET_ACT_HIT
			else
				blocked = 100
				target.visible_message("<span class='danger'>[capitalize(src.name)] был отражен!</span>", \
									   "<span class='userdanger'>Моя броня отражает [src]!</span>")

	..(target, blocked)
	reagents.flags &= ~(NO_REACT)
	reagents.handle_reactions()
	return BULLET_ACT_HIT

/obj/projectile/bullet/dart/metalfoam/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/aluminium, 15)
	reagents.add_reagent(/datum/reagent/foaming_agent, 5)
	reagents.add_reagent(/datum/reagent/toxin/acid/fluacid, 5)

/obj/projectile/bullet/dart/syringe
	name = "шприц"
	icon_state = "syringeproj"
