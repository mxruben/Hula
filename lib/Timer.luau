--!strict
--!native

local Timer = {}
Timer.__index = Timer

export type Timer = typeof(setmetatable(
	{} :: {
		_start: number,
		_elapsed: number,
		stopped: boolean,
	},
	Timer
))

-- Constructor
local function new(): Timer
	local self = {
		_start = 0,
		_elapsed = 0,
		stopped = true,
	}

	setmetatable(self, Timer)

	return self
end

local function _timerUpdateElapsed(self: Timer): ()
	if not self.stopped then
		local time = os.clock()
		self._elapsed = self._elapsed + time - self._start
		self._start = time
	end
end

function Timer:stop(): ()
	_timerUpdateElapsed(self)
	self.stopped = true
end

function Timer:start(): ()
	self.stopped = false
	self._start = os.clock()
end

function Timer:elapsed(): number
	_timerUpdateElapsed(self)
	return self._elapsed
end

function Timer:reset(): ()
	self._elapsed = 0
	self._start = os.clock()
end

return {
    new = new
}
