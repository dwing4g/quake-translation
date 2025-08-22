-- luajit txt2loc.lua <input_e.txt> <input_c.txt> <input_loc.txt> <output_loc.txt>
-- luajit txt2loc.lua quake2_e.txt quake2_c.txt localization_quake2/loc_english.ori.txt localization_quake2/loc_english.txt

local trans = {
	m_secrets = '秘密',
	m_kills = '击杀',

	g_primary_mission_objective = '首要目标:\\n{}',
	g_secondary_mission_objective = '次要目标:\\n{}',

	g_pc_primary_objective = '首要目标',
	g_pc_secondary_objective = '次要目标',
	g_pc_kills = '击杀',
	g_pc_goals = '目标',
	g_pc_secrets = '秘密',

	boss2_jonatan = '乔纳坦·珀尔约\\n增强模型与额外美术',
	g_fact3_objective = '你有30秒……\\n尽可能多地收集！',
}

local t = {}
for line in io.lines(arg[1]) do
	line = line:gsub('\r+$', '')
	t[#t + 1] = line
end
local i = 0
for line in io.lines(arg[2]) do
	line = line:gsub('\r+$', '')
	i = i + 1
	local e0 = t[i]
	if not e0 then
		error 'ERROR: mismatch lines'
	end
	local e, en = e0:gsub('%[br%]', '\\n')
	local c, cn = line:gsub('%[br%]', '\\n')
	if t[e] and t[e] ~= c then
		error('ERROR: mismatch translation: ' .. e0)
	end
	if en ~= cn then
		error('ERROR: mismatch [br] in translation: ' .. e0)
	end
	t[e] = c
end
if t[i + 1] then
	error 'ERROR: mismatch lines'
end

local out = {}
for line in io.lines(arg[3]) do
	line = line:gsub('\r+$', '')
	local p, e, q = line:match '^(map_.-")%s*(.-)%s*(".*)$'
	if e then
		local c = t[e]
		if not c then
			error('ERROR: not found translation: ' .. e)
		end
		out[#out + 1] = p .. c .. q
	else
		local k, q = line:match '^%s*([%w_]+)%s*=%s*".-"(.*)$'
		if k and trans[k] then
			out[#out + 1] = k .. ' = "' .. trans[k] .. '"' .. q
		else
			out[#out + 1] = line
		end
	end
end

local f = io.open(arg[4], 'wb')
f:write(table.concat(out, '\r\n'), '\r\n')
f:close()

print 'DONE!'
