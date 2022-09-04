/**
 * This file contain the eight parts surrounding the main core, those are: fuel input, moderator input, waste output, interface and the corners
 * The file also contain the guicode of the machine
 */
/obj/machinery/atmospherics/components/unary/hypertorus
	icon = 'icons/obj/atmospherics/components/hypertorus.dmi'
	icon_state = "core"

	name = "thermomachine"
	desc = "Heats or cools gas in connected pipes."
	anchored = TRUE
	density = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1
	layer = OBJ_LAYER
	pipe_flags = PIPING_ONE_PER_TURF | PIPING_DEFAULT_LAYER_ONLY
	circuit = /obj/item/circuitboard/machine/thermomachine
	///Vars for the state of the icon of the object (open, off, active)
	var/icon_state_open
	var/icon_state_off
	var/icon_state_active
	///Check if the machine has been activated
	var/active = FALSE
	///Check if fusion has started
	var/fusion_started = FALSE
	///Check if the machine is cracked open
	var/cracked = FALSE

/obj/machinery/atmospherics/components/unary/hypertorus/Initialize(mapload)
	. = ..()
	initialize_directions = dir

/obj/machinery/atmospherics/components/unary/hypertorus/examine(mob/user)
	. = ..()
	. += "<span class='notice'>[src] can be rotated by first opening the panel with a screwdriver and then using a wrench on it.</span>"

/obj/machinery/atmospherics/components/unary/hypertorus/attackby(obj/item/I, mob/user, params)
	if(!fusion_started)
		if(default_deconstruction_screwdriver(user, icon_state_open, icon_state_off, I))
			return
	if(default_change_direction_wrench(user, I))
		return
	if(default_deconstruction_crowbar(I))
		return
	return ..()

/obj/machinery/atmospherics/components/unary/hypertorus/welder_act(mob/living/user, obj/item/tool)
	if(!cracked)
		return FALSE
	if(user.a_intent == INTENT_HARM)
		return FALSE
	balloon_alert(user, "You start repairing the crack...")
	if(tool.use_tool(src, user, 10 SECONDS, volume=30, amount=5))
		balloon_alert(user, "You repaired the crack.")
		cracked = FALSE
		update_appearance()

/obj/machinery/atmospherics/components/unary/hypertorus/default_change_direction_wrench(mob/user, obj/item/I)
	. = ..()
	if(.)
		var/obj/machinery/atmospherics/node = nodes[1]
		if(node)
			node.disconnect(src)
			nodes[1] = null
			if(parents[1])
				nullifyNode(parents[1])
		atmosinit()
		node = nodes[1]
		if(node)
			node.atmosinit()
			node.addMember(src)
		SSair.add_to_rebuild_queue(src)

/obj/machinery/atmospherics/components/unary/hypertorus/update_icon_state()
	if(panel_open)
		icon_state = icon_state_open
		return ..()
	if(active)
		icon_state = icon_state_active
		return ..()
	icon_state = icon_state_off
	return ..()

/obj/machinery/atmospherics/components/unary/hypertorus/update_overlays()
	. = ..()
	if(!cracked)
		return
	var/image/crack = image(icon, icon_state = "crack")
	crack.dir = dir
	. += crack

/obj/machinery/atmospherics/components/unary/hypertorus/fuel_input
	name = "Термоядерный реактор - Топливный порт"
	desc = "Входной порт термоядерного реактора, принимает исключительно водород и тритий в газообразной форме."
	icon_state = "fuel_input_off"
	icon_state_open = "fuel_input_open"
	icon_state_off = "fuel_input_off"
	icon_state_active = "fuel_input_active"
	circuit = /obj/item/circuitboard/machine/HFR_fuel_input

/obj/machinery/atmospherics/components/unary/hypertorus/waste_output
	name = "Термоядерный реактор - Порт вывода"
	desc = "Выпускной порт термоядерного реактора, предназначенный для вывода горячих отработанных газов, сбрасываемых из активной зоны машины."
	icon_state = "waste_output_off"
	icon_state_open = "waste_output_open"
	icon_state_off = "waste_output_off"
	icon_state_active = "waste_output_active"
	circuit = /obj/item/circuitboard/machine/HFR_waste_output

/obj/machinery/atmospherics/components/unary/hypertorus/moderator_input
	name = "Термоядерный реактор - Порт регулятора"
	desc = "Порт регулятора термоядерного реактора, предназначенный для охлаждения и управления протекания реакции."
	icon_state = "moderator_input_off"
	icon_state_open = "moderator_input_open"
	icon_state_off = "moderator_input_off"
	icon_state_active = "moderator_input_active"
	circuit = /obj/item/circuitboard/machine/HFR_moderator_input

/*
* Interface and corners
*/
/obj/machinery/hypertorus
	name = "hypertorus_core"
	desc = "hypertorus_core"
	icon = 'icons/obj/atmospherics/components/hypertorus.dmi'
	icon_state = "core"
	move_resist = INFINITY
	anchored = TRUE
	density = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1
	power_channel = AREA_USAGE_ENVIRON
	var/active = FALSE
	var/icon_state_open
	var/icon_state_off
	var/icon_state_active
	var/fusion_started = FALSE

/obj/machinery/hypertorus/examine(mob/user)
	. = ..()
	. += "<span class='notice'>[src] can be rotated by first opening the panel with a screwdriver and then using a wrench on it.</span>"

/obj/machinery/hypertorus/attackby(obj/item/I, mob/user, params)
	if(!fusion_started)
		if(default_deconstruction_screwdriver(user, icon_state_open, icon_state_off, I))
			return
	if(default_change_direction_wrench(user, I))
		return
	if(default_deconstruction_crowbar(I))
		return
	return ..()

/obj/machinery/hypertorus/update_icon_state()
	if(panel_open)
		icon_state = icon_state_open
		return ..()
	if(active)
		icon_state = icon_state_active
		return ..()
	icon_state = icon_state_off
	return ..()

/obj/machinery/hypertorus/interface
	name = "Термоядерный реактор - Интерфейс"
	desc = "Интерфейс термоядерного реактора для управления протекания реакции."
	icon_state = "interface_off"
	circuit = /obj/item/circuitboard/machine/HFR_interface
	var/obj/machinery/atmospherics/components/unary/hypertorus/core/connected_core
	icon_state_off = "interface_off"
	icon_state_open = "interface_open"
	icon_state_active = "interface_active"

/obj/machinery/hypertorus/interface/Destroy()
	if(connected_core)
		connected_core = null
	return..()

/obj/machinery/hypertorus/interface/multitool_act(mob/living/user, obj/item/I)
	. = ..()
	var/turf/T = get_step(src,turn(dir,180))
	var/obj/machinery/atmospherics/components/unary/hypertorus/core/centre = locate() in T

	if(!centre || !centre.check_part_connectivity())
		to_chat(user, "<span class='notice'>Check all parts and then try again.</span>")
		return TRUE
	new/obj/item/paper/guides/jobs/atmos/hypertorus(loc)
	connected_core = centre

	connected_core.activate(user)
	return TRUE

/obj/machinery/hypertorus/interface/ui_interact(mob/user, datum/tgui/ui)
	if(active)
		ui = SStgui.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "Hypertorus", name)
			ui.open()
	else
		to_chat(user, "<span class='notice'>Activate the machine first by using a multitool on the interface.</span>")

/obj/machinery/hypertorus/interface/ui_static_data()
	var/data = list()
	data["base_max_temperature"] = FUSION_MAXIMUM_TEMPERATURE
	data["selectable_fuel"] = list(list("name" = "Nothing", "id" = null))
	for(var/path in GLOB.hfr_fuels_list)
		var/datum/hfr_fuel/recipe = GLOB.hfr_fuels_list[path]

		data["selectable_fuel"] += list(list(
			"name" = recipe.name,
			"id" = recipe.id,
			"requirements" = recipe.requirements,
			"fusion_byproducts" = recipe.primary_products,
			"product_gases" = recipe.secondary_products,
			"recipe_cooling_multiplier" = recipe.negative_temperature_multiplier,
			"recipe_heating_multiplier" = recipe.positive_temperature_multiplier,
			"energy_loss_multiplier" = recipe.energy_concentration_multiplier,
			"fuel_consumption_multiplier" = recipe.fuel_consumption_multiplier,
			"gas_production_multiplier" = recipe.gas_production_multiplier,
			"temperature_multiplier" = recipe.temperature_change_multiplier,
		))
	return data

/obj/machinery/hypertorus/interface/ui_data()
	var/data = list()

	if(connected_core.selected_fuel)
		data["selected"] = connected_core.selected_fuel.id
	else
		data["selected"] = ""

	//Internal Fusion gases
	var/list/fusion_gasdata = list()
	if(connected_core.internal_fusion.total_moles())
		for(var/gas_id in connected_core.internal_fusion.get_gases())
			fusion_gasdata.Add(list(list(
			"id"= gas_id,
			"amount" = round(connected_core.internal_fusion.get_moles(gas_id), 0.01),
			)))
	else
		for(var/gas_id in connected_core.internal_fusion.get_gases())
			fusion_gasdata.Add(list(list(
				"id"= gas_id,
				"amount" = 0,
				)))
	//Moderator gases
	var/list/moderator_gasdata = list()
	if(connected_core.moderator_internal.total_moles())
		for(var/gas_id in connected_core.moderator_internal.get_gases())
			moderator_gasdata.Add(list(list(
			"id"= gas_id,
			"amount" = round(connected_core.moderator_internal.get_moles(gas_id), 0.01),
			)))
	else
		for(var/gas_id in connected_core.moderator_internal.get_gases())
			moderator_gasdata.Add(list(list(
				"id"= gas_id,
				"amount" = 0,
				)))

	data["fusion_gases"] = fusion_gasdata
	data["moderator_gases"] = moderator_gasdata

	data["energy_level"] = connected_core.energy
	data["heat_limiter_modifier"] = connected_core.heat_limiter_modifier
	data["heat_output_min"] = connected_core.heat_output_min
	data["heat_output_max"] = connected_core.heat_output_max
	data["heat_output"] = connected_core.heat_output
	data["instability"] = connected_core.instability

	data["heating_conductor"] = connected_core.heating_conductor
	data["magnetic_constrictor"] = connected_core.magnetic_constrictor
	data["fuel_injection_rate"] = connected_core.fuel_injection_rate
	data["moderator_injection_rate"] = connected_core.moderator_injection_rate
	data["current_damper"] = connected_core.current_damper

	data["power_level"] = connected_core.power_level
	data["apc_energy"] = connected_core.get_area_cell_percent()
	data["iron_content"] = connected_core.iron_content
	data["integrity"] = connected_core.get_integrity_percent()

	data["start_power"] = connected_core.start_power
	data["start_cooling"] = connected_core.start_cooling
	data["start_fuel"] = connected_core.start_fuel
	data["start_moderator"] = connected_core.start_moderator

	data["internal_fusion_temperature"] = connected_core.fusion_temperature
	data["moderator_internal_temperature"] = connected_core.moderator_temperature
	data["internal_output_temperature"] = connected_core.output_temperature
	data["internal_coolant_temperature"] = connected_core.coolant_temperature

	data["internal_fusion_temperature_archived"] = connected_core.fusion_temperature_archived
	data["moderator_internal_temperature_archived"] = connected_core.moderator_temperature_archived
	data["internal_output_temperature_archived"] = connected_core.output_temperature_archived
	data["internal_coolant_temperature_archived"] = connected_core.coolant_temperature_archived
	data["temperature_period"] = connected_core.temperature_period

	data["waste_remove"] = connected_core.waste_remove
	data["filter_types"] = list()
	for(var/id in GLOB.gas_data.ids)
		data["filter_types"] += list(list("gas_id" = id, "gas_name" = GLOB.gas_data.names[id], "enabled" = (id in connected_core.moderator_scrubbing)))

	data["cooling_volume"] = connected_core.airs[1].return_volume()
	data["mod_filtering_rate"] = connected_core.moderator_filtering_rate

	return data

/obj/machinery/hypertorus/interface/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("start_power")
			connected_core.start_power = !connected_core.start_power
			connected_core.update_use_power(connected_core.start_power ? ACTIVE_POWER_USE : IDLE_POWER_USE)
			. = TRUE
		if("start_cooling")
			connected_core.start_cooling = !connected_core.start_cooling
			. = TRUE
		if("start_fuel")
			connected_core.start_fuel = !connected_core.start_fuel
			. = TRUE
		if("start_moderator")
			connected_core.start_moderator = !connected_core.start_moderator
			. = TRUE
		if("heating_conductor")
			var/heating_conductor = text2num(params["heating_conductor"])
			if(heating_conductor != null)
				connected_core.heating_conductor = clamp(heating_conductor, 50, 500)
				. = TRUE
		if("magnetic_constrictor")
			var/magnetic_constrictor = text2num(params["magnetic_constrictor"])
			if(magnetic_constrictor != null)
				connected_core.magnetic_constrictor = clamp(magnetic_constrictor, 50, 1000)
				. = TRUE
		if("fuel_injection_rate")
			var/fuel_injection_rate = text2num(params["fuel_injection_rate"])
			if(fuel_injection_rate != null)
				connected_core.fuel_injection_rate = clamp(fuel_injection_rate, 0.5, 150)
				. = TRUE
		if("moderator_injection_rate")
			var/moderator_injection_rate = text2num(params["moderator_injection_rate"])
			if(moderator_injection_rate != null)
				connected_core.moderator_injection_rate = clamp(moderator_injection_rate, 0.5, 150)
				. = TRUE
		if("current_damper")
			var/current_damper = text2num(params["current_damper"])
			if(current_damper != null)
				connected_core.current_damper = clamp(current_damper, 0, 1000)
				. = TRUE
		if("waste_remove")
			connected_core.waste_remove = !connected_core.waste_remove
			. = TRUE
		if("filter")
			connected_core.moderator_scrubbing ^= params["mode"]
			. = TRUE
		if("mod_filtering_rate")
			var/mod_filtering_rate = text2num(params["mod_filtering_rate"])
			if(mod_filtering_rate != null)
				connected_core.moderator_filtering_rate = clamp(mod_filtering_rate, 5, 200)
				. = TRUE
		if("fuel")
			connected_core.selected_fuel = null
			var/fuel_mix = "nothing"
			var/datum/hfr_fuel/fuel = null
			if(params["mode"] != "")
				fuel = GLOB.hfr_fuels_list[params["mode"]]
			if(fuel)
				connected_core.selected_fuel = fuel
				fuel_mix = fuel.name
			if(connected_core.internal_fusion.total_moles())
				connected_core.dump_gases()
			connected_core.update_parents() //prevent the machine from stopping because of the recipe change and the pipenet not updating
			connected_core.linked_input.update_parents()
			connected_core.linked_output.update_parents()
			connected_core.linked_moderator.update_parents()
			investigate_log("was set to recipe [fuel_mix ? fuel_mix : "null"] by [key_name(usr)]", INVESTIGATE_ATMOS)
			. = TRUE
		if("cooling_volume")
			var/cooling_volume = text2num(params["cooling_volume"])
			if(cooling_volume != null)
				connected_core.airs[1].set_volume(clamp(cooling_volume, 50, 2000))
				. = TRUE

/obj/machinery/hypertorus/corner
	name = "Термоядерный реактор - Корпус"
	desc = "Конструктивная часть машины."
	icon_state = "corner_off"
	circuit = /obj/item/circuitboard/machine/HFR_corner
	icon_state_off = "corner_off"
	icon_state_open = "corner_open"
	icon_state_active = "corner_active"
	dir = SOUTHEAST

/obj/item/paper/guides/jobs/atmos/hypertorus
	name = "paper- 'Краткое руководство по Термоядерныму Реактору'"
	info = "<B>Как безопасно управлять Термоядерным реактором</B><BR>\
	-Соберите машину так, как показано в главном руководстве.<BR>\
	- Сделайте газовую смесь 50/50 из трития и водорода общим количеством около 2000 молей.<BR>\
	-Запустите машину, заполните контур охлаждения плазмой / гиперноблием и используйте космос или термомашины для его охлаждения.<BR>\
	-Подсоедините топливную смесь к отверстию топливного порта, впустите в машину только 1000 молей, чтобы облегчить запуск реакции<BR>\
	-Установите значение теплопроводности на 500 при запуске реакции, сбросьте его на 100, когда уровень мощности превышает 1<BR>\
	-В случае расплавления установите теплопровод на максимальное значение и установите демпфер тока на максимальное значение. Установите впрыск топлива на минимальное значение. \
	Если тепловая мощность не становится отрицательной, попробуйте заменить магнитные ограничители до тех пор, пока тепловая мощность не станет отрицательной. \
	Сделайте охлаждение сильнее, поместите газы с высокой теплоемкостью внутрь замедлителя (гиперноблий поможет справиться с проблемой)<BR><BR>\
	<B>Предупреждения:</B><BR>\
	-Вы не можете демонтировать машину, если уровень мощности превышает 0<BR>\
	-Вы не можете включить машину, если уровень мощности превышает 0<BR>\
	-Вы не можете утилизировать отходящие газы, если уровень мощности превышает 5<BR>\
	-Вы не можете удалить газы из термоядерной смеси, если они не являются гелием и антиноблием<BR>\
	-Гиперноблий значительно уменьшит мощность микса<BR>\
	-Антиноблиум увеличит мощность микса намного больше<BR>\
	-Газы с высокой теплоемкостью труднее нагревать/охлаждать<BR>\
	-Газы с низкой теплоемкостью легче нагревать/охлаждать<BR>\
	- Машина потребляет 50 кВт на уровень мощности, достигая 350 кВт на уровне мощности 6, поэтому подготовьте реактор соответствующим образом<BR>\
	-В случае нехватки энергии термоядерная реакция ПРОДОЛЖИТСЯ, но охлаждение ПРЕКРАТИТСЯ<BR><BR>\
	Автор краткого руководства не несет ответственности за неправильное использование и разрушение, вызванные использованием руководства, \
	используйте более продвинутые руководства, чтобы понять, как различные газы будут действовать в качестве модераторов "

/obj/item/hfr_box
	name = "HFR box"
	desc = "If you see this, call the police."
	icon = 'icons/obj/atmospherics/components/hypertorus.dmi'
	icon_state = "box"
	///What kind of box are we handling?
	var/box_type = "impossible"
	///What's the path of the machine we making
	var/part_path

/obj/item/hfr_box/corner
	name = "Термоядерный реактор - Корпус"
	desc = "Устанавливать по углам."
	icon_state = "box_corner"
	box_type = "corner"
	part_path = /obj/machinery/hypertorus/corner

/obj/item/hfr_box/body
	name = "HFR box body"
	desc = "Устанавливать сверху, снизу, справа или слева от ядра."
	box_type = "body"
	icon_state = "box_body"

/obj/item/hfr_box/body/fuel_input
	name = "Термоядерный реактор - Топливный порт"
	part_path = /obj/machinery/atmospherics/components/unary/hypertorus/fuel_input

/obj/item/hfr_box/body/moderator_input
	name = "Термоядерный реактор - Порт регулятора"
	part_path = /obj/machinery/atmospherics/components/unary/hypertorus/moderator_input

/obj/item/hfr_box/body/waste_output
	name = "Термоядерный реактор - Порт вывода"
	part_path = /obj/machinery/atmospherics/components/unary/hypertorus/waste_output

/obj/item/hfr_box/body/interface
	name = "Термоядерный реактор - Интерфейс"
	part_path = /obj/machinery/hypertorus/interface

/obj/item/hfr_box/core
	name = "Термоядерный реактор - Ядро"
	desc = "Активируйте при помощи мультитула, чтобы развернуть всю машину после настройки других блоков"
	icon_state = "box_core"
	box_type = "core"
	part_path = /obj/machinery/atmospherics/components/unary/hypertorus/core

/obj/item/hfr_box/core/multitool_act(mob/living/user, obj/item/I)
	. = ..()
	var/list/parts = list()
	for(var/obj/item/hfr_box/box in orange(1,src))
		var/direction = get_dir(src, box)
		if(box.box_type == "corner")
			if(ISDIAGONALDIR(direction))
				box.dir = direction
				parts |= box
			continue
		if(box.box_type == "body")
			if(direction in GLOB.cardinals)
				box.dir = direction
				parts |= box
			continue
	if(parts.len == 8)
		build_reactor(parts)
	return

/obj/item/hfr_box/core/proc/build_reactor(list/parts)
	for(var/obj/item/hfr_box/box in parts)
		if(box.box_type == "corner")
			var/obj/machinery/hypertorus/corner/corner = new box.part_path(box.loc)
			corner.dir = box.dir
			qdel(box)
			continue
		if(box.box_type == "body")
			var/location = get_turf(box)
			if(box.part_path != /obj/machinery/hypertorus/interface)
				var/obj/machinery/atmospherics/components/unary/hypertorus/part = new box.part_path(location, TRUE, box.dir)
				part.dir = box.dir
			else
				var/obj/machinery/hypertorus/interface/part = new box.part_path(location)
				part.dir = box.dir
			qdel(box)
			continue

	new/obj/machinery/atmospherics/components/unary/hypertorus/core(loc, TRUE)
	qdel(src)
