---@meta
---@diagnostic disable

--$Factorio 1.1.69
--$Overlay 5
--$Section LuaConstantCombinatorControlBehavior
-- This file is automatically generated. Edits will be overwritten.

---Control behavior for constant combinators.
---
---[View documentation](https://lua-api.factorio.com/latest/LuaConstantCombinatorControlBehavior.html)
---@class LuaConstantCombinatorControlBehavior:LuaControlBehavior
---[RW]  
---Turns this constant combinator on and off.
---
---[View documentation](https://lua-api.factorio.com/latest/LuaConstantCombinatorControlBehavior.html#LuaConstantCombinatorControlBehavior.enabled)
---@field enabled boolean 
---[R]  
---The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.
---
---[View documentation](https://lua-api.factorio.com/latest/LuaConstantCombinatorControlBehavior.html#LuaConstantCombinatorControlBehavior.object_name)
---@field object_name string 
---[RW]  
---This constant combinator's parameters. `nil` if the [item_slot_count](https://lua-api.factorio.com/latest/LuaEntityPrototype.html#LuaEntityPrototype.item_slot_count) of the combinator's prototype is `0`.
---
---Writing `nil` clears the combinator's parameters.
---
---[View documentation](https://lua-api.factorio.com/latest/LuaConstantCombinatorControlBehavior.html#LuaConstantCombinatorControlBehavior.parameters)
---@field parameters? ConstantCombinatorParameters[] 
---[R]  
---The number of signals this constant combinator supports
---
---[View documentation](https://lua-api.factorio.com/latest/LuaConstantCombinatorControlBehavior.html#LuaConstantCombinatorControlBehavior.signals_count)
---@field signals_count uint 
---[R]  
---Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.
---
---[View documentation](https://lua-api.factorio.com/latest/LuaConstantCombinatorControlBehavior.html#LuaConstantCombinatorControlBehavior.valid)
---@field valid boolean 
local LuaConstantCombinatorControlBehavior={
---Gets the signal at the given index. Returned [Signal](https://lua-api.factorio.com/latest/Concepts.html#Signal) will not contain signal if none is set for the index.
---
---[View documentation](https://lua-api.factorio.com/latest/LuaConstantCombinatorControlBehavior.html#LuaConstantCombinatorControlBehavior.get_signal)
---@param index uint
---@return Signal
get_signal=function(index)end,
---All methods and properties that this object supports.
---
---[View documentation](https://lua-api.factorio.com/latest/LuaConstantCombinatorControlBehavior.html#LuaConstantCombinatorControlBehavior.help)
---@return string
help=function()end,
---Sets the signal at the given index
---
---[View documentation](https://lua-api.factorio.com/latest/LuaConstantCombinatorControlBehavior.html#LuaConstantCombinatorControlBehavior.set_signal)
---@param index uint
---@param signal Signal
set_signal=function(index,signal)end,
}


