//A massive gear, effectively a girder for clocks.
/obj/structure/destructible/clockwork/wall_gear
	name = "огромная шестерня"
	icon_state = "wall_gear"
	unanchored_icon = "wall_gear"
	max_integrity = 100
	layer = BELOW_OBJ_LAYER
	desc = "Массивная латунная шестеренка. Вероятно, вы могли бы закрепить или разблокировать его гаечным ключом или просто перелезть через него."
	break_message = "<span class='warning'>Шестерня разлетается на осколки!</span>"
	debris = list(/obj/item/clockwork/alloy_shards/large = 1, \
	/obj/item/clockwork/alloy_shards/medium = 4, \
	/obj/item/clockwork/alloy_shards/small = 2) //slightly more debris than the default, totals 26 alloy

/obj/structure/destructible/clockwork/wall_gear/displaced
	anchored = FALSE

/obj/structure/destructible/clockwork/wall_gear/Initialize(mapload)
	. = ..()
	new /obj/effect/temp_visual/ratvar/gear(get_turf(src))
	AddElement(/datum/element/climbable)

/obj/structure/destructible/clockwork/wall_gear/emp_act(severity)
	return

/obj/structure/destructible/clockwork/wall_gear/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_WELDER)
		if(!I.tool_start_check(user, amount = 0))
			return
		to_chat(user, "<span class='notice'>Начинаю разрезать огромную шестерню...</span>")
		if(I.use_tool(src, user, 40, volume=50))
			to_chat(user, "<span class='notice'>Разрезаю огромную шестерню на части.</span>")
			var/obj/item/stack/tile/bronze/B = new(drop_location(), 2)
			transfer_fingerprints_to(B)
			qdel(src)

	else if(I.tool_behaviour == TOOL_WRENCH)
		default_unfasten_wrench(user, I, 10)
		return 1
	else if(I.tool_behaviour == TOOL_SCREWDRIVER)
		if(anchored)
			to_chat(user, "<span class='warning'>[src] нужно сперва открутить!</span>")
		else
			user.visible_message("<span class='warning'>[user] начинает разбирать [src].</span>" , "<span class='notice'>Начинаю разбирать [src]...</span>")
			if(I.use_tool(src, user, 30, volume=100) && !anchored)
				to_chat(user, "<span class='notice'>Разбираю [src].</span>")
				deconstruct(TRUE)
		return 1
	else if(istype(I, /obj/item/stack/tile/bronze))
		var/obj/item/stack/tile/bronze/W = I
		if(W.get_amount() < 1)
			to_chat(user, "<span class='warning'>Мне потребуется хотя бы один лист латуни для этого!</span>")
			return
		var/turf/T = get_turf(src)
		if(iswallturf(T))
			to_chat(user, "<span class='warning'>Здесь уже есть стена!</span>")
			return
		if(!isfloorturf(T))
			to_chat(user, "<span class='warning'>Нужен пол для создания [anchored ? "фальшивой ":""]стены!</span>")
			return
		if(locate(/obj/structure/falsewall) in T.contents)
			to_chat(user, "<span class='warning'>Здесь уже есть фальшивая стена!</span>")
			return
		to_chat(user, "<span class='notice'>Начинаю устанавливать [W] на [src]...</span>")
		if(do_after(user, 20, target = src))
			var/brass_floor = FALSE
			if(istype(T, /turf/open/floor/clockwork)) //if the floor is already brass, costs less to make(conservation of masssssss)
				brass_floor = TRUE
			if(W.use(2 - brass_floor))
				if(anchored)
					T.PlaceOnTop(/turf/closed/wall/clockwork)
				else
					T.PlaceOnTop(/turf/open/floor/clockwork, flags = CHANGETURF_INHERIT_AIR)
					new /obj/structure/falsewall/bronze(T)
				qdel(src)
			else
				to_chat(user, "<span class='warning'>Мне потребуется больше латуни чтобы сделать [anchored ? "фальшивую ":""]стену!</span>")
		return 1
	return ..()

/obj/structure/destructible/clockwork/wall_gear/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1) && disassembled)
		new /obj/item/stack/tile/bronze(loc, 3)
	return ..()
