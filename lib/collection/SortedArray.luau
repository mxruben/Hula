--!strict
--!native
-- Sorted array class. Wraps the table.sort function. Works with numbers and
-- any class that implements relational metamethods
local common = require("lib/collection/internal/common")

local SortedArray = {}
SortedArray.__index = SortedArray
SortedArray.iter = common.iterator
SortedArray.__iter = common.iterator

export type SortedArray<T> = typeof(setmetatable({} :: {
	size: number,
	_data: {T}
}, SortedArray))

-- Constructor
local function new<T>(): SortedArray<T>
    local self = {
        _data = {},
        size = 0
    }

    setmetatable(self, SortedArray)

    return self
end

local function fromData<T>(data: {T}): SortedArray<T>
	local self = {
		_data = data,
		size = #data
	}
	table.sort(self._data)

	setmetatable(self, SortedArray)

	return self
end

function SortedArray.insert<T>(self: SortedArray<T>, value: any): ()
	self.size += 1
	self._data[self.size] = value
	table.sort(self._data)
end

function SortedArray.remove<T>(self: SortedArray<T>, index: number): ()
	self.size -= 1
	table.remove(self._data, index)
end

return {
    new = new,
	fromData = fromData
}