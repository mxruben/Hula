--!strict
local Thread = {}

Thread.Yielder = {}
Thread.Yielder.__index = Thread.Yielder

export type Yielder = typeof(setmetatable({} :: {
	_budget: number,
	_expire: number
}, Thread.Yielder))

-- Constructor
function Thread.Yielder.new(budget: number?): Yielder
    local self = {
        _budget = budget or 1/60,
        _expire = 0
    }

    setmetatable(self, Thread.Yielder)

	self:reset()

    return self
end

function Thread.Yielder:reset(): ()
	self._expire = os.clock() + self._budget
end

function Thread.Yielder:maybe(): ()
	if os.clock() >= self._expire then
		task.wait()
		self:reset()
	end
end

Thread.Timer = {}
Thread.Timer.__index = Thread.Timer

export type Timer = typeof(setmetatable({} :: {
	_start: number,
	_elapsed: number,
	stopped: boolean
}, Thread.Timer))

-- Constructor
function Thread.Timer.new(): Timer
    local self = {
        _start = 0,
        _elapsed = 0,
        stopped = true
    }

    setmetatable(self, Thread.Timer)

    return self
end

local function _timerUpdateElapsed(self: Timer): ()
	if not self.stopped then
		local time = os.clock()
		self._elapsed = self._elapsed + time - self._start
		self._start = time
	end
end

function Thread.Timer:stop(): ()
	_timerUpdateElapsed(self)
	self.stopped = true
end

function Thread.Timer:start(): ()
	self.stopped = false
	self._start = os.clock()
end

function Thread.Timer:elapsed(): number
	_timerUpdateElapsed(self)
	return self._elapsed
end

function Thread.Timer:reset(): ()
	self._elapsed = 0
	self._start = os.clock()
end

return Thread