--!strict
--!native

--- @class PriorityQueue
--- Collection that orders items by priority. Items with the highest priority
--- are popped first.
local PriorityQueue = {}
PriorityQueue.__index = PriorityQueue

--- @prop size number
--- @within PriorityQueue
--- @readonly

--- @prop _heapItems {T}
--- @within PriorityQueue
--- @ignore

--- @prop _heapPriority {number}
--- @within PriorityQueue
--- @ignore

export type PriorityQueue<T> = typeof(setmetatable({} :: {
	size: number,
	_heapItems: {T},
	_heapPriority: {number}
}, PriorityQueue))

--- @within PriorityQueue
--- Creates a new priority queue.
local function new<T>(): PriorityQueue<T>
    local self = {
        _heapItems = {},
	    _heapPriority = {},
	    size = 0
    }

    setmetatable(self, PriorityQueue)

    return self
end

--- @within PriorityQueue
function PriorityQueue.isEmpty<T>(self: PriorityQueue<T>): boolean
	return self.size == 0
end

-- Swim up on the tree and fix heap order
local function _swim<T>(self: PriorityQueue<T>): ()
	local heapItems = self._heapItems
	local heapPriority = self._heapPriority
	local i = self.size

	while math.floor(i / 2) > 0 do
		local half = math.floor(i / 2)
		if heapPriority[i] < heapPriority[half] then
			-- If node is less than it's parent, swap
			heapItems[i], heapItems[half] = heapItems[half], heapItems[i]
			heapPriority[i], heapPriority[half] = heapPriority[half], heapPriority[i]
		end
		i = half
	end
end

--- @within PriorityQueue
--- Pushes an item with a specified priority into the queue.
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
	local heapItems = self._heapItems
	local heapPriority = self._heapPriority
	local i = 1

	while (i * 2) <= size do
		local mc = _minChild(self, i)
		if heapPriority[i] > heapPriority[mc] then
			-- If node is greater than its smallest child then swap
			heapItems[i], heapItems[mc] = heapItems[mc], heapItems[i]
			heapPriority[i], heapPriority[mc] = heapPriority[mc], heapPriority[i]
		end
		i = mc
	end
end

--- @within PriorityQueue
--- Returns and remove the top priority item and its priority value.
function PriorityQueue.pop<T>(self: PriorityQueue<T>): (T, number)
	local heapItems = self._heapItems
	local heapPriority = self._heapPriority
	local item, priority = heapItems[1], heapPriority[1]
	heapItems[1], heapPriority[1] = heapItems[self.size], heapPriority[self.size]
	heapItems[self.size], heapPriority[self.size] = nil, nil
	self.size -= 1
	_sink(self)
	return item, priority
end

--- @within PriorityQueue
--- Returns the top priority item and priority value without removing them.
function PriorityQueue.peek<T>(self: PriorityQueue<T>): (T, number)
	return self._heapItems[1], self._heapPriority[1]
end

return {
    new = new
}
