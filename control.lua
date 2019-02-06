require("constants")
require("utility.event")
require("utility.event_functions")
require("utility.game_functions")
require("utility.gui_functions")
require("utility.map_helpers")
require("utility.math")
require("utility.player_functions")
require("utility.position")
require("utility.table")
require("utility.team_functions")
require("utility.tick_helper")
require("utility.utilities")
require("utility.configuration_gui")
require("utility.alliance");
require("utility.team_chat");

script.on_init(on_init); 
script.on_load(on_load);
script.on_event(defines.events.on_player_created, on_player_created);
script.on_event(defines.events.on_tick, on_tick)
script.on_event(defines.events.on_gui_click, on_gui_click)
script.on_event(defines.events.on_rocket_launched, on_rocket_launched)
script.on_event(defines.events.on_research_started, on_research_started)
script.on_event(defines.events.on_research_finished, on_research_finished)
script.on_event(defines.events.on_entity_died, on_entity_died)

