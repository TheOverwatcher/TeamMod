function areTeamsEnabled()
    return global.TEAMS_ENABLED or false;
end

function setTeamsEnabled()
    global.TEAMS_ENABLED = true;
end

function areTeamsEnabledStartup()
    return global.TEAMS_ENABLED_STARTUP or false;
end

function setTeamsEnabledStartup()
    global.TEAMS_ENABLED_STARTUP = true;
end

function set_spawns()
	if global.DEBUG then
		PrintToAllPlayers({'debug.enter-method', "team_functions:set_spawns"})
	end
	global.s = game.surfaces['nauvis'];
    game.daytime = 0.9

    table.each(global.forcesData, function(data)
        MM_set_spawns(data);
    end)
	if global.DEBUG then
		PrintToAllPlayers({'debug.exit-method', "team_functions:set_spawns"})
	end
end

function set_starting_areas()
	if global.DEBUG then
		PrintToAllPlayers({'debug.enter-method', "team_functions:set_starting_areas"})
	end
	global.s = game.surfaces['nauvis'];

    table.each(global.forcesData, function(data)
        MM_set_starting_area(data);
    end)
	if global.DEBUG then
		PrintToAllPlayers({'debug.exit-method', "team_functions:set_starting_areas"})
	end
end

function make_forces()
	if global.DEBUG then
		PrintToAllPlayers({'debug.enter-method', "team_functions:make_forces"})
	end
    global.LAST_POINT = nil
    global.USED_POINTS = {}
    global.s = game.surfaces["nauvis"]
    table.each(global.forcesData, function(data, k)
        if data.cords == nil then
            global.RANDOM_POINT = MM_get_random_point(global.USED_POINTS, global.LAST_POINT);
            global.LAST_POINT = global.RANDOM_POINT;
			
            global.forcesData[k].team_x = global.RANDOM_POINT.x
            global.forcesData[k].team_y = global.RANDOM_POINT.y
            global.forcesData[k].team_position = { global.forcesData[k].team_x, global.forcesData[k].team_y }
            global.forcesData[k].cords = { x = global.forcesData[k].team_x, y = global.forcesData[k].team_y }
            global.forcesData[k].team_area = { { global.forcesData[k].team_x - global.distance, global.forcesData[k].team_y - global.distance }, { global.forcesData[k].team_x + global.distance, global.forcesData[k].team_y + global.distance } }
            global.LAST_POINT = global.forcesData[k].cords
            table.insert(global.USED_POINTS, global.LAST_POINT)
        end
        MM_create_force(data);
    end);
	if global.DEBUG then
		PrintToAllPlayers({'debug.exit-method', "team_functions:make_forces"})
	end
end

function triggerTeamsEnabling()
	if global.DEBUG then
		PrintToAllPlayers({'debug.enter-method', "team_functions:triggerTeamsEnabling"})
	end
	global.TRIGGER_TEAMS_SECONDS = 10;
	global.TICK_INTERVAL = global.TRIGGER_TEAMS_SECONDS * SECONDS;
    PrintToAllPlayers({ "resources.teams-enable-wait-to-be-charted" })
    global.checked_teams = {};
    global.if_valid = function(tick)
		if global.DEBUG_ALL and global.forcesData ~= nil  then
			PrintToAllPlayers('debug.forces-data-not-null')
		end
        for _, data in pairs(global.forcesData) do
            if global.checked_teams[data.name] == nil then
				if is_area_charted(round_area_to_chunk_save(SquareArea(data.cords, global.big_distance)), global.s) == false then
					PrintToAllPlayers({ 'resources.teams-enable-not-charted-yet', data.title, global.seconds })
					return false;
                end
                PrintToAllPlayers({ 'resources.team-area-charted', data.title })
                global.checked_teams[data.name] = true;
            end
        end
		
        return true;
    end
	
	if global.if_valid == true then
		PrintToAllPlayers({"if_valid true"})
	end
	
    global.tick_helper = function(tick)
        table.each(global.forcesData, function(data)
            MM_set_spawns(data);
            MM_set_starting_area(data);
        end)
        setTeamsEnabled();
        table.each(game.players, function(player)
			make_team_option(player);
        end)
    end
    register_tick_helper_if_valid('CREATE_TEAMS', global.tick_helper, global.TICK_INTERVAL, global.if_valid);
	if global.DEBUG then
		PrintToAllPlayers({'debug.exit-method', "team_functions:triggerTeamsEnabling"})
	end
end