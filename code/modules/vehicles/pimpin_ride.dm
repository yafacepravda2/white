//PIMP-CART
/obj/vehicle/ridden/janicart
	name = "janicart (pimpin' ride)"
	desc = "A brave janitor cyborg gave its life to produce such an amazing combination of speed and utility."
	icon_state = "pussywagon"
	key_type = /obj/item/key/janitor
	var/obj/item/storage/bag/trash/mybag = null
	var/floorbuffer = FALSE

/obj/vehicle/ridden/janicart/Initialize(mapload)
	. = ..()
	update_icon()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/janicart)

	GLOB.janitor_devices += src

	if(floorbuffer)
		AddElement(/datum/element/cleaning)

/obj/vehicle/ridden/janicart/Destroy()
	GLOB.janitor_devices -= src
	if(mybag)
		QDEL_NULL(mybag)
	return ..()

/obj/item/janiupgrade
	name = "модернизация полоукладчика"
	desc = "Модернизация для ремонта пола на ДжениКаре."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "upgrade"

/obj/vehicle/ridden/janicart/examine(mob/user)
	. = ..()
	if(floorbuffer)
		. += "<hr>It has been upgraded with a floor buffer."

/obj/vehicle/ridden/janicart/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/storage/bag/trash))
		if(mybag)
			to_chat(user, "<span class='warning'>[capitalize(src.name)] already has a trashbag hooked!</span>")
			return
		if(!user.transferItemToLoc(I, src))
			return
		to_chat(user, "<span class='notice'>You hook the trashbag onto [src].</span>")
		mybag = I
		update_icon()
	else if(istype(I, /obj/item/janiupgrade))
		if(floorbuffer)
			to_chat(user, "<span class='warning'>[capitalize(src.name)] already has a floor buffer!</span>")
			return
		floorbuffer = TRUE
		qdel(I)
		to_chat(user, "<span class='notice'>You upgrade [src] with the floor buffer.</span>")
		AddElement(/datum/element/cleaning)
		update_icon()
	else if(mybag)
		mybag.attackby(I, user)
	else
		return ..()

/obj/vehicle/ridden/janicart/update_overlays()
	. = ..()
	if(mybag)
		. += "cart_garbage"
	if(floorbuffer)
		. += "cart_buffer"

/obj/vehicle/ridden/janicart/attack_hand(mob/user)
	. = ..()
	if(. || !mybag)
		return
	mybag.forceMove(get_turf(user))
	user.put_in_hands(mybag)
	mybag = null
	update_icon()

/obj/vehicle/ridden/janicart/upgraded
	floorbuffer = TRUE
