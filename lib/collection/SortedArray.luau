--!strict
--!native
-- Sorted array using the merge sort algorithim. Works with numbers and
-- any class that implements relational metamethods
local common = require("lib/collection/internal/common")

local SortedArray = {}
SortedArray.__index = SortedArray
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

-- Sort array using merge sort algorithim
function SortedArray.sort<T>(self: SortedArray<T>, first: number?, last: number?): ()
	local first = first or 1
	local last = last or self.size

	if first < last then
		local middle = math.floor((first + last) / 2)
		self:sort(first, middle)
		self:sort(middle + 1, last)

		local left = first
		local leftTail = math.floor((first + last) / 2)
		local right = leftTail + 1
		local temp = {table.unpack(self._data)}

		for i = first, last do
			if right > last or ((self._data[left] <= self._data[right]) and left <= leftTail) then
				temp[i] = self._data[left]
				left += 1
			else
				temp[i] = self._data[right]
				right += 1
			end
		end

		-- Copy sorted data back into array
		for i = first, last do
			self._data[i] = temp[i]
		end
	end
end

function SortedArray.insert<T>(self: SortedArray<T>, value: any): ()
	self.size += 1
	self._data[self.size] = value
	self:sort()
end

function SortedArray.remove<T>(self: SortedArray<T>, index: number): ()
	self.size -= 1
	table.remove(self._data, index)
end

return {
    new = new
}