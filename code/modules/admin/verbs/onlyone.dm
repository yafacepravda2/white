GLOBAL_VAR_INIT(highlander, FALSE)
/client/proc/only_one() //Gives everyone kilts, berets, claymores, and pinpointers, with the objective to hijack the emergency shuttle.
	if(!SSticker.HasRoundStarted())
		alert("The game hasn't started yet!")
		return
	GLOB.highlander = TRUE

	sound_to_playing_players('sound/misc/highlander.ogg')
	send_to_playing_players(span_boldannounce("<font size=6>THERE CAN BE ONLY ONE</font>"))

	for(var/obj/item/disk/nuclear/N in SSpoints_of_interest.other_points_of_interest)
		var/datum/component/stationloving/component = N.GetComponent(/datum/component/stationloving)
		if (component)
			component.relocate() //Gets it out of bags and such

	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(H.stat == DEAD)
			continue
		H.make_scottish()

	for(var/mob/living/silicon/ai/AI in GLOB.player_list)
		if(!istype(AI) || AI.stat == DEAD)
			continue
		if(AI.deployed_shell)
			AI.deployed_shell.undeploy()
		AI.change_mob_type(/mob/living/silicon/robot , null, null)
		AI.gib()

	for(var/mob/living/silicon/robot/robot in GLOB.player_list)
		if(!istype(robot) || robot.stat == DEAD)
			continue
		if(robot.shell)
			robot.gib()
			continue
		robot.make_scottish()

	message_admins(span_adminnotice("[key_name_admin(usr)] used THERE CAN BE ONLY ONE!"))
	log_admin("[key_name(usr)] used THERE CAN BE ONLY ONE.")
	addtimer(CALLBACK(SSshuttle.emergency, TYPE_PROC_REF(/obj/docking_port/mobile/emergency, request), null, 1), 50)

/client/proc/only_one_delayed()
	send_to_playing_players(span_userdanger("Bagpipes begin to blare. You feel Scottish pride coming over you."))
	message_admins(span_adminnotice("[key_name_admin(usr)] used (delayed) THERE CAN BE ONLY ONE!"))
	log_admin("[key_name(usr)] used delayed THERE CAN BE ONLY ONE.")
	addtimer(CALLBACK(src, PROC_REF(only_one)), 42 SECONDS)

/mob/living/carbon/human/proc/make_scottish()
	mind.add_antag_datum(/datum/antagonist/highlander)

/mob/living/silicon/robot/proc/make_scottish()
	mind.add_antag_datum(/datum/antagonist/highlander/robot)
