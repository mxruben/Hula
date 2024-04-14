--!strict
--!native

--- @class WeightedArray
--- Array where each item has an associated weight. Items with a higher weight
--- are more likely to be selected by the random() method.
local WeightedArrayIterate = {}
WeightedArrayIterate.__index = WeightedArrayIterate
local WeightedArrayBinarySearch = {}
WeightedArrayBinarySearch.__index = WeightedArrayBinarySearch

--- @prop size number
--- @within WeightedArray
--- @readonly

--- @prop _data {WeightedArrayItem<T>}
--- @within WeightedArray
--- @ignore

--- @prop _totalWeight number
--- @within WeightedArray
--- @ignore

--- @within WeightedArray
--- @type WeightedArrayItem<T> {value: T, weight: number, _cumulativeWeight: number?}
export type WeightedArrayItem<T> = {value: T, weight: number, _cumulativeWeight: number?}

--- @within WeightedArray
--- @type WeightedArrayKind "Iterate" | "BinarySearch"
export type WeightedArrayKind = "Iterate" | "BinarySearch"

export type WeightedArray<T> = typeof(setmetatable({} :: {
	size: number,
	_data: {WeightedArrayItem<T>},
	_totalWeight: number
}, WeightedArrayIterate)) -- All kinds should have the same type, they only have
-- different implementation. WeightedArrayIterate is just a placeholder.

-- Iterate through _data and calculate cumulative weight for each item.
local function calculateCumulativeWeights<T>(self: WeightedArray<T>): ()
    local cumulativeWeight = 0
    for _, item in self._data do
        cumulativeWeight += item.weight
        item._cumulativeWeight = cumulativeWeight
    end
end

local function createWeightedArrayIterate<T>(data: {WeightedArrayItem<T>}): WeightedArray<T>
    local size, weight = 0, 0
    for _, item in data do
        size += 1
        weight += item.weight
    end

    local self = {size = size, _totalWeight = weight, _data = data}
    setmetatable(self, WeightedArrayIterate)
    return self
end

local function createWeightedArrayBinarySearch<T>(data: {WeightedArrayItem<T>}): WeightedArray<T>
    local size, weight = 0, 0
    for _, item in data do
        size += 1
        weight += item.weight
        item._cumulativeWeight = weight
    end

    local self = {size = size, _totalWeight = weight, _data = data}
    setmetatable(self, WeightedArrayBinarySearch)
    return self
end

--- @within WeightedArray
--- Creates a new weighted array of specified kind.
local function new<T>(kind: WeightedArrayKind?): WeightedArray<T>
    kind = kind or "Iterate"
    local self = {size = 0, _totalWeight = 0, _data = {}}
    if kind == "Iterate" then
        return setmetatable(self, WeightedArrayIterate)
    elseif kind =="BinarySearch" then
        return setmetatable(self, WeightedArrayBinarySearch)
    else
        error(`invalid kind of WeightedArray: {kind}`)
    end
end

--- @within WeightedArray
--- Creates a new weighted array from an existing array.
local function fromData<T>(data: {WeightedArrayItem<T>}, kind: WeightedArrayKind?): WeightedArray<T>
    kind = kind or "Iterate"
    if kind == "Iterate" then
        return createWeightedArrayIterate(data)
    elseif kind == "BinarySearch" then
        return createWeightedArrayBinarySearch(data)
    else
        error(`invalid kind of WeightedArray: {kind}`)
    end
end

--- @within WeightedArray
local function isEmpty<T>(self: WeightedArray<T>): boolean
    return self.size < 1
end
WeightedArrayIterate.isEmpty = isEmpty
WeightedArrayBinarySearch.isEmpty = isEmpty

--- @within WeightedArray
--- Returns a random item from the array based on weight. Items with higher weight
--- are more likely to be returned.
function WeightedArrayIterate.random<T>(self: WeightedArray<T>): T
    if self:isEmpty() then error("cannot pick random item from empty array") end
	local target = math.random(0, self._totalWeight - 1)
	for _, item in ipairs(self._data) do
		if target < item.weight then
			return item.value
		end
		target -= item.weight
	end
	error(`unreachable`)
end

-- Implement using BinarySearch module when type intersections with metatables are fixed
function WeightedArrayBinarySearch.random<T>(self: WeightedArray<T>): T
    if self:isEmpty() then error("cannot pick random item from empty array") end
    local low = 1
    local high = self.size
    local target = math.random(0, self._totalWeight)

    while low < high do
        local mid = low + math.floor((high - low) / 2)
        local item = self._data[mid]

        if item._cumulativeWeight :: number <= target then
            low = mid + 1
        else
            high = mid
        end
    end

    if low < self.size and self._data[low]._cumulativeWeight :: number <= target then
        low += 1
    end

    return self._data[low].value
end

--- @within WeightedArray
--- Returns the item at the index, or nil if the index is out of range.
local function at<T>(self: WeightedArray<T>, index: number): WeightedArrayItem<T>?
    return self._data[index]
end
WeightedArrayIterate.at = at
WeightedArrayBinarySearch.at = at

--- @within WeightedArray
--- Insert an item into the array.
function WeightedArrayIterate.insert<T>(self: WeightedArray<T>, item: WeightedArrayItem<T>): ()
	self._totalWeight += item.weight
	self.size += 1
	self._data[self.size] = item
end

function WeightedArrayBinarySearch.insert<T>(self: WeightedArray<T>, item: WeightedArrayItem<T>): ()
    self._totalWeight += item.weight
	self.size += 1
	self._data[self.size] = item
    calculateCumulativeWeights(self)
end

--- @within WeightedArray
--- Remove an item at the specified index from the array.
function WeightedArrayIterate.remove<T>(self: WeightedArray<T>, index: number): WeightedArrayItem<T>?
	self._totalWeight -= self._data[index].weight
	self.size -= 1
	return table.remove(self._data, index)
end

function WeightedArrayBinarySearch.remove<T>(self: WeightedArray<T>, index: number): WeightedArrayItem<T>?
	self._totalWeight -= self._data[index].weight
	self.size -= 1
	local result = table.remove(self._data, index)
    calculateCumulativeWeights(self)
    return result
end

--- @within WeightedArray
local function __len<T>(self: WeightedArray<T>): number
    return self.size
end
WeightedArrayIterate.__len = __len
WeightedArrayBinarySearch.__len = __len

--- @within WeightedArray
--- Creates a lazy evaluated iterator.
local function iter<T>(self: WeightedArray<T>): () -> (number, WeightedArrayItem<T>)
    return coroutine.wrap(function()
        for i = 1, self.size do
            coroutine.yield(i, self._data[i])
        end
    end)
end
WeightedArrayIterate.iter = iter
WeightedArrayBinarySearch.iter = iter

--- @within WeightedArray
--- Same as WeightedArray:iter(). Recommended to use that one instead as it gives
--- you proper type checking.
--- @method __iter
--- @return () -> (number, WeightedArrayItem<T>)
WeightedArrayIterate.__iter = WeightedArrayIterate.iter
WeightedArrayBinarySearch.__iter = WeightedArrayIterate.iter

return {
    new = new,
    fromData = fromData
}
