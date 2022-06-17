/obj/item/melee/touch_attack
	name = "\improper outstretched hand"
	desc = "High Five?"
	var/catchphrase = "High Five!"
	var/on_use_sound = null
	var/obj/effect/proc_holder/spell/targeted/touch/attached_spell
	icon = 'icons/obj/items_and_weapons.dmi'
	lefthand_file = 'icons/mob/inhands/misc/touchspell_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/touchspell_righthand.dmi'
	icon_state = "latexballon"
	inhand_icon_state = null
	item_flags = NEEDS_PERMIT | ABSTRACT | DROPDEL
	w_class = WEIGHT_CLASS_HUGE
	force = 0
	throwforce = 0
	throw_range = 0
	throw_speed = 0
	var/charges = 1

/obj/item/melee/touch_attack/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)

/obj/item/melee/touch_attack/attack(mob/target, mob/living/carbon/user)
	if(!iscarbon(user)) //Look ma, no hands
		return
	if(!(user.mobility_flags & MOBILITY_USE))
		to_chat(user, span_warning("You can't reach out!"))
		return
	..()

/obj/item/melee/touch_attack/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(catchphrase)
		user.say(catchphrase, forced = "spell")
	playsound(get_turf(user), on_use_sound,50,TRUE)
	charges--
	if(charges <= 0)
		qdel(src)

/obj/item/melee/touch_attack/proc/use_charge(mob/living/user, whisper = FALSE)
	if(QDELETED(src))
		return

	if(catchphrase)
		if(whisper)
			user.say("#[catchphrase]", forced = "spell")
		else
			user.say(catchphrase, forced = "spell")
	playsound(get_turf(user), on_use_sound, 50, TRUE)
	if(--charges <= 0)
		qdel(src)

/obj/item/melee/touch_attack/Destroy()
	if(attached_spell)
		attached_spell.on_hand_destroy(src)
	return ..()

/obj/item/melee/touch_attack/disintegrate
	name = "\improper smiting touch"
	desc = "This hand of mine glows with an awesome power!"
	catchphrase = "EI NATH!!"
	on_use_sound = 'sound/magic/disintegrate.ogg'
	icon_state = "disintegrate"
	inhand_icon_state = "disintegrate"

/obj/item/melee/touch_attack/disintegrate/afterattack(mob/living/target, mob/living/carbon/user, proximity)
	if(!proximity || target == user || !istype(target) || !iscarbon(user) || !(user.mobility_flags & MOBILITY_USE)) //exploding after touching yourself would be bad
		return
	if(!user.can_speak_vocal())
		to_chat(user, span_warning("You can't get the words out!"))
		return
	do_sparks(4, FALSE, target.loc)
	for(var/mob/living/L in view(src, 7))
		if(L != user)
			L.flash_act(affect_silicon = FALSE)
	var/atom/A = target.anti_magic_check()
	if(A)
		if(isitem(A))
			target.visible_message(span_warning("[target] [A] glows brightly as it wards off the spell!"))
		user.visible_message(span_warning("The feedback blows [user] arm off!") ,span_userdanger("The spell bounces from [target] skin back into your arm!"))
		user.flash_act()
		var/obj/item/bodypart/part = user.get_holding_bodypart_of_item(src)
		if(part)
			part.dismember()
		return ..()
	var/obj/item/clothing/suit/hooded/bloated_human/suit = target.get_item_by_slot(ITEM_SLOT_OCLOTHING)
	if(istype(suit))
		target.visible_message(span_danger("[target] [suit] explodes off of them into a puddle of gore!"))
		target.dropItemToGround(suit)
		qdel(suit)
		new /obj/effect/gibspawner(target.loc)
		return ..()
	target.gib()
	return ..()

/obj/item/melee/touch_attack/fleshtostone
	name = "\improper petrifying touch"
	desc = "That's the bottom line, because flesh to stone said so!"
	catchphrase = "STAUN EI!!"
	on_use_sound = 'sound/magic/fleshtostone.ogg'
	icon_state = "fleshtostone"
	inhand_icon_state = "fleshtostone"

/obj/item/melee/touch_attack/fleshtostone/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!proximity || target == user || !isliving(target) || !iscarbon(user)) //getting hard after touching yourself would also be bad
		return
	if(!(user.mobility_flags & MOBILITY_USE))
		to_chat(user, span_warning("You can't reach out!"))
		return
	if(!user.can_speak_vocal())
		to_chat(user, span_warning("You can't get the words out!"))
		return
	var/mob/living/M = target
	if(M.anti_magic_check())
		to_chat(user, span_warning("The spell can't seem to affect [M]!"))
		to_chat(M, span_warning("You feel your flesh turn to stone for a moment, then revert back!"))
		..()
		return
	M.Stun(40)
	M.petrify()
	return ..()

/obj/item/melee/touch_attack/fleshtostone/midas
	name = "рука мидаса"
	desc = "То, что превратит существо в золото!"
	catchphrase = "PO F'ARM'U CH'EMP'ION!!"
	on_use_sound = 'white/valtos/sounds/midas.ogg'
	icon_state = "fleshtostone"
	inhand_icon_state = "fleshtostone"
	color = "#ff9900"

/obj/item/melee/touch_attack/fleshtostone/midas/afterattack(atom/target, mob/living/carbon/user, proximity)
	. = ..()
	if(target)
		var/obj/O = locate(/obj/structure/statue/petrified) in get_turf(target)
		if(O)
			O.color = "#ff9900"
			O.desc = "Невероятно реалистичное золотое сечение."
			custom_materials = list(/datum/material/gold = 10000)
