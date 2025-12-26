_G.OnlyHeadshots = _G.OnlyHeadshots or {}
local M = _G.OnlyHeadshots

if M._core_ready then
	return
end

M._core_ready = true
M._mod_path = ModPath
M._save_path = SavePath .. "only_headshots.json"

M._defaults = {
	enabled = true,
	exclude_civilians = false,
	apply_to = "everyone",
	strict_no_body = false,
	allow_priority_head = true,
	allow_helmet = true,
	ai_cover_head = false,
	ai_cover_strength = 80,
	ai_cover_panic_mode = "run_only",
	show_head_sphere = false,
	head_sphere_scale = 1,
	head_sphere_mode = "crosshair",
	head_sphere_max_distance = 2500,
	head_sphere_max_units = 6,
	head_sphere_refresh = 0.25,
	head_sphere_include_civilians = false,
	enforce = {
		bullet = true,
		melee = true,
		fire = false,
		explosion = false,
		dot = false,
		simple = false
	}
}

function M:_clone(value, seen)
	if type(value) ~= "table" then
		return value
	end
	seen = seen or {}
	if seen[value] then
		return seen[value]
	end
	local out = {}
	seen[value] = out
	for k, v in pairs(value) do
		out[self:_clone(k, seen)] = self:_clone(v, seen)
	end
	return out
end

function M:_merge(dst, src)
	if type(dst) ~= "table" then
		dst = {}
	end
	if type(src) ~= "table" then
		return dst
	end
	for k, v in pairs(src) do
		if type(v) == "table" and type(dst[k]) == "table" then
			dst[k] = self:_merge(dst[k], v)
		else
			dst[k] = v
		end
	end
	return dst
end

function M:_sanitize()
	local s = self.settings
	if type(s) ~= "table" then
		s = {}
		self.settings = s
	end

	if type(s.enabled) ~= "boolean" then
		s.enabled = self._defaults.enabled
	end
	if type(s.exclude_civilians) ~= "boolean" then
		s.exclude_civilians = self._defaults.exclude_civilians
	end
	if s.apply_to ~= "human_players" and s.apply_to ~= "human_and_ai" and s.apply_to ~= "everyone" then
		s.apply_to = self._defaults.apply_to
	end
	if type(s.strict_no_body) ~= "boolean" then
		s.strict_no_body = self._defaults.strict_no_body
	end
	if type(s.allow_priority_head) ~= "boolean" then
		s.allow_priority_head = self._defaults.allow_priority_head
	end
	if type(s.allow_helmet) ~= "boolean" then
		s.allow_helmet = self._defaults.allow_helmet
	end
	if type(s.ai_cover_head) ~= "boolean" then
		s.ai_cover_head = self._defaults.ai_cover_head
	end
	if type(s.ai_cover_strength) ~= "number" then
		s.ai_cover_strength = self._defaults.ai_cover_strength
	end
	s.ai_cover_strength = math.floor(math.clamp(s.ai_cover_strength, 0, 100))
	if s.ai_cover_panic_mode ~= "run_only" and s.ai_cover_panic_mode ~= "always" and s.ai_cover_panic_mode ~= "never" then
		s.ai_cover_panic_mode = self._defaults.ai_cover_panic_mode
	end
	if type(s.show_head_sphere) ~= "boolean" then
		s.show_head_sphere = self._defaults.show_head_sphere
	end
	if type(s.head_sphere_scale) ~= "number" then
		s.head_sphere_scale = self._defaults.head_sphere_scale
	end
	s.head_sphere_scale = math.clamp(s.head_sphere_scale, 0.25, 4)
	if s.head_sphere_mode ~= "crosshair" and s.head_sphere_mode ~= "near" and s.head_sphere_mode ~= "all" then
		s.head_sphere_mode = self._defaults.head_sphere_mode
	end
	if type(s.head_sphere_max_distance) ~= "number" then
		s.head_sphere_max_distance = self._defaults.head_sphere_max_distance
	end
	s.head_sphere_max_distance = math.clamp(s.head_sphere_max_distance, 500, 20000)
	if type(s.head_sphere_max_units) ~= "number" then
		s.head_sphere_max_units = self._defaults.head_sphere_max_units
	end
	s.head_sphere_max_units = math.floor(math.clamp(s.head_sphere_max_units, 1, 40))
	if type(s.head_sphere_refresh) ~= "number" then
		s.head_sphere_refresh = self._defaults.head_sphere_refresh
	end
	s.head_sphere_refresh = math.clamp(s.head_sphere_refresh, 0.05, 1)
	if type(s.head_sphere_include_civilians) ~= "boolean" then
		s.head_sphere_include_civilians = self._defaults.head_sphere_include_civilians
	end

	local enforce = type(s.enforce) == "table" and s.enforce or {}
	s.enforce = {
		bullet = enforce.bullet ~= false,
		melee = enforce.melee ~= false,
		fire = enforce.fire == true,
		explosion = enforce.explosion == true,
		dot = enforce.dot == true,
		simple = enforce.simple == true
	}
end

function M:Reset()
	self.settings = self:_clone(self._defaults)
	self:_sanitize()
end

function M:Load()
	self:Reset()
	local f = io.open(self._save_path, "r")
	if f then
		local raw = f:read("*all")
		f:close()
		if type(raw) == "string" and raw ~= "" then
			local ok, decoded = pcall(json.decode, raw)
			if ok and type(decoded) == "table" then
				self.settings = self:_merge(self.settings, decoded)
			end
		end
	end
	self:_sanitize()
end

function M:Save()
	if not self.settings then
		self:Reset()
	end
	self:_sanitize()
	local ok, encoded = pcall(json.encode, self.settings)
	if not ok then
		return false
	end
	local f = io.open(self._save_path, "w+")
	if not f then
		return false
	end
	f:write(encoded)
	f:close()
	return true
end

function M:EnsureLocalization()
	if self._loc_loaded then
		return true
	end
	if not managers or not managers.localization or not managers.localization.add_localized_strings then
		return false
	end

	local lang_key = SystemInfo and SystemInfo:language() and SystemInfo:language():key()
	local is_ru = lang_key == Idstring("russian"):key()

	local strings = {
		only_headshots_menu_title = "Only Headshots",
		only_headshots_menu_desc = "Headshot-only damage filter (host-side).",
		only_headshots_opt_enabled_title = "Enabled",
		only_headshots_opt_enabled_desc = "Enable headshot-only damage filtering.",
		only_headshots_opt_apply_to_title = "Apply to",
		only_headshots_opt_apply_to_desc = "Whose attacks are filtered.",
		only_headshots_opt_apply_to_human = "Human players",
		only_headshots_opt_apply_to_human_ai = "Human + AI",
		only_headshots_opt_apply_to_everyone = "Everyone",
		only_headshots_opt_exclude_civilians_title = "Exclude civilians",
		only_headshots_opt_exclude_civilians_desc = "Do not apply the filter to civilians.",
		only_headshots_opt_strict_no_body_title = "Strict (no hit body)",
		only_headshots_opt_strict_no_body_desc = "If there is no hit body data, block the damage anyway.",
		only_headshots_opt_allow_helmet_title = "Allow helmet/visor hits",
		only_headshots_opt_allow_helmet_desc = "Treat visor/helmet bodies as head hits for some enemies.",
		only_headshots_opt_allow_priority_head_title = "Allow priority weakspots",
		only_headshots_opt_allow_priority_head_desc = "Treat priority bodies as head hits (used by heavy units).",
		only_headshots_opt_ai_cover_head_title = "AI cover head (host only)",
		only_headshots_opt_ai_cover_head_desc = "When you miss the head, enemies react by ducking/covering their head.",
		only_headshots_opt_ai_cover_strength_title = "AI cover strength",
		only_headshots_opt_ai_cover_strength_desc = "How aggressively enemies react to body hits while headshots-only is enabled.",
		only_headshots_opt_ai_cover_panic_mode_title = "AI cover panic mode",
		only_headshots_opt_ai_cover_panic_mode_desc = "Controls when panic-level reactions can happen.",
		only_headshots_opt_ai_cover_panic_mode_run_only = "Panic when running",
		only_headshots_opt_ai_cover_panic_mode_always = "Always panic",
		only_headshots_opt_ai_cover_panic_mode_never = "Never panic",
		only_headshots_opt_show_head_sphere_title = "Show head sphere (host only)",
		only_headshots_opt_show_head_sphere_desc = "Draw a sphere around the head hitbox.",
		only_headshots_opt_head_sphere_scale_title = "Head sphere scale",
		only_headshots_opt_head_sphere_scale_desc = "Scale factor for the head sphere size.",
		only_headshots_opt_head_sphere_mode_title = "Head sphere mode (host only)",
		only_headshots_opt_head_sphere_mode_desc = "Controls how many spheres are drawn.",
		only_headshots_opt_head_sphere_mode_crosshair = "Crosshair target",
		only_headshots_opt_head_sphere_mode_near = "Nearest units",
		only_headshots_opt_head_sphere_mode_all = "All (limited)",
		only_headshots_opt_head_sphere_max_distance_title = "Head sphere max distance",
		only_headshots_opt_head_sphere_max_distance_desc = "Maximum distance for drawing spheres.",
		only_headshots_opt_head_sphere_max_units_title = "Head sphere max units",
		only_headshots_opt_head_sphere_max_units_desc = "Maximum number of spheres to draw.",
		only_headshots_opt_head_sphere_refresh_title = "Head sphere refresh",
		only_headshots_opt_head_sphere_refresh_desc = "How often spheres are redrawn.",
		only_headshots_opt_head_sphere_include_civilians_title = "Include civilians",
		only_headshots_opt_head_sphere_include_civilians_desc = "Draw spheres for civilians too.",
		only_headshots_opt_enforce_bullet_title = "Bullet damage",
		only_headshots_opt_enforce_bullet_desc = "Require head hits for bullet damage.",
		only_headshots_opt_enforce_melee_title = "Melee damage",
		only_headshots_opt_enforce_melee_desc = "Require head hits for melee damage.",
		only_headshots_opt_enforce_fire_title = "Fire damage",
		only_headshots_opt_enforce_fire_desc = "Require head hits for fire damage.",
		only_headshots_opt_enforce_explosion_title = "Explosion damage",
		only_headshots_opt_enforce_explosion_desc = "Require head hits for explosion damage.",
		only_headshots_opt_enforce_dot_title = "DoT damage",
		only_headshots_opt_enforce_dot_desc = "Require head hits for damage-over-time effects.",
		only_headshots_opt_enforce_simple_title = "Simple damage",
		only_headshots_opt_enforce_simple_desc = "Require head hits for simple damage types."
	}

	if is_ru then
		strings = {
			only_headshots_menu_title = "Только хедшоты",
			only_headshots_menu_desc = "Урон засчитывается только при попадании в голову (на стороне хоста).",
			only_headshots_opt_enabled_title = "Включено",
			only_headshots_opt_enabled_desc = "Включить режим «только попадания в голову».",
			only_headshots_opt_apply_to_title = "Применять к",
			only_headshots_opt_apply_to_desc = "Чьи атаки фильтруются.",
			only_headshots_opt_apply_to_human = "Игроки",
			only_headshots_opt_apply_to_human_ai = "Игроки + боты",
			only_headshots_opt_apply_to_everyone = "Все",
			only_headshots_opt_exclude_civilians_title = "Исключить гражданских",
			only_headshots_opt_exclude_civilians_desc = "Не применять фильтр к гражданским.",
			only_headshots_opt_strict_no_body_title = "Строго (нет тела попадания)",
			only_headshots_opt_strict_no_body_desc = "Если у атаки нет данных о теле попадания, урон всё равно блокируется.",
			only_headshots_opt_allow_helmet_title = "Считать шлем/визор головой",
			only_headshots_opt_allow_helmet_desc = "Считать попадания по визору/шлему как попадания в голову для некоторых врагов.",
			only_headshots_opt_allow_priority_head_title = "Учитывать приоритетные слабые места",
			only_headshots_opt_allow_priority_head_desc = "Считать приоритетные хитбоксы попаданием в голову (актуально для тяжёлых юнитов).",
			only_headshots_opt_ai_cover_head_title = "ИИ прикрывает голову (только хост)",
			only_headshots_opt_ai_cover_head_desc = "Если промазал по голове, враги чаще приседают/реагируют, прикрывая голову.",
			only_headshots_opt_ai_cover_strength_title = "Сила реакции ИИ",
			only_headshots_opt_ai_cover_strength_desc = "Насколько агрессивно враги реагируют на попадания в тело в режиме only headshot.",
			only_headshots_opt_ai_cover_panic_mode_title = "Panic-режим реакции",
			only_headshots_opt_ai_cover_panic_mode_desc = "Когда разрешены panic-реакции (самые сильные).",
			only_headshots_opt_ai_cover_panic_mode_run_only = "Panic только на беге",
			only_headshots_opt_ai_cover_panic_mode_always = "Panic всегда",
			only_headshots_opt_ai_cover_panic_mode_never = "Без panic",
			only_headshots_opt_show_head_sphere_title = "Показывать сферу головы (только хост)",
			only_headshots_opt_show_head_sphere_desc = "Рисовать сферу вокруг хитбокса головы.",
			only_headshots_opt_head_sphere_scale_title = "Масштаб сферы головы",
			only_headshots_opt_head_sphere_scale_desc = "Множитель размера сферы головы.",
			only_headshots_opt_head_sphere_mode_title = "Режим сферы головы (только хост)",
			only_headshots_opt_head_sphere_mode_desc = "Сколько сфер рисовать и как выбирать цели.",
			only_headshots_opt_head_sphere_mode_crosshair = "Цель под прицелом",
			only_headshots_opt_head_sphere_mode_near = "Ближайшие",
			only_headshots_opt_head_sphere_mode_all = "Все (с лимитом)",
			only_headshots_opt_head_sphere_max_distance_title = "Дистанция сферы головы",
			only_headshots_opt_head_sphere_max_distance_desc = "Максимальная дистанция отрисовки.",
			only_headshots_opt_head_sphere_max_units_title = "Лимит сфер",
			only_headshots_opt_head_sphere_max_units_desc = "Максимум сфер одновременно.",
			only_headshots_opt_head_sphere_refresh_title = "Частота обновления",
			only_headshots_opt_head_sphere_refresh_desc = "Как часто перерисовывать сферу.",
			only_headshots_opt_head_sphere_include_civilians_title = "Включать гражданских",
			only_headshots_opt_head_sphere_include_civilians_desc = "Рисовать сферы и для гражданских.",
			only_headshots_opt_enforce_bullet_title = "Пули",
			only_headshots_opt_enforce_bullet_desc = "Требовать попадание в голову для урона от пуль.",
			only_headshots_opt_enforce_melee_title = "Ближний бой",
			only_headshots_opt_enforce_melee_desc = "Требовать попадание в голову для урона ближнего боя.",
			only_headshots_opt_enforce_fire_title = "Огонь",
			only_headshots_opt_enforce_fire_desc = "Требовать попадание в голову для урона огнём.",
			only_headshots_opt_enforce_explosion_title = "Взрывы",
			only_headshots_opt_enforce_explosion_desc = "Требовать попадание в голову для урона от взрывов.",
			only_headshots_opt_enforce_dot_title = "Периодический урон",
			only_headshots_opt_enforce_dot_desc = "Требовать попадание в голову для периодического урона (DoT).",
			only_headshots_opt_enforce_simple_title = "Простой урон",
			only_headshots_opt_enforce_simple_desc = "Требовать попадание в голову для простых типов урона."
		}
	end

	managers.localization:add_localized_strings(strings)
	self._loc_loaded = true
	return true
end

function M:_head_like_body_keys()
	if self._head_like_body_keys_cache then
		return self._head_like_body_keys_cache
	end
	local out = {}
	for _, n in ipairs({ "body_helmet", "body_helmet_plate", "body_helmet_glass" }) do
		out[Idstring(n):key()] = true
	end
	self._head_like_body_keys_cache = out
	return out
end

function M:_head_body_keys()
	if self._head_body_keys_cache then
		return self._head_body_keys_cache
	end
	local out = {}
	for _, n in ipairs({ "Head", "head", "c_sphere_head" }) do
		out[Idstring(n):key()] = true
	end
	self._head_body_keys_cache = out
	return out
end

function M:_resolve_attacker(unit)
	if alive(unit) and unit:base() then
		local base = unit:base()
		if base.thrower_unit then
			local t = base:thrower_unit()
			if alive(t) then
				unit = t
			end
		elseif base.sentry_gun then
			local owner = base:get_owner()
			if alive(owner) then
				unit = owner
			end
		end
	end
	return unit
end

function M:_is_human_player(unit)
	if not alive(unit) then
		return false
	end
	local base = unit:base()
	if not base then
		return false
	end
	return base.is_local_player or base.is_husk_player or false
end

function M:_is_ai_criminal(unit)
	if not alive(unit) then
		return false
	end
	local state = managers.groupai and managers.groupai:state()
	if not state or not state.is_unit_team_AI then
		return false
	end
	return state:is_unit_team_AI(unit)
end

function M:_should_filter_attacker(unit)
	local mode = self.settings and self.settings.apply_to or "human_players"
	if mode == "everyone" then
		return alive(unit)
	end
	if mode == "human_and_ai" then
		return self:_is_human_player(unit) or self:_is_ai_criminal(unit)
	end
	return self:_is_human_player(unit)
end

function M:_is_allowed_hit(damage_ext, attack_data)
	local strict = self.settings and self.settings.strict_no_body
	if type(attack_data) ~= "table" then
		return not strict
	end
	local col_ray = attack_data.col_ray
	local body = col_ray and col_ray.body
	if not body then
		return not strict
	end

	local name = body:name()
	local name_key = name and name:key() or nil

	if name_key and self:_head_body_keys()[name_key] then
		return true
	end

	if damage_ext and damage_ext.is_head and damage_ext:is_head(body) then
		return true
	end

	if damage_ext and damage_ext._head_body_key and body:key() == damage_ext._head_body_key then
		return true
	end

	local unit = damage_ext and damage_ext._unit
	if alive(unit) then
		local hb = unit:body("Head") or unit:body("c_sphere_head") or unit:body("head")
		if hb and hb:key() == body:key() then
			return true
		end
	end

	if self.settings.allow_helmet and name_key and self:_head_like_body_keys()[name_key] then
		return true
	end

	if self.settings.allow_priority_head and damage_ext and damage_ext._priority_bodies_ids and name_key and damage_ext._priority_bodies_ids[name_key] == 1 then
		return true
	end

	return false
end

function M:ShouldBlock(damage_ext, attack_data, category)
	local s = self.settings
	if not s or not s.enabled then
		return false
	end
	local enforce = s.enforce
	if category and (not enforce or enforce[category] ~= true) then
		return false
	end

	if damage_ext and s.exclude_civilians and CopDamage and CopDamage.is_civilian then
		local unit = damage_ext._unit
		local base = unit and unit:base()
		local tweak = base and base._tweak_table
		if tweak and CopDamage.is_civilian(tweak) then
			return false
		end
	end

	local attacker = self:_resolve_attacker(attack_data and attack_data.attacker_unit)
	if not self:_should_filter_attacker(attacker) then
		return false
	end

	return not self:_is_allowed_hit(damage_ext, attack_data)
end

function M:_is_host()
	return Network and Network:is_server() or false
end

function M:OnBlockedHit(damage_ext, attack_data, category)
	local s = self.settings
	if not s or not s.ai_cover_head then
		return
	end
	if not self:_is_host() then
		return
	end
	if category ~= "bullet" and category ~= "melee" then
		return
	end
	local unit = damage_ext and damage_ext._unit
	if not alive(unit) then
		return
	end
	if managers and managers.enemy and managers.enemy.is_enemy and not managers.enemy:is_enemy(unit) then
		return
	end

	local timer = TimerManager and TimerManager:game()
	local t = timer and timer:time() or 0

	self._ai_cover_cd = self._ai_cover_cd or setmetatable({}, { __mode = "k" })
	local next_t = self._ai_cover_cd[unit] or 0
	if t < next_t then
		return
	end
	local strength = (s.ai_cover_strength or 80) * 0.01
	if strength <= 0 then
		return
	end

	if strength < 1 and math.random() > strength then
		return
	end

	local cooldown = math.lerp(0.9, 0.25, strength)
	self._ai_cover_cd[unit] = t + cooldown

	local movement = unit.movement and unit:movement()
	local ext_anim = movement and movement._ext_anim
	local moving = ext_anim and (ext_anim.run or ext_anim.sprint or ext_anim.move) or false
	local panic_mode = s.ai_cover_panic_mode or "run_only"
	local want_panic = panic_mode == "always" or panic_mode == "run_only" and moving
	local state = want_panic and "panic" or true

	if damage_ext.build_suppression then
		pcall(damage_ext.build_suppression, damage_ext, want_panic and "panic" or "max")
	end

	if movement and movement.on_suppressed then
		pcall(movement.on_suppressed, movement, state)

		local force_reaction = strength >= 0.35
		if force_reaction and movement.action_request then
			if movement.chk_action_forbidden and not movement:chk_action_forbidden("act") then
				pcall(movement.action_request, movement, {
					body_part = 2,
					type = "act",
					variant = "suppressed_reaction",
					blocks = {
						walk = -1
					}
				})
			end
			if strength >= 0.65 and movement.chk_action_forbidden and not movement:chk_action_forbidden("crouch") then
				pcall(movement.action_request, movement, {
					body_part = 4,
					type = "crouch"
				})
			end
		end

		local enemy = managers.enemy
		if enemy and enemy.add_delayed_clbk and enemy.is_clbk_registered and enemy.reschedule_delayed_clbk then
			local id = "OnlyHeadshots_unsup_" .. tostring(unit:key())
			local hold = math.lerp(0.25, 1.25, strength) * (want_panic and 1.15 or 1)
			local exec_t = t + hold
			if enemy:is_clbk_registered(id) then
				enemy:reschedule_delayed_clbk(id, exec_t)
			else
				enemy:add_delayed_clbk(id, function()
					if alive(unit) then
						local m = unit:movement()
						if m and m.on_suppressed then
							pcall(m.on_suppressed, m, false)
						end
					end
				end, exec_t)
			end
		end
	end
end

function M:_draw_head_spheres(t, dt)
	local s = self.settings
	if not s or not s.show_head_sphere then
		return
	end
	if not self:_is_host() then
		return
	end
	if not Draw or not Draw.brush then
		return
	end
	if not managers or not managers.enemy or not managers.enemy.all_enemies then
		return
	end

	local player = managers.player and managers.player:player_unit()
	if not alive(player) then
		return
	end
	local movement = player:movement()
	local origin = movement and movement:m_head_pos()
	local fwd = movement and movement:m_head_fwd()
	if not origin or not fwd then
		return
	end

	local max_dist = s.head_sphere_max_distance or 2500
	local max_dist_sq = max_dist * max_dist
	local max_units = s.head_sphere_max_units or 6
	local mode = s.head_sphere_mode or "crosshair"
	local include_civs = s.head_sphere_include_civilians and true or false

	local scale = s.head_sphere_scale or 1
	if mode == "crosshair" then
		local duration = math.clamp(tonumber(dt) or 0.016, 0.01, 0.05)
		local brush = Draw:brush(Color(0.2, 0.1, 0.9, 1), nil, duration)
		local slot = managers and managers.slot
		local mask = slot and (include_civs and slot:get_mask("enemies", "civilians") or slot:get_mask("enemies")) or nil
		if not mask then
			return
		end

		self._sphere_to_pos = self._sphere_to_pos or Vector3()
		local to_pos = self._sphere_to_pos
		mvector3.set(to_pos, fwd)
		mvector3.multiply(to_pos, max_dist)
		mvector3.add(to_pos, origin)

		local ray = World and World.raycast and World:raycast("ray", origin, to_pos, "slot_mask", mask) or nil
		if not ray or not alive(ray.unit) then
			return
		end

		local unit = ray.unit
		if unit:in_slot(8) and alive(unit:parent()) then
			unit = unit:parent() or unit
		end

		if not include_civs and managers.enemy and managers.enemy.is_enemy and not managers.enemy:is_enemy(unit) then
			return
		end

		local body = unit:body("Head") or unit:body("c_sphere_head") or unit:body("head")
		if not body then
			return
		end
		local pos = body:position()
		local name = body:name()
		local radius = 15
		if CopDamage and CopDamage.impact_body_distance and name then
			radius = CopDamage.impact_body_distance[name:key()] or radius
		end
		brush:sphere(pos, radius * scale, 1)

		return
	end

	local interval = s.head_sphere_refresh or 0.25
	self._sphere_next_t = self._sphere_next_t or 0
	if t < self._sphere_next_t then
		return
	end
	self._sphere_next_t = t + interval

	local brush = Draw:brush(Color(0.2, 0.1, 0.9, 1), nil, interval * 1.25)

	local function draw_unit(unit)
		if not alive(unit) then
			return
		end
		local body = unit:body("Head") or unit:body("c_sphere_head") or unit:body("head")
		if not body then
			return
		end
		local pos = body:position()
		local name = body:name()
		local radius = 15
		if CopDamage and CopDamage.impact_body_distance and name then
			radius = CopDamage.impact_body_distance[name:key()] or radius
		end
		brush:sphere(pos, radius * scale, 1)
	end

	local tmp_vec = Vector3()
	local consider = nil
	local chosen = {}
	local worst_i = 0
	local worst_score = -1

	consider = function(unit, score)
		if #chosen < max_units then
			chosen[#chosen + 1] = { unit = unit, score = score }
			if score > worst_score then
				worst_score = score
				worst_i = #chosen
			end
			return
		end
		if score >= worst_score then
			return
		end
		chosen[worst_i] = { unit = unit, score = score }
		worst_i = 1
		worst_score = chosen[1].score
		for i = 2, #chosen do
			if chosen[i].score > worst_score then
				worst_score = chosen[i].score
				worst_i = i
			end
		end
	end

	local function pick_from(t)
		for _, data in pairs(t or {}) do
			local unit = data.unit or data
			if alive(unit) then
				local body = unit:body("Head") or unit:body("c_sphere_head") or unit:body("head")
				if body then
					local pos = body:position()
					local dist_sq = mvector3.distance_sq(origin, pos)
					if dist_sq <= max_dist_sq then
						if mode == "crosshair" then
							mvector3.set(tmp_vec, pos)
							mvector3.subtract(tmp_vec, origin)
							mvector3.normalize(tmp_vec)
							local dot = mvector3.dot(tmp_vec, fwd)
							if dot >= 0.975 then
								consider(unit, (1 - dot) * 100 + dist_sq * 1e-6)
							end
						else
							consider(unit, dist_sq)
						end
					end
				end
			end
		end
	end

	pick_from(managers.enemy:all_enemies())
	if include_civs then
		pick_from(managers.enemy:all_civilians())
	end

	if mode == "all" then
		max_units = max_units
	elseif mode == "near" then
		max_units = max_units
	else
		if #chosen > 1 then
			table.sort(chosen, function(a, b)
				return a.score < b.score
			end)
			for i = #chosen, 2, -1 do
				chosen[i] = nil
			end
		end
	end

	for i = 1, #chosen do
		local entry = chosen[i]
		if entry and entry.unit then
			draw_unit(entry.unit)
		end
	end
end

function M:Update(t, dt)
	pcall(self._draw_head_spheres, self, t, dt)
end

function M:_override_once(cls, method, wrapper_factory)
	if type(cls) ~= "table" or type(method) ~= "string" or type(wrapper_factory) ~= "function" then
		return
	end
	local original = cls[method]
	if type(original) ~= "function" then
		return
	end
	self._overrides = self._overrides or setmetatable({}, { __mode = "k" })
	local bucket = self._overrides[cls]
	if not bucket then
		bucket = {}
		self._overrides[cls] = bucket
	end
	if bucket[method] then
		return
	end
	bucket[method] = original
	cls[method] = wrapper_factory(original)
end

function M:_override_damage_method(cls, method, category)
	self:_override_once(cls, method, function(original)
		return function(self, attack_data)
		if M:ShouldBlock(self, attack_data, category) then
			M:OnBlockedHit(self, attack_data, category)
			return
		end
		return original(self, attack_data)
		end
	end)
end

function M:InstallBulletFilter()
	if self._bullet_installed then
		return
	end
	self._bullet_installed = true

	if type(InstantBulletBase) ~= "table" then
		return
	end

	self:_override_once(InstantBulletBase, "give_impact_damage", function(original)
		return function(self, col_ray, weapon_unit, user_unit, damage, armor_piercing, shield_knock, knock_down, stagger, variant)
			local hit_unit = col_ray and col_ray.unit
			local dmg_ext = hit_unit and hit_unit.character_damage and hit_unit:character_damage()

			if dmg_ext then
				local attack_data = {
					variant = variant or "bullet",
					weapon_unit = weapon_unit,
					attacker_unit = user_unit,
					col_ray = col_ray,
					damage = damage
				}
				if M:ShouldBlock(dmg_ext, attack_data, "bullet") then
					M:OnBlockedHit(dmg_ext, attack_data, "bullet")
					return
				end
			end

			return original(self, col_ray, weapon_unit, user_unit, damage, armor_piercing, shield_knock, knock_down, stagger, variant)
		end
	end)
end

function M:Install()
	if self._installed then
		return
	end
	self._installed = true

	self:_override_damage_method(CopDamage, "damage_bullet", "bullet")
	self:_override_damage_method(CopDamage, "damage_melee", "melee")
	self:_override_damage_method(CopDamage, "damage_fire", "fire")
	self:_override_damage_method(CopDamage, "damage_explosion", "explosion")
	self:_override_damage_method(CopDamage, "damage_dot", "dot")
	self:_override_damage_method(CopDamage, "damage_simple", "simple")
end

M:Load()


