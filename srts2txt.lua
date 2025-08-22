-- luajit srts2txt.lua <output.txt>
-- luajit srts2txt.lua srts_e.txt

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

local f = io.open(arg[1], 'wb')
for _, fn in ipairs(srts) do
	local i, s, t = 0, 0, {}
	for line in io.lines(fn) do
		line = line:gsub('^%s+', ''):gsub('%s+$', '')
		i = i + 1
		if s == 0 then
			local v = line:match '^%d+$'
			if not v then
				error('ERROR: invalid(0) line ' .. i .. ' @ ' .. fn)
			end
			s = 1
		elseif s == 1 then
			local v = line:match '^%d%d:%d%d:%d%d,%d%d%d %-%-> %d%d:%d%d:%d%d,%d%d%d$'
			if not v then
				error('ERROR: invalid(1) line ' .. i .. ' @ ' .. fn)
			end
			s = 2
		elseif s == 2 then
			if line ~= '' then
				t[#t + 1] = line
			else
				if #t > 0 then
					if #t > 1 and t[1]:find "^[A-Z '._]+$" then
						t[1] = t[1] .. ':'
					end
					f:write(table.concat(t, ' '), '\n')
					t = {}
				end
				s = 0
			end
		end
	end
	if #t > 0 then
		f:write(table.concat(t, ' '), '\n')
		t = {}
	end
	f:write '---\n'
end
f:close()

print 'DONE!'
