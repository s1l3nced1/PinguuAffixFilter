menu = require("menu")
filter = require("filter")
dump = require("dump")
selling = require("selling")

local last_cache_update = 0
local update_interval = 0

local filter_lookup = {
    ["Amulet"] = filter.amulet_affix_filter,
    ["Ring"] = filter.ring_affix_filter,
    ["2H"] = filter.two_hand_weapons_affix_filter,
    ["1H"] = filter.one_hand_weapons_affix_filter,
    ["Boots"] = filter.boots_affix_filter,
    ["Pants"] = filter.pants_affix_filter,
    ["Gloves"] = filter.gloves_affix_filter,
    ["Chest"] = filter.chest_affix_filter,
    ["Helm"] = filter.helm_affix_filter
}

local function get_filter(skin_name)
  
    -- Additional Weapons
    if #filter.focus_weapons_affix_filter > 0 and skin_name:match("Focus") then       
        return filter.focus_weapons_affix_filter
    end

    if #filter.dagger_weapons_affix_filter > 0 and skin_name:match("Dagger") then
        return filter.dagger_weapons_affix_filter
    end

    if #filter.shield_weapons_affix_filter > 0 and skin_name:match("Shield") then
        return filter.shield_weapons_affix_filter
    end

    -- Default Search
    for pattern, filter in pairs(filter_lookup) do
        if skin_name:match(pattern) then
            return filter
        end
    end
    return nil
end

local function is_sno_id_in_table(filter_entry, sno_id) 
    for _, filter_entry in pairs(filter_table) do
        if filter_entry.sno_id == sno_id then
            return true
        end
    end

    return false
end

local uber_table = {
    { name = "Tyrael's Might", sno = 1901484 },
    { name = "The Grandfather", sno = 223271 },
    { name = "Andariel's Visage", sno = 241930 },
    { name = "Ahavarion, Spear of Lycander", sno = 359165 },
    { name = "Doombringer", sno = 221017 },
    { name = "Harlequin Crest", sno = 609820 },
    { name = "Melted Heart of Selig", sno = 1275935 },
    { name = "‍Ring of Starless Skies", sno = 1306338 }
}

function is_uber_item(sno_to_check)
    for _, entry in ipairs(uber_table) do
        if entry.sno == sno_to_check then
            return true
        end
    end
    return false
end


local function get_affix_screen_position(item) -- (credits QQT)
    local row, col = item:get_inventory_row(), item:get_inventory_column()
    local screen_width, screen_height = get_screen_width(), get_screen_height()

    local inventory_start_x = screen_width * 0.6619
    local inventory_start_y = screen_height * 0.670
    local slot_width = menu.menu_elements.slot_offset_x_slider:get()
    local slot_height = menu.menu_elements.slot_offset_y_slider:get()
    local space_between_items_x = menu.menu_elements.box_space_slider:get()
    local space_between_items_y = 6.2

    local adjusted_slot_width = slot_width + space_between_items_x
    local adjusted_slot_height = slot_height + space_between_items_y
    local margin_x = space_between_items_x / 2
    local margin_y = space_between_items_y / 2
    local box_width = menu.menu_elements.box_width_slider:get()
    local box_height = menu.menu_elements.box_height_slider:get()

    local x = inventory_start_x + col * adjusted_slot_width + margin_x
    local y = inventory_start_y + row * adjusted_slot_height + margin_y

    return x, y, box_width, box_height
end

on_render_menu(function ()
    menu.render_menu()

    if menu.menu_elements.dumping_button:get() then
        dump.retrieve_inventory_items()
    end

end)

on_key_release(function(key)
    if key == 88 then 
        local local_player = get_local_player()
        if not local_player then
            return
        end

        local nearest_vendor = selling.get_nearest_vendor()
        if nearest_vendor and get_open_inventory_bag() == 0 then    
            local inventory_items = local_player:get_inventory_items()
            for _, inventory_item in pairs(inventory_items) do
                if inventory_item then
                    local skin_name = inventory_item:get_name()
                    local filter_table = get_filter(skin_name)
                
                    if filter_table then
                        local item_affixes = inventory_item:get_affixes()

                        if #item_affixes > 2 then
                            local found_required_affixes = 0
                            local found_optional_affixes = 0
                            local required_count = 0

                            -- Count required affixes in filter
                            for _, filter_entry in pairs(filter_table) do
                                if filter_entry.required then
                                    required_count = required_count + 1
                                end
                            end

                            for _, affix in pairs(item_affixes) do
                                if affix then
                                    for _, filter_entry in pairs(filter_table) do
                                        if filter_entry.sno_id == affix.affix_name_hash then
                                            if filter_entry.required then
                                                found_required_affixes = found_required_affixes + 1
                                            else
                                                found_optional_affixes = found_optional_affixes + 1
                                            end
                                        end
                                    end
                                end
                            end
        
                            -- Check if all required affixes are present and at least one optional affix
                            if found_required_affixes < required_count or 
                               (found_required_affixes == required_count and found_optional_affixes == 0) then
                                if not is_uber_item(inventory_item:get_sno_id()) then
                                    loot_manager.sell_specific_item(inventory_item)
                                end
                            end
                        else
                            loot_manager.sell_specific_item(inventory_item)
                        end
                    end
                end
            end
        end       
    end   
end)


on_render(function()
    if not menu.menu_elements.main_boolean:get() then
        return
    end

    local local_player = get_local_player()
    if not local_player then
        return
    end

    local current_time = os.time()
    if current_time - last_cache_update >= update_interval then
        if get_open_inventory_bag() == 0 then
            local inventory_items = local_player:get_inventory_items()
            for _, inventory_item in pairs(inventory_items) do
                if inventory_item then
                    local skin_name = inventory_item:get_name()
                    local filter_table = get_filter(skin_name)

                    if filter_table then
                        local item_affixes = inventory_item:get_affixes()
                        if #item_affixes > 1 then
                            local found_required_affixes = 0
                            local found_optional_affixes = 0
                            local required_count = 0

                            -- Count required affixes in filter
                            for _, filter_entry in pairs(filter_table) do
                                if filter_entry.required then
                                    required_count = required_count + 1
                                end
                            end

                            for _, affix in pairs(item_affixes) do
                                if affix then                                 
                                    for _, filter_entry in pairs(filter_table) do
                                        if filter_entry.sno_id == affix.affix_name_hash then
                                            if filter_entry.required then
                                                found_required_affixes = found_required_affixes + 1
                                            else
                                                found_optional_affixes = found_optional_affixes + 1
                                            end
                                        end
                                    end
                                end
                            end

                          

                            local x, y, box_width, box_height = get_affix_screen_position(inventory_item)
                            local total_found = found_required_affixes + found_optional_affixes

                            if is_uber_item(inventory_item:get_sno_id()) then
                                graphics.text_2d(tostring(total_found), vec2:new(x + box_width - 15, y + box_height - 25), 20, color_white(255))
                                graphics.rect(vec2:new(x, y), vec2:new(x + box_width, y + box_height), color_purple(255), 1, 3)
                            end

                            if required_count > 0 then
                                if found_required_affixes >= required_count and found_optional_affixes == 0 then
                                    -- Required Found, Optional Affixes not found
                                    graphics.text_2d(tostring(total_found) .. "R", vec2:new(x + box_width - 25, y + box_height - 25), 20, color_white(255))
                                    graphics.rect(vec2:new(x, y), vec2:new(x + box_width, y + box_height), color_red(255), 1, 3)
                                elseif found_required_affixes >= required_count and found_optional_affixes == 1 then
                                    -- Required Found, and 1 Optional Affix found
                                    graphics.text_2d(tostring(total_found) .. "R", vec2:new(x + box_width - 25, y + box_height - 25), 20, color_white(255))
                                    graphics.rect(vec2:new(x, y), vec2:new(x + box_width, y + box_height), color_orange(255), 1, 3)
                                elseif found_required_affixes >= required_count and found_optional_affixes == 2 then
                                    -- Perfect found, 2 optional affixes found and requiredo ne
                                    graphics.text_2d(tostring(total_found) .. "R", vec2:new(x + box_width - 25, y + box_height - 25), 20, color_white(255))
                                    graphics.rect(vec2:new(x, y), vec2:new(x + box_width, y + box_height), color_green(255), 1, 3)
                                end
                            else
                                -- No required offsets needed
                                if found_optional_affixes == 1 then
                                    graphics.text_2d(tostring(total_found), vec2:new(x + box_width - 15, y + box_height - 25), 20, color_white(255))
                                    graphics.rect(vec2:new(x, y), vec2:new(x + box_width, y + box_height), color_red(255), 1, 3)
                                elseif found_optional_affixes == 2 then
                                    graphics.text_2d(tostring(total_found), vec2:new(x + box_width - 15, y + box_height - 25), 20, color_white(255))
                                    graphics.rect(vec2:new(x, y), vec2:new(x + box_width, y + box_height), color_orange(255), 1, 3)
                                elseif found_optional_affixes == 3 then
                                    graphics.text_2d(tostring(total_found), vec2:new(x + box_width - 15, y + box_height - 25), 20, color_white(255))
                                    graphics.rect(vec2:new(x, y), vec2:new(x + box_width, y + box_height), color_green(255), 1, 3)
                                end
                            end
                        end
                    end
                end
            end
        end

        last_cache_update = current_time
    end
end)
