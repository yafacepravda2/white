/datum/map_template
	var/name = "Default Template Name"
	var/width = 0
	var/height = 0
	var/mappath = null
	var/loaded = 0 // Times loaded this round
	var/datum/parsed_map/cached_map
	var/keep_cached_map = FALSE
	var/station_id = null // used to override the root id when generating

	///if true, turfs loaded from this template are placed on top of the turfs already there, defaults to TRUE
	var/should_place_on_top = TRUE

	///if true, creates a list of all atoms created by this template loading, defaults to FALSE
	var/returns_created_atoms = FALSE

	///the list of atoms created by this template being loaded, only populated if returns_created_atoms is TRUE
	var/list/created_atoms = list()
	//make sure this list is accounted for/cleared if you request it from ssatoms!

	// vars for automatic ceiling generation
	var/has_ceiling = FALSE
	var/turf/ceiling_turf = /turf/open/floor/plating
	var/list/ceiling_baseturfs = list()

/datum/map_template/New(path = null, rename = null, cache = FALSE, admin_load = FALSE)
	if(path)
		mappath = path
	if(mappath)
		preload_size(mappath, cache)
	if(rename)
		name = rename
	ceiling_baseturfs.Insert(1, /turf/baseturf_bottom)

/datum/map_template/proc/preload_size(path, cache = FALSE)
	var/datum/parsed_map/parsed = new(file(path))
	var/bounds = parsed?.bounds
	if(bounds)
		width = bounds[MAP_MAXX] // Assumes all templates are rectangular, have a single Z level, and begin at 1,1,1
		height = bounds[MAP_MAXY]
		if(cache)
			cached_map = parsed
	return bounds

/datum/map_template/proc/initTemplateBounds(list/bounds, init_atmos = TRUE)
	if (!bounds) //something went wrong
		stack_trace("[name] template failed to initialize correctly!")
		return

	var/list/obj/machinery/atmospherics/atmos_machines = list()
	var/list/obj/structure/cable/cables = list()
	var/list/atom/movable/movables = list()
	var/list/area/areas = list()

	var/list/turfs = block(
		locate(
			bounds[MAP_MINX],
			bounds[MAP_MINY],
			bounds[MAP_MINZ]
			),
		locate(
			bounds[MAP_MAXX],
			bounds[MAP_MAXY],
			bounds[MAP_MAXZ]
			)
		)
	for(var/turf/current_turf as anything in turfs)
		var/area/current_turfs_area = current_turf.loc
		areas |= current_turfs_area
		if(!SSatoms.initialized)
			continue

		for(var/movable_in_turf in current_turf)
			movables += movable_in_turf
			if(istype(movable_in_turf, /obj/structure/cable))
				cables += movable_in_turf
				continue
			if(istype(movable_in_turf, /obj/machinery/atmospherics))
				atmos_machines += movable_in_turf

	// Not sure if there is some importance here to make sure the area is in z
	// first or not.  Its defined In Initialize yet its run first in templates
	// BEFORE so... hummm
	SSmapping.reg_in_areas_in_z(areas)
	SSnetworks.assign_areas_root_ids(areas, src)
	if(!SSatoms.initialized)
		return

	SSatoms.InitializeAtoms(areas + turfs + movables, returns_created_atoms ? created_atoms : null)

	for(var/turf/unlit as anything in turfs)
		if(unlit.space_lit)
			continue
		var/area/loc_area = unlit.loc
		if(!loc_area.static_lighting)
			continue
		unlit.lighting_build_overlay()

	// NOTE, now that Initialize and LateInitialize run correctly, do we really
	// need these two below?
	SSmachines.setup_template_powernets(cables)
	SSair.setup_template_machinery(atmos_machines)

	if(init_atmos)
		//calculate all turfs inside the border
		var/list/template_and_bordering_turfs = block(
			locate(
				max(bounds[MAP_MINX]-1, 1),
				max(bounds[MAP_MINY]-1, 1),
				bounds[MAP_MINZ]
				),
			locate(
				min(bounds[MAP_MAXX]+1, world.maxx),
				min(bounds[MAP_MAXY]+1, world.maxy),
				bounds[MAP_MAXZ]
				)
		)
		for(var/turf/affected_turf as anything in template_and_bordering_turfs)
			affected_turf.air_update_turf(TRUE)
			affected_turf.levelupdate()

/datum/map_template/proc/load_new_z(orbital_body_type, list/level_traits = list(ZTRAIT_AWAY = TRUE, ZTRAIT_NOPARALLAX = TRUE))
	var/x = round((world.maxx - width) * 0.5) + 1
	var/y = round((world.maxy - height) * 0.5) + 1

	var/datum/space_level/level = SSmapping.add_new_zlevel(name, level_traits, orbital_body_type = orbital_body_type, contain_turfs = FALSE)
	SSair.pause_z(level.z_value)
	var/datum/parsed_map/parsed = load_map(file(mappath), x, y, level.z_value, no_changeturf=(SSatoms.initialized == INITIALIZATION_INSSATOMS), placeOnTop=should_place_on_top, new_z = TRUE)
	var/list/bounds = parsed.bounds
	if(!bounds)
		return FALSE

	require_area_resort()

	//initialize things that are normally initialized after map load
	initTemplateBounds(bounds)
	smooth_zlevel(world.maxz)

	log_game("Z-level [name] ([mappath]) loaded at [x],[y],[world.maxz]")

	SSair.unpause_z(level.z_value)

	return level

/datum/map_template/proc/load(turf/T, centered = FALSE, init_atmos = TRUE, finalize = TRUE)
	if(centered)
		T = locate(T.x - round(width/2) , T.y - round(height/2) , T.z)
	if(!T)
		return
	if(T.x+width > world.maxx)
		return
	if(T.y+height > world.maxy)
		return

	var/list/border = block(locate(max(T.x, 1), max(T.y, 1),  T.z),
							locate(min(T.x+width, world.maxx), min(T.y+height, world.maxy), T.z))
	for(var/L in border)
		var/turf/turf_to_disable = L
		turf_to_disable.ImmediateDisableAdjacency()

	// Accept cached maps, but don't save them automatically - we don't want
	// ruins clogging up memory for the whole round.
	var/datum/parsed_map/parsed = cached_map || new(file(mappath))
	cached_map = keep_cached_map ? parsed : null

	var/list/turf_blacklist = list()
	update_blacklist(T, turf_blacklist)

	UNSETEMPTY(turf_blacklist)
	parsed.turf_blacklist = turf_blacklist
	if(!parsed.load(T.x, T.y, T.z, cropMap=TRUE, no_changeturf=(SSatoms.initialized == INITIALIZATION_INSSATOMS), placeOnTop=should_place_on_top))
		return
	var/list/bounds = parsed.bounds
	if(!bounds)
		return

	if(!SSmapping.loading_ruins) //Will be done manually during mapping ss init
		require_area_resort()

	//initialize things that are normally initialized after map load
	//If this is a superfunction call, we don't want to initialize atoms here, let the subfunction handle that
	if(finalize)
		//initialize things that are normally initialized after map load
		initTemplateBounds(bounds, init_atmos)

		if(has_ceiling)
			var/affected_turfs = get_affected_turfs(T, FALSE)
			generate_ceiling(affected_turfs)

		log_game("[name] loaded at [T.x],[T.y],[T.z]")
	return bounds

/datum/map_template/proc/generate_ceiling(affected_turfs)
	for (var/turf/turf in affected_turfs)
		var/turf/ceiling = get_step_multiz(turf, UP)
		if (ceiling)
			if (istype(ceiling, /turf/open/openspace) || istype(ceiling, /turf/open/space/openspace))
				ceiling.ChangeTurf(ceiling_turf, ceiling_baseturfs, CHANGETURF_INHERIT_AIR)

/datum/map_template/proc/post_load()
	return

/datum/map_template/proc/update_blacklist(turf/T, list/input_blacklist)
	return

/datum/map_template/proc/get_affected_turfs(turf/T, centered = FALSE)
	var/turf/placement = T
	if(centered)
		var/turf/corner = locate(placement.x - round(width/2), placement.y - round(height/2), placement.z)
		if(corner)
			placement = corner
	return block(placement, locate(placement.x+width-1, placement.y+height-1, placement.z))

/// Takes in a type path, locates an instance of that type in the cached map, and calculates its offset from the origin of the map, returns this offset in the form list(x, y).
/datum/map_template/proc/discover_offset(obj/marker)
	var/key
	var/list/models = cached_map.grid_models
	for(key in models)
		if(findtext(models[key], "[marker]")) // Yay compile time checks
			break // This works by assuming there will ever only be one mobile dock in a template at most

	for(var/datum/grid_set/gset as anything in cached_map.gridSets)
		var/ycrd = gset.ycrd
		for(var/line in gset.gridLines)
			var/xcrd = gset.xcrd
			for(var/j in 1 to length(line) step cached_map.key_len)
				if(key == copytext(line, j, j + cached_map.key_len))
					return list(xcrd, ycrd)
				++xcrd
			--ycrd

//for your ever biggening badminnery kevinz000
//❤ - Cyberboss
/proc/load_new_z_level(file, name, orbital_body_type)
	var/datum/map_template/template = new(file, name)
	var/datum/space_level/SL = template.load_new_z(orbital_body_type = orbital_body_type)
	return SL.z_value
