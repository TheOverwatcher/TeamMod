function putPlayerInTeam(player, forceData)
	if global.DEBUG then
		PrintToAllPlayers({'debug.enter-method', "player_functions:putPlayerInTeam"})
	end
	global.s = game.surfaces['nauvis'];
    player.teleport(game.forces[forceData.cName].get_spawn_position(global.s), global.s)
    player.color = forceData.color
    player.force = game.forces[forceData.cName]
    player.gui.left.choose_team.destroy()
    player.insert { name = "iron-plate", count = 8 }
    player.insert { name = "pistol", count = 1 }
    player.insert { name = "firearm-magazine", count = 10 }
    player.insert { name = "burner-mining-drill", count = 1 }
    player.insert { name = "stone-furnace", count = 1 }
    Alliance:make_alliance_overlay_button(player);
    TeamChat:make_team_chat_button(player);
    PrintToAllPlayers({ 'resources.player-msg-team-join', player.name, forceData.title })
	if global.DEBUG then
		PrintToAllPlayers({'debug.exit-method', "player_functions:putPlayerInTeam"})
	end
end

function couldJoinIntoForce(forceName)
	if global.DEBUG then
		PrintToAllPlayers({'debug.enter-method', "player_functions:couldJoinIntoForce"})
	end

    if global.teamBalance.enabled == false then
        return true;
    end

    global.check = {}
    global.lastValue = 0;
    global.onlyOne = false;
    table.each(global.forcesData, function(data)
        global.c = 0;
        table.each(game.players, function(player)
            if data.cName == player.force.name then c = c + 1 end
        end)
        global.check[data.cName] = global.c;
        if global.lastValue == global.c then -- check if all teams have the same amount of players
            global.onlyOne = true;
        else
            global.onlyOne = false;
        end
        global.lastValue = global.c
    end)
    if global.onlyOne == true then -- if all teams have the same amount of players, then it is possible to join this team
        return true;
    end
    for k,v in spairs(global.check) do
        return global.check[forceName] < v -- only join, if wanted force has fewer amount of players as the largest team
    end
	if global.DEBUG then
		PrintToAllPlayers({'debug.exit-method', "player_functions:couldJoinIntoForce"})
	end
    return true;
end

