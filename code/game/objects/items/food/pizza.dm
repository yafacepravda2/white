// Pizza (Whole)
/obj/item/food/pizza
	icon = 'icons/obj/food/pizzaspaghetti.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	max_volume = 80
	food_reagents = list(/datum/reagent/consumable/nutriment = 28, /datum/reagent/consumable/nutriment/protein = 3, /datum/reagent/consumable/tomatojuice = 6, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("корка" = 1, "томаты" = 1, "сыр" = 1)
	foodtypes = GRAIN | DAIRY | VEGETABLES
	venue_value = FOOD_PRICE_CHEAP
	gender = FEMALE
	burns_in_oven = TRUE
	/// type is spawned 6 at a time and replaces this pizza when processed by cutting tool
	var/obj/item/food/pizzaslice/slice_type
	///What label pizza boxes use if this pizza spawns in them.
	var/boxtag = ""

/obj/item/food/pizza/raw
	foodtypes =  GRAIN | DAIRY | VEGETABLES | RAW
	burns_in_oven = FALSE
	slice_type = null
	boxtag = "Хуй в пизду"

/obj/item/food/pizza/raw/MakeBakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/pizza, rand(70 SECONDS, 80 SECONDS), TRUE, TRUE)

/obj/item/food/pizza/MakeProcessable()
	if (slice_type)
		AddElement(/datum/element/processable, TOOL_KNIFE, slice_type, 6, 30)
		AddElement(/datum/element/processable, TOOL_SAW, slice_type, 6, 45)
		AddElement(/datum/element/processable, TOOL_SCALPEL, slice_type, 6, 60)

// Pizza Slice
/obj/item/food/pizzaslice
	icon = 'icons/obj/food/pizzaspaghetti.dmi'
	food_reagents = list(/datum/reagent/consumable/nutriment = 5)
	foodtypes = GRAIN | DAIRY | VEGETABLES
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/pizzaslice/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_ROLLINGPIN, /obj/item/stack/sheet/pizza, 1, 10)


/obj/item/food/pizza/margherita
	name = "пицца Маргарита"
	desc = "Самая сырная пицца в галактике."
	icon_state = "pizzamargherita"
	food_reagents = list(/datum/reagent/consumable/nutriment = 25, /datum/reagent/consumable/nutriment/protein = 8, /datum/reagent/consumable/tomatojuice = 6, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("корка" = 1, "томаты" = 1, "сыр" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY
	slice_type = /obj/item/food/pizzaslice/margherita
	boxtag = "Margherita Deluxe"


/obj/item/food/pizza/margherita/raw
	name = "сырая пицца Маргарита"
	icon_state = "pizzamargherita_raw"
	foodtypes =  GRAIN | VEGETABLES | DAIRY | RAW
	burns_in_oven = FALSE
	slice_type = null

/obj/item/food/pizza/margherita/raw/MakeBakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/pizza/margherita, rand(70 SECONDS, 80 SECONDS), TRUE, TRUE)

/obj/item/food/pizza/margherita/robo
	food_reagents = list(/datum/reagent/nanomachines = 70, /datum/reagent/consumable/nutriment = 25, /datum/reagent/consumable/nutriment/protein = 8, /datum/reagent/consumable/tomatojuice = 6, /datum/reagent/consumable/nutriment/vitamin = 5)

/obj/item/food/pizzaslice/margherita
	name = "кусок Маргариты"
	desc = "Кусочек самой сырной пиццы в галактике."
	icon_state = "pizzamargheritaslice"
	tastes = list("корка" = 1, "томаты" = 1, "сыр" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY

/obj/item/food/pizzaslice/margherita/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/customizable_reagent_holder, null, CUSTOM_INGREDIENT_ICON_FILL, max_ingredients = 12)

/obj/item/food/pizza/meat
	name = "мясная пицца"
	desc = "Жирная пицца со вкусным мясом."
	icon_state = "meatpizza"
	food_reagents = list(/datum/reagent/consumable/nutriment = 25, /datum/reagent/consumable/nutriment/protein = 8, /datum/reagent/consumable/tomatojuice = 6, /datum/reagent/consumable/nutriment/vitamin = 8)
	foodtypes = GRAIN | VEGETABLES| DAIRY | MEAT
	slice_type = /obj/item/food/pizzaslice/meat
	boxtag = "Meatlovers' Supreme"

/obj/item/food/pizza/meat/raw
	name = "сырая Мясная пицца"
	icon_state = "meatpizza_raw"
	foodtypes =  GRAIN | VEGETABLES| DAIRY | MEAT | RAW
	burns_in_oven = FALSE
	slice_type = null

/obj/item/food/pizza/meat/raw/MakeBakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/pizza/meat, rand(70 SECONDS, 80 SECONDS), TRUE, TRUE)

/obj/item/food/pizzaslice/meat
	name = "кусок Мясной пицца"
	desc = "Очень вкусный кусочек мясной пиццы."
	icon_state = "meatpizzaslice"
	tastes = list("корка" = 1, "томаты" = 1, "сыр" = 1, "мясо" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY | MEAT

/obj/item/food/pizza/mushroom
	name = "грибная пицца"
	desc = "Очень особенная пицца."
	icon_state = "mushroompizza"
	food_reagents = list(/datum/reagent/consumable/nutriment = 28, /datum/reagent/consumable/nutriment/protein = 3,  /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("корка" = 1, "томаты" = 1, "сыр" = 1, "грибы" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY
	slice_type = /obj/item/food/pizzaslice/mushroom
	boxtag = "Mushroom Special"

/obj/item/food/pizza/mushroom/raw
	name = "сырая Грибная пицца"
	icon_state = "mushroompizza_raw"
	foodtypes =  GRAIN | VEGETABLES | DAIRY | RAW
	burns_in_oven = FALSE
	slice_type = null

/obj/item/food/pizza/mushroom/raw/MakeBakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/pizza/mushroom, rand(70 SECONDS, 80 SECONDS), TRUE, TRUE)

/obj/item/food/pizzaslice/mushroom
	name = "кусок Грибной пиццы"
	desc = "Может быть, это последний кусок пиццы в вашей жизни."
	icon_state = "mushroompizzaslice"
	tastes = list("корка" = 1, "томаты" = 1, "сыр" = 1, "грибы" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY


/obj/item/food/pizza/vegetable
	name = "овощная пицца"
	desc = "При приготовлении этой пиццы не пострадал ни один разумный томат."
	icon_state = "vegetablepizza"
	food_reagents = list(/datum/reagent/consumable/nutriment = 25, /datum/reagent/consumable/tomatojuice = 6, /datum/reagent/medicine/oculine = 12, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("корка" = 1, "томаты" = 2, "сыр" = 1, "морковь" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY
	slice_type = /obj/item/food/pizzaslice/vegetable
	venue_value = FOOD_PRICE_NORMAL
	boxtag = "Gourmet Vegetable"

/obj/item/food/pizza/vegetable/raw
	name = "сырая Овощная пицца"
	icon_state = "vegetablepizza_raw"
	foodtypes =  GRAIN | VEGETABLES | DAIRY | RAW
	burns_in_oven = FALSE
	slice_type = null

/obj/item/food/pizza/vegetable/raw/MakeBakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/pizza/vegetable, rand(70 SECONDS, 80 SECONDS), TRUE, TRUE)

/obj/item/food/pizzaslice/vegetable
	name = "кусок Овощной пиццы"
	desc = "Кусочек самой веганской пиццы из всех пицц."
	icon_state = "vegetablepizzaslice"
	tastes = list("корка" = 1, "томаты" = 2, "сыр" = 1, "морковь" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY


/obj/item/food/pizza/donkpocket
	name = "пицца \"Донк-покет\""
	desc = "Кто решил, что это будет хорошей идеей?"
	icon_state = "donkpocketpizza"
	food_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/protein = 15, /datum/reagent/consumable/tomatojuice = 6, /datum/reagent/medicine/omnizine = 10, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("корка" = 1, "томаты" = 1, "сыр" = 1, "мясо" = 1, "лень" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY | MEAT | JUNKFOOD
	slice_type = /obj/item/food/pizzaslice/donkpocket
	boxtag = "Bangin' Donk"

/obj/item/food/pizza/donkpocket/raw
	name = "сырая пицца \"Донк-покет\""
	icon_state = "donkpocketpizza_raw"
	foodtypes =  GRAIN | VEGETABLES | DAIRY | MEAT | JUNKFOOD | RAW
	burns_in_oven = FALSE
	slice_type = null

/obj/item/food/pizza/donkpocket/raw/MakeBakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/pizza/donkpocket, rand(70 SECONDS, 80 SECONDS), TRUE, TRUE)

/obj/item/food/pizzaslice/donkpocket
	name = "кусок пиццы \"Донк-покет\""
	desc = "Пахнет донк-покетом"
	icon_state = "donkpocketpizzaslice"
	tastes = list("корка" = 1, "томаты" = 1, "сыр" = 1, "мясо" = 1, "лень" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY | MEAT | JUNKFOOD


/obj/item/food/pizza/dank
	name = "шняжная пицца"
	desc = "Лучшая пицца, по мнению хиппи."
	icon_state = "dankpizza"
	food_reagents = list(/datum/reagent/consumable/nutriment = 25, /datum/reagent/consumable/doctor_delight = 5, /datum/reagent/consumable/tomatojuice = 6, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("корка" = 1, "томаты" = 1, "сыр" = 1, "мясо" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY
	slice_type = /obj/item/food/pizzaslice/dank
	boxtag = "Fresh Herb"

/obj/item/food/pizza/dank/raw
	name = "сырая Шняжная пицца"
	icon_state = "dankpizza_raw"
	foodtypes =  GRAIN | VEGETABLES | DAIRY | RAW
	burns_in_oven = FALSE
	slice_type = null

/obj/item/food/pizza/dank/raw/MakeBakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/pizza/dank, rand(70 SECONDS, 80 SECONDS), TRUE, TRUE)

/obj/item/food/pizzaslice/dank
	name = "кусок Шняжной пиццы"
	desc = "Как же она хороша, чувак..."
	icon_state = "dankpizzaslice"
	tastes = list("корка" = 1, "томаты" = 1, "сыр" = 1, "мясо" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY


/obj/item/food/pizza/sassysage
	name = "колбасная пицца"
	desc = "Ты действительно чувствуешь запах \"колбасок\"."
	icon_state = "sassysagepizza"
	food_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/protein = 15, /datum/reagent/consumable/tomatojuice = 6, /datum/reagent/consumable/nutriment/vitamin = 6)
	tastes = list("корка" = 1, "томаты" = 1, "сыр" = 1, "мясо" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY
	slice_type = /obj/item/food/pizzaslice/sassysage
	boxtag = "Sausage Lovers"

/obj/item/food/pizza/sassysage/raw
	name = "сырая Колбасная пицца"
	icon_state = "sassysagepizza_raw"
	foodtypes =  GRAIN | VEGETABLES | DAIRY | MEAT | RAW
	burns_in_oven = FALSE
	slice_type = null

/obj/item/food/pizza/sassysage/raw/MakeBakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/pizza/sassysage, rand(70 SECONDS, 80 SECONDS), TRUE, TRUE)

/obj/item/food/pizzaslice/sassysage
	name = "кусок Колбасной пиццы"
	desc = "Восхитительный кусок пиццы."
	icon_state = "sassysagepizzaslice"
	tastes = list("корка" = 1, "томаты" = 1, "сыр" = 1, "мясо" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY


/obj/item/food/pizza/pineapple
	name = "гавайская пицца"
	desc = "Эта пицца - эквивалент загадки Эйнштейна."
	icon_state = "pineapplepizza"
	food_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/protein = 5, /datum/reagent/consumable/tomatojuice = 6, /datum/reagent/consumable/nutriment/vitamin = 6, /datum/reagent/consumable/pineapplejuice = 8)
	tastes = list("корка" = 1, "томаты" = 1, "сыр" = 1, "ананас" = 2, "ветчина" = 2)
	foodtypes = GRAIN | VEGETABLES | DAIRY | MEAT | FRUIT | PINEAPPLE
	slice_type = /obj/item/food/pizzaslice/pineapple
	boxtag = "Honolulu Chew"

/obj/item/food/pizza/pineapple/raw
	name = "сырая Гавайская пицца"
	icon_state = "pineapplepizza_raw"
	foodtypes =  GRAIN | VEGETABLES | DAIRY | MEAT | FRUIT | PINEAPPLE | RAW
	burns_in_oven = FALSE
	slice_type = null

/obj/item/food/pizza/pineapple/raw/MakeBakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/pizza/pineapple, rand(70 SECONDS, 80 SECONDS), TRUE, TRUE)

/obj/item/food/pizzaslice/pineapple
	name = "кусок Гавайской пиццы"
	desc = "Кусочек самой противоречивой пиццы."
	icon_state = "pineapplepizzaslice"
	tastes = list("корка" = 1, "томаты" = 1, "сыр" = 1, "ананас" = 2, "ветчина" = 2)
	foodtypes = GRAIN | VEGETABLES | DAIRY | MEAT | FRUIT | PINEAPPLE


// Moldly Pizza
// Used in cytobiology.
/obj/item/food/pizzaslice/moldy
	name = "заплесневелый кусок пиццы"
	desc = "Когда-то это был отличный кусок пиццы, но теперь он лежит здесь, прогорклый и кишащий бактериями. Какой ужас! Но мы не должны зацикливаться на прошлом."
	icon_state = "moldy_slice"
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/peptides = 3, /datum/reagent/consumable/tomatojuice = 1, /datum/reagent/toxin/amatoxin = 2)
	tastes = list("stale crust" = 1, "rancid cheese" = 2, "mushroom" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY | GROSS

/obj/item/food/pizzaslice/moldy/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_MOLD, CELL_VIRUS_TABLE_GENERIC, rand(2,4), 25)


// Arnold Pizza
// Has meme code.
/obj/item/food/pizza/arnold
	name = "пицца Арнольд"
	desc = "Здравствуйте, вы позвонили в пиццерию Арнольда. Меня здесь сейчас нет, я убиваю пепперони."
	icon_state = "arnoldpizza"
	food_reagents = list(/datum/reagent/consumable/nutriment = 25, /datum/reagent/consumable/nutriment/protein = 9, /datum/reagent/consumable/nutriment/vitamin = 6, /datum/reagent/iron = 10, /datum/reagent/medicine/omnizine = 30)
	tastes = list("корка" = 1, "томаты" = 1, "сыр" = 1, "пепперони" = 2, "9-ти миллиметровые пули" = 2)
	slice_type = /obj/item/food/pizzaslice/arnold
	boxtag = "9mm Pepperoni"

/obj/item/food/pizza/arnold/raw
	name = "сырая пицца Арнольд"
	icon_state = "arnoldpizza_raw"
	foodtypes =  GRAIN | DAIRY | VEGETABLES | RAW
	burns_in_oven = FALSE
	slice_type = null

/obj/item/food/pizza/arnold/raw/MakeBakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/pizza/arnold, rand(70 SECONDS, 80 SECONDS), TRUE, TRUE)

//fuck it, i will leave this at the food level for now.
/obj/item/food/proc/try_break_off(mob/living/M, mob/living/user) //maybe i give you a pizza maybe i break off your arm
	if(prob(50) || (M != user) || !iscarbon(user) || HAS_TRAIT(user, TRAIT_NODISMEMBER))
		return
	var/obj/item/bodypart/l_arm = user.get_bodypart(BODY_ZONE_L_ARM)
	var/obj/item/bodypart/r_arm = user.get_bodypart(BODY_ZONE_R_ARM)
	var/did_the_thing = (l_arm?.dismember() || r_arm?.dismember()) //not all limbs can be removed, so important to check that we did. the. thing.
	if(!did_the_thing)
		return
	to_chat(user, span_userdanger("Может быть, я дам тебе пиццу, может быть, я сломаю тебе руку..")) //makes the reference more obvious
	user.visible_message(span_warning("<b>[capitalize(src)]</b> ломает руку [user]!") , span_warning("<b>[capitalize(src)]</b> ломает мою руку!"))
	playsound(user, "desecration", 50, TRUE, -1)

/obj/item/food/proc/i_kill_you(obj/item/I, mob/living/user)
	if(istype(I, /obj/item/food/pineappleslice))
		to_chat(user, span_boldwarning("Если ты хочешь чего-то безумного, по типу ананасов, я убью тебя.")) //this is in bigger text because it's hard to spam something that gibs you, and so that you're perfectly aware of the reason why you died
		user.gib() //if you want something crazy like pineapple, i'll kill you
	else if(istype(I, /obj/item/food/grown/mushroom) && iscarbon(user))
		to_chat(user, span_userdanger("Так что, если хочешь грибов, заткнись.")) //not as large as the pineapple text, because you could in theory spam it
		var/mob/living/carbon/shutup = user
		shutup.gain_trauma(/datum/brain_trauma/severe/mute)

/obj/item/food/pizza/arnold/attack(mob/living/M, mob/living/user)
	. = ..()
	try_break_off(M, user)

/obj/item/food/pizza/arnold/attackby(obj/item/I, mob/user)
	i_kill_you(I, user)
	. = ..()

/obj/item/food/pizzaslice/arnold
	name = "кусок пиццы Арнольд"
	desc = "Я приду, может, угощу тебя пиццей, может, сломаю тебе руку."
	icon_state = "arnoldpizzaslice"
	tastes = list("корка" = 1, "томаты" = 1, "сыр" = 1, "пепперони" = 2, "9-ти миллиметровые пули" = 2)
	foodtypes = GRAIN | VEGETABLES | DAIRY | MEAT

/obj/item/food/pizzaslice/arnold/attack(mob/living/M, mob/living/user)
	. =..()
	try_break_off(M, user)

/obj/item/food/pizzaslice/arnold/attackby(obj/item/I, mob/user)
	i_kill_you(I, user)
	. = ..()

// Ant Pizza, now with more ants.
/obj/item/food/pizza/ants
	name = "пицца для муравьиной вечеринки"
	desc = "//Полна багов, надо не забыть исправить"
	icon_state = "antpizza"
	food_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/ants = 25, /datum/reagent/consumable/tomatojuice = 10, /datum/reagent/consumable/nutriment/vitamin = 4, /datum/reagent/consumable/nutriment/protein = 2)
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "insects" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY | GROSS
	slice_type = /obj/item/food/pizzaslice/ants
	boxtag = "Anthill Deluxe"

/obj/item/food/pizzaslice/ants
	name = "кусок пиццы для муравьиной вечеринки"
	desc = "Ключ к идеальному куску пиццы - не переборщить с муравьями."
	icon_state = "antpizzaslice"
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "insects" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY | GROSS
