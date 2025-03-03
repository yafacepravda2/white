/obj/item/stack/sheet
	name = "лист"
	lefthand_file = 'icons/mob/inhands/misc/sheets_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/sheets_righthand.dmi'
	icon_state = "sheet-metal_3" //затычка, она вас не укусит
	full_w_class = WEIGHT_CLASS_NORMAL
	force = 5
	throwforce = 5
	max_amount = 50
	throw_speed = 1
	throw_range = 3
	attack_verb_continuous = list("лупит", "бьёт", "разбивает", "вмазывает", "атакует")
	attack_verb_simple = list("лупит", "бьёт", "разбивает", "вмазывает", "атакует")
	novariants = FALSE
	var/sheettype = null //this is used for girders in the creation of walls/false walls
	var/point_value = 0 //turn-in value for the gulag stacker - loosely relative to its rarity.
	///What type of wall does this sheet spawn
	var/walltype
	merge_parent = TRUE

/obj/item/stack/sheet/Initialize(mapload, new_amount, merge = TRUE, list/mat_override=null, mat_amt=1)
	. = ..()
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)

/**
 * Facilitates sheets being smacked on the floor
 *
 * This is used for crafting by hitting the floor with items.
 * The inital use case is glass sheets breaking in to shards when the floor is hit.
 * Args:
 * * user: The user that did the action
 * * params: paramas passed in from attackby
 */
/obj/item/stack/sheet/proc/on_attack_floor(mob/user, params)
	var/list/shards = list()
	for(var/datum/material/mat in custom_materials)
		if(mat.shard_type)
			var/obj/item/new_shard = new mat.shard_type(user.loc)
			new_shard.add_fingerprint(user)
			shards += "\a [new_shard.name]"
	if(!shards.len)
		return FALSE
	user.do_attack_animation(src, ATTACK_EFFECT_BOOP)
	playsound(src, "shatter", 70, TRUE)
	use(1)
	user.visible_message(span_notice("[user] разбивает лист [name] об пол, оставляя [english_list(shards)].") , \
		span_notice("Разбиваю лист [name] об пол, оставляя [english_list(shards)]."))
	return TRUE
