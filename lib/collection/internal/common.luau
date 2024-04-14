--!strict
--!native
local Memory = require("lib/Memory")

-- Fills the collection with a specified value.
local function fill<T>(self: {_data: {T}, size: number, [any]: any}, value: T): ()
	for x = 1, self.size do
		self._data[x] = Memory.copy(value)
	end
end

-- Iterates over elements.
local function iterator<T>(self: {_data: {T}, [any]: any}): (typeof(next), {T})
	return next, self._data
end

return {
    fill = fill,
    iterator = iterator
}
