--!strict
--!native

local Yielder = {}
Yielder.__index = Yielder

export type Yielder = typeof(setmetatable(
	{} :: {
		_budget: number,
		_expire: number,
	},
	Yielder
))

-- Constructor
local function new(budget: number?): Yielder
	local self = {
		_budget = budget or 1 / 60,
		_expire = 0,
	}

	setmetatable(self, Yielder)

	self:reset()

	return self
end

function Yielder:reset(): ()
	self._expire = os.clock() + self._budget
end

function Yielder:maybe(): ()
	if os.clock() >= self._expire then
		task.wait()
		self:reset()
	end
end

return {
	new = new,
}
