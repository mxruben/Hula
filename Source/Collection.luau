local Memory = require("Source/Memory")

----------------------
-- SHARED FUNCTIONS --
----------------------

-- Fills a collection with copies of a given value. Use this with statically-sized collections.
-- Requires _data and size

local function fill(self, value)
	for x = 1, self.size do
		self._data[x] = Memory.copy(value)
	end
end

-- Iterates over elements
-- Requires _data
local function iterator(self)
	return next, self._data
end

-----------------
-- COLLECTIONS --
-----------------

local Collection = {}

-- Statically-sized 3D grid
Collection.Grid3D = {}
Collection.Grid3D.__index = Collection.Grid3D
Collection.Grid3D.fill = fill

-- Constructor
function Collection.Grid3D.new(width: number, height: number, depth: number)
    local self = {
        width = width,
        height = height,
        depth = depth,
        size = width * height * depth,
        _data = {}
    }

    setmetatable(self, Collection.Grid3D)

    return self
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

function Collection.Grid3D:mutate(mutator: (x: number, y: number, z: number, value: any) -> (any))
	for z = 1, self.depth do
		for y = 1, self.height do
			local row = self.width * ((y - 1) + self.height * (z - 1))
			for x = 1, self.width do
				self._data[row + x] = mutator(x, y, z, self._data[row + x])
			end
		end
	end
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
Collection.Grid2D = {}
Collection.Grid2D.__index = Collection.Grid2D
Collection.Grid2D.fill = fill

-- Constructor
function Collection.Grid2D.new(width: number, height: number)
    local self = {
        width = width,
        height = height,
        size = width * height,
        _data = {}
    }
    
    setmetatable(self, Collection.Grid2D)

    return self
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

function Collection.Grid2D:mutate(mutator: (x: number, y: number, value: any) -> (any))
	for y = 1, self.height do
		local row = self.width * (y - 1)
		for x = 1, self.width do
			self._data[row + x] = mutator(x, y, self._data[row + x])
		end
	end
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
Collection.WeightedArray = {}
Collection.WeightedArray.__index = Collection.WeightedArray
Collection.WeightedArray.__iter = iterator

-- Constructor
function Collection.WeightedArray.new()
    local self = {
        size = 0,
        _data = {},
        _totalWeight = 0
    }

    setmetatable(self, Collection.WeightedArray)

    return self
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

-- First in first out container
Collection.Queue = {}
Collection.Queue.__index = Collection.Queue

-- Constructor
function Collection.Queue.new()
    local self = {
        _data = {},
	    first = 0,
	    last = -1
    }

    setmetatable(self, Collection.Queue)

    return self
end

function Collection.Queue:push(value: any): ()
	self.last += 1
	self._data[self.last] = value
end

function Collection.Queue:pop(): any
	local first = self.first
	local value = self._data[first]
	self._data[first] = nil
	self.first += 1
	return value
end

function Collection.Queue:isEmpty(): boolean
	return self.first > self.last
end

function Collection.Queue:clear(): ()
	self.first = 0
	self.last = -1
	self._data = {}
end

function Collection.Queue:__iter()
	local i = self.first - 1
	local n = self.last
	return function()
		i += 1
		if i <= n then
			return self:pop()
		else
			-- Queue is empty, reset it
			self.first = 0
			self.last = -1
			return nil
		end
	end
end

Collection.PriorityQueue = {}
Collection.PriorityQueue.__index = Collection.PriorityQueue

-- Constructor
function Collection.PriorityQueue.new()
    local self = {
        _heap_items = {},
	    _heap_priority = {},
	    size = 0
    }

    setmetatable(self, Collection.PriorityQueue)

    return self
end

-- Check if the queue is empty
function Collection.PriorityQueue:isEmpty(): boolean
	return self.size == 0
end

-- Swim up on the tree and fix heap order
function Collection.PriorityQueue:_swim(): ()
	local heap_items = self._heap_items
	local heap_priority = self._heap_priority
	local i = self.size

	while math.floor(i / 2) > 0 do
		local half = math.floor(i / 2)
		if heap_priority[i] < heap_priority[half] then
			-- If node is less than it's parent, swap
			heap_items[i], heap_items[half] = heap_items[half], heap_items[i]
			heap_priority[i], heap_priority[half] = heap_priority[half], heap_priority[i]
		end
		i = half
	end
end

-- Put an item with a specified priority into the queue
function Collection.PriorityQueue:put(item: any, priority: number): ()
	self.size += 1
	self._heap_items[self.size] = item
	self._heap_priority[self.size] = priority
	self:_swim()
end

function Collection.PriorityQueue:_minChild(i: number): number
	if (i * 2) + 1 > self.size then
		-- No right child, must return left
		return i * 2
	elseif self._heap_priority[i * 2] < self._heap_priority[i * 2 + 1] then
		-- Return left
		return i * 2
	else
		-- Return right
		return i * 2 + 1
	end
end

-- Sink down on the tree and fix the heap order
function Collection.PriorityQueue:_sink(): ()
	local size = self.size
	local heap_items = self._heap_items
	local heap_priority = self._heap_priority
	local i = 1

	while (i * 2) <= size do
		local mc = self:_minChild(i)
		if heap_priority[i] > heap_priority[mc] then
			-- If node is greater than its smallest child then swap
			heap_items[i], heap_items[mc] = heap_items[mc], heap_items[i]
			heap_priority[i], heap_priority[mc] = heap_priority[mc], heap_priority[i]
		end
		i = mc
	end
end

-- Return and remove the top priority item
function Collection.PriorityQueue:pop(): (any, number)
	local heap_items = self._heap_items
	local heap_priority = self._heap_priority
	local item, priority = heap_items[1], heap_priority[1]
	heap_items[1], heap_priority[1] = heap_items[self.size], heap_priority[self.size]
	heap_items[self.size], heap_priority[self.size] = nil, nil
	self.size -= 1
	self:_sink()
	return item, priority
end

-- Return top priority item without removing
function Collection.PriorityQueue:peek(): (any, number)
	return self._heap_items[1], self._heap_priority[1]
end

-- Pop each item with an iterator
function Collection.PriorityQueue:__iter()
	local i = 0
	local n = self.size
	return function()
		i += 1
		if i <= n then
			return self:pop()
		else
			return nil
		end
	end
end

Collection.Stack = {}
Collection.Stack.__index = Collection.Stack

-- Constructor
function Collection.Stack.new()
    local self = {
        _data = {},
        _top = 0
    }

    setmetatable(self, Collection.Stack)

    return self
end

function Collection.Stack:push(value: any): ()
	self._top += 1
	self._data[self._top] = value
end

function Collection.Stack:pop(): any
	if self._top <= 0 then return nil end
	local value = self._data[self._top]
	self._data[self._top] = nil
	self._top -= 1
	return value
end

function Collection.Stack:isEmpty(): boolean
	return self._top <= 0
end

function Collection.Stack:__iter()
	local i = self._top
	return function()
		i -= 1
		if i >= 0 then
			return self:pop()
		else
			-- Stack is empty
			self._top = 0
			return nil
		end
	end
end

-- Sorted array using the merge sort algorithim. Works with numbers and
-- any class that implements relational metamethods
Collection.SortedArray = {}
Collection.SortedArray.__index = Collection.SortedArray
Collection.SortedArray.__iter = iterator

-- Constructor
function Collection.SortedArray.new()
    local self = {
        _data = {},
        size = 0
    }

    setmetatable(self, Collection.SortedArray)

    return self
end

-- Sort array using merge sort algorithim
function Collection.SortedArray:sort(first: number?, last: number?): ()
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

function Collection.SortedArray:insert(value: any): ()
	self.size += 1
	self._data[self.size] = value
	self:sort()
end

function Collection.SortedArray:remove(index: number): ()
	self.size -= 1
	table.remove(self._data, index)
end

return Collection
