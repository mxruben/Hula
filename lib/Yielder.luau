--!strict
--!native

--- @class Yielder
--- Yields the thread if a specified amount of time has passed since the last
--- yield. This is useful if you have a long running initialization function and
--- you need to prevent script exhaustion. You should try to avoid using this
--- whenever possible.
--- @tag Roblox
local Yielder = {}
Yielder.__index = Yielder

--- @prop _budget number
--- @within Yielder
--- @ignore
--- Minimum time between yields.

--- @prop _expire number
--- @within Yielder
--- @ignore
--- Time when the next yield can happen.

export type Yielder = typeof(setmetatable(
	{} :: {
		_budget: number,
		_expire: number,
	},
	Yielder
))

--- @within Yielder
--- Creates a new yielder object.
--- @param budget -- minimum time between yields
local function new(budget: number?): Yielder
	local self = {
		_budget = budget or 1 / 60,
		_expire = 0,
	}

	setmetatable(self, Yielder)

	self:reset()

	return self
end

--- @within Yielder
--- Resets the time until the next yield.
function Yielder:reset(): ()
	self._expire = os.clock() + self._budget
end

--- @within Yielder
--- Checks if enough time has passed since the last yield, and yields if enough
--- time has passed.
--- @yields
function Yielder:maybe(): ()
	if os.clock() >= self._expire then
		task.wait()
		self:reset()
	end
end

return {
	new = new,
}
