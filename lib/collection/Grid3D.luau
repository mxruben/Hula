--!strict
--!native
local common = require("lib/collection/internal/common")

-- Fixed-size 3D grid
local Grid3D = {}
Grid3D.__index = Grid3D
Grid3D.fill = common.fill

export type Grid3D<T> = typeof(setmetatable({} :: {
	width: number,
	height: number,
	depth: number,
	size: number,
	_data: {T}
}, Grid3D))

-- Constructor
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

function Grid3D.isCoordinateInBounds<T>(self: Grid3D<T>, x: number, y: number, z: number): boolean
	return x <= self.width and x > 0 and y <= self.height and y > 0 and z <= self.depth and z > 0
end

-- Get the value at coordinate
function Grid3D.at<T>(self: Grid3D<T>, x: number, y: number, z: number): T?
	return self._data[x + self.width * ((y - 1) + self.height * (z - 1))]
end

-- Set the value at coordinate
function Grid3D.set<T>(self: Grid3D<T>, x: number, y: number, z: number, value: T): ()
	if not self:isCoordinateInBounds(x, y, z) then
		error(`Coordinate ({x}, {y}, {z}) is out of bounds.`)
	end
	self._data[x + self.width * ((y - 1) + self.height * (z - 1))] = value
end

-- Set the value at coordinate without checking if the coordinate is in bounds
function Grid3D.setUnchecked<T>(self: Grid3D<T>, x: number, y: number, z: number, value: T): ()
	self._data[x + self.width * ((y - 1) + self.height * (z - 1))] = value
end

export type Direction3D = "Front" | "Back" | "Left" | "Right" | "Top" | "Bottom"

-- Returns values of surrounding grid cells
function Grid3D.neighborsAt<T>(self: Grid3D<T>, x: number, y: number, z: number): {[Direction3D]: T}
	local neighbors = {}
	neighbors["Top"] = self:at(x, y + 1, z)
	neighbors["Bottom"] = self:at(x, y - 1, z)
	neighbors["Left"] = self:at(x - 1, y, z)
	neighbors["Right"] = self:at(x + 1, y, z)
	neighbors["Front"] = self:at(x, y, z - 1)
	neighbors["Back"] = self:at(x, y, z + 1)
	return neighbors
end

local function checkRegionBounds<T>(grid: Grid3D<T>, x1: number, y1: number, z1: number, x2: number, y2: number, z2: number): ()
	if not grid:isCoordinateInBounds(x1, y1, z1) or not grid:isCoordinateInBounds(x2, y2, z2) then
		error(`Region is out of bounds: ({x1}, {y1}, {z1}) to ({x2}, {y2}, {z2})`)
	end
end

-- Returns a grid of the values in the specified region
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

-- Iterates over a region of the grid
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

-- Iterates over a region of the grid by reference
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

function Grid3D.__len<T>(self: Grid3D<T>): number
	return self.size
end

-- Iterates over grid by value
function Grid3D.iter<T>(self: Grid3D<T>): () -> (number?, number?, number?, T?)
	local x, y, z, i = 0, 1, 1, 0
	return function()
		i += 1
		if x < self.width then
			x += 1
		else
			x = 1
			if y < self.height then
				y += 1
			else
				y = 1
				z += 1
				if z > self.depth then
					return
				end
			end
		end
		return x, y, z, self._data[i]
	end
end

Grid3D.__iter = Grid3D.iter

-- Iterates over grid by reference
function Grid3D.iterRef<T>(self: Grid3D<T>): () -> (number, number, number, {value: T})
	return coroutine.wrap(function()
		local i = 0
		for x = 1, self.width do
			for y = 1, self.height do
				for z = 1, self.depth do
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
