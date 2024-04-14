--!strict
--!native
local common = require("lib/collection/internal/common")

--- @class Grid3D
--- Fixed-size 3D grid
local Grid3D = {}
Grid3D.__index = Grid3D

--- @within Grid3D
--- Fills the grid with the specified value.
--- @method fill
--- @param value T -- value to fill
Grid3D.fill = common.fill

--- @prop width number
--- @within Grid3D
--- @readonly

--- @prop height number
--- @within Grid3D
--- @readonly

--- @prop depth number
--- @within Grid3D
--- @readonly

--- @prop size number
--- @within Grid3D
--- @readonly

--- @prop _data {T}
--- @within Grid3D
--- @ignore
--- Array of values contained within the grid.

export type Grid3D<T> = typeof(setmetatable({} :: {
	width: number,
	height: number,
	depth: number,
	size: number,
	_data: {T}
}, Grid3D))

--- @within Grid3D
--- Creates a new 3D grid filled with a specified value.
--- @param fill -- value to fill
local function new<T>(width: number, height: number, depth: number, fill: T): Grid3D<T>
    local self = {
        width = width,
        height = height,
        depth = depth,
        size = width * height * depth,
        _data = {}
    }

	common.fill(self, fill)

    setmetatable(self, Grid3D)

    return self
end

--- @within Grid3D
--- Creates a new 3D grid from an array of values. Errors if the data does not
--- fit the dimensions of the grid.
local function fromData<T>(width: number, height: number, depth: number, data: {T}): Grid3D<T>
	if #data / width / height ~= depth then
		error("Data passed does not fit the dimensions.")
	end

	local self = {
        width = width,
        height = height,
        depth = depth,
        size = width * height * depth,
        _data = data
    }

	setmetatable(self, Grid3D)

	return self
end

--- @within Grid3D
--- Checks if the coordinate is within the bounds of the grid.
function Grid3D.isCoordinateInBounds<T>(self: Grid3D<T>, x: number, y: number, z: number): boolean
	return x <= self.width and x > 0 and y <= self.height and y > 0 and z <= self.depth and z > 0
end

--- @within Grid3D
--- Returns the value at the coordinate, if in bounds. Otherwise returns nil.
function Grid3D.at<T>(self: Grid3D<T>, x: number, y: number, z: number): T?
	if not self:isCoordinateInBounds(x, y, z) then
		return nil
	end
	return self._data[x + self.width * ((y - 1) + self.height * (z - 1))]
end

--- @within Grid3D
--- Unsafe version of at, only use when performance is of upmost importance and when you know
--- you will stay in bounds.
function Grid3D.atUnchecked<T>(self: Grid3D<T>, x: number, y: number, z: number): T?
	return self._data[x + self.width * ((y - 1) + self.height * (z - 1))]
end

--- @within Grid3D
--- Sets the value at the coordinate. Errors if coordinate is out of bounds.
function Grid3D.set<T>(self: Grid3D<T>, x: number, y: number, z: number, value: T): ()
	if not self:isCoordinateInBounds(x, y, z) then
		error(`Coordinate ({x}, {y}, {z}) is out of bounds.`)
	end
	self._data[x + self.width * ((y - 1) + self.height * (z - 1))] = value
end

--- @within Grid3D
--- Unsafe version of set, only use when performance is of upmost importance and when you know
--- you will stay in bounds
function Grid3D.setUnchecked<T>(self: Grid3D<T>, x: number, y: number, z: number, value: T): ()
	self._data[x + self.width * ((y - 1) + self.height * (z - 1))] = value
end

--- @within Grid3D
--- @type Neighbors3D<T> {top: T?, bottom: T?, left: T?, right: T?, front: T?, back: T?}
type Neighbors3D<T> = {top: T?, bottom: T?, left: T?, right: T?, front: T?, back: T?}
-- moonwave flippin sucks i know

--- @within Grid3D
--- Returns a map of surrounding grid cells.
function Grid3D.neighborsAt<T>(self: Grid3D<T>, x: number, y: number, z: number): Neighbors3D<T>
	local neighbors = {}
	neighbors["top"] = self:at(x, y + 1, z)
	neighbors["bottom"] = self:at(x, y - 1, z)
	neighbors["left"] = self:at(x - 1, y, z)
	neighbors["right"] = self:at(x + 1, y, z)
	neighbors["front"] = self:at(x, y, z - 1)
	neighbors["back"] = self:at(x, y, z + 1)
	return neighbors
end

local function checkRegionBounds<T>(grid: Grid3D<T>, x1: number, y1: number, z1: number, x2: number, y2: number, z2: number): ()
	if not grid:isCoordinateInBounds(x1, y1, z1) or not grid:isCoordinateInBounds(x2, y2, z2) then
		error(`Region is out of bounds: ({x1}, {y1}, {z1}) to ({x2}, {y2}, {z2})`)
	end
end

--- @within Grid3D
--- Returns a new grid of the values in the specified region.
function Grid3D.region<T>(self: Grid3D<T>, x1: number, y1: number, z1: number, x2: number, y2: number, z2: number): Grid3D<T>
	checkRegionBounds(self, x1, y1, z1, x2, y2, z2)

	local xmin = math.min(x1, x2)
	local xmax = math.max(x1, x2)
	local ymin = math.min(y1, y2)
	local ymax = math.max(y1, y2)
	local zmin = math.min(z1, z2)
	local zmax = math.max(z1, z2)
	local width = xmax - xmin + 1
	local height = ymax - ymin + 1
	local depth = zmax - zmin + 1

	local data = {}
	local regionPos = 1

	for z = zmin, zmax do
		for y = ymin, ymax do
			local row = xmin + self.width * ((y - 1) + self.height * (z - 1))
			for offset = 0, width - 1 do
				data[regionPos] = self._data[row + offset]
				regionPos += 1
			end
		end
	end
	return fromData(width, height, depth, data)
end

--- @within Grid3D
--- Creates a lazy evaluated iterator that iterates over a region in the grid by value.
--- @return () -> (number, number, number, T) -- lazy evaluated iterator that returns x, y, z and value
function Grid3D.iterRegion<T>(self: Grid3D<T>, x1: number, y1: number, z1: number, x2: number, y2: number, z2: number): () -> (number, number, number, T)
	return coroutine.wrap(function()
		checkRegionBounds(self, x1, y1, z1, x2, y2, z2)

		local xmin = math.min(x1, x2)
		local xmax = math.max(x1, x2)
		local ymin = math.min(y1, y2)
		local ymax = math.max(y1, y2)
		local zmin = math.min(z1, z2)
		local zmax = math.max(z1, z2)
		local width = xmax - xmin + 1

		for z = zmin, zmax do
			for y = ymin, ymax do
				local row = xmin + self.width * ((y - 1) + self.height * (z - 1))
				for offset = 0, width - 1 do
					coroutine.yield(xmin + offset, y, z, self._data[row + offset])
				end
			end
		end
	end)
end

--- @within Grid3D
--- Creates a lazy evaluated iterator that iterates over a region in the grid by reference.
--- To access the data within the reference, do ref.value.
--- @return () -> (number, number, number, {value: T}) -- lazy evaluated iterator that returns x, y, z and a reference
function Grid3D.iterRegionRef<T>(self: Grid3D<T>, x1: number, y1: number, z1: number, x2: number, y2: number, z2: number): () -> (number, number, number, {value: T})
	return coroutine.wrap(function()
		checkRegionBounds(self, x1, y1, z1, x2, y2, z2)

		local xmin = math.min(x1, x2)
		local xmax = math.max(x1, x2)
		local ymin = math.min(y1, y2)
		local ymax = math.max(y1, y2)
		local zmin = math.min(z1, z2)
		local zmax = math.max(z1, z2)
		local width = xmax - xmin + 1

		for z = zmin, zmax do
			for y = ymin, ymax do
				local row = xmin + self.width * ((y - 1) + self.height * (z - 1))
				for offset = 0, width - 1 do
					local i = row + offset
					local ref = {value = self._data[i]}
					coroutine.yield(xmin + offset, y, z, ref)
					self._data[i] = ref.value
				end
			end
		end
	end)
end

--- @within Grid3D
--- Returns size of grid.
function Grid3D.__len<T>(self: Grid3D<T>): number
	return self.size
end

--- @within Grid3D
--- Creates a lazy evaluated iterator that iterates over the grid by value.
--- @return () -> (number, number, number, T) -- lazy evaluated iterator that returns x, y, z and value
function Grid3D.iter<T>(self: Grid3D<T>): () -> (number, number, number, T)
	return coroutine.wrap(function()
		local i = 0
		for z = 1, self.depth do
			for y = 1, self.height do
				for x = 1, self.width do
					i += 1
					coroutine.yield(x, y, z, self._data[i])
				end
			end
		end
	end)
end

--- @within Grid3D
--- Same as Grid3D:iter(). Recommended to use that one instead as it gives you
--- proper type checking.
--- @method __iter
--- @return () -> (number, number, number, T)
Grid3D.__iter = Grid3D.iter

--- @within Grid3D
--- Creates a lazy evaluated iterator that iterates over the grid by reference.
--- To access the data within the reference, do ref.value.
--- @return () -> (number, number, number, {value: T}) -- lazy evaluated iterator that returns x, y, z and a reference
function Grid3D.iterRef<T>(self: Grid3D<T>): () -> (number, number, number, {value: T})
	return coroutine.wrap(function()
		local i = 0
		for z = 1, self.depth do
			for y = 1, self.height do
				for x = 1, self.width do
					i += 1
					local ref = {value = self._data[i]}
					coroutine.yield(x, y, z, ref)
					self._data[i] = ref.value
				end
			end
		end
	end)
end

return {
	new = new,
	fromData = fromData
}
