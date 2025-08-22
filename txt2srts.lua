-- luajit txt2srts.lua <input.txt>
-- luajit txt2srts.lua srts_c.txt

local srts = {
	'baseq2/video/ntro.srt',
	'baseq2/video/eou1_.srt',
	'baseq2/video/eou2_.srt',
	'baseq2/video/eou3_.srt',
	'baseq2/video/eou4_.srt',
	'baseq2/video/eou5_.srt',
	'baseq2/video/eou6_.srt',
	'baseq2/video/eou7_.srt',
	'baseq2/video/eou8_.srt',
	'baseq2/video/end.srt',

	'baseq2/video/rintro.srt',
	'baseq2/video/reu1_.srt',
	'baseq2/video/reu2_.srt',
	'baseq2/video/reu3_.srt',
	'baseq2/video/reu4_.srt',
	'baseq2/video/rend.srt',

	'baseq2/video/xin.srt',
	'baseq2/video/xu1.srt',
	'baseq2/video/xu2.srt',
	'baseq2/video/xu3.srt',
	'baseq2/video/xu4.srt',
	'baseq2/video/xout.srt',
}

local txt = {}
for line in io.lines(arg[1]) do
	line = line:gsub('^%s+', ''):gsub('%s+$', '')
	txt[#txt + 1] = line
end

local txti = 1
local out = {}
for _, fn in ipairs(srts) do
	local i, s, t = 0, 0, {}
	for line in io.lines(fn) do
		line = line:gsub('^%s+', ''):gsub('%s+$', '')
		i = i + 1
		if s == 0 then
			local v = line:match '^%d+$'
			if not v then
				error('ERROR: invalid(0) at line ' .. i .. ' @ ' .. fn)
			end
			out[#out + 1] = v
			s = 1
		elseif s == 1 then
			local v = line:match '^%d%d:%d%d:%d%d,%d%d%d %-%-> %d%d:%d%d:%d%d,%d%d%d$'
			if not v then
				error('ERROR: invalid(1) at line ' .. i .. ' @ ' .. fn)
			end
			out[#out + 1] = v
			s = 2
		elseif s == 2 then
			if line ~= '' then
				t[#t + 1] = line
			else
				if #t > 0 then
					if not txt[txti] then
						error('ERROR: not enough txt for line ' .. i .. ' @ ' .. fn)
					end
					out[#out + 1] = txt[txti]
					out[#out + 1] = ''
					txti = txti + 1
					t = {}
				end
				s = 0
			end
		end
	end
	if #t > 0 then
		if not txt[txti] then
			error('ERROR: not enough txt for line ' .. i .. ' @ ' .. fn)
		end
		out[#out + 1] = txt[txti]
		out[#out + 1] = ''
		txti = txti + 1
		t = {}
	end
	if txt[txti] ~= '---' then
		error('ERROR: not found file end for ' .. fn)
	end
	txti = txti + 1
	local f = io.open(fn, 'wb')
	f:write(table.concat(out, '\n'), '\n')
	f:close()
	out = {}
end
if txt[txti] then
	error('ERROR: found extra line in txt from line ' .. txti)
end

print 'DONE!'
