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

-- Source: https://stackoverflow.com/a/1283608/18147378
-- Merges two tables, overwriting duplicate keys
function Memory.merge(t1, t2)
    for k,v in pairs(t2) do
        if type(v) == "table" then
            if type(t1[k] or false) == "table" then
                Memory.merge(t1[k] or {}, t2[k] or {})
            else
                t1[k] = v
            end
        else
            t1[k] = v
        end
    end
    return t1
end

return Memory
