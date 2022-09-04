//Thing that you stick on the floor
/obj/item/clockwork/trap_placer
	name = "ловушка"
	desc = "джокера"
	icon = 'icons/obj/clockwork_objects.dmi'
	w_class = WEIGHT_CLASS_HUGE
	var/result_path = /obj/structure/destructible/clockwork/trap

/obj/item/clockwork/trap_placer/attack_self(mob/user)
	. = ..()
	if(!is_servant_of_ratvar(user))
		return
	for(var/obj/structure/destructible/clockwork/trap/T in get_turf(src))
		if(istype(T, type))
			to_chat(user, "<span class='warning'>That space is occupied!</span>")
			return
	to_chat(user, "<span class='brass'>You place [src], use a <b>clockwork slab</b> to link it to other traps.</span>")
	var/obj/new_obj = new result_path(get_turf(src))
	new_obj.setDir(user.dir)
	qdel(src)

//Thing you stick on the wall
/obj/item/wallframe/clocktrap
	name = "эээ"
	desc = "че?"
	icon = 'icons/obj/clockwork_objects.dmi'
	pixel_shift = -24
	w_class = WEIGHT_CLASS_HUGE
	result_path = /obj/structure/destructible/clockwork/trap

/obj/item/wallframe/clocktrap/examine(mob/user)
	. = ..()
	if(is_servant_of_ratvar(user))
		. += "<span class='brass'><hr>Это можно разместить на стене.</span>"

//Wall item (either spawned by a wallframe or directly)
/obj/structure/destructible/clockwork/trap
	name = "ыыы"
	desc = "пук"
	icon = 'icons/obj/clockwork_objects.dmi'
	density = FALSE
	layer = LOW_OBJ_LAYER
	break_message = "<span class='warning'>Замысловатое устройство разваливается.</span>"
	var/unwrench_path = /obj/item/wallframe/clocktrap
	var/component_datum = /datum/component/clockwork_trap

/obj/structure/destructible/clockwork/trap/Initialize(mapload)
	. = ..()
	AddComponent(component_datum)

/obj/structure/destructible/clockwork/trap/wrench_act(mob/living/user, obj/item/I)
	. = ..()
	to_chat(user, "<span class='warning'>Начинаю откручивать [src]...</span>")
	if(do_after(user, 50, target=src))
		to_chat(user, "<span class='warning'>Отсоединяю [src], убирая все подключения к нему.</span>")
		new unwrench_path(get_turf(src))
		qdel(src)
		return TRUE

//Component
/datum/component/clockwork_trap
	var/list/outputs
	var/sends_input = FALSE
	var/takes_input = FALSE

/datum/component/clockwork_trap/Initialize(mapload)
	. = ..()
	outputs = list()

	RegisterSignal(parent, COMSIG_CLOCKWORK_SIGNAL_RECEIVED, .proc/trigger)
	RegisterSignal(parent, COMSIG_ATOM_EMINENCE_ACT, .proc/trigger)	//The eminence can trigger traps too
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, .proc/clicked)
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/OnAttackBy)

/datum/component/clockwork_trap/proc/add_input(datum/component/clockwork_trap/input)
	outputs |= input.parent

/datum/component/clockwork_trap/proc/add_output(datum/component/clockwork_trap/output)
	output.outputs |= parent

/datum/component/clockwork_trap/proc/trigger()
	return TRUE

/datum/component/clockwork_trap/proc/clicked(mob/user)
	return

/datum/component/clockwork_trap/proc/OnAttackBy(datum/source, obj/item/I, mob/user)
	if(is_servant_of_ratvar(user))
		if(istype(I, /obj/item/clockwork/clockwork_slab))
			var/obj/item/clockwork/clockwork_slab/slab = I
			if(slab.buffer)
				if(takes_input)
					to_chat(user, "<span class='brass'>Подключаю [slab.buffer.parent] к [parent].</span>")
					add_output(slab.buffer)
					slab.buffer = null
				else
					to_chat(user, "<span class='brass'>У этого механизма нет входа.</span>")
			else
				if(sends_input)
					to_chat(user, "<span class='brass'>Буду подключать [parent] к другим механизмам.</span>")
					slab.buffer = src
				else
					to_chat(user, "<span class='brass'>Этот механизм не имеет выходов.</span>")

/datum/component/clockwork_trap/proc/trigger_connected()
	for(var/obj/O in outputs)
		SEND_SIGNAL(O, COMSIG_CLOCKWORK_SIGNAL_RECEIVED)
