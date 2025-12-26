dofile(ModPath .. "only_headshots.lua")

local M = _G.OnlyHeadshots
if not M or M._menu_ready then
	return
end
M._menu_ready = true

local function values()
	return setmetatable({}, {
		__index = function(_, key)
			local s = M.settings or {}
			if key == "enabled" then
				return s.enabled
			end
			if key == "exclude_civilians" then
				return s.exclude_civilians
			end
			if key == "apply_to" then
				return s.apply_to
			end
			if key == "strict_no_body" then
				return s.strict_no_body
			end
			if key == "allow_helmet" then
				return s.allow_helmet
			end
			if key == "allow_priority_head" then
				return s.allow_priority_head
			end
			if key == "ai_cover_head" then
				return s.ai_cover_head
			end
			if key == "ai_cover_strength" then
				return s.ai_cover_strength
			end
			if key == "ai_cover_panic_mode" then
				return s.ai_cover_panic_mode
			end
			if key == "show_head_sphere" then
				return s.show_head_sphere
			end
			if key == "head_sphere_scale" then
				return s.head_sphere_scale
			end
			if key == "head_sphere_mode" then
				return s.head_sphere_mode
			end
			if key == "head_sphere_max_distance" then
				return s.head_sphere_max_distance
			end
			if key == "head_sphere_max_units" then
				return s.head_sphere_max_units
			end
			if key == "head_sphere_refresh" then
				return s.head_sphere_refresh
			end
			if key == "head_sphere_include_civilians" then
				return s.head_sphere_include_civilians
			end
			local e = s.enforce or {}
			if key == "enforce_bullet" then
				return e.bullet
			end
			if key == "enforce_melee" then
				return e.melee
			end
			if key == "enforce_fire" then
				return e.fire
			end
			if key == "enforce_explosion" then
				return e.explosion
			end
			if key == "enforce_dot" then
				return e.dot
			end
			if key == "enforce_simple" then
				return e.simple
			end
			return nil
		end
	})
end

if not Hooks then
	return
end

Hooks:Add("MenuManagerInitialize", "OnlyHeadshots_MenuInit", function()
	M:EnsureLocalization()
	if MenuHelper and not M._menu_loaded then
		M._menu_loaded = true
		MenuHelper:LoadFromJsonFile(M._mod_path .. "menu/options.json", M, values())
	end

	MenuCallbackHandler.OnlyHeadshots_ToggleEnabled = function(_, item)
		M.settings.enabled = item:value() == "on"
		M:Save()
	end
	MenuCallbackHandler.OnlyHeadshots_ToggleExcludeCivilians = function(_, item)
		M.settings.exclude_civilians = item:value() == "on"
		M:Save()
	end
	MenuCallbackHandler.OnlyHeadshots_SetApplyTo = function(_, item)
		M.settings.apply_to = item:value()
		M:Save()
	end
	MenuCallbackHandler.OnlyHeadshots_ToggleStrictNoBody = function(_, item)
		M.settings.strict_no_body = item:value() == "on"
		M:Save()
	end
	MenuCallbackHandler.OnlyHeadshots_ToggleAllowHelmet = function(_, item)
		M.settings.allow_helmet = item:value() == "on"
		M:Save()
	end
	MenuCallbackHandler.OnlyHeadshots_ToggleAllowPriorityHead = function(_, item)
		M.settings.allow_priority_head = item:value() == "on"
		M:Save()
	end
	MenuCallbackHandler.OnlyHeadshots_ToggleAICoverHead = function(_, item)
		M.settings.ai_cover_head = item:value() == "on"
		M:Save()
	end
	MenuCallbackHandler.OnlyHeadshots_SetAICoverStrength = function(_, item)
		M.settings.ai_cover_strength = tonumber(item:value()) or 80
		M:Save()
	end
	MenuCallbackHandler.OnlyHeadshots_SetAICoverPanicMode = function(_, item)
		M.settings.ai_cover_panic_mode = item:value()
		M:Save()
	end
	MenuCallbackHandler.OnlyHeadshots_ToggleShowHeadSphere = function(_, item)
		M.settings.show_head_sphere = item:value() == "on"
		M:Save()
	end
	MenuCallbackHandler.OnlyHeadshots_SetHeadSphereMode = function(_, item)
		M.settings.head_sphere_mode = item:value()
		M:Save()
	end
	MenuCallbackHandler.OnlyHeadshots_SetHeadSphereScale = function(_, item)
		M.settings.head_sphere_scale = tonumber(item:value()) or 1
		M:Save()
	end
	MenuCallbackHandler.OnlyHeadshots_SetHeadSphereMaxDistance = function(_, item)
		M.settings.head_sphere_max_distance = tonumber(item:value()) or 2500
		M:Save()
	end
	MenuCallbackHandler.OnlyHeadshots_SetHeadSphereMaxUnits = function(_, item)
		M.settings.head_sphere_max_units = tonumber(item:value()) or 6
		M:Save()
	end
	MenuCallbackHandler.OnlyHeadshots_SetHeadSphereRefresh = function(_, item)
		M.settings.head_sphere_refresh = tonumber(item:value()) or 0.25
		M:Save()
	end
	MenuCallbackHandler.OnlyHeadshots_ToggleHeadSphereIncludeCivilians = function(_, item)
		M.settings.head_sphere_include_civilians = item:value() == "on"
		M:Save()
	end
	MenuCallbackHandler.OnlyHeadshots_ToggleBullet = function(_, item)
		M.settings.enforce.bullet = item:value() == "on"
		M:Save()
	end
	MenuCallbackHandler.OnlyHeadshots_ToggleMelee = function(_, item)
		M.settings.enforce.melee = item:value() == "on"
		M:Save()
	end
	MenuCallbackHandler.OnlyHeadshots_ToggleFire = function(_, item)
		M.settings.enforce.fire = item:value() == "on"
		M:Save()
	end
	MenuCallbackHandler.OnlyHeadshots_ToggleExplosion = function(_, item)
		M.settings.enforce.explosion = item:value() == "on"
		M:Save()
	end
	MenuCallbackHandler.OnlyHeadshots_ToggleDot = function(_, item)
		M.settings.enforce.dot = item:value() == "on"
		M:Save()
	end
	MenuCallbackHandler.OnlyHeadshots_ToggleSimple = function(_, item)
		M.settings.enforce.simple = item:value() == "on"
		M:Save()
	end
end)