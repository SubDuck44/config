fmt = string.format

local mouse_active = true

for _, dir in pairs({ "left", "right", "up", "down" }) do
	hl.bind(fmt("SUPER + %s", dir), hl.dsp.focus({ direction = dir }))
	hl.bind(fmt("SUPER + SHIFT + %s", dir), hl.dsp.window.swap({ direction = dir }))
end

function terminal()
	ws = "1"
	class = "foot-main-terminal"
	should_move = true

	if hl.get_active_workspace().name ~= ws then
		hl.dispatch(hl.dsp.focus({ workspace = ws }))
		should_move = false
	end

	present = #hl.get_windows({
		workspace = ws,
		class = class,
	}) > 0

	if not present then
		hl.dispatch(hl.dsp.exec_cmd(fmt("foot -a %s tmux new-session -A -s 0", class)))
	elseif should_move then
		hl.dispatch(hl.dsp.focus({ workspace = "previous" }))
	end
end

for i = 1, 10 do
	local offset = 100
	local key = i % 10 -- 10 maps to key 0
	hl.bind(fmt("SUPER + %s", key), function()
		hl.dsp.focus({ workspace = i })
		if hl.get_active_monitor().x < 0 then
			hl.dispatch(hl.dsp.focus({ workspace = i + offset }))
		else
			hl.dispatch(hl.dsp.focus({ workspace = i }))
		end
	end)
	hl.bind(fmt("SUPER + SHIFT + %s", key), function()
		if hl.get_active_monitor().x < 0 then
			hl.dispatch(hl.dsp.window.move({ workspace = i + offset }))
		else
			hl.dispatch(hl.dsp.window.move({ workspace = i }))
		end
	end)
end
