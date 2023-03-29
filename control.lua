require("util")

local id = 0
local id2 = 0
local skip = 1
local player
local steps = {}
local step_list = {}
local speed = 1


local scope = {
    index = 0,
    start = 0,
    stop = 0,
    steps = {},
}

---@diagnostic disable: assign-type-mismatch
---@type boolean
local reach = settings.global["tas-reach"].value
---@type boolean
local reachable = settings.global["tas-reachable"].value
---@type boolean
local burn = settings.global["tas-burn"].value
---@type boolean
local craft = settings.global["tas-craft"].value
---@type uint
local reachable_range = settings.global["tas-reachable-range"].value
---@type uint
local skip = settings.global["tas-skip-tick"].value
---@type boolean
local craftable = settings.global["tas-craftable"].value
---@type boolean
local output = settings.global["tas-output"].value
---@diagnostic enable: assign-type-mismatch

local function update_game_speed()
    if game then speed = game.speed end
end

---Draws two circles indication your range
local function draw_reachable_range()
    if not reach then return end
    if id == 0 then
        id = rendering.draw_circle{
            color = {r=0.5,a=0.5},
            width = 2,
            radius = player.reach_distance,
            filled = false,
            target = player.character,
            surface = player.surface,
            draw_on_ground = true
        }
    end

    if id2 == 0 then
        id2 = rendering.draw_circle{
            color = {r=0.2, g=0.5,a=0.5},
            width = 2,
            radius = player.resource_reach_distance,
            filled = false,
            target = player.character,
            surface = player.surface,
            draw_on_ground = true
        }
    end
end

---draws bounding boxes on entities in range
local function draw_reachable_entities()
    if not reachable then return end
    local entities = player.surface.find_entities_filtered{
        position = player.position,
        radius = player.reach_distance+reachable_range,
        force = player.force
    }
    for i in pairs(entities) do
        if entities[i] ~= player.character and player.can_reach_entity(entities[i]) then
            rendering.draw_rectangle{
                color = {r=155, g=155, b=125, a=155},
                width = 1,
                filled = false,
                left_top = entities[i].bounding_box.left_top,
                right_bottom = entities[i].bounding_box.right_bottom,
                surface = player.surface,
                time_to_live = skip+1
            }
        end
    end

    entities = player.surface.find_entities_filtered{
        position = player.position,
        radius = player.resource_reach_distance+reachable_range,
        ---@diagnostic disable-next-line:undefined-global
        force = none
    }
    for i in pairs(entities) do
        if entities[i] ~= player.character and player.can_reach_entity(entities[i]) then
            rendering.draw_rectangle{
                color = {g=1, a=0.5},
                width = 1,
                filled = false,
                left_top = entities[i].bounding_box.left_top,
                right_bottom = entities[i].bounding_box.right_bottom,
                surface = player.surface,
                time_to_live = skip + 1,
                draw_on_ground = true
            }
        end
    end
end

---Draws crafting time left in ticks, of the current craft, for a furnace or assembler
---@param entity LuaEntity
local function draw_craft(entity)
    if not craft then return end
    if entity.prototype.type == "furnace" or entity.type == "assembling-machine" then
        local rec = entity.get_recipe()
        if rec ~= nil then
            local ticks_left = math.ceil(60*(1-entity.crafting_progress)*(rec.energy/entity.crafting_speed))
            if not entity.is_crafting() then ticks_left = 0 end
            rendering.draw_text{
                text = ticks_left,
                surface = entity.surface,
                target = entity.bounding_box.left_top,
                color = {1,1,1,1},
                time_to_live=skip+1
            }
        end
    end
end

---Draws fuel remaining in seconds on a burner entity (furnace, boiler, burner inserter etc.)
---@param entity LuaEntity
local function draw_burn(entity)
    if not burn then return end
    local fuel
    local fuel_remain = 0
    if  entity.burner == nil then return end
    fuel = entity.get_fuel_inventory()
    if  fuel == nil then return end

    local inv = fuel.get_contents()
    for stack, count in pairs(inv) do
        local stack_ent = game.item_prototypes[stack]
        fuel_remain = fuel_remain + stack_ent.fuel_value * count
    end

    local burner_time
    if entity.prototype.energy_usage == nil then
        burner_time = math.floor((entity.burner.remaining_burning_fuel + fuel_remain) / entity.prototype.max_energy_usage / 60)
    else
        burner_time = math.floor((entity.burner.remaining_burning_fuel + fuel_remain) / entity.prototype.energy_usage / 60)
    end

    rendering.draw_text{
        text = burner_time .. "s",
        surface = entity.surface,
        target = {entity.bounding_box.left_top.x, entity.bounding_box.right_bottom.y - 0.5},
        color = {1,1,1,1},
        time_to_live=skip+1
    }
end

---Draws the time an assembler will craft with the current input and the number of craftable items an assembler will produce before it runs out of resources
---@param entity LuaEntity
local function draw_craftable(entity)
    if not craftable then return end
    local inv = entity.get_inventory(defines.inventory.assembling_machine_input)
    if inv == nil or entity.type ~= "assembling-machine" then return end
    local rec = entity.get_recipe()
    if rec == nil then return end
    local count = 999
    local content = inv.get_contents()
    for i = 1, #rec.ingredients do
        if content[rec.ingredients[i].name] then
            count = math.min(count, math.floor(content[rec.ingredients[i].name] / rec.ingredients[i].amount))
        else
            count = 0
        end
    end

    local time
    if entity.crafting_progress == 0 then
        time = count * rec.energy / entity.crafting_speed
    else
        time = (1-entity.crafting_progress + count) * rec.energy / entity.crafting_speed
    end
    local text
    if time < 1 then text = math.floor(time*60) .. "t" else text = math.floor(time) .. "s" end --if less than 1 second

    rendering.draw_text{
        text = text,
        surface = entity.surface,
        target = {entity.bounding_box.left_top.x, entity.bounding_box.right_bottom.y -0.5}, --left bottom
        color = {1,1,1,1},
        time_to_live=skip+1
    }

    local color = {1,0,0,1} --red
    if entity.is_crafting() then
        count = count + 1
        color = {1,1,1,1} --shift color to white if crafting
    end

    rendering.draw_text{
        text = count,
        surface = entity.surface,
        target = {entity.bounding_box.right_bottom.x - 0.5, entity.bounding_box.left_top.y}, --right top
        color = color,
        time_to_live=skip+1
    }
end

---Draws the time left an lab can work and the number of cycles it has left
---@param entity LuaEntity
local function draw_lab(entity)
    if not craftable then return end
    local inv = entity.get_inventory(defines.inventory.lab_input)
    local research = player.force.current_research
    if inv == nil or research == nil or entity.type ~= "lab" then return end
    local ing = research.research_unit_ingredients
    local content = inv.get_contents()
    local count = 999.9
    for i = 1, #ing do
        if content[ing[i].name] then
            local stack = inv.find_item_stack(ing[i].name)
            if stack then count = math.min(count, (content[ing[i].name] -1 + stack.durability) / ing[i].amount)
            else count = 0 end
        else
            count = 0
        end
    end

    local time = count * research.research_unit_energy / entity.prototype.researching_speed
    local text
    if time < 61 then text = math.floor(time) .. "t" else text = math.floor(time/60) .. "s" end

    rendering.draw_text{
        text = text,
        surface = entity.surface,
        target = {entity.bounding_box.left_top.x, entity.bounding_box.right_bottom.y -0.5}, --left bottom
        color = {1,1,0,1},
        time_to_live=skip+1
    }

    rendering.draw_text{
        text = string.format("%.2f",count),
        surface = entity.surface,
        target = {entity.bounding_box.right_bottom.x - 0.85, entity.bounding_box.left_top.y}, --right top
        color = {1,1,1,1},
        time_to_live=skip+1
    }
end

---Draws the number of items ready for pick up
---@param entity LuaEntity
local function draw_output(entity)
    if not output then return end
    local count = -1
    local t = entity.type
    if t == "assembling-machine" then
        local inv = entity.get_inventory(defines.inventory.assembling_machine_output)
        if inv and #inv > 0 then
            count = inv[1].count--just take the first stack, whatever
        end
    elseif t == "furnace" then
        local inv = entity.get_inventory(defines.inventory.furnace_result)
        if inv and #inv > 0 then count = inv[1].count else count = 0 end --just take the first stack, whatever
    elseif t == "container" then
        local contents = entity.get_inventory(defines.inventory.chest).get_contents()
        count = 0
        for k,v in pairs(contents) do
            count = count + v
        end
    end --unhandled defines.inventory.rocket_silo_output

    if count > 0 then
        rendering.draw_text{
            text = count,
            surface = entity.surface,
            target = {entity.bounding_box.right_bottom.x - 0.5, entity.bounding_box.right_bottom.y - 0.5}, --right bottom
            color = {1,1,1,1},
            time_to_live=skip+1
        }
    end
end

---Creates the GUI for a player
---@param player_index uint
local function build_gui(player_index)
    local player = game.players[player_index]
    local screen = player.gui.screen

    global.player_info[player_index] = {
        -- references to gui objects belonging to this player
        refs = {},
    }
    local refs = global.player_info[player_index].refs

    local main_frame = screen.add{ type = "frame", direction = "vertical", }
    refs.main_frame = main_frame

    -- add title bar (from raiguard's style guide)
    do
        local title_bar = main_frame.add{ type = "flow", direction = "horizontal", name = "title_bar", }
        title_bar.drag_target = main_frame
        title_bar.add{ type = "label", style = "frame_title", caption = "T-helper", ignored_by_interaction = true, }
        title_bar.add{ type = "empty-widget", style = "game_speed_title_bar_draggable_space", ignored_by_interaction = true, }
        --refs.toggle_options_button = title_bar.add{ type = "sprite-button", style = "frame_action_button", sprite = "game_speed_settings_icon_white", hovered_sprite = "game_speed_settings_icon_black", clicked_sprite = "game_speed_settings_icon_black", }
        refs.t_main_frame_close_button = title_bar.add{ type = "sprite-button", style = "frame_action_button", sprite = "utility/close_white", hovered_sprite = "utility/close_black", clicked_sprite = "utility/close_black", }
    end

    local main_table = main_frame.add{ type = "table", style = "bordered_table", column_count = 1, }

    local function make_textfield_spec(style, default_text)
        return {
            type = "textfield",
            style = style,
            text = default_text,
            numeric = true,
            allow_decimal = true,
            allow_negative = true,
            lose_focus_on_confirm = true,
        }
    end

    do --controls
        local flow = main_table.add{ type = "flow", direction = "vertical" }
        refs.btn_controls = flow
        local display_flow = flow.add{ type = "flow", direction = "horizontal" }
        --display_flow.add{ type = "label", style = "caption_label", caption = {"t-tas-helper.tas-controls"}, }
        display_flow.add{ type = "empty-widget", style = "game_speed_horizontal_space", }
        local controls_flow = flow.add{ type = "flow", style = "game_speed_control_flow", direction = "horizontal", }
        refs.btn_controls_controls_flow = controls_flow
        controls_flow.add{ type = "empty-widget", style = "game_speed_horizontal_space", }
        refs.editor_button = controls_flow.add{ type = "sprite-button", style = "slot_sized_button", tooltip = "editor", sprite = "t_tas_controls_editor_icon",}
        refs.release_button = controls_flow.add{ type = "sprite-button", style = "slot_sized_button", tooltip = "release", sprite = "t_tas_controls_breaking_chain_icon",}
        refs.resume_button = controls_flow.add{ type = "sprite-button", style = "slot_sized_button", tooltip = "resume", sprite = "t_tas_controls_resume_icon",}
        refs.skip_button = controls_flow.add{ type = "sprite-button", style = "slot_sized_button", tooltip = "skip", sprite = "t_tas_controls_skip_icon",}
    end

    do --position & teleport 
        local flow = main_table.add{ type = "flow", direction = "vertical" }
        flow.add{ type = "label", style = "caption_label", caption = "Position", }
        local display_flow_pos = flow.add{ type = "flow", direction = "horizontal" }
        display_flow_pos.add{ type = "empty-widget", style = "game_speed_horizontal_space", }
        refs.current_position = display_flow_pos.add{ type = "label", caption = "[0 , 0]" }
        refs.teleport_flow = flow
        local display_flow = flow.add{ type = "flow", direction = "horizontal" }
        display_flow.add{ type = "label", style = "caption_label", caption = {"t-tas-helper.teleport"}, }
        display_flow.add{ type = "empty-widget", style = "game_speed_horizontal_space", }
        local controls_flow = flow.add{ type = "flow", style = "game_speed_control_flow", direction = "horizontal", }
        refs.teleport_controls_flow = controls_flow
        refs.x_textfield = controls_flow.add(make_textfield_spec("t_tas_helper_number_textfield", player.position.x))
        refs.y_textfield = controls_flow.add(make_textfield_spec("t_tas_helper_number_textfield", player.position.y))

        refs.teleport_button = controls_flow.add{ type = "sprite-button", style = "tool_button", tooltip = "teleport", sprite = "t_tas_controls_teleport_icon",}
    end

    do --tasklist
        local flow = main_table.add{ type = "flow", direction = "vertical" }
        local display_flow = flow.add{ type = "flow", direction = "horizontal" }
        display_flow.add{ type = "label", style = "caption_label", caption = {"t-tas-helper.step-list"}, }
        display_flow.add{ type = "empty-widget", style = "game_speed_horizontal_space", }
        refs.tasks = flow.add{type = "list-box", style = "t-tas-helper-tasks", items = scope.steps}
    end
end

---@param player_index uint
local function do_update(player_index)
    local refs = global.player_info[player_index].refs
    local p = game.players[player_index].position
    refs.current_position.caption = string.format("[ %.2f, %.2f ]", p.x, p.y)
end

---@param player_index uint?
local function update_gui_internal(player_index)
    if global.player_info == nil then global.player_info = {} end
    if player_index then
        do_update(player_index)
    else
        for player_index_, __ in pairs(global.player_info) do
            do_update(player_index_)
        end
    end
end

---@param player_index uint?
local function update_gui(player_index)
    update_gui_internal(player_index)
end

local function update_gui_for_all_players()
    if speed < 1.4 then
        update_gui_internal()
    end
end

---@param event EventData.on_lua_shortcut
local function toggle_gui(event)
    local player_index = event.player_index
    local refs = global.player_info[player_index].refs
    local frame = refs.main_frame

    frame.visible = not frame.visible
    frame.bring_to_front()

    -- toggle shortcut
    local player_ = game.players[player_index]
    player_.set_shortcut_toggled("t-tas-helper-toggle-gui", frame.visible)
end

---@param event EventData.on_gui_click
local function teleport(event)
    local p = game.players[event.player_index]
    local refs = global.player_info[event.player_index].refs
    local x = refs.x_textfield.text
    local y = refs.y_textfield.text
    p.teleport({x, y})
end

---@param player_index number
local function destroy_gui(player_index)
    if global
    and global.player_info
    and #global.player_info > 0
    and global.player_info[player_index].refs
    and global.player_info[player_index].refs.main_frame
    then
        global.player_info[player_index].refs.main_frame.destroy()
    end
    if global
    and global.player_info
    and global.player_info[player_index]
    then
        global.player_info[player_index] = nil
    end
end

---@param n number
---@return string
local function amount(n)
    if n == -1 then return "all"
    else return tostring(n) end
end

local function position_to_string(position)
    -- round to 2 decimal places
    local x = tonumber(string.format("%.2f", position.x))
    local y = tonumber(string.format("%.2f", position.y))
    return "[font=default-bold][" .. x .. ", " .. y .. "][/font]"
end

---@param str string
---@return string, integer
local function format_name(str)
    return str:gsub("^%l", string.upper):gsub("-", " ")
end

---Converts one entry in steps_ into a string for tasklist -> [task-number]: Taskname taskdetail
---@param step table
---@return string|table step_line
local function step_to_string(step)
    if not step then return "" end
    local n = step[2]
    if not n then return "" end
    local description
    if n == "walk" then
        description = {"tas-step.description_walk", position_to_string({x=step[3][1], y=step[3][2]})}
    elseif n == "put" or n == "take" then
        description = {"tas-step.description_"..n, amount(step[5]), step[4], position_to_string({x=step[3][1], y=step[3][2]})}
    elseif n == "craft" then
        description = {"tas-step.description_craft", amount(step[3]), step[4]}
    elseif n == "build" then
        return {"tas-step.description_step", step[1][1], {"tas-step.description_build", step[4], position_to_string({x=step[3][1], y=step[3][2]})}}
    elseif n == "mine" then
        description = {"tas-step.description_mine", position_to_string({x=step[3][1], y=step[3][2]})}
    elseif n == "recipe" then
        description = {"tas-step.description_recipe", step[4], position_to_string({x=step[3][1], y=step[3][2]})}
    elseif n == "drop" then
        description = {"tas-step.description_drop", step[4], position_to_string({x=step[3][1], y=step[3][2]})}
    elseif n == "filter" then
        description = {"tas-step.description_filter", step[4], position_to_string({x=step[3][1], y=step[3][2]})}
    elseif n == "limit" then
        description = {"tas-step.description_limit", step[4], position_to_string({x=step[3][1], y=step[3][2]})}
    elseif n == "tech" then
        description = {"tas-step.description_research", step[3]}
    elseif n == "priority" then
        description = {"tas-step.description_priority", step[4], step[5], position_to_string({x=step[3][1], y=step[3][2]})}
    elseif n == "pick" then
        description = {"tas-step.description_pickup", amount(step[3])}
    elseif n == "launch" then
        description = {"tas-step.description_launch", position_to_string({x=step[3][1], y=step[3][2]})}
    elseif n == "rotate" then
        description = {"tas-step.description_rotate", step[4] and "tas_helper_rotate_anticlockwise" or "tas_helper_rotate_clockwise", position_to_string({x=step[3][1], y=step[3][2]})}
    elseif n == "save" or n == "start" or n == "stop" or n == "pause" or n == "game_speed" or n == "idle" then
        description = {"tas-step.description_misc", n == "game_speed" and "Game speed" or format_name(n), step[3] and amount(step[3]) or ""}
    end
    return {"tas-step.description_step", step[1][1], description}
end

---comment
---@param player_index uint
---@param to_step uint
local function handle_scroll(player_index, to_step)
    local tasks = global.player_info[player_index].refs.tasks
    local scope_changed = false
    
    while math.abs(to_step - scope.index) > 100 do
        scope_changed = true
        if to_step - scope.index < 0 then scope.index = scope.index - 100
        else scope.index = scope.index + 100 end
    end
    if scope_changed then
        scope = {
            index = scope.index,
            start = math.max(1, scope.index - 100),
            stop = math.min(#steps, scope.index + 200),
            steps = {},
        }
        for i = scope.start, scope.stop do
            scope.steps[i] = steps[i]
        end
        global.player_info[player_index].refs.tasks.items = scope.steps
        tasks = global.player_info[player_index].refs.tasks
    end
    local step = step_list[to_step]
    if step and step[3] and step[3][1] then
        local x, y = step[3][1], step[3][2]
        if global.current_highlight_box then global.current_highlight_box.destroy{} end
        local highlight_box = game.surfaces[1].create_entity{
            name = "highlight-box",
            position = {0, 0}, -- ignored
            bounding_box = {{x-0.5,y-0.5},{x+0.5,y+0.5}},
        }
        global.current_highlight_box = highlight_box
    end
    tasks.scroll_to_item(to_step - (scope.start - 1), "top-third")
    tasks.selected_index = to_step - (scope.start - 1)

end

local function handle_task_change(data)
    if data and data.step then
        local to_step = math.max(1, math.min(#steps, data.step))
        for player_index, _ in pairs(game.players) do
            ---@cast player_index uint
            handle_scroll(player_index, to_step)
        end
    end
end

local function setup_tasklist()
    local interface = remote.interfaces["DunRaider-TAS"]
    if interface then
        --setup task list
        step_list = remote.call("DunRaider-TAS", "get_task_list")
        if not step_list then return end
        for i = 1, #step_list do
            steps[i] = step_to_string(step_list[i])
        end
        scope = {
            index = 0,
            start = 1,
            stop = math.min(#steps, 200),
            steps = {},
        }
        for i = scope.start, scope.stop do
            scope.steps[i] = steps[i]
        end
        for player_info, _ in pairs(global.player_info) do
            local refs = global.player_info[player_info].refs
            refs.tasks.items = scope.steps
            if refs.release_button and refs.skip_button and refs.resume_button then
                refs.release_button.enabled = interface.release
                refs.skip_button.enabled = interface.skip
                refs.resume_button.enabled = interface.resume
            end
            --handle_task_change({step = 1})
        end
        --setup event to fire on step change
        script.on_event(
            remote.call("DunRaider-TAS", "get_tas_step_change_id"),
            handle_task_change
        )
    end
end

local function change_setting(setting)
    if (setting == "tas-reach") then
        reach = settings.global["tas-reach"].value
        if id ~= 0 then
            rendering.destroy(id)
            id = 0
        end
        if id2 ~= 0 then
            rendering.destroy(id2)
            id2 = 0
        end
    end
    if (setting == "tas-reachable") then
        reachable = settings.global["tas-reachable"].value
    end
    if (setting == "tas-burn") then
        burn = settings.global["tas-burn"].value
    end
    if (setting == "tas-craft") then
        craft = settings.global["tas-craft"].value
    end
    if (setting == "tas-craftable") then
        craftable = settings.global["tas-craftable"].value
    end
    if (setting == "tas-output") then
        output = settings.global["tas-output"].value
    end
    if (setting == "tas-reachable-range") then
        reachable_range = settings.global["tas-reachable-range"].value
    end
end

script.on_event(defines.events.on_player_toggled_map_editor, function (event)
    if global.player_info and
        global.player_info[event.player_index] and global.player_info[event.player_index].refs and
        global.player_info[event.player_index].refs.editor_button
    then
        global.player_info[event.player_index].refs.editor_button.style =
            game.players[event.player_index].controller_type == defines.controllers.editor and "game_speed_selected_slot_sized_button" or "slot_sized_button"
    end
end)

script.on_init(function ()
    -- initialise player_info table
    global.player_info = {}

    -- build gui for all existing players
    for player_index, _ in pairs(game.players) do
        ---@cast player_index uint
        build_gui(player_index)
    end

    --The tas generated mod changes name so we just have to test if it is there
    setup_tasklist()
end)

script.on_load(function ()
    setup_tasklist()
    ---@diagnostic disable
    reach = settings.global["tas-reach"].value
    reachable = settings.global["tas-reachable"].value
    burn = settings.global["tas-burn"].value
    craft = settings.global["tas-craft"].value
    craftable = settings.global["tas-craftable"].value
    output = settings.global["tas-output"].value
    reachable_range = settings.global["tas-reachable-range"].value
    ---@diagnostic enable
end)

script.on_event(defines.events.on_player_created, function(event)
    build_gui(event.player_index)
end)

script.on_event(defines.events.on_pre_player_removed, function(event)
    pcall(destroy_gui,event.player_index)
end)

script.on_event(defines.events.on_tick, function(event)
    if event.tick % skip ~= 0 then return end
    if speed > 1.4 then return end

    if game.players == nil then return end
    player = game.players[1]
    if player == nil or player.character == nil then return end

    draw_reachable_range()
    draw_reachable_entities()
    if not (burn or craft or craftable or output) then return end
    local entities = player.surface.find_entities_filtered{
        position = player.position,
        radius = player.reach_distance+reachable_range,
        force = player.force
    }

    for i in pairs(entities) do
        local entity = entities[i]
        if entity ~= nil then
            draw_burn(entity)
            draw_craft(entity)
            draw_craftable(entity)
            draw_output(entity)
            draw_lab(entity)
        end
    end
end)

script.on_nth_tick(11, update_gui_for_all_players)
script.on_nth_tick(123, update_game_speed)

script.on_event(defines.events.on_runtime_mod_setting_changed , function(event)
    local setting = event.setting
    change_setting(setting)
end)

script.on_event("t-tas-helper-toggle-gui", toggle_gui)

script.on_configuration_changed(function (param1)
    local pi = true
    if global and not global.player_info then
        global.player_info = {}
        pi = false
    end

    -- build gui for all existing players
    for player_index, _ in pairs(game.players) do
        ---@cast player_index uint
        if player_index and pi then
            pcall(destroy_gui,player_index) --protected calling
            build_gui(player_index)
        elseif player_index then
            build_gui(player_index)
        end
    end
    setup_tasklist()
end)

local function defines_to_string(i)
    if i == defines.inventory.assembling_machine_input or i == defines.inventory.lab_input or i == defines.inventory.rocket_silo_input then
        return "input"
    elseif i == defines.inventory.assembling_machine_output then return "output"
    elseif i == defines.inventory.fuel then return "fuel"
    elseif i == defines.inventory.chest then return "inventory"
    else return tostring(i)
    end
end

local direction_strings = {
    "north",
    "northeast",
    "east",
    "southeast",
    "south",
    "southwest",
    "west",
    "northwest"
}
local function direction_to_string(i)
    return direction_strings[i+1]
end

---converts a step into a printable sting
local function step_to_print(step)
    local n = step[2]
    local extra = ""
    if n == "walk" then
        extra = string.format("to [gps=%.2f,%.2f]", step[3][1], step[3][2])
    elseif n == "pick" then
        n = "pick up"
        --extra = string.format("at [gps=%f,%f]", step[3][1], step[3][2])
    elseif n == "put" or n == "take" then
        extra = string.format("%s [item=%s] at [gps=%.1f,%.1f] %s", amount(step[5]), step[4], step[3][1], step[3][2], defines_to_string(step[6]))
    elseif n == "craft" then
        extra = string.format("%s [item=%s]", amount(step[3]), step[4])
    elseif n == "build" then
        extra = string.format("[item=%s] [gps=%.1f,%.1f] %s", step[4], step[3][1], step[3][2], direction_to_string(step[5]))
    elseif n == "mine" then --try to see if there is an entity
        extra = string.format("area [gps=%.2f,%.2f] for %d ticks", step[3][1], step[3][2], step[4])
    elseif n == "recipe" then
        extra = string.format("set [recipe=%s] at [gps=%.1f,%.1f]", step[4], step[3][1], step[3][2])
    elseif n == "drop" then
        extra = string.format("item [item=%s] at [gps=%.1f,%.1f]", step[4], step[3][1], step[3][2])
    elseif n == "filter" then
        extra = string.format("[item=%s] at [gps=%.1f,%.1f]", step[4], step[3][1], step[3][2])
    elseif n == "limit" then
        extra = string.format("to %d slots at [gps=%.1f,%.1f]", step[4], step[3][1], step[3][2])
    elseif n == "tech" then
        n = "research"
        extra = string.format("[technology=%s]",step[3])
    elseif n == "priority" then
        extra = string.format("in:%s, out:%s at [gps=%.1f,%.1f]", step[4], step[5], step[3][1], step[3][2])
    elseif n == "launch" then
        extra = string.format("[gps=%d,%d]", step[3][1], step[3][2])
    elseif n == "rotate" then
        if step[4] then n = "counter-rotate" else n = "rotate" end
        extra = string.format("[gps=%.1f,%.1f]", step[3][1], step[3][2])
    elseif n == "save" or n == "start" or n == "stop" or n == "pause" or n == "game_speed" or n == "idle" then
        extra = string.format("%s", step[3])
    end

    return string.format("task: [%d, %d] - %s %s", step[1][1], step[1][2], n, extra)
end

---@param event EventData.on_gui_selection_state_changed
local function select_task(event)
    local player_ = game.players[event.player_index]
    local element_ = event.element
    local step = step_list[element_.selected_index + (scope.start - 1)]

    player_.print(string.format("step: %d, %s", element_.selected_index + (scope.start - 1), step_to_print(step)))

    local type = step[2]
    if type == "walk" or
        type == "build" or
        type == "take" or
        type == "put" or
        type == "rotate" or type == "counter-rotate"
    then
        if player_.character and player_.character.surface then
            player_.character.surface.create_entity{
                name = "flare",
                position = step[3],
                movement = {0,0},
                height = 0,
                vertical_speed = 0,
                frame_speed = 120,
            }
        end
    end
end

script.on_event(defines.events.on_gui_selection_state_changed, function(event)
    local player_index = event.player_index
    local refs = global.player_info[player_index].refs
    local handlers = {
        [refs.tasks] = select_task,
    }
    for element, handler in pairs(handlers) do
        if event.element == element then
            handler(event)
        end
    end
end)

script.on_event(defines.events.on_lua_shortcut, function(event)
    if event.prototype_name == "t-tas-helper-toggle-gui" then
        toggle_gui(event)
    end
end)

local function editor()
    if player then player.toggle_map_editor() end
end
local function release()
    if remote.interfaces["DunRaider-TAS"] and remote.interfaces["DunRaider-TAS"].release then
        remote.call("DunRaider-TAS", "release")
    end
end
local function resume()
    if remote.interfaces["DunRaider-TAS"] and remote.interfaces["DunRaider-TAS"].resume then
        remote.call("DunRaider-TAS", "resume")
    end
end
local function skip_c()
    if remote.interfaces["DunRaider-TAS"] and remote.interfaces["DunRaider-TAS"].skip then
        remote.call("DunRaider-TAS", "skip", 1)
    end
end


script.on_event(defines.events.on_gui_click, function(event)
    local player_index = event.player_index
    local refs = global.player_info[player_index].refs
    local handlers = {
        [refs.t_main_frame_close_button] = toggle_gui,
        [refs.teleport_button] = teleport,
        [refs.editor_button] = editor,
        [refs.release_button] = release,
        [refs.resume_button] = resume,
        [refs.skip_button] = skip_c,
    }
    for element, handler in pairs(handlers) do
        if event.element == element then
            handler(event)
        end
    end
end)
