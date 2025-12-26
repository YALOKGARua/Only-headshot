dofile(ModPath .. "only_headshots.lua")

local M = _G.OnlyHeadshots
if not M then
	return
end

M:InstallBulletFilter()


