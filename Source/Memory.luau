local Memory = {}

-- Source: https://stackoverflow.com/a/26367080/18147378
function Memory.copy(obj, seen)
	if type(obj) ~= 'table' then return obj end
	if seen and seen[obj] then return seen[obj] end
	local s = seen or {}
	local res = setmetatable({}, getmetatable(obj))
	s[obj] = res
	for k, v in pairs(obj) do res[Memory.copy(k, s)] = Memory.copy(v, s) end
	return res
end

return Memory
