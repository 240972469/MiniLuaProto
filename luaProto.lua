luaProto = {}

--------------------------- proto definition ---------------------------
--[[
number,string,bool, table,repeated
5 type supported
]]
luaProto.studentInfo = {
	{ "id", "number" },
	{ "name", "string" },
	{ "sex", "bool", },
	{ "dInfo", "table", "detailInfo" },
	{ "friends", "repeated", "studentInfo" },
}

luaProto.detailInfo = {
	{ "charId", "number" },
	{ "nickName", "string" },
}

--------------------------- core function ---------------------------
luaProto.encode = function(protoName, t)
	local s = ""
	local protoInfo = luaProto[protoName]
	if protoInfo then
		for _,v in ipairs(protoInfo) do
			if v[2] == "bool" then
				if t[v[1]] then
					s = s.."1"
				else
					s = s.."0"
				end
			elseif v[2] == "number" then
				local numberStr = tostring(t[v[1]])
				local length = string.len(numberStr)
				local lengthStr = string.char(length)
				s = s..lengthStr..numberStr
			elseif v[2] == "string" then
				local length = string.len(t[v[1]])
				local lengthStr = string.char(length)
				s = s..lengthStr..t[v[1]]
			elseif v[2] == "table" then
				s = s..luaProto.encode(v[3], t[v[1]])
			elseif v[2] == "repeated" then
				local length = #(t[v[1]])
				local lengthStr = string.char(length)
				s = s..lengthStr
				for _,vv in ipairs(t[v[1]]) do
					s = s..luaProto.encode(v[3], vv)
				end
			end
		end
	end
	return s
end

luaProto.decode = function(protoName, s, currentIndex)
	if not currentIndex then currentIndex = 1 end
	local t = {}
	local length = 0
	local protoInfo = luaProto[protoName]
	if protoInfo then
		for _,v in ipairs(protoInfo) do
			if v[2] == "bool" then
				t[v[1]] = (string.sub(s, currentIndex, currentIndex) == "1")
				currentIndex = currentIndex + 1
			elseif v[2] == "number" then
				length = s:byte(currentIndex)
				t[v[1]] = tonumber(string.sub(s, currentIndex + 1, currentIndex + 1 + length - 1))
				currentIndex = currentIndex + 1 + length
			elseif v[2] == "string" then
				length = s:byte(currentIndex)
				t[v[1]] = string.sub(s, currentIndex + 1, currentIndex + 1 + length - 1)
				currentIndex = currentIndex + 1 + length
			elseif v[2] == "table" then
				t[v[1]], currentIndex = luaProto.decode(v[3], s, currentIndex)
			elseif v[2] == "repeated" then
				length = s:byte(currentIndex)
				currentIndex = currentIndex + 1
				t[v[1]] = {}
				for i=1,length do
					t[v[1]][i], currentIndex = luaProto.decode(v[3], s, currentIndex)
				end
			end
		end
	end
	return t, currentIndex
end

--------------------------- test sample ---------------------------
--[[test
	local s1 = {
		id = 1,
		name = "test",
		sex = true,
		dInfo = {
			charId = 5,
			nickName = "nick",
		},
		friends = {},
	}

	local s2 = {
		id = 2,
		name = "test2",
		sex = false,
		dInfo = {
			charId = 4,
			nickName = "nick2",
		},
		friends = { s1, s1 },
	}


	local s = luaProto.encode("studentInfo", s2)
	local t = luaProto.decode("studentInfo", s)
]]