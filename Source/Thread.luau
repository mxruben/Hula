local Thread = {}

Thread.Yielder = {}
Thread.Yielder.__index = Thread.Yielder

-- Constructor
function Thread.Yielder.new(budget: number?)
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

-- Constructor
function Thread.Timer.new()
    local self = {
        _start = 0,
        _elapsed = 0,
        stopped = true
    }

    setmetatable(self, Thread.Timer)

    return self
end

function Thread.Timer:_updateElapsed(): ()
	if not self.stopped then
		self._elapsed = self._elapsed + os.clock() - self._start
		self._start = os.clock()
	end
end

function Thread.Timer:stop(): ()
	self:_updateElapsed()
	self.stopped = true
end

function Thread.Timer:start(): ()
	self.stopped = false
	self._start = os.clock()
end

function Thread.Timer:elapsed(): number
	self:_updateElapsed()
	return self._elapsed
end

function Thread.Timer:reset(): ()
	self._elapsed = 0
	self._start = os.clock()
end

return Thread