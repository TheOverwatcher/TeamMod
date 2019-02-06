TeamChat = {};

function TeamChat:make_team_chat_gui(player)
    if player.gui.center.team_chat == nil then
        local f = player.gui.center.add { name = "team_chat", type = "frame", direction = "vertical", caption = {"resources.team-chat-caption"} }
        f.add{type="textfield", name="team_chat_message", caption ={"resources.team-chat-message"}}
        f.add{type="button", name="team_chat_message_send", caption ={"resources.team-chat-send"}}
        f.add{type="button", name="team_chat_message_close", caption ={"resources.team-chat-close"}}
    end
end

function TeamChat:make_team_chat_button(player)
    if player.gui.left.team_chat_button == nil and global.teamMessageGui.enabled then
        player.gui.left.add { name = "team_chat_button", type = "button", caption = "C", direction = "horizontal" }
    end
end

function TeamChat:destroy_team_chat_button(player)
	if player.gui.left.team_chat_button ~= nil then 
		player.gui.left.team_chat_button.destroy()
	end
end