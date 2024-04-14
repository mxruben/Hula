--!strict
--!native
local common = require("lib/collection/internal/common")

--- @class Grid2D
--- Fixed-size 2D grid.
local Grid2D = {}
Grid2D.__index = Grid2D

--- @within Grid2D
--- Fills the grid with the specified value.
--- @method fill
--- @param value T -- value to fill
Grid2D.fill = common.fill

--- @prop width number
--- @within Grid2D
--- @readonly

--- @prop height number
--- @within Grid2D
--- @readonly

--- @prop size number
--- @within Grid2D
--- @readonly

--- @prop _data {T}
--- @within Grid2D
--- @ignore
--- Array of values contained within the grid.

type Grid2D<T> = typeof(setmetatable({} :: {
	width: number,
	height: number,
	size: number,
	_data: {T}
}, Grid2D))
export type Type<T> = Grid2D<T>

--- @within Grid2D
--- Creates a new 2D grid filled with a specified value.
--- @param fill -- value to fill
local function new<T>(width: number, height: number, fill: T): Grid2D<T>
    local self = {
        width = width,
        height = height,
        size = width * height,
        _data = {}
    }

    common.fill(self, fill)

    setmetatable(self, Grid2D)

    return self
end

--- @within Grid2D
--- Creates a new 2D grid from an array of values. Errors if the data does not
--- fit the dimensions of the grid.
local function fromData<T>(width: number, height: number, data: {T}): Grid2D<T>
	if #data / width ~= height then
		error("Data passed does not fit the dimensions.")
	end

	local self = {
		width = width,
		height = height,
		size = width * height,
		_data = data
	}

	setmetatable(self, Grid2D)

	return self
end

--- @within Grid2D
--- Checks if the coordinate is within the bounds of the grid.
function Grid2D.isCoordinateInBounds<T>(self: Grid2D<T>, x: number, y: number): boolean
	return x <= self.width and x > 0 and y <= self.height and y > 0
end

--- @within Grid2D
--- Returns the value at the coordinate, if in bounds. Otherwise returns nil.
function Grid2D.at<T>(self: Grid2D<T>, x: number, y: number): T?
	if not self:isCoordinateInBounds(x, y) then
		return nil
	end
	return self._data[x + (y - 1) * self.width]
end

--- @within Grid2D
--- Unsafe version of at, only use when performance is of upmost importance and when you know
--- you will stay in bounds.
function Grid2D.atUnchecked<T>(self: Grid2D<T>, x: number, y: number): T?
	return self._data[x + (y - 1) * self.width]
end

--- @within Grid2D
--- Sets the value at the coordinate. Errors if coordinate is out of bounds.
function Grid2D.set<T>(self: Grid2D<T>, x: number, y: number, value: T): ()
	if not self:isCoordinateInBounds(x, y) then
		error(`Coordinate ({x}, {y}) is out of bounds.`)
	end
	self._data[x + (y - 1) * self.width] = value
end

--- @within Grid2D
--- Unsafe version of set, only use when performance is of upmost importance and when you know
--- you will stay in bounds
function Grid2D.setUnchecked<T>(self: Grid2D<T>, x: number, y: number, value: T): ()
	self._data[x + (y - 1) * self.width] = value
end

--- @within Grid2D
--- @type Neighbors2D<T> {top: T?, bottom: T?, left: T?, right: T?}
type Neighbors2D<T> = {top: T?, bottom: T?, left: T?, right: T?}

--- @within Grid2D
--- Returns a map of surrounding grid cells.
function Grid2D.neighborsAt<T>(self: Grid2D<T>, x: number, y: number): Neighbors2D<T>
	local neighbors: Neighbors2D<T> = {}
	neighbors["top"] = self:at(x, y + 1)
	neighbors["bottom"] = self:at(x, y - 1)
	neighbors["left"] = self:at(x - 1, y)
	neighbors["right"] = self:at(x + 1, y)
	return neighbors
end

local function checkRegionBounds<T>(grid: Grid2D<T>, x1: number, y1: number, x2: number, y2: number): ()
	if not grid:isCoordinateInBounds(x1, y1) or not grid:isCoordinateInBounds(x2, y2) then
		error(`Region is out of bounds: ({x1}, {y1}) to ({x2}, {y2})`)
	end
end

--- @within Grid2D
--- Returns a new grid of the values in the specified region.
function Grid2D.region<T>(self: Grid2D<T>, x1: number, y1: number, x2: number, y2: number): Grid2D<T>
	checkRegionBounds(self, x1, y1, x2, y2)

	local xmin = math.min(x1, x2)
	local xmax = math.max(x1, x2)
	local ymin = math.min(y1, y2)
	local ymax = math.max(y1, y2)
	local width = xmax - xmin + 1
	local height = ymax - ymin + 1

	local data = {}
	local regionPos = 1

	for y = ymin, ymax do
		local row = xmin + self.width * (y - 1)
		for offset = 0, width - 1 do
			data[regionPos] = self._data[row + offset]
			regionPos += 1
		end
	end

	return fromData(width, height, data)
end

--- @within Grid2D
--- Creates a lazy evaluated iterator that iterates over a region in the grid by value.
--- @return () -> (number, number, T) -- lazy evaluated iterator that returns x, y and value
function Grid2D.iterRegion<T>(self: Grid2D<T>, x1: number, y1: number, x2: number, y2: number): () -> (number, number, T)
	return coroutine.wrap(function()
		checkRegionBounds(self, x1, y1, x2, y2)

		local xmin = math.min(x1, x2)
		local xmax = math.max(x1, x2)
		local ymin = math.min(y1, y2)
		local ymax = math.max(y1, y2)
		local width = xmax - xmin + 1

		for y = ymin, ymax do
			local row = xmin + self.width * (y - 1)
			for offset = 0, width - 1 do
				coroutine.yield(xmin + offset, y, self._data[row + offset])
			end
		end
	end)
end

--- @within Grid2D
--- Creates a lazy evaluated iterator that iterates over a region in the grid by reference.
--- To access the data within the reference, do ref.value.
--- @return () -> (number, number, {value: T}) -- lazy evaluated iterator that returns x, y and a reference
function Grid2D.iterRegionRef<T>(self: Grid2D<T>, x1: number, y1: number, x2: number, y2: number): () -> (number, number, {value: T})
	return coroutine.wrap(function()
		checkRegionBounds(self, x1, y1, x2, y2)

		local xmin = math.min(x1, x2)
		local xmax = math.max(x1, x2)
		local ymin = math.min(y1, y2)
		local ymax = math.max(y1, y2)
		local width = xmax - xmin + 1

		for y = ymin, ymax do
			local row = xmin + self.width * (y - 1)
			for offset = 0, width - 1 do
				local i = row + offset
				local ref = {value = self._data[i]}
				coroutine.yield(xmin + offset, y, ref)
				self._data[i] = ref.value
			end
		end
	end)
end

--- @within Grid2D
--- Returns size of grid.
function Grid2D.__len<T>(self: Grid2D<T>): number
	return self.size
end

--- @within Grid2D
--- Creates a lazy evaluated iterator that iterates over the grid by value.
--- @return () -> (number, number, T) -- lazy evaluated iterator that returns x, y and value
function Grid2D.iter<T>(self: Grid2D<T>): () -> (number, number, T)
	return coroutine.wrap(function()
		for i = 1, self.size do
			coroutine.yield(
				i % self.width + 1,
				math.ceil(i / self.width),
				self._data[i]
			)
		end
	end)
end

--- @within Grid2D
--- Same as Grid2D:iter(). Recommended to use that one instead as it gives you
--- proper type checking.
--- @method __iter
--- @return () -> (number, number, T)
Grid2D.__iter = Grid2D.iter

--- @within Grid2D
--- Creates a lazy evaluated iterator that iterates over the grid by reference.
--- To access the data within the reference, do ref.value.
--- @return () -> (number, number, {value: T}) -- lazy evaluated iterator that returns x, y and a reference
function Grid2D.iterRef<T>(self: Grid2D<T>): () -> (number, number, {value: T})
	return coroutine.wrap(function()
		for i = 1, self.size do
			local ref = {value = self._data[i]}
			coroutine.yield(
				i % self.width + 1,
				math.ceil(i / self.width),
				ref
			)
			self._data[i] = ref.value
		end
	end)
end

-- Crude implementation for debugging
function Grid2D.__tostring<T>(self: Grid2D<T>): string
	local rows = {}
	for i = 1, self.height do
		rows[i] = ""
	end

	for x, y, v in self:iter() do
		rows[self.width + 1 - y] ..= tostring(v).." "
	end

	return table.concat(rows, "\n")
end

return {
    new = new,
	fromData = fromData
}
