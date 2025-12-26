dofile(ModPath .. "only_headshots.lua")

local M = _G.OnlyHeadshots
if not M or M._copbrain_hooked then
	return
end
M._copbrain_hooked = true

if not CopBrain or type(CopBrain.on_suppressed) ~= "function" then
	return
end

local original = CopBrain.on_suppressed
CopBrain.on_suppressed = function(self, state, ...)
	local logic_data = self and self._logic_data
	if logic_data then
		logic_data.is_suppressed = state or nil
	end

	local unit = self and self._unit
	local snd = unit and unit.sound and unit:sound()
	if snd and snd.say then
		if state == "panic" then
			pcall(snd.say, snd, "lk3b", true)
		else
			local chatter = logic_data and logic_data.char_tweak and logic_data.char_tweak.chatter
			if chatter and chatter.suppress then
				pcall(snd.say, snd, "hlp", true)
			end
		end
	end

	local cur_logic = self and self._current_logic
	if cur_logic and cur_logic.on_suppressed_state and logic_data then
		pcall(cur_logic.on_suppressed_state, logic_data)
	end
end


