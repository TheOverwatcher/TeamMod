--	On_load is used in 3 cases

--	1) re-register conditional event handlers
--	2) re-setup meta tables
--	3) create local references to tables stored in the global table

function on_load(event)
	global.DEBUG = false;
	global.DEBUG_ALL = false;
		
	-- global information modified from initial config
	if global.forcesData == nil then
		global.forcesData = {}
	end
	
	if global.points == nil then
		global.points = {
			startingAreaRadius = 50, -- in this radius every tree will be destroyed
			start = {
				-- defines start point of map			
				x = math.random(220, 1060),
				y = math.random(220, 1060)  
			}, -- defines distance between spawn points for teams
			distance = {
				min = 1200,
				max = 1800,
			},
			numberOfTrysBeforeError = 40 -- this is just a helper value (if we try to locate a non colliding point, we try it max XX times before we abort)
		}
	end

	if global.distance == nil then
		global.distance = 60 * 3
	end
	
	if global.big_distance == nil then
		global.big_distance = 40 * 3 * 3
	end
	
	if global.researchMessage == nil then
		global.researchMessage = {
			enabled = true
		}
	end
	
	if global.attackMessage == nil then
		global.attackMessage = {
			enabled = true,
			interval = 5*MINUTES
		}
	end
	
	if global.enableTeams == nil then
		global.enableTeams = {
			after = 30 * SECONDS, -- teams are eneabled after XX Seconds
			messageInterval = 10 * SECONDS -- message interval /(when are the teams unlocked)
		}
	end
	
	if global.teamBalance == nil then
		global.teamBalance = {
			enabled = true, -- wether team balance should be enabled or not
		}
	end
	
	if global.teamMessageGui == nil then
		global.teamMessageGui = {
			enabled = true
		}
	end
	
	if global.allianceGui == nil then
		global.allianceGui = {
			enabled = true,
			changeAbleTick = 5 * MINUTES -- alliances could only be changed every XXX ticks
		}
	end
	
	if global.configStep == nil then
		global.configStep = "teams"
	end
	
	global.isInitialized = true;

end

-- NO DEBUG. INIT WONT HAVE PLAYERS. Setting variable to test for init failure.
function on_init(event)
	global.DEBUG = false;
	global.DEBUG_ALL = false;
	
	make_lobby()
	
	-- global information modified from initial config
	if global.forcesData == nil then
		global.forcesData = {}
	end
	
	if global.points == nil then
		global.points = {
			startingAreaRadius = 50, -- in this radius every tree will be destroyed
			start = {
				-- defines start point of map			
				x = math.random(220, 1060),
				y = math.random(220, 1060)  
			}, -- defines distance between spawn points for teams
			distance = {
				min = 1200,
				max = 1800,
			},
			numberOfTrysBeforeError = 40 -- this is just a helper value (if we try to locate a non colliding point, we try it max XX times before we abort)
		}
	end

	if global.distance == nil then
		global.distance = 60 * 3
	end
	
	if global.big_distance == nil then
		global.big_distance = 40 * 3 * 3
	end
	
	if global.researchMessage == nil then
		global.researchMessage = {
			enabled = true
		}
	end
	
	if global.attackMessage == nil then
		global.attackMessage = {
			enabled = true,
			interval = 5*MINUTES
		}
	end
	
	if global.enableTeams == nil then
		global.enableTeams = {
			after = 30 * SECONDS, -- teams are eneabled after XX Seconds
			messageInterval = 10 * SECONDS -- message interval /(when are the teams unlocked)
		}
	end
	
	if global.teamBalance == nil then
		global.teamBalance = {
			enabled = true, -- wether team balance should be enabled or not
		}
	end
	
	if global.teamMessageGui == nil then
		global.teamMessageGui = {
			enabled = true
		}
	end
	
	if global.allianceGui == nil then
		global.allianceGui = {
			enabled = true,
			changeAbleTick = 5 * MINUTES -- alliances could only be changed every XXX ticks
		}
	end
	
	if global.configStep == nil then
		global.configStep = "teams"
	end
	
	global.isInitialized = true;
	
end

function on_player_created(event)

	if global.isInitialized and global.DEBUG then
		PrintToAllPlayers({'debug.enter-method', "event_functions:on_player_created"})
		PrintToAllPlayers({'debug.init-msg'})
	end

	--Get the player that just joined
	local player = game.players[event.player_index]
	
	--Take them to the lobby
	player.teleport({ 0, 8 }, game.surfaces["Lobby"])

	if global.DEBUG then
		PrintToAllPlayers({'debug.player-loaded', player.name})
		if global.DEBUG_ALL then
			PrintToAllPlayers({'debug.variable-information', "event.player_index" , event.player_index})
		end
	end
	
	--If the host player and configuration was not set.
	if event.player_index == 1 and not isConfigWritten() then
		PrintToAllPlayers('Creating configuration gui');
        ConfigurationGui:createConfigurationGui(player);
	end
	
	--Print messages to new arrivals
	if areTeamsEnabled() then
		PrintToAllPlayers({"resources.please-select-team-msg"})
		make_team_option(player)
	else 
		PrintToAllPlayers({"resources.teams-have-not-been-set-msg"})
	end
	
	player.get_inventory(defines.inventory.player_ammo).clear();
    player.get_inventory(defines.inventory.chest).clear();
    player.get_inventory(defines.inventory.player_guns).clear();
    player.get_inventory(defines.inventory.player_main).clear();
    player.get_inventory(defines.inventory.player_quickbar).clear();
	
	if global.DEBUG then
		PrintToAllPlayers({'debug.exit-method', "event_functions:on_player_created"})
	end
end

function on_entity_died(event)
	if global.DEBUG then
		PrintToAllPlayers({'debug.enter-method', "event_functions:on_entity_died"})
	end
    if global.attackMessage.enabled then
        global.entity = event.entity;
        global.force = event.force;
        if global.force ~= nil and global.entity.force.name ~= 'neutral' then
            if global.entity.force.name == 'enemy' then
                if global.entity.name ~= "spitter-spawner"
                        and global.entity.name ~= "biter-spawner"
                        and global.entity.name ~= "small-worm-turret"
                        and global.entity.name ~= "medium-worm-turret"
                        and global.entity.name ~= "big-worm-turret"
                then
                    return
                end
            end
            if global.entity.force ~= nil and global.entity.force ~= global.force then
                global.attacked = global.entity.force.name;
                global.attackedFrom = global.force.name;
                if global.attacked == 'enemy' then
                    global.attacked = 'Aliens'
                end
                if global.attackedFrom == 'enemy' then
                    global.attackedFrom = 'Aliens';
                end
                PrintToAllPlayers({ 'resources.team-attacked-by-team', global.attacked, global.attackedFrom })
            end
        end
    end
	if global.DEBUG then
		PrintToAllPlayers({'debug.exit-method', "event_functions:on_entity_died"})
	end
end

--Handling the gui clicks
function on_gui_click(event)

	if global.DEBUG then -- this would be annoying for 
		PrintToAllPlayers({'debug.enter-method', "event_functions:on_gui_click"})
	end
	
	global.s = game.surfaces.nauvis;
    global.element = event.element
    if global.element.valid ~= true then
        return;
    end

    global.eventName = global.element.name;
	
	if global.DEBUG_ALL then
		PrintToAllPlayers({'debug.variable-information','global.eventName',global.eventName})
	end

	local player = game.players[event.player_index];	
	--team chat related
	if global.eventName == 'team_chat_button' then
		disable_left_gui_interaction(player);
        TeamChat:make_team_chat_gui(player);
    elseif global.eventName == 'team_chat_message_close' then
		enable_left_gui_interaction(player);
        player.gui.center.team_chat.destroy()
    elseif global.eventName == 'team_chat_message_send' then
        for k,p in pairs(player.force.players) do
            player.print({'resources.team-msg', player.name, player.gui.center.team_chat.team_chat_message.text})
        end
        player.gui.center.team_chat.team_chat_message.text = ''
	
	--Frame related
	elseif global.eventName == 'next_step' then
        ConfigurationGui:try(ConfigurationGui.steps[global.configStep].saveStep, player);
        ConfigurationGui:try(ConfigurationGui.steps[global.configStep].destroyStep, player);
        global.configStep = ConfigurationGui.steps[global.configStep].nextStep;
        global.g = ConfigurationGui:try(ConfigurationGui.steps[global.configStep].createStep, player);
        ConfigurationGui:createNextAndPrev(global.g);
    elseif global.eventName == 'prev_step' then
        ConfigurationGui:try(ConfigurationGui.steps[global.configStep].saveStep, player);
        ConfigurationGui:try(ConfigurationGui.steps[global.configStep].destroyStep, player);
        global.configStep = ConfigurationGui.steps[global.configStep].prevStep;
        global.g = ConfigurationGui:try(ConfigurationGui.steps[global.configStep].createStep, player);
        ConfigurationGui:createNextAndPrev(global.g);
	elseif global.eventName == 'start_game' then
        ConfigurationGui:try(ConfigurationGui.steps[global.configStep].saveStep, player);
        ConfigurationGui:try(ConfigurationGui.steps[global.configStep].destroyStep, player);
        PrintToAllPlayers({ "lobby.lobby-msg-config-finished", game.players[1].name })
        make_forces()
        setConfigWritten();
	elseif global.eventName == 'force_cancel' then
        if player.gui.center.create_force ~= nil and player.gui.center.create_force.valid then
           player.gui.center.create_force.destroy();
        end
        ConfigurationGui:createNextAndPrev(ConfigurationGui.steps.teams.createFrame(player));
    --Force related
	elseif global.eventName == 'force_save' then
        if player.gui.center.create_force ~= nil and player.gui.center.create_force.valid then
            if player.gui.center.create_force.caption ~= nil then
                global.forcesData[player.gui.center.create_force.caption] = nil;
            end
            global.forceData = ConfigurationGui.steps.teams.getForceData(player.gui.center.create_force);
            if global.forceData.cName ~= '' then
                global.forcesData[global.forceData.cName] = global.forceData;
                player.gui.center.create_force.destroy();
            end
        end
        ConfigurationGui:createNextAndPrev(ConfigurationGui.steps.teams.createFrame(player));
    elseif global.eventName == 'force_remove' then
        global.parent = global.element.parent;
        table.each(global.forcesData, function(forceData, k)
            if global.parent.name == 'force_frame_' .. forceData.name then
                global.forcesData[k] = nil;
            end
        end)
        ConfigurationGui:createNextAndPrev(ConfigurationGui.steps.teams.createFrame(player));
    elseif string.match(global.eventName,'force_edit_(.*)') ~= nil then
        table.each(global.forcesData, function(forceData)
            if global.element.valid and global.element.name == 'force_edit_' .. forceData.name then
                if player.gui.center.teams_gui ~= nil then
                    player.gui.center.teams_gui.destroy();
                end
                ConfigurationGui.steps.teams.createForceGuiWithData(player, forceData);
                return;
            end
        end)
    elseif global.eventName == 'force_new' then
        if player.gui.center.teams_gui ~= nil then
            player.gui.center.teams_gui.destroy();
        end
        ConfigurationGui.steps.teams.createForceGui(player);
		
	--team realated
	elseif global.eventName == 'team_number_check' then
        table.each(global.forcesData, function(data)
            global.c = 0;
            table.each(game.players, function(player)
                if data.cName == player.force.name then global.c = global.c + 1 end
            end)
            player.print({ 'resources.player-msg-team-number', data.title, global.c })
        end)
    elseif global.eventName == 'autoAssign' then
        global.check = {}
        table.each(global.forcesData, function(data)
            global.c = 0;
            table.each(game.players, function(player)
                if data.cName == player.force.name then global.c = global.c + 1 end
            end)
            global.check[data.cName] = global.c;
        end)
        for k,v in spairs(global.check, function (t,a,b) return t[a] < t[b] end) do
            putPlayerInTeam(player, global.forcesData[k]);
            break
        end
    elseif string.match(global.eventName, 'choose_team_.*') ~= nil then
        table.each(global.forcesData, function(data)
            if global.eventName == 'choose_team_' .. data.name then
                if couldJoinIntoForce(data.cName) then
                    putPlayerInTeam(player, data);
                else
                    player.print( { 'resources.player-msg-could-not-join', data.title } )
                end
            end
        end)
	elseif global.eventName == 'alliance_button' then
		disable_left_gui_interaction(player)
        Alliance:buildAllianceGui(player)
    elseif global.eventName == 'alliance_close' then
		enable_left_gui_interaction(player)
        if player.gui.center.alliance ~= nil then
            player.gui.center.alliance.destroy();
        end
    elseif string.match(global.eventName, 'make_alliance_.*') ~= nil then
        global.forceTwo = string.sub(event.element.name, 15);
        global.forceOne = player.force.name;
        if Alliance:isAllianceRequested(global.forceOne, global.forceTwo) then
            Alliance:deleteRequest(global.forceOne, global.forceTwo);
            game.forces[global.forceOne].set_cease_fire(global.forceTwo, true)
            game.forces[global.forceTwo].set_cease_fire(global.forceOne, true)
            Alliance:updateChangeable(global.forceOne, global.forceTwo);
            Alliance:updateGuis()
            PrintToAllPlayers({ 'resources.alliance-accept', player.name, global.forcesData[global.forceTwo].title, global.forcesData[global.forceOne].title })
        elseif game.forces[global.forceOne].get_cease_fire(global.forceTwo) and game.forces[global.forceTwo].get_cease_fire(global.forceOne) then
            game.forces[global.forceOne].set_cease_fire(global.forceTwo, false)
            game.forces[global.forceTwo].set_cease_fire(global.forceOne, false)
            Alliance:updateChangeable(global.forceOne, global.forceTwo);
            Alliance:updateGuis()
            PrintToAllPlayers({ 'resources.alliance-terminated', player.name, global.forcesData[global.forceTwo].title, global.forcesData[global.forceOne].title })
        else
            Alliance:requestAlliance(global.forceOne, global.forceTwo);
            Alliance:updateGuis()
            PrintToAllPlayers({ 'resources.alliance-request', player.name, global.forcesData[global.forceTwo].title, global.forcesData[global.forceOne].title })
        end
    elseif string.match(global.eventName, 'alliance_deny_.*') ~= nil then
        global.forceTwo = string.sub(event.element.name, 15);
        global.forceOne = player.force.name;
        if Alliance:isAllianceRequested(global.forceOne, global.forceTwo) then
            Alliance:deleteRequest(global.forceOne, global.forceTwo);
            Alliance:updateGuis()
            game.forces[global.forceOne].set_cease_fire(global.forceTwo, false)
            game.forces[global.forceTwo].set_cease_fire(global.forceOne, false)
            PrintToAllPlayers({ 'resources.alliance-denied', player.name, global.forcesData[global.forceTwo].title, global.forcesData[global.forceOne].title })
        end
    elseif string.match(global.eventName, 'alliance_abort_.*') ~= nil then
        global.forceTwo = string.sub(event.element.name, 16);
        global.forceOne = player.force.name;
        if Alliance:isAllianceRequested(global.forceOne, global.forceTwo) then
            Alliance:deleteRequest(global.forceOne, global.forceTwo);
            Alliance:updateGuis()
            PrintToAllPlayers({ 'resources.alliance-abort', player.name, global.forcesData[global.forceTwo].title, global.forcesData[global.forceOne].title })
        end
    elseif string.match(global.eventName, 'make_alliance_.*') ~= nil then
        global.forceTwo = string.sub(event.element.name, 15);
        global.forceOne = player.force.name;
        if Alliance:isAllianceRequested(global.forceOne, global.forceTwo) then
            Alliance:deleteRequest(global.forceOne, global.forceTwo);
            game.forces[global.forceOne].set_cease_fire(global.forceTwo, true)
            game.forces[global.forceTwo].set_cease_fire(global.forceOne, true)
            Alliance:updateChangeable(global.forceOne, global.forceTwo);
            Alliance:updateGuis()
            PrintToAllPlayers({ 'resources.alliance-accept', player.name, global.forcesData[global.forceTwo].title, global.forcesData[global.forceOne].title })
        elseif game.forces[global.forceOne].get_cease_fire(global.forceTwo) and game.forces[global.forceTwo].get_cease_fire(global.forceOne) then
            game.forces[global.forceOne].set_cease_fire(global.forceTwo, false)
            game.forces[global.forceTwo].set_cease_fire(global.forceOne, false)
            Alliance:updateChangeable(global.forceOne, global.forceTwo);
            Alliance:updateGuis()
            PrintToAllPlayers({ 'resources.alliance-terminated', player.name, global.forcesData[global.forceTwo].title, global.forcesData[global.forceOne].title })
        else
            Alliance:requestAlliance(global.forceOne, global.forceTwo);
            Alliance:updateGuis()
            PrintToAllPlayers({ 'resources.alliance-request', player.name, global.forcesData[global.forceTwo].title, global.forcesData[global.forceOne].title })
        end
	end
	if global.DEBUG then
		PrintToAllPlayers({'debug.exit-method', "event_functions:on_gui_click"})
	end
end
--end event handler for gui click

function on_tick(event)
	if global.DEBUG_ALL then -- Needs to be DEBUG_ALL for on_tick. It's a lot of messages
		PrintToAllPlayers({'debug.enter-method', "event_functions:on_tick"})
	end
	if isConfigWritten() then
		tick_all_helper(event.tick);
		tick_all_helper_if_valid(event.tick);
		
		if game.tick >= global.CONFIG_WRITTEN_TIME + global.enableTeams.after then
			teamsEnablingStarted = areTeamsEnabledStartup();
			if global.DEBUG_ALL then
				PrintToAllPlayers({'debug.variable-information', "areTeamsEnabled", areTeamsEnabledStartup()})
			end
			if areTeamsEnabledStartup() == false then
				setTeamsEnabledStartup();
				triggerTeamsEnabling();
			end
		elseif game.tick <= global.CONFIG_WRITTEN_TIME + global.enableTeams.after and game.tick % global.enableTeams.messageInterval == 0 then
			global.enableTick = (global.CONFIG_WRITTEN_TIME + global.enableTeams.after) - game.tick;
			global.seconds = Math.round(global.enableTick / SECONDS);
			PrintToAllPlayers({ 'resources.teams-enable-in', global.seconds })
		end
		
		if (areTeamsEnabled()) then
			tick_all_helper(event.tick);
			tick_all_helper_if_valid(event.tick);
		end
	end		
	if global.DEBUG_ALL then
		PrintToAllPlayers({'debug.exit-method', "event_functions:on_tick"})
	end
end

-- Normal Events for game changes (launching rocket, dieing)
function on_rocket_launched(event)
	if global.DEBUG then
		PrintToAllPlayers({'debug.enter-method', "event_functions:on_rocket_launched"})
	end
    force = event.rocket.force
    if event.rocket.get_item_count("satellite") > 0 then
        if global.satellite_sent == nil then
            global.satellite_sent = {}
        end
        if global.satellite_sent[force.name] == nil then
            game.set_game_state { game_finished = true, player_won = true, can_continue = true }
            global.satellite_sent[force.name] = 1
        else
            global.satellite_sent[force.name] = global.satellite_sent[force.name] + 1
        end
        for index, player in pairs(force.players) do
            if player.gui.left.rocket_score == nil then
                frame = player.gui.left.add { name = "rocket_score", type = "frame", direction = "horizontal", caption = { "score" } }
                frame.add { name = "rocket_count_label", type = "label", caption = { "", { "rockets-sent" }, "" } }
                frame.add { name = "rocket_count", type = "label", caption = "1" }
            else
                player.gui.left.rocket_score.rocket_count.caption = tostring(global.satellite_sent[force.name])
            end
        end
    else
        if (#game.players <= 1) then
            game.show_message_dialog { text = { "gui-rocket-silo.rocket-launched-without-satellite" } }
        else
            for index, player in pairs(force.players) do
                player.print({ "gui-rocket-silo.rocket-launched-without-satellite" })
            end
        end
    end
	if global.DEBUG then
		PrintToAllPlayers({'debug.exit-method', "event_functions:on_rocket_launched"})
	end
end

function on_research_started(event)
	if global.DEBUG then
		PrintToAllPlayers({'debug.enter-method', "event_functions:on_research_started"})
	end
    if global.researchMessage.enabled then
        force = event.research.force
        PrintToAllPlayers({ 'resources.team-research-start', global.forcesData[force.name].title, { 'research-name' .. event.research.name } })
    end
	if global.DEBUG then
		PrintToAllPlayers({'debug.exit-method', "event_functions:on_research_started"})
	end
end

function on_research_finished(event)
	if global.DEBUG then
		PrintToAllPlayers({'debug.enter-method', "event_functions:on_research_finished"})
	end
    if global.researchMessage.enabled then
        force = event.research.force
        PrintToAllPlayers({ 'resources.team-research-end', global.forcesData[force.name].title, { 'research-name' .. event.research.name } })
    end
	if global.DEBUG then
		PrintToAllPlayers({'debug.exit-method', "event_functions:on_research_finished"})
	end
end

function getEventName(event)
    if event == nil then
        return 'event is kind of nil :O';
    end
    if event == defines.events.on_built_entity then
        return 'on_built_entity';
    elseif event == defines.events.on_canceled_deconstruction then
        return 'on_canceled_deconstruction';
    elseif event == defines.events.on_chunk_generated then
        return 'on_chunk_generated';
    elseif event == defines.events.on_entity_died then
        return 'on_entity_died';
    elseif event == defines.events.on_entity_settings_pasted then
        return 'on_entity_settings_pasted';
    elseif event == defines.events.on_force_created then
        return 'on_force_created';
    elseif event == defines.events.on_forces_merging then
        return 'on_forces_merging';
    elseif event == defines.events.on_gui_checked_state_changed then
        return 'on_gui_checked_state_changed';
    elseif event == defines.events.on_gui_click then
        return 'on_gui_click';
    elseif event == defines.events.on_gui_text_changed then
        return 'on_gui_text_changed';
    elseif event == defines.events.on_marked_for_deconstruction then
        return 'on_marked_for_deconstruction';
    elseif event == defines.events.on_picked_up_item then
        return 'on_picked_up_item';
    elseif event == defines.events.on_player_alt_selected_area then
        return 'on_player_alt_selected_area';
    elseif event == defines.events.on_player_ammo_inventory_changed then
        return 'on_player_ammo_inventory_changed';
    elseif event == defines.events.on_player_armor_inventory_changed then
        return 'on_player_armor_inventory_changed';
    elseif event == defines.events.on_player_built_tile then
        return 'on_player_built_tile';
    elseif event == defines.events.on_player_crafted_item then
        return 'on_player_crafted_item';
    elseif event == defines.events.on_player_created then
        return 'on_player_created';
    elseif event == defines.events.on_player_cursor_stack_changed then
        return 'on_player_cursor_stack_changed';
    elseif event == defines.events.on_player_died then
        return 'on_player_died';
    elseif event == defines.events.on_player_driving_changed_state then
        return 'on_player_driving_changed_state';
    elseif event == defines.events.on_player_gun_inventory_changed then
        return 'on_player_gun_inventory_changed';
    elseif event == defines.events.on_player_joined_game then
        return 'on_player_joined_game';
    elseif event == defines.events.on_player_left_game then
        return 'on_player_left_game';
    elseif event == defines.events.on_player_main_inventory_changed then
        return 'on_player_main_inventory_changed';
    elseif event == defines.events.on_player_mined_item then
        return 'on_player_mined_item';
    elseif event == defines.events.on_player_mined_tile then
        return 'on_player_mined_tile';
    elseif event == defines.events.on_player_placed_equipment then
        return 'on_player_placed_equipment';
    elseif event == defines.events.on_player_quickbar_inventory_changed then
        return 'on_player_quickbar_inventory_changed';
    elseif event == defines.events.on_player_removed_equipment then
        return 'on_player_removed_equipment';
    elseif event == defines.events.on_player_respawned then
        return 'on_player_respawned';
    elseif event == defines.events.on_player_rotated_entity then
        return 'on_player_rotated_entity';
    elseif event == defines.events.on_player_selected_area then
        return 'on_player_selected_area';
    elseif event == defines.events.on_player_tool_inventory_changed then
        return 'on_player_tool_inventory_changed';
    elseif event == defines.events.on_pre_entity_settings_pasted then
        return 'on_pre_entity_settings_pasted';
    elseif event == defines.events.on_pre_player_died then
        return 'on_pre_player_died';
    elseif event == defines.events.on_preplayer_mined_item then
        return 'on_preplayer_mined_item';
    elseif event == defines.events.on_put_item then
        return 'on_put_item';
    elseif event == defines.events.on_research_finished then
        return 'on_research_finished';
    elseif event == defines.events.on_research_started then
        return 'on_research_started';
    elseif event == defines.events.on_resource_depleted then
        return 'on_resource_depleted';
    elseif event == defines.events.on_robot_built_entity then
        return 'on_robot_built_entity';
    elseif event == defines.events.on_robot_built_tile then
        return 'on_robot_built_tile';
    elseif event == defines.events.on_robot_mined then
        return 'on_robot_mined';
    elseif event == defines.events.on_robot_mined_tile then
        return 'on_robot_mined_tile';
    elseif event == defines.events.on_robot_pre_mined then
        return 'on_robot_pre_mined';
    elseif event == defines.events.on_rocket_launched then
        return 'on_rocket_launched';
    elseif event == defines.events.on_sector_scanned then
        return 'on_sector_scanned';
    elseif event == defines.events.on_tick then
        return 'on_tick';
    elseif event == defines.events.on_train_changed_state then
        return 'on_train_changed_state';
    elseif event == defines.events.on_trigger_created_entity then
        return 'on_trigger_created_entity';
    else
        return 'unknown event';
    end
end