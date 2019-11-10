ConfigurationGui = {}

ConfigurationGui.steps = {
    teams = {
        prevStep = nil,
        nextStep = 'enable',
        caption = { 'resources-gui.forces-gui-caption' },
        
		createFrame = function(player)
			if global.DEBUG then
				PrintToAllPlayers({'debug.enter-method', "ConfigurationGui.steps.teams:createFrame"})
			end
			--if it already exists, close it
			if player.gui.center.teams_gui ~= nil then
                player.gui.center.teams_gui.destroy();
            end
			
			--create the frame
			local frame = ConfigurationGui:createFrame(player.gui.center, 'teams_gui', { 'resources-gui.create-gui-caption' });
			
			table.each(global.forcesData, function(forceData)
                local forceFrame = frame.add {
                    name = 'force_frame_' .. forceData.name,
                    type = 'scroll-pane',
                    direction = 'vertical'
                }
                forceFrame.add {
                    type = 'label',
                    --name = 'name', @2.1.1
                    caption = forceData.title
                }.style.font_color = forceData.color
                forceFrame.add {
                    type = 'button',
                    name = 'force_edit_' .. forceData.name,
                    caption = { 'resources-gui.force-edit-caption' }
                }
                if game.forces[forceData.name] == nil then
                    forceFrame.add {
                        type = 'button',
                        name = 'force_remove',
                        caption = { 'resources-gui.force-remove-caption' }
                    }
                end
            end)
			frame.add {
                type = 'button',
                name = 'force_new',
                caption = { 'resources-gui.force-new-caption' }
            }
			if global.DEBUG then
				PrintToAllPlayers({'debug.exit-method', "ConfigurationGui.steps.teams:createFrame"})
			end
            return frame;
		end,
		createForceGuiWithData = function(player, forceData)
			if global.DEBUG then
				PrintToAllPlayers({'debug.enter-method', "ConfigurationGui.steps.teams:createForceGuiWithData"})
			end
            if player.gui.center.create_force ~= nil then
                player.gui.center.create_force.destroy();
            end
            local frame = ConfigurationGui:createFrame(player.gui.center, 'create_force', { 'resources-gui.create-gui-caption' });
            if forceData.cName ~= '' then
                frame.caption = forceData.cName;
            end
			
			--Add scroll to overall frame.
			local scrollPane = ConfigurationGui:createScrollPane(frame, 'force_details', 'horizontal', "")
			
			local flow = scrollPane.add { type = 'flow', name = "force_name", direction = 'vertical'}
			
			flow.add { type = "label", caption = { 'resources-gui.force-name-caption' } }
			flow.add { type = "textfield", name = "textfield", text = forceData.title }
			
            color = scrollPane.add {
                type = 'frame',
                direction = 'vertical',
                name = 'color',
                caption = { 'resources-gui.force-color-caption' }
            }

            local forceColor = ConfigurationGui:colorToRgb(forceData.color)
            for k, v in pairs(forceColor) do
                local colorTable = color.add {
                    type = 'table',
                    direction = 'horizontal',
                    name = k,
					column_count = 2,
					draw_vertical_lines = true,
					draw_horizontal_lines = true,
					draw_horizontal_lines_after_headers = true,
                }
				
				--Trying to determine even spacing for table columns
				colorTable.style.horizontal_spacing = 20
				colorTable.style.vertical_spacing = 10
				
                local nameFrame = colorTable.add {
                    type = 'frame',
					direction = 'horizontal',
					
				}
				
				nameFrame.add {
					type = "label",
                    caption = { 'resources-gui.force-color-' .. k .. '-caption' }
                
				}
				
				local maxVal = 255
				
				PrintToAllPlayers({'debug.key-value-pair-msg',k,v})
				
				if k == 'a' then
					maxVal = 1
				end
				
				PrintToAllPlayers({'debug.max-amount-msg',maxVal})
				
                local slider = colorTable.add {
                    name = "slider",
                    text = v,	
                    type = "slider",
					minimum_value = 0,
					maximum_value = maxVal,
					value = v,
                }
            end
			
			-- Add to parent frame outside of scrolling
			
            local button = frame.add {
                type = 'button',
                name = 'force_save',
                caption = { 'resources-gui.force-save-caption' }
            }
			local button = frame.add {
                type = 'button',
                name = 'force_cancel',
                caption = { 'resources-gui.force-cancel-caption' }
            }
			if global.DEBUG then
				PrintToAllPlayers({'debug.exit-method', "ConfigurationGui.steps.teams:createForceGuiWithData"})
			end
        end,
        createForceGui = function(player)
			if global.DEBUG then
				PrintToAllPlayers({'debug.enter-method', "ConfigurationGui.steps.teams:createForceGui"})
			end
            local forceData = {
                name = "",
                title = "",
                cName = '',
                color = { r = 1, g = 1, b = 1, a = 1 }
            }
            ConfigurationGui.steps.teams.createForceGuiWithData(player, forceData);
			if global.DEBUG then
				PrintToAllPlayers({'debug.exit-method', "ConfigurationGui.steps.teams:createForceGui"})
			end
        end,
		getForceData = function(frame)
            return {
                name = frame.force_name.textfield.text,
                title = frame.force_name.textfield.text,
                cName = frame.force_name.textfield.text,
                color = ConfigurationGui:rgbToColor({
                    r = frame.color.r.slider.slider_value,
                    g = frame.color.g.slider.slider_value,
                    b = frame.color.b.slider.slider_value,
                    a = frame.color.a.slider.slider_value
                })
            }
        end,
		createStep = function(player)
			if global.DEBUG then
				PrintToAllPlayers({'debug.enter-method', "ConfigurationGui.steps.teams:createStep"})
			end
			if global.DEBUG_ALL then 
				PrintToAllPlayers({'debug.variable-information',"ConfigurationGui.steps.teams.prevStep",ConfigurationGui.steps.teams.prevStep})
				PrintToAllPlayers({'debug.variable-information',"ConfigurationGui.steps.teams.nextStep",ConfigurationGui.steps.teams.nextStep})
			end
			
            return ConfigurationGui.steps.teams.createFrame(player);
        end,
        saveStep = function(player) 
			if global.DEBUG then
				PrintToAllPlayers({'debug.enter-method', "ConfigurationGui.steps.teams:saveStep"})
			end
			if global.DEBUG then
				PrintToAllPlayers({'debug.exit-method', "ConfigurationGui.steps.teams:saveStep"})
			end
		end,
        destroyStep = function(player)
			if global.DEBUG then
				PrintToAllPlayers({'debug.enter-method', "ConfigurationGui.steps.teams:destroyStep"})
			end
            if player.gui.center.teams_gui ~= nil then
                player.gui.center.teams_gui.destroy();
            end
			if global.DEBUG then
				PrintToAllPlayers({'debug.enter-method', "ConfigurationGui.steps.teams:destroyStep"})
			end
        end
    },
    enable = {
        prevStep = 'teams',
        nextStep = 'points',
        caption = { 'enable-gui.caption' },
        createStep = function(player)
			if global.DEBUG then
				PrintToAllPlayers({'debug.enter-method', "ConfigurationGui.steps.enable:createStep"})
			end
			if global.DEBUG_ALL then 
				PrintToAllPlayers({'debug.variable-information',"ConfigurationGui.steps.enable.prevStep",ConfigurationGui.steps.enable.prevStep})
				PrintToAllPlayers({'debug.variable-information',"ConfigurationGui.steps.enable.nextStep",ConfigurationGui.steps.enable.nextStep})
			end
			
            local frame = ConfigurationGui:createFrame(player.gui.center, 'enable_gui', { 'enable-gui.caption' });
			
			ConfigurationGui:createCheckboxFlow(frame, "attackMessage", { 'enable-gui.label-' .. "attackMessage" }, global.attackMessage.enabled)
			ConfigurationGui:createCheckboxFlow(frame, "researchMessage", { 'enable-gui.label-' .. "researchMessage" }, global.researchMessage.enabled)
			ConfigurationGui:createCheckboxFlow(frame, "teamMessageGui", { 'enable-gui.label-' .. "teamMessageGui" }, global.teamMessageGui.enabled)
			ConfigurationGui:createCheckboxFlow(frame, "allianceGui", { 'enable-gui.label-' .. "allianceGui" }, global.allianceGui.enabled)
			ConfigurationGui:createCheckboxFlow(frame, "teamBalance", { 'enable-gui.label-' .. "teamBalance" }, global.teamBalance.enabled)
            
			if global.DEBUG then
				PrintToAllPlayers({'debug.exit-method', "ConfigurationGui.steps.enable:createStep"})
			end
			return frame -- Check about other frame names
        end,
        saveStep = function(player)
			if global.DEBUG then
				PrintToAllPlayers({'debug.enter-method', "ConfigurationGui.steps.enable:saveStep"})
			end
			
			global.attackMessage.enabled = player.gui.center.enable_gui["attackMessage"].checkbox.state
			global.researchMessage.enabled = player.gui.center.enable_gui["researchMessage"].checkbox.state
			global.teamMessageGui.enabled = player.gui.center.enable_gui["teamMessageGui"].checkbox.state
			global.allianceGui.enabled = player.gui.center.enable_gui["allianceGui"].checkbox.state
			global.teamBalance.enabled = player.gui.center.enable_gui["teamBalance"].checkbox.state
			
			if global.DEBUG_ALL then
				PrintToAllPlayers({'debug.variable-information', "global.attackMessage.enabled", global.attackMessage.enabled})
				PrintToAllPlayers({'debug.variable-information', "global.researchMessage.enabled", global.researchMessage.enabled})
				PrintToAllPlayers({'debug.variable-information', "global.teamMessageGui.enabled", global.teamMessageGui.enabled})
				PrintToAllPlayers({'debug.variable-information', "global.allianceGui.enabled", global.allianceGui.enabled})
				PrintToAllPlayers({'debug.variable-information', "global.teamBalance.enabled", global.teamBalance.enabled})
			end
			
			if global.DEBUG then
				PrintToAllPlayers({'debug.exit-method', "ConfigurationGui.steps.enable:saveStep"})
			end
        end,
        destroyStep = function(player)
			if global.DEBUG then
				PrintToAllPlayers({'debug.enter-method', "ConfigurationGui.steps.enable:destroyStep"})
			end
            if player.gui.center.enable_gui ~= nil then
                player.gui.center.enable_gui.destroy();
            end
			if global.DEBUG then
				PrintToAllPlayers({'debug.exit-method', "ConfigurationGui.steps.enable:destroyStep"})
			end
        end
    },
    points = {
        prevStep = 'enable',
        nextStep = nil,
        caption = { 'point-gui.caption' },
        createStep = function(player)
			if global.DEBUG then
				PrintToAllPlayers({'debug.enter-method', "ConfigurationGui.steps.points:createStep"})
			end
			if global.DEBUG_ALL then 
				PrintToAllPlayers({'debug.variable-information',"ConfigurationGui.steps.points.prevStep",ConfigurationGui.steps.points.prevStep})
				PrintToAllPlayers({'debug.variable-information',"ConfigurationGui.steps.points.nextStep",ConfigurationGui.steps.points.nextStep})
			end
			
            local frame = ConfigurationGui:createFrame(player.gui.center, 'point_gui', { 'point-gui.caption' });
            ConfigurationGui:createTextFieldFlow(frame, 'startingAreaRadius', { 'point-gui.label-startingAreaRadius' }, global.points.startingAreaRadius);
            ConfigurationGui:createTextFieldFlow(frame, 'pointsMin', { 'point-gui.label-distance-min' }, global.points.distance.min);
            ConfigurationGui:createTextFieldFlow(frame, 'pointsMax', { 'point-gui.label-distance-max' }, global.points.distance.max);
            ConfigurationGui:createTextFieldFlow(frame, 'd', { 'point-gui.label-distance' }, global.distance);
            ConfigurationGui:createTextFieldFlow(frame, 'bd', { 'point-gui.label-big-distance' }, global.big_distance);
            
			if global.DEBUG then
				PrintToAllPlayers({'debug.exit-method', "ConfigurationGui.steps.points:createStep"})
			end
			return frame;
        end,
        saveStep = function(player)
			if global.DEBUG then
				PrintToAllPlayers({'debug.enter-method', "ConfigurationGui.steps.points:saveStep"})
			end
            local gui = player.gui.center.point_gui;
            global.distance = tonumber(gui.d.textfield.text);
            global.big_distance = tonumber(gui.bd.textfield.text);
            global.points.startingAreaRadius = tonumber(gui.startingAreaRadius.textfield.text);
            global.points.distance.min = tonumber(gui.pointsMin.textfield.text);
            global.points.distance.max = tonumber(gui.pointsMax.textfield.text);
			
			if global.DEBUG_ALL then
				PrintToAllPlayers({'debug.variable-information', "global.distance", global.distance})
				PrintToAllPlayers({'debug.variable-information', "global.big_distance", global.big_distance})
				PrintToAllPlayers({'debug.variable-information', "global.points.startingAreaRadius", global.points.startingAreaRadius})
				PrintToAllPlayers({'debug.variable-information', "global.points..distance.min", global.points..distance.min})
				PrintToAllPlayers({'debug.variable-information', "global.points..distance.max", global.points..distance.max})
			end
			
			if global.DEBUG then
				PrintToAllPlayers({'debug.exit-method', "ConfigurationGui.steps.points:saveStep"})
			end
		end,
        destroyStep = function(player)
			if global.DEBUG then
				PrintToAllPlayers({'debug.enter-method', "ConfigurationGui.steps.points:destroyStep"})
			end
            if player.gui.center.point_gui ~= nil then
                player.gui.center.point_gui.destroy();
            end
			if global.DEBUG then
				PrintToAllPlayers({'debug.exit-method', "ConfigurationGui.steps.points:destroyStep"})
			end
        end
    }
}

function ConfigurationGui:createNextAndPrev(gui)
	if global.DEBUG then
		PrintToAllPlayers({'debug.enter-method', "ConfigurationGui:createNextAndPrev"})
	end
    local f = gui.add {
        type = 'flow',
        direction = 'horizontal'
    }

	if global.DEBUG then
		PrintToAllPlayers({'debug.current-step', global.configStep})
	end
	
    local s = ConfigurationGui.steps[global.configStep];

    if s.prevStep ~= nil then
        f.add {
            type = 'button',
            name = 'prev_step',
            caption = { '', '< ', ConfigurationGui.steps[s.prevStep].caption }
        }
    end

    if s.nextStep == nil then
        if global.forcesData ~= nil and table.length(global.forcesData) > 0 then
            f.add {
                type = 'button',
                name = 'start_game',
                caption = { 'config-gui.start' }
            }
        else
            f.add {
                type = 'label',
                caption = { 'config-gui.min-one-team' }
            }
        end
    else
        f.add {
            type = 'button',
            name = 'next_step',
            caption = { '', ConfigurationGui.steps[s.nextStep].caption, ' >' }
        }
    end
	if global.DEBUG then
		PrintToAllPlayers({'debug.exit-method', "ConfigurationGui:createNextAndPrev"})
	end
end

function ConfigurationGui:createConfigurationGui(player)
	if global.DEBUG then
		PrintToAllPlayers({'debug.enter-method', "ConfigurationGui:createConfigurationGui"})
	end

	if global.DEBUG then
		PrintToAllPlayers({'debug.current-step', global.configStep})
	end
	
    -- init first step
    local g = ConfigurationGui:try(ConfigurationGui.steps[global.configStep].createStep, player);

    ConfigurationGui:createNextAndPrev(g);
	
	if global.DEBUG then
		PrintToAllPlayers({'debug.exit-method', "ConfigurationGui:createConfigurationGui"})
	end
end

function ConfigurationGui:try(f, ...)
    local status, r = pcall(f, ...);
    if not status then
        PrintToAllPlayers(r);
    end
    return r;
end

function ConfigurationGui:createFrame(parent, name, caption)
    return parent.add {
        type = 'frame',
        name = name,
        direction = 'vertical',
        caption = caption
    }
end

function ConfigurationGui:createScrollPane(parent, name, direction, caption)
    return parent.add {
        type = 'scroll-pane',
        name = name,
        direction = direction,
        caption = caption,
		vertical_scroll_policy = "always"
    }
end

function ConfigurationGui:createTextFieldFlow(gui, name, caption, value)
	if global.DEBUG then
		PrintToAllPlayers({'debug.enter-method', "ConfigurationGui:createTextFieldFlow"})
	end
    local flow = gui.add {
        type = 'flow',
        direction = 'horizontal',
        name = name
    }
    flow.add {
        type = "label",
        caption = caption
    }
    flow.add {
        name = "textfield",
        type = "textfield",
        text = value,
    }
	if global.DEBUG then
		PrintToAllPlayers({'debug.exit-method', "ConfigurationGui:createTextFieldFlow"})
	end
end

function ConfigurationGui:createCheckboxFlow(gui, name, caption, value)
	if global.DEBUG then
		PrintToAllPlayers({'debug.enter-method', "ConfigurationGui:createCheckboxFlow"})
	end
    local flow = gui.add {
        type = 'flow',
        direction = 'horizontal',
        name = name
    }
    flow.add {
        type = "label",
        caption = caption
    }
    flow.add {
        name = "checkbox",
        type = "checkbox",
        state = value,
    }
	if global.DEBUG then
		PrintToAllPlayers({'debug.exit-method', "ConfigurationGui:createCheckboxFlow"})
	end
end

function ConfigurationGui:colorToRgb(color)
    return {
        r = color.r * 255,
        g = color.g * 255,
        b = color.b * 255,
        a = color.a
    }
end

function ConfigurationGui:rgbToColor(rgb)
    return {
        r = rgb.r / 255,
        g = rgb.g / 255,
        b = rgb.b / 255,
        a = rgb.a
    }
end