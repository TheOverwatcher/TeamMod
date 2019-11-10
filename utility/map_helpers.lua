function MM_set_spawns(data, message)
	if global.DEBUG then
		PrintToAllPlayers({'debug.enter-method', "map_helpers:MM_set_spawns"})
	end
    global.s = game.surfaces["nauvis"]
    -- kill trees and enemy units
    if message then
        PrintToAllPlayers('resources.kill-enemy');
    end

	if global.DEBUG then
		PrintToAllPlayers({"First for"})
	end
	
    for _, enemyName in ipairs({"spitter-spawner","biter-spawner","small-worm-turret","medium-worm-turret","big-worm-turret", "behemoth-worm-turret"}) do
        for _, entity in ipairs(global.s.find_entities_filtered({area = SquareArea( data.cords, global.big_distance), name = enemyName})) do
            entity.destroy()
        end
    end
	if global.DEBUG then
		PrintToAllPlayers({"second for"})
	end
    for k, entity in pairs(global.s.find_enemy_units(data.cords, global.big_distance)) do
        entity.destroy()
    end

    if message then
        PrintToAllPlayers('resources.kill-trees');
    end
	if global.DEBUG then
		PrintToAllPlayers({"Third for"})
	end
    for _, enemyName in ipairs({"dead-dry-hairy-tree","dead-grey-trunk","dead-tree","dry-hairy-tree","dry-tree","green-coral","tree-01","tree-02","tree-02-red","tree-03","tree-04","tree-05","tree-06","tree-06-brown","tree-07","tree-08","tree-08-brown","tree-08-red","tree-09","tree-09-brown","tree-09-red"}) do
        for _, entity in ipairs(global.s.find_entities_filtered({area = SquareArea( data.cords, math.floor(global.points.startingAreaRadius*1.25)), name = enemyName})) do
            entity.destroy()
        end
    end
    global.attempts = 0
    global.non_colliding = nil;
	if global.DEBUG then
		PrintToAllPlayers({"First repeat"})
	end
    repeat
		if global.DEBUG then
			PrintToAllPlayers({'debug.variable-information', "global.non_colliding", global.non_colliding})
			PrintToAllPlayers({'debug.variable-information', "global.attempts", global.attempts})
			PrintToAllPlayers({'debug.variable-information', "data.cords", data.cords})
			PrintToAllPlayers({'debug.variable-information', "global.points.startingAreaRadius",global.points.startingAreaRadius})
		end
        global.non_colliding = global.s.find_non_colliding_position('character',data.cords, global.points.startingAreaRadius, 4)
		if global.DEBUG then
			PrintToAllPlayers({'debug.variable-information', "global.non_colliding", global.non_colliding})
			PrintToAllPlayers({'debug.variable-information', "global.attempts", global.attempts})
		end
        global.attempts = global.attempts + 1
    until (global.attempts == 20 or global.non_colliding ~= nil)
	if global.DEBUG then
		PrintToAllPlayers({"After until"})
	end
    if global.non_colliding == nil then
        PrintToAllPlayers('resources.map-unsutitable',data.title)
        game.forces[data.cName].set_spawn_position({ data.cords.x, data.cords.y }, global.s);
    else
        game.forces[data.cName].set_spawn_position({ global.non_colliding.x, global.non_colliding.y }, global.s);
    end

	if global.DEBUG then
		PrintToAllPlayers({"non_colliding"})
	end
    if global.non_colliding ~= nil then
        if message then
            PrintToAllPlayers('resources.kill-more-enemies');
        end
		if global.DEBUG then
			PrintToAllPlayers({"Destroy buildings"})
		end

        -- destroy enemy buildings
        for _, enemyName in ipairs({"spitter-spawner","biter-spawner","small-worm-turret","medium-worm-turret","big-worm-turret", "behemoth-worm-turret"}) do
            for _, entity in ipairs(global.s.find_entities_filtered({area = SquareArea( global.non_colliding, global.big_distance), name = enemyName})) do
                entity.destroy()
            end
        end
		
		if global.DEBUG then
			PrintToAllPlayers({"Destroy units"})
		end
        -- destroy enemy units
        for k, entity in pairs(global.s.find_enemy_units(global.non_colliding, global.big_distance)) do
            entity.destroy()
        end
    end
	
	if global.DEBUG then
		PrintToAllPlayers({'debug.exit-method', "map_helpers:MM_set_spawns"})
	end
end

function MM_set_starting_area(data)
	if global.DEBUG then
		PrintToAllPlayers({'debug.enter-method', "map_helpers:MM_set_starting_area"})
	end

    global.s = game.surfaces["nauvis"]
    global.s.set_tiles {
        { name = "water", position = { data.cords.x + 16, data.cords.y + 16 } },
        { name = "water", position = { data.cords.x + 17, data.cords.y + 16 } },
        { name = "water", position = { data.cords.x + 16, data.cords.y + 17 } },
        { name = "water", position = { data.cords.x + 17, data.cords.y + 17 } }
    }

    for k, pr in pairs(global.s.find_entities_filtered { area = { { data.cords.x - 128, data.cords.y - 128 }, { data.cords.x + 128, data.cords.y + 128 } }, type = "resource" }) do
        pr.destroy()
    end

    for k, r in pairs(global.s.find_entities_filtered { area = { { -128, -128 }, { 128, 128 } }, type = "resource" }) do
        global.prx = r.position.x
        global.pry = r.position.y
        global.force_prx = global.prx + data.team_x
        global.force_pry = global.pry + data.team_y
        global.tile = global.s.get_tile(global.force_prx, global.force_pry)
        if tile ~= nil and tile.valid then
            if tile.name ~= "water" and tile.name ~= "deepwater" then
                global.s.create_entity { name = r.name, position = { global.force_prx, global.force_pry }, force = r.force, amount = r.amount }
            end
        end
    end
	if global.DEBUG then
		PrintToAllPlayers({'debug.exit-method', "map_helpers:MM_set_starting_area"})
	end
end


function MM_create_force(data)
	if global.DEBUG then
		PrintToAllPlayers({'debug.enter-method', "map_helpers:MM_create_force"})
	end
    game.create_force(data.cName);
    MM_chart(data);
	if global.DEBUG then
		PrintToAllPlayers({'debug.exit-method', "map_helpers:MM_create_force"})
	end
end

function MM_chart(data)
	if global.DEBUG then
		PrintToAllPlayers({'debug.enter-method', "map_helpers:MM_chart"})
	end
    global.areabig_distance = round_area_to_chunk_save(SquareArea(data.cords, global.big_distance));
    game.forces["player"].chart('nauvis', global.areabig_distance)
    game.forces[data.cName].chart('nauvis', global.areabig_distance)
	if global.DEBUG then
		PrintToAllPlayers({'debug.exit-method', "map_helpers:MM_chart"})
	end
end


function MM_get_random_point(used_points, last_point)
    global.valid = true
    global.random_point_a = {x = 0, y = 0 }
    global.attempts = 0
    repeat
        global.valid = true
        if last_point ~= nil then
            global.factor = 1.5
            if global.attempts > ( global.points.numberOfTrysBeforeError / 2) then
                global.factor = math.floor(global.attempts / 2)
            end
            global.random_dis = math.floor(math.random(global.points.distance.min, global.points.distance.max) * global.factor)
            if math.random(0,1) == 1 then
                global.random_point_a.y = last_point.y + global.random_dis
            else
                global.random_point_a.y = last_point.y - global.random_dis
            end
            if math.random(0,1) == 1 then
                global.random_point_a.x = last_point.x + global.random_dis
            else
                global.random_point_a.x = last_point.x - global.random_dis
            end
            for point_index = 1, #used_points do
                global.p = used_points[point_index]
                global.x = (global.p.x - global.random_point_a.x) ^ 2
                global.y = (global.p.y - global.random_point_a.y) ^ 2
                global.dis = math.sqrt(global.x+global.y);
                if global.dis < global.points.distance.min then
                    global.valid = false
                end
            end
        else
            global.random_point_a = global.points.start
            last_point = global.random_point_a
        end
        global.attempts = global.attempts + 1
        if global.attempts > global.points.numberOfTrysBeforeError then
            error('ERROR: try to locate team position. Number of attempts '..global.points.numberOfTrysBeforeError..' exceded ' ..data.title..' ' ..global.attempts)
        end
    until global.valid == true

    return global.random_point_a;
end

