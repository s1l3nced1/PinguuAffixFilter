local selling = {}

function selling.get_nearest_vendor() 
    local actors = actors_manager.get_all_actors()

    local player_position = get_player_position()
    table.sort(actors, function(a, b)
        return a:get_position():squared_dist_to_ignore_z(player_position) <
         b:get_position():squared_dist_to_ignore_z(player_position)
    end);
    
    -- now interact with the actors in order of proximity
    for _, actor in ipairs(actors) do
        if actor then
            if actor:get_position():dist_to_ignore_z(player_position) <= 8 and (actor:get_skin_name():match("Vendor_Armor") or actor:get_skin_name():match("Vendor_Silver") or actor:get_skin_name():match("Vendor_Weapons")) then
                return actor
            end
        end
    end

    return nil
end

function selling.draw_vendor_information()
    local nearest_vendor = selling.get_nearest_vendor()

    if nearest_vendor then
        graphics.text_3d("Press [X] to sell all items that have less than 2 searched affixes", nearest_vendor:get_position(), 15, color_red(255))
    end
end


return selling