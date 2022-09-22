---@meta
---@diagnostic disable

--$Factorio 1.1.69
--$Overlay 5
--$Section LuaGroup
-- This file is automatically generated. Edits will be overwritten.

---Item group or subgroup.
---
---[View documentation](https://lua-api.factorio.com/latest/LuaGroup.html)
---@class LuaGroup:LuaObject
---[R]  
---The parent group, if any.
---
---[View documentation](https://lua-api.factorio.com/latest/LuaGroup.html#LuaGroup.group)
---@field group? LuaGroup 
---[R]  
---Localised name of the group.
---
---[View documentation](https://lua-api.factorio.com/latest/LuaGroup.html#LuaGroup.localised_name)
---@field localised_name? LocalisedString 
---[R]
---
---[View documentation](https://lua-api.factorio.com/latest/LuaGroup.html#LuaGroup.name)
---@field name? string 
---[R]  
---The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.
---
---[View documentation](https://lua-api.factorio.com/latest/LuaGroup.html#LuaGroup.object_name)
---@field object_name string 
---[R]  
---The string used to alphabetically sort these prototypes. It is a simple string that has no additional semantic meaning.
---
---[View documentation](https://lua-api.factorio.com/latest/LuaGroup.html#LuaGroup.order)
---@field order string 
---[R]  
---The additional order value used in recipe ordering.
---
---**Note:** Can only be used on groups, not on subgroups.
---
---[View documentation](https://lua-api.factorio.com/latest/LuaGroup.html#LuaGroup.order_in_recipe)
---@field order_in_recipe string 
---[R]  
---Subgroups of this group.
---
---**Note:** Can only be used on groups, not on subgroups.
---
---[View documentation](https://lua-api.factorio.com/latest/LuaGroup.html#LuaGroup.subgroups)
---@field subgroups LuaGroup[] 
---[R]
---
---[View documentation](https://lua-api.factorio.com/latest/LuaGroup.html#LuaGroup.type)
---@field type? string 
---[R]  
---Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.
---
---[View documentation](https://lua-api.factorio.com/latest/LuaGroup.html#LuaGroup.valid)
---@field valid boolean 
local LuaGroup={
---All methods and properties that this object supports.
---
---[View documentation](https://lua-api.factorio.com/latest/LuaGroup.html#LuaGroup.help)
---@return string
help=function()end,
}


