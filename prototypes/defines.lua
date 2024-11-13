defines.constants = {}
defines.constants.preferences = {}

defines.constants.preferences['q-tasklist-size'] = {}
defines.constants.preferences['q-tasklist-size'].type = "int-setting"
defines.constants.preferences['q-tasklist-size'].name = "q-tasklist-size"
defines.constants.preferences['q-tasklist-size'].setting_type = "startup"
defines.constants.preferences['q-tasklist-size'].default_value = 450
defines.constants.preferences['q-tasklist-size'].minimum_value = 10
defines.constants.preferences['q-tasklist-size'].maximum_value = 4000
defines.constants.preferences['q-tasklist-size'].order = "a0"

defines.constants.preferences['q-gui-width'] = {}
defines.constants.preferences['q-gui-width'].type = "int-setting"
defines.constants.preferences['q-gui-width'].name = "q-gui-width"
defines.constants.preferences['q-gui-width'].setting_type = "startup"
defines.constants.preferences['q-gui-width'].default_value = 250
defines.constants.preferences['q-gui-width'].minimum_value = 100
defines.constants.preferences['q-gui-width'].maximum_value = 500
defines.constants.preferences['q-gui-width'].order = "a1"

defines.constants.preferences['q-reload-settings-on-load'] = {}
defines.constants.preferences['q-reload-settings-on-load'].type = "bool-setting"
defines.constants.preferences['q-reload-settings-on-load'].name = "q-reload-settings-on-load"
defines.constants.preferences['q-reload-settings-on-load'].setting_type = "startup"
defines.constants.preferences['q-reload-settings-on-load'].default_value = false
defines.constants.preferences['q-reload-settings-on-load'].hidden = false
defines.constants.preferences['q-reload-settings-on-load'].order = "a2"

defines.constants.preferences['q-scope-increment'] = {}
defines.constants.preferences['q-scope-increment'].type = "int-setting"
defines.constants.preferences['q-scope-increment'].name = "q-scope-increment"
defines.constants.preferences['q-scope-increment'].setting_type = "startup"
defines.constants.preferences['q-scope-increment'].default_value = 100
defines.constants.preferences['q-scope-increment'].minimum_value = 10
defines.constants.preferences['q-scope-increment'].maximum_value = 500
defines.constants.preferences['q-scope-increment'].order = "a3"

-- {
--   type = "bool-setting",
--   name = prefix .. "reachable",
--   setting_type = "runtime-global",
--   default_value = true,
--   hidden = true,
--   order = "q2"
-- }, {
--   type = "bool-setting",
--   name = prefix .. "crafting",
--   setting_type = "runtime-global",
--   default_value = true,
--   hidden = true,
--   order = "q3a"
-- }, {
--   type = "int-setting",
--   name = prefix .. "crafting-yellow-swap",
--   setting_type = "runtime-global",
--   default_value = 120,
--   hidden = true,
--   order = "q3b"
-- }, {
--   type = "int-setting",
--   name = prefix .. "crafting-red-swap",
--   setting_type = "runtime-global",
--   default_value = 30,
--   hidden = true,
--   order = "q3c"
-- }, {
--   type = "bool-setting",
--   name = prefix .. "burn",
--   setting_type = "runtime-global",
--   default_value = true,
--   hidden = true,
--   order = "q4a"
-- }, {
--   type = "int-setting",
--   name = prefix .. "burn-yellow-swap",
--   setting_type = "runtime-global",
--   default_value = 150,
--   hidden = true,
--   order = "q4b"
-- }, {
--   type = "int-setting",
--   name = prefix .. "burn-red-swap",
--   setting_type = "runtime-global",
--   default_value = 2,
--   hidden = true,
--   order = "q4c"
-- }, {
--   type = "bool-setting",
--   name = prefix .. "lab",
--   setting_type = "runtime-global",
--   default_value = true,
--   hidden = true,
--   order = "qa4a"
-- }, {
--   type = "int-setting",
--   name = prefix .. "lab-yellow-swap",
--   setting_type = "runtime-global",
--   default_value = 150,
--   hidden = true,
--   order = "qa4b"
-- }, {
--   type = "int-setting",
--   name = prefix .. "lab-red-swap",
--   setting_type = "runtime-global",
--   default_value = 2,
--   hidden = true,
--   order = "qa4c"
-- }, {
--   type = "int-setting",
--   name = prefix .. "reachable-range",
--   setting_type = "runtime-global",
--   default_value = 1,
--   minimum_value = -5,
--   maximum_value = 100,
--   hidden = true,
--   order = "q5"
-- }, {
--   type = "int-setting",
--   name = prefix .. "skip-tick",
--   setting_type = "runtime-global",
--   default_value = 3,
--   minimum_value = 1,
--   maximum_value = 1000,
--   hidden = true,
--   order = "q6"
-- }, {
--   type = "bool-setting",
--   name = prefix .. "output",
--   setting_type = "runtime-global",
--   default_value = true,
--   hidden = true,
--   order = "q8"
-- }, {
--   type = "bool-setting",
--   name = prefix .. "cycle",
--   setting_type = "runtime-global",
--   default_value = true,
--   hidden = true,
--   order = "q8a"
-- }, {
--   type = "bool-setting",
--   name = prefix .. "cycle_furnace",
--   setting_type = "runtime-global",
--   default_value = true,
--   hidden = true,
--   order = "q8b"
-- }, {
--   type = "bool-setting",
--   name = prefix .. "cycle_miner",
--   setting_type = "runtime-global",
--   default_value = false,
--   hidden = true,
--   order = "q8c"
-- }, {
--   type = "bool-setting",
--   name = prefix .. "furnace_craftable",
--   setting_type = "runtime-global",
--   default_value = false,
--   hidden = true,
--   order = "q10"
-- }, {
--   type = "bool-setting",
--   name = prefix .. "speed_boost",
--   setting_type = "runtime-global",
--   default_value = true,
--   hidden = true,
--   order = "q9"
-- }, {
--   type = "int-setting",
--   name = prefix .. "x",
--   setting_type = "runtime-global",
--   default_value = 0,
--   -- minimum_value = 0,
--   -- maximum_value = 10000,
--   hidden = true,
--   order = "p6"
-- }, {
--   type = "int-setting",
--   name = "y",
--   setting_type = "runtime-global",
--   default_value = 0,
--   -- minimum_value = 0,
--   -- maximum_value = 5000,
--   hidden = true,
--   order = "p7"
-- }}
