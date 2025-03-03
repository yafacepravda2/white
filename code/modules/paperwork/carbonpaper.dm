/obj/item/paper/carbon
	name = "углеродный лист"
	icon_state = "paper_stack"
	inhand_icon_state = "paper"
	show_written_words = FALSE
	var/copied = FALSE
	var/iscopy = FALSE

/obj/item/paper/carbon/update_icon_state()
	. = ..()
	if(iscopy)
		icon_state = "cpaper"
	else if(copied)
		icon_state = "paper"
	else
		icon_state = "paper_stack"
	if(info)
		icon_state = "[icon_state]_words"

/obj/item/paper/carbon/proc/removecopy(mob/living/user)
	if(!copied)
		var/obj/item/paper/carbon/C = src
		var/copycontents = C.info
		var/obj/item/paper/carbon/Copy = new /obj/item/paper/carbon(user.loc)

		if(info)
			copycontents = replacetext(copycontents, "<font face=\"[PEN_FONT]\" color=", "<font face=\"[PEN_FONT]\" nocolor=")
			copycontents = replacetext(copycontents, "<font face=\"[CRAYON_FONT]\" color=", "<font face=\"[CRAYON_FONT]\" nocolor=")
			Copy.info += copycontents
			Copy.info += "</font>"
			Copy.name = "Copy - [C.name]"
		to_chat(user, span_notice("Оторвал образец углеродного листа!"))
		C.copied = TRUE
		Copy.iscopy = TRUE
		Copy.update_icon_state()
		C.update_icon_state()
		user.put_in_hands(Copy)
	else
		to_chat(user, span_notice("К этой бумаге более не приложены никакие образцы углерода"))

/obj/item/paper/carbon/attack_hand(mob/living/user)
	if(loc == user && user.is_holding(src))
		removecopy(user)
		return
	return ..()
