-- chcp 65001
-- luajit bdf2img.lua fusion-pixel-12px-monospaced-zh_hans.bdf qconfont.tga qconfont.kfont

--[[
PIXEL_SIZE 12
FONT_ASCENT 10
FONT_DESCENT 2
{
STARTCHAR u0020
ENCODING 32
DWIDTH 6 0 // 4 0 | 8 0 | 12 0
BBX 6 12 0 -2 // 4 14 0 -3 | 8 14 0 -3 | 12 12 0 -2 | 12 14 0 -3 | 包围盒宽高+包围盒左下角对基准原点的偏移(正方向:↑→)
BITMAP
0000
0180 // 每字符从高位开始4bit
1FE0
....
ENDCHAR
}*
--]]
local floor = math.floor
local codes = {}
local code, width, height, dataLine, data = 0, 0, 0, 0, {}
local i, n = 0, 0
for line in io.lines(arg[1] or "fusion-pixel-12px-monospaced-zh_hans.bdf") do -- https://github.com/TakWolf/fusion-pixel-font
	i = i + 1
	if dataLine == 0 then
		local tag, args = line:match "^([%w_]+)%s*(.*)$"
		if tag == "ENCODING" then
			code = tonumber(args)
		elseif tag == "DWIDTH" then
			width = tonumber(args:match "^%d+")
			if not width then error("ERROR(" .. i .. "): invalid: " .. line) end
		elseif tag == "BBX" then
			local w, h, x, y = args:match "^(%d+) (%d+) ([%d%-]+) ([%d%-]+)$"
			if not w then error("ERROR(" .. i .. "): invalid: " .. line) end
			w = tonumber(w)
			h = tonumber(h)
			x = tonumber(x)
			y = tonumber(y)
			if w ~= width then error("ERROR(" .. i .. "): invalid w: " .. line) end
			if x ~= 0 then error("ERROR(" .. i .. "): invalid x: " .. line) end
			if not (h == 12 and y == -2 or h == 14 and y == -3) then error("ERROR(" .. i .. "): invalid h&y: " .. line) end
			height = h
		elseif tag == "BITMAP" then
			dataLine = height
		elseif tag == "ENDCHAR" then
			local b = 1
			local h = { w = width }
			for j = height == 12 and 2 or 3, height == 12 and 12 or 13 do
				h[b] = data[j]
				b = b + 1
			end
			codes[code] = h -- [1..11]=[0,0x7ff]
			n = n + 1
			code, width, height, dataLine, data = 0, 0, 0, 0, {}
		elseif tag == "PIXEL_SIZE" then
			if args ~= "12" then
				error("ERROR(" .. i .. "): invalid: " .. line)
			end
		end
	else
		local v = tonumber(line, 16)
		local v2 = 0
		for i = 1, #line * 4 do
			v2 = v2 * 2 + v % 2
			v = floor(v / 2)
		end
		data[#data + 1] = v2 % 0x800 -- only need 11 bits, from low(left) to high(right)
		dataLine = dataLine - 1
	end
end

local f = io.open(arg[3] or 'qconfont.kfont', 'wb')
f:write 'texture "fonts/qconfont.png"\n'
f:write 'unicode\n'
f:write 'mapchar\n'
f:write '{\n'
local img = {}
local x, y = 0, 0
for line in io.lines 'gb2312.txt' do
	local v, c = line:match '^(%d+)%((.-)%)'
	if v then
		v = tonumber(v)
		local code = codes[v]
		if not code then
			print('WARN: undefined unicode: ' .. v .. ' ' .. c)
			code = codes[0x231b] -- for showing unavailable char
		end
		if x + 12 > 1024 then
			x = 0
			y = y + 12
			if y + 12 > 1024 then
				error 'ERROR: img overflow'
			end
		end
		f:write(string.format('\t%d %d %d %d 12 0\n', v, x, y, code.w))
		for i = 0, 10 do
			v = code[i + 1]
			if v and v ~= 0 then
				for j = 0, 10 do
					if v % 2 == 1 then
						v = v - 1
						img[(y + i) * 1024 + (x + j)] = true
					end
					v = v / 2
				end
			end
		end
		x = x + 12
	end
end
f:write '}\n'
f:close()

local w, h = 1024, 1024
local f = io.open(arg[2] or "qconfont.tga", "wb")
f:write "\x00\x00\x02\x00\x00\x00\x00\x00\x00\x00\x00\x00"
f:write(string.char(      w % 256 ))
f:write(string.char(floor(w / 256)))
f:write(string.char(      h % 256 ))
f:write(string.char(floor(h / 256)))
f:write "\x20\x20"
for i = 0, 1024*1024-1 do
	f:write(img[i] and '\xbb\xbb\xbb\xff' or '\x00\x00\x00\x00')
end
f:close()

print "DONE!"
