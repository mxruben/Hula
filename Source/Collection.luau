local class = require("Lib/30log")
local Memory = require("Source/Memory")

local Collection = {}

local Fill = {
	-- Fills the collection with a given value
	fill = function(self, value)
		for x = 1, self.size do
			self._data[x] = Memory.copy(value)
		end
	end,
}

local Mutator = {
	-- Iterates over value only
	mutate = function(self, mutator: (value: any) -> (any))
		for i = 1, self.size do
			self._data[i] = mutator(self._data[i])
		end
	end,
	
	-- Iterates over index and value
	mutatePairs = function(self, mutator: (index: number, value: any) -> (any))
		for i = 1, self.size do
			self._data[i] = mutator(i, self._data[i])
		end
	end,
}

local Iterator = {
	iterate = function(self): () -> (any)
		local i = 0
		local n = self.size
		local t = self._data
		
		return function()
			i = i + 1
			if i <= n then return t[i] end
		end
	end,

	iteratePairs = function(self): () -> (number, any)
		local i = 0
		local n = self.size
		local t = self._data

		return function()
			i = i + 1
			if i <= n then return i, t[i] end
		end
	end
}

-- Statically-sized 3D grid
Collection.Grid3D = class("Grid3D"):with(Fill):with(Mutator):with(Iterator)

function Collection.Grid3D:init(width: number, height: number, depth: number)
	self.width = width
	self.height = height
	self.depth = depth
	self.size = width * height * depth
	self._data = {}
end

function Collection.Grid3D:isCoordinateInBounds(x: number, y: number, z: number): boolean
	return x <= self.width and x > 0 and y <= self.height and y > 0 and z <= self.depth and z > 0
end

function Collection.Grid3D:get(x: number, y: number, z: number)
	if not self:isCoordinateInBounds(x, y, z) then return nil end
	return self._data[x + (self.width - 1) * (y + (self.depth - 1) * z)]
end

function Collection.Grid3D:set(x: number, y: number, z: number, value)
	if not self:isCoordinateInBounds(x, y, z) then return end
	self._data[x + (self.width - 1) * (y + (self.depth - 1) * z)] = value
end

function Collection.Grid3D:getNeighbors(x: number, y: number, z: number)
	local neighbors = {}
	neighbors["Top"] = self:get(x, y + 1, z)
	neighbors["Bottom"] = self:get(x, y - 1, z)
	neighbors["Left"] = self:get(x - 1, y, z)
	neighbors["Right"] = self:get(x + 1, y, z)
	neighbors["Front"] = self:get(x, y, z - 1)
	neighbors["Back"] = self:get(x, y, z + 1)
	return neighbors
end

function Collection.Grid3D:getRegion(x: number, y: number, z: number, width: number, height: number, depth: number)
	-- Bounds check
	if not self:isCoordinateInBounds(x, y, z) 
	or not self:isCoordinateInBounds(x + width, y + height, z + depth) then return end
	local region = Collection.Grid3D(width, height, depth)
	local regionPos = 1
end

-- Statically-sized 2D grid
Collection.Grid2D = class("Grid2D"):with(Fill):with(Mutator):with(Iterator)

function Collection.Grid2D:init(width: number, height: number)
	self.width = width
	self.height = height
	self.size = width * height
	self._data = {}
end

function Collection.Grid2D:isCoordinateInBounds(x: number, y: number)
	return x <= self.width and x > 0 and y <= self.height and y > 0
end

function Collection.Grid2D:get(x: number, y: number)
	if not self:isCoordinateInBounds(x, y) then return nil end
	return self._data[x + y * (self.width - 1)]
end

function Collection.Grid2D:set(x: number, y: number, value)
	if not self:isCoordinateInBounds(x, y) then return end
	self._data[x + y * (self.width - 1)] = value
end

function Collection.Grid2D:getNeighbors(x: number, y: number)
	local neighbors = {}
	-- TODO, optimize with only 2 coordinate bounds checks
	neighbors["Top"] = self:get(x, y + 1)
	neighbors["Bottom"] = self:get(x, y - 1)
	neighbors["Left"] = self:get(x - 1, y)
	neighbors["Right"] = self:get(x + 1, y)
	return neighbors
end

-- Returns a grid of the values in the specified region if in bounds
function Collection.Grid2D:getRegion(x: number, y: number, width: number, height: number)
	-- Bounds check. Subtract 1 from width/height to get end position
	if not self:isCoordinateInBounds(x, y) then return nil end
	if not self:isCoordinateInBounds(x + width - 1, y + height - 1) then return nil end
	local region = Collection.Grid2D(width, height)
	local regionPos = 1
	for row = y, y + height - 1 do
		local rowPos = x + self.width * (row - 1)
		for pos = rowPos, rowPos + width - 1 do
			region._data[regionPos] = self._data[pos]
			regionPos = regionPos + 1
		end
	end
	return region
end

function Collection.Grid2D:mutateRegion(x: number, y: number, width: number, height: number, mutator: (x: number, y: number, value: any) -> (any))
	-- Bounds check
	if not self:isCoordinateInBounds(x, y)
	or not self:isCoordinateInBounds(x + width - 1, y + height - 1) then return end
	for row = y, y + height - 1 do
		local rowPos = x + self.width * (row - 1)
		local column = x
		for pos = rowPos, rowPos + width - 1 do
			self._data[pos] = mutator(column, row, self._data[pos])
			column = column + 1
		end
	end
end

return Collection
