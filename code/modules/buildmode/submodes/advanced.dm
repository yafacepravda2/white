/datum/buildmode_mode/advanced
	key = "advanced"
	var/atom/objholder = null

// FIXME: add logic which adds a button displaying the icon
// of the currently selected path

/datum/buildmode_mode/advanced/show_help(client/c)
	to_chat(c, "<span class='notice'>***********************************************************</span>")
	to_chat(c, "<span class='notice'>Right Mouse Button on buildmode button = Set object type</span>")
	to_chat(c, "<span class='notice'>Left Mouse Button + alt on turf/obj = Copy object type</span>")
	to_chat(c, "<span class='notice'>Left Mouse Button on turf/obj = Place objects</span>")
	to_chat(c, "<span class='notice'>Right Mouse Button = Delete objects</span>")
	to_chat(c, "<span class='notice'>Use the button in the upper left corner to</span>")
	to_chat(c, "<span class='notice'>change the direction of built objects.</span>")
	to_chat(c, "<span class='notice'>***********************************************************</span>")

/datum/buildmode_mode/advanced/change_settings(client/c)
	var/target_path = tgui_input_text(c, "Enter typepath:", "Typepath", "/obj/structure/closet")
	objholder = text2path(target_path)
	if(!ispath(objholder))
		if(isnull(target_path) || target_path == FALSE || target_path == "")
			if(tgui_alert(usr, "Are you sure you would like to display ALL of the atoms? This may freeze your client for a while.", list("Yes", "No") ) == "No")
				tgui_alert(usr,"No path was selected")
				return
		objholder = pick_closest_path(target_path)
		if(!objholder)
			tgui_alert(usr,"No path was selected")
			return
		else if(ispath(objholder, /area))
			objholder = null
			tgui_alert(usr,"That path is not allowed.")
			return

/datum/buildmode_mode/advanced/handle_click(client/c, params, obj/object)
	var/list/pa = params2list(params)
	var/left_click = pa.Find("left")
	var/right_click = pa.Find("right")
	var/alt_click = pa.Find("alt")

	if(left_click && alt_click)
		if (istype(object, /turf) || istype(object, /obj) || istype(object, /mob))
			objholder = object.type
			to_chat(c, "<span class='notice'>[initial(object.name)] ([object.type]) selected.</span>")
		else
			to_chat(c, "<span class='notice'>[initial(object.name)] is not a turf, object, or mob! Please select again.</span>")
	else if(left_click)
		if(ispath(objholder,/turf))
			var/turf/T = get_turf(object)
			log_admin("Build Mode: [key_name(c)] modified [T] in [AREACOORD(object)] to [objholder]")
			T = T.ChangeTurf(objholder)
			T.setDir(BM.build_dir)
		else if(ispath(objholder, /obj/effect/turf_decal))
			var/turf/T = get_turf(object)
			T.AddElement(/datum/element/decal, initial(objholder.icon), initial(objholder.icon_state), BM.build_dir, null, null, initial(objholder.alpha), initial(objholder.color), null, FALSE, null)
			log_admin("Build Mode: [key_name(c)] in [AREACOORD(object)] added a [initial(objholder.name)] decal with dir [BM.build_dir] to [T]")
		else if(!isnull(objholder))
			var/obj/A = new objholder (get_turf(object))
			A.setDir(BM.build_dir)
			log_admin("Build Mode: [key_name(c)] modified [A] [COORD(A)] dir to [BM.build_dir]")
		else
			to_chat(c, "<span class='warning'>Select object type first.</span>")
	else if(right_click)
		if(isobj(object))
			log_admin("Build Mode: [key_name(c)] deleted [object] at [AREACOORD(object)]")
			qdel(object)
