local class = require("Lib/30log")
local Memory = require("Source/Memory")

------------
-- MIXINS --
------------

-- Fills a collection with copies of a given value. Use this with statically-sized collections.
-- Requires _data and size
local Fill = {
	-- Fills the collection with a given value
	fill = function(self, value)
		for x = 1, self.size do
			self._data[x] = Memory.copy(value)
		end
	end,
}

-- Iterates over elements in a collection sets to the mutator's return value.
-- Requires _data and size
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

-- Iterates over elements
-- Requires _data
local Iterator = {
	__iter = function(self)
		return next, self._data
	end
}

-----------------
-- COLLECTIONS --
-----------------

local Collection = {}

-- Statically-sized 3D grid
Collection.Grid3D = class("Grid3D"):with(Fill):with(Iterator)

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
	return self._data[x + self.width * ((y - 1) + self.height * (z - 1))]
end

function Collection.Grid3D:set(x: number, y: number, z: number, value)
	if not self:isCoordinateInBounds(x, y, z) then return end
	self._data[x + self.width * ((y - 1) + self.height * (z - 1))] = value
end

function Collection.Grid3D:setUnchecked(x: number, y: number, z: number, value)
	self._data[x + self.width * ((y - 1) + self.height * (z - 1))] = value
end

function Collection.Grid3D:__iter()
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

-- Returns values of surrounding grid cells
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
	or not self:isCoordinateInBounds(x + width - 1, y + height - 1, z + depth - 1)
	then return end
	local region = Collection.Grid3D(width, height, depth)
	local regionPos = 1
	for z = z, z + depth - 1 do
		for y = y, y + height - 1 do
			local row = x + self.width * ((y - 1) + self.height * (z - 1))
			for offset = 0, width - 1 do
				region._data[regionPos] = self._data[row + offset]
				regionPos += 1
			end
		end
	end
	return region
end

function Collection.Grid3D:mutateRegion(x: number, y: number, z: number, width: number, height: number, depth: number, mutator: (x: number, y: number, z: number, value: any) -> (any))
	-- Bounds check
	if not self:isCoordinateInBounds(x, y, z) 
	or not self:isCoordinateInBounds(x + width - 1, y + height - 1, z + depth - 1)
	then return end
	for z = z, z + depth - 1 do
		for y = y, y + height - 1 do
			local row = x + self.width * ((y - 1) + self.height * (z - 1))
			for offset = 0, width - 1 do
				self._data[row + offset] = mutator(x + offset, y, z, self._data[row + offset])
			end
		end
	end
end

-- Statically-sized 2D grid
Collection.Grid2D = class("Grid2D"):with(Fill):with(Mutator)

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
	return self._data[x + (y - 1) * self.width]
end

function Collection.Grid2D:set(x: number, y: number, value)
	if not self:isCoordinateInBounds(x, y) then return end
	self._data[x + (y - 1) * self.width] = value
end

function Collection.Grid2D:setUnchecked(x: number, y: number, value)
	self._data[x + (y - 1) * self.width] = value
end

function Collection.Grid2D:__iter()
	local x, y, i = 0, 1, 0
	return function()
		i += 1
		if x < self.width then
			x += 1
		else
			x = 1
			y += 1
			if y > self.height then
				return
			end
		end
		return x, y, self._data[i]
	end
end

-- Returns values of surrounding grid cells
function Collection.Grid2D:getNeighbors(x: number, y: number)
	local neighbors = {}
	neighbors["Top"] = self:get(x, y + 1)
	neighbors["Bottom"] = self:get(x, y - 1)
	neighbors["Left"] = self:get(x - 1, y)
	neighbors["Right"] = self:get(x + 1, y)
	return neighbors
end

-- Returns a grid of the values in the specified region if in bounds
function Collection.Grid2D:getRegion(x: number, y: number, width: number, height: number)
	-- Bounds check. Subtract 1 from width/height to get end position
	if not self:isCoordinateInBounds(x, y)
	or not self:isCoordinateInBounds(x + width - 1, y + height - 1) 
	then return nil end
	local region = Collection.Grid2D(width, height)
	local regionPos = 1
	for y = y, y + height - 1 do
		local row = x + self.width * (y - 1)
		for offset = 0, width - 1 do
			region._data[regionPos] = self._data[row + offset]
			regionPos += 1
		end
	end
	return region
end

function Collection.Grid2D:mutateRegion(x: number, y: number, width: number, height: number, mutator: (x: number, y: number, value: any) -> (any))
	-- Bounds check
	if not self:isCoordinateInBounds(x, y)
	or not self:isCoordinateInBounds(x + width - 1, y + height - 1)
	then return end
	for y = y, y + height - 1 do
		local row = x + self.width * (y - 1)
		for offset = 0, width - 1 do
			self._data[row + offset] = mutator(x + offset, y, self._data[row + offset])
		end
	end
end

-- Possible optimization, use binary search for random function by storing cumulative weights in each element.
-- Drawbacks, would have to recalculate cumulative weights each time an element is added or removed.
Collection.WeightedArray = class("WeightedArray"):with(Iterator)

function Collection.WeightedArray:init()
	self._data = {}
	self._totalWeight = 0
	self.size = 0
end

function Collection.WeightedArray:insert(element: {value: any, weight: number})
	self._totalWeight += element.weight
	self.size += 1
	self._data[self.size] = element
end

function Collection.WeightedArray:remove(index: number)
	self._totalWeight -= self._data[index].weight
	self.size -= 1
	table.remove(self._data, index)
end

function Collection.WeightedArray:random(): any
	local target = math.random(0, self._totalWeight - 1)
	for _, element in ipairs(self._data) do
		if target < element.weight then
			return element.value
		end
		target -= element.weight
	end
	return -- should never get here
end

return Collection
