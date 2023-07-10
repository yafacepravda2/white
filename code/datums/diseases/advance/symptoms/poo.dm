/*
//////////////////////////////////////
Shitting
	Noticable.
	Little Resistance.
	Doesn't increase stage speed much.
	Transmissibile.
	Low Level.
BONUS
	Will force the affected mob to shitting more often!
//////////////////////////////////////
*/

/datum/symptom/poo

	name = "Понос"
	desc = "Вирус, который вызывает дикий понос у носителя."
	stealth = -1
	resistance = 3
	stage_speed = 1
	transmittable = 2
	level = 1
	severity = 1
	base_message_chance = 15
	symptom_delay_min = 30
	symptom_delay_max = 50
	var/infective = FALSE
	threshold_descs = list(
		"Сопротивление 3" = "Носитель теряет предметы из рук при дефекации.",
		"Сопротивление 10" = "Носитель обездвиживается, когда происходит дефекация.",
		"Скорость 6" = "Увеличивает скорость дефекации.",
		"Если по воздуху" = "Понос заражает всех, кто его смог учуять.",
		"Скрытность 4" = "Симптом остаётся скрытым."
	)

/datum/symptom/poo/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["stealth"] >= 4)
		suppress_warning = TRUE
	if(A.spread_flags & DISEASE_SPREAD_AIRBORNE) //infect bystanders
		infective = TRUE
	if(A.properties["resistance"] >= 3) //strong enough to drop items
		power = 1.5
	if(A.properties["resistance"] >= 10) //strong enough to stun (rarely)
		power = 2
	if(A.properties["stage_rate"] >= 6) //shitting more often
		symptom_delay_max = 40

/datum/symptom/poo/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(1, 2, 3)
			if(prob(base_message_chance) && !suppress_warning)
				to_chat(M, "<span notice='warning'>[pick("Что-то хочет выйти из моего ануса.", "Пержу с подливой.")]</span>")
		else
			M.emote("poo")
			if(power >= 1.5)
				var/obj/item/I = M.get_active_held_item()
				if(I && I.w_class == WEIGHT_CLASS_TINY)
					M.dropItemToGround(I)
			if(power >= 2 && prob(10))
				to_chat(M, "<span notice='userdanger'>[pick("Врата прорвало!", "Не могу перестать СРАТЬ!")]</span>")
				M.Immobilize(20)
				M.emote("poo")
				addtimer(CALLBACK(M, /mob/.proc/emote, "poo"), 12)
				addtimer(CALLBACK(M, /mob/.proc/emote, "poo"), 24)
				addtimer(CALLBACK(M, /mob/.proc/emote, "poo"), 36)
			if(infective && M.CanSpreadAirborneDisease())
				A.spread(1)
