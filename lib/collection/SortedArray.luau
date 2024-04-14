--!strict
--!native
-- Sorted array class. Wraps the table.sort function. Works with numbers and
-- any class that implements relational metamethods
local common = require("lib/collection/internal/common")

--- @class SortedArray
--- Sorted array. Wraps the table.sort function so that the array is sorted
--- every time an element is inserted. Works with strings, numbers and any class
--- that implements relational metamethods.
local SortedArray = {}
SortedArray.__index = SortedArray
--- @within SortedArray
SortedArray.iter = common.iterator
--- @within SortedArray
SortedArray.__iter = common.iterator

--- @prop size number
--- @within SortedArray
--- @readonly

--- @prop _data {T}
--- @within SortedArray
--- @ignore

export type SortedArray<T> = typeof(setmetatable({} :: {
	size: number,
	_data: {T}
}, SortedArray))

--- @within SortedArray
--- Creates a new sorted array.
local function new<T>(): SortedArray<T>
    local self = {
        _data = {},
        size = 0
    }

    setmetatable(self, SortedArray)

    return self
end

--- @within SortedArray
--- Creates a new sorted array from an existing array. Array items must be
--- comparable with each other.
local function fromData<T>(data: {T}): SortedArray<T>
	local self = {
		_data = data,
		size = #data
	}
	table.sort(self._data)

	setmetatable(self, SortedArray)

	return self
end

--- @within SortedArray
--- Insert an item into the array.
function SortedArray.insert<T>(self: SortedArray<T>, value: T): ()
	self.size += 1
	self._data[self.size] = value
	table.sort(self._data)
end

--- @within SortedArray
--- Remove an item from the array at the index.
function SortedArray.remove<T>(self: SortedArray<T>, index: number): ()
	self.size -= 1
	table.remove(self._data, index)
end

return {
    new = new,
	fromData = fromData
}
