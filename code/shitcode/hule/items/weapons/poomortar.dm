/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/poo_mortar
	name = "R3801U710N two-twenty-eight poo mortar"
	desc = "����."
	icon_state = "mecha_bananamrtr"
	projectile = /obj/item/reagent_containers/food/snacks/poo
	fire_sound = 'sound/items/bikehorn.ogg'
	//projectiles = 15
	//missile_speed = 1.5
	projectile_energy_cost = 100
	equip_cooldown = 20

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/poo_mortar/can_attach(obj/mecha/M)
	if(..()) //combat mech
		return 1
	else if(M.equipment.len < M.max_equip && istype(M))
		return 1
	return 0

/datum/crafting_recipe/poomortar  //��� ���� ������ ��� �������� ������ ��� ������������
	name = "poo mortar"
	result = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/poo_mortar
	time = 600
	reqs = list(/obj/item/mecha_parts/mecha_equipment/weapon/energy/plasma = 1,
				/datum/reagent/fuel = 100,
				/obj/item/reagent_containers/food/snacks/poo = 15,
				/obj/item/stack/sheet/metal = 1)
	tools = list(TOOL_WELDER, TOOL_SCREWDRIVER, TOOL_WIRECUTTER, TOOL_WRENCH)
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON