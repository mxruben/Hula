--!strict
--!native

--- @class Timer
--- Timer objects are used to measure time.
local Timer = {}
Timer.__index = Timer

--- @prop _start number
--- @within Timer
--- @ignore
--- The time that the timer was started.

--- @prop _elapsed number
--- @within Timer
--- @ignore
--- Time passed. Added to when the timer is stopped and when the elapsed() method
--- is called.

--- @prop stopped boolean
--- @within Timer
--- @readonly
--- Indicates if the timer is counting time.

type Timer = typeof(setmetatable(
	{} :: {
		_start: number,
		_elapsed: number,
		stopped: boolean,
	},
	Timer
))
export type Type = Timer

--- @within Timer
--- Creates a new timer object. Note that it starts stopped.
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

--- @within Timer
--- Stops the timer. Does not reset the elapsed time.
function Timer:stop(): ()
	_timerUpdateElapsed(self)
	self.stopped = true
end

--- @within Timer
--- Starts the timer.
function Timer:start(): ()
	self.stopped = false
	self._start = os.clock()
end

--- @within Timer
--- Returns the elapsed time.
function Timer:elapsed(): number
	_timerUpdateElapsed(self)
	return self._elapsed
end

--- @within Timer
--- Resets the elapsed time. Does not stop the timer.
function Timer:reset(): ()
	self._elapsed = 0
	self._start = os.clock()
end

return {
    new = new
}
