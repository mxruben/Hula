--!strict
--!native

--- @class Queue
--- First in first out container.
local Queue = {}
Queue.__index = Queue

type Queue<T> = typeof(setmetatable({} :: {
	_first: number,
	_last: number,
	_data: {T}
}, Queue))
export type Type<T> = Queue<T>

--- @within Queue
--- Creates a new queue.
local function new<T>(): Queue<T>
    local self = {
        _data = {},
	    _first = 1,
	    _last = 0
    }

    setmetatable(self, Queue)

    return self
end

--- @within Queue
--- Creates a new queue from an array.
local function fromData<T>(data: {T}): Queue<T>
    local self = {
        _data = data,
        _first = 1,
        _last = #data
    }

    setmetatable(self, Queue)

    return self
end
--- @within Queue
--- Pushes an item into the back of the queue.
function Queue.push<T>(self: Queue<T>, value: T): ()
	self._last += 1
	self._data[self._last] = value
end

--- @within Queue
--- Return and remove the front item.
function Queue.pop<T>(self: Queue<T>): T?
    if self:isEmpty() then return nil end
	local first = self._first
	local value = self._data[first]
	self._data[first] = nil
	self._first += 1
	return value
end

--- @within Queue
function Queue.isEmpty<T>(self: Queue<T>): boolean
	return self._first > self._last
end

--- @within Queue
--- Clear all data from the queue.
function Queue.clear<T>(self: Queue<T>): ()
	self._first = 1
	self._last = 0
	self._data = {}
end

--- @within Queue
--- Return the front item.
function Queue.front<T>(self: Queue<T>): T?
    return self._data[self._first]
end

--- @within Queue
--- Return the back item.
function Queue.back<T>(self: Queue<T>): T?
    return self._data[self._last]
end

--- @within Queue
function Queue.__len<T>(self: Queue<T>): number
    return self._last - self._first + 1
end

--- @within Queue
function Queue.iter<T>(self: Queue<T>): () -> T
    return coroutine.wrap(function()
        while self._first <= self._last do
            coroutine.yield(self:pop() :: T)
        end
    end)
end

--- @within Queue
Queue.__iter = Queue.iter

return {
    new = new,
    fromData = fromData
}
