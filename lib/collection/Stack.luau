--!strict
--!native

--- @class Stack
--- Last in, first out data structure.
local Stack = {}
Stack.__index = Stack

--- @prop _data {T}
--- @within Stack
--- @ignore

--- @prop size number
--- @within Stack
--- @readonly

type Stack<T> = typeof(setmetatable({} :: {
	_data: {T},
	size: number
}, Stack))
export type Type<T> = Stack<T>

--- @within Stack
--- Creates a new stack.
local function new<T>(): Stack<T>
    local self = {
        _data = {},
        size = 0
    }

    setmetatable(self, Stack)

    return self
end

--- @within Stack
--- Pushes an item onto the top of the stack.
function Stack.push<T>(self: Stack<T>, value: T): ()
	self.size += 1
	self._data[self.size] = value
end

--- @within Stack
--- Pops an item from the top of the stack.
function Stack.pop<T>(self: Stack<T>): T?
	if self.size <= 0 then return nil end
	local value = self._data[self.size]
	self._data[self.size] = nil
	self.size -= 1
	return value
end

--- @within Stack
function Stack.isEmpty<T>(self: Stack<T>): boolean
	return self.size <= 0
end

--- @within Stack
function Stack.__len<T>(self: Stack<T>): number
    return self.size
end

return {
    new = new
}
