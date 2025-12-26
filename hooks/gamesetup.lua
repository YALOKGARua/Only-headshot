dofile(ModPath .. "only_headshots.lua")

local M = _G.OnlyHeadshots
if not M or M._gamesetup_hooked then
	return
end
M._gamesetup_hooked = true

if not GameSetup or type(GameSetup.update) ~= "function" then
	return
end

local original = GameSetup.update
GameSetup.update = function(self, t, dt, ...)
	local r = original(self, t, dt, ...)
	if M and M.Update then
		M:Update(t, dt)
	end
	return r
end