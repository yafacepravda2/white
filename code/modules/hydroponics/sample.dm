/obj/item/seeds/sample
	name = "Образец растения"
	icon_state = "sample-empty"
	potency = -1
	yield = -1
	var/sample_color = "#FFFFFF"

/obj/item/seeds/sample/Initialize(mapload)
	. = ..()
	if(sample_color)
		var/mutable_appearance/filling = mutable_appearance(icon, "sample-filling")
		filling.color = sample_color
		add_overlay(filling)

/obj/item/seeds/sample/get_unique_analyzer_text()
	return "The DNA of this sample is damaged beyond recovery, it can't support life on its own."

/obj/item/seeds/sample/alienweed
	name = "Образец инопланетного растения"
	icon_state = "alienweed"
	sample_color = null
