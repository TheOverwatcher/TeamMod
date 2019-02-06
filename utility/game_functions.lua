function isConfigWritten()
    return global.CONFIG_WRITTEN or false;
end

function setConfigWritten()
    if isConfigWritten() == false then
        global.CONFIG_WRITTEN_TIME = game.tick
    end
    global.CONFIG_WRITTEN = true;
end

function make_lobby()
	game.create_surface("Lobby", { width = 96, height = 32, starting_area = "big", water = "none" })
end