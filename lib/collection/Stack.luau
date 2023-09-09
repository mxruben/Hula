--!strict
--!native
local Stack = {}
Stack.__index = Stack

export type Stack<T> = typeof(setmetatable({} :: {
	_data: {T},
	_top: number
}, Stack))

-- Constructor
local function new<T>(): Stack<T>
    local self = {
        _data = {},
        _top = 0
    }

    setmetatable(self, Stack)

    return self
end

function Stack.push<T>(self: Stack<T>, value: T): ()
	self._top += 1
	self._data[self._top] = value
end

function Stack.pop<T>(self: Stack<T>): T?
	if self._top <= 0 then return nil end
	local value = self._data[self._top]
	self._data[self._top] = nil
	self._top -= 1
	return value
end

function Stack.isEmpty<T>(self: Stack<T>): boolean
	return self._top <= 0
end

function Stack.__len<T>(self: Stack<T>): number
    return self._top
end

return {
    new = new
}