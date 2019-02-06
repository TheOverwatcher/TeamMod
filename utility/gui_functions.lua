function make_alliance_overlay_button(player)
    Alliance:make_alliance_overlay_button(player);
end

-- This prevents extra clicking on the Alliance button
function disable_left_gui_interaction(player)
	if player.gui.left ~= nil then 
		player.gui.left.ignored_by_interaction = true;
	end
end

function enable_left_gui_interaction(player)
	if player.gui.left ~= nil then 
		player.gui.left.ignored_by_interaction = false;
	end
end

function make_alliance_overlay(player)
    Alliance:make_alliance_overlay(player);
end

function init_alliance_overlay()
    Alliance:init_overlay();
end

function make_team_chat_button(player)
    TeamChat:make_team_chat_button(player);
end

function make_team_option(player)
	if global.DEBUG then
		PrintToAllPlayers({'debug.enter-method', "gui_functions:make_team_option"})
	end

	if player.gui.left.choose_team == nil then
		global.frame = player.gui.left.add { name = "choose_team", type = "frame", direction = "vertical", caption = { "resources.team-choose" } }

		table.each(global.forcesData, function(data)
			global.frame.add { type = "button", caption = { 'resources.team-join', data.title }, name = 'choose_team_' .. data.name }.style.font_color = data.color
		end)
		global.frame.add { type = "button", caption = { "resources.team-auto-assign"}, name = "autoAssign" }
		global.frame.add { type = "button", caption = { "resources.team-check-number" }, name = "team_number_check" }.style.font_color = { r = 0.9, g = 0.9, b = 0.9 }
	end
	
	if global.DEBUG then
		PrintToAllPlayers({'debug.exit-method', "gui_functions:make_team_option"})
	end
end