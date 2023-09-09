--!strict
--!native
local PriorityQueue = {}
PriorityQueue.__index = PriorityQueue

export type PriorityQueue<T> = typeof(setmetatable({} :: {
	size: number,
	_heapItems: {T},
	_heapPriority: {number}
}, PriorityQueue))

-- Constructor
local function new<T>(): PriorityQueue<T>
    local self = {
        _heapItems = {},
	    _heapPriority = {},
	    size = 0
    }

    setmetatable(self, PriorityQueue)

    return self
end

-- Check if the queue is empty
function PriorityQueue.isEmpty<T>(self: PriorityQueue<T>): boolean
	return self.size == 0
end

-- Swim up on the tree and fix heap order
local function _swim<T>(self: PriorityQueue<T>): ()
	local heap_items = self._heapItems
	local heap_priority = self._heapPriority
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
function PriorityQueue.push<T>(self: PriorityQueue<T>, item: T, priority: number): ()
	self.size += 1
	self._heapItems[self.size] = item
	self._heapPriority[self.size] = priority
	_swim(self)
end

local function _minChild<T>(self: PriorityQueue<T>, i: number): number
	if (i * 2) + 1 > self.size then
		-- No right child, must return left
		return i * 2
	elseif self._heapPriority[i * 2] < self._heapPriority[i * 2 + 1] then
		-- Return left
		return i * 2
	else
		-- Return right
		return i * 2 + 1
	end
end

-- Sink down on the tree and fix the heap order
local function _sink<T>(self: PriorityQueue<T>): ()
	local size = self.size
	local heap_items = self._heapItems
	local heap_priority = self._heapPriority
	local i = 1

	while (i * 2) <= size do
		local mc = _minChild(self, i)
		if heap_priority[i] > heap_priority[mc] then
			-- If node is greater than its smallest child then swap
			heap_items[i], heap_items[mc] = heap_items[mc], heap_items[i]
			heap_priority[i], heap_priority[mc] = heap_priority[mc], heap_priority[i]
		end
		i = mc
	end
end

-- Return and remove the top priority item
function PriorityQueue.pop<T>(self: PriorityQueue<T>): (T, number)
	local heap_items = self._heapItems
	local heap_priority = self._heapPriority
	local item, priority = heap_items[1], heap_priority[1]
	heap_items[1], heap_priority[1] = heap_items[self.size], heap_priority[self.size]
	heap_items[self.size], heap_priority[self.size] = nil, nil
	self.size -= 1
	_sink(self)
	return item, priority
end

-- Return top priority item without removing
function PriorityQueue.peek<T>(self: PriorityQueue<T>): (T, number)
	return self._heapItems[1], self._heapPriority[1]
end

return {
    new = new
}