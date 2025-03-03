/obj/machinery/computer/shuttle_flight/ferry
	name = "transport ferry console"
	desc = "A console that controls the transport ferry."
	circuit = /obj/item/circuitboard/computer/ferry
	shuttleId = "ferry"
	possible_destinations = "ferry_home;ferry_away;ferry_escape"
	req_access = list(ACCESS_CENT_GENERAL)
	var/allow_silicons = FALSE
	var/allow_emag = FALSE

/obj/machinery/computer/shuttle_flight/ferry/emag_act(mob/user)
	if(!allow_emag)
		to_chat(user, span_warning("[capitalize(src.name)] сообщает о том, что синдикат вроде как может и на хуй пойти, ладно?"))
		return FALSE
	return ..()

/obj/machinery/computer/shuttle_flight/ferry/attack_ai()
	return allow_silicons ? ..() : FALSE

/obj/machinery/computer/shuttle_flight/ferry/attack_robot()
	return allow_silicons ? ..() : FALSE

/obj/machinery/computer/shuttle_flight/ferry/request
	name = "ferry console"
	circuit = /obj/item/circuitboard/computer/ferry/request
	possible_destinations = "ferry_home;ferry_away;ferry_escape"
	req_access = list(ACCESS_CENT_GENERAL)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
