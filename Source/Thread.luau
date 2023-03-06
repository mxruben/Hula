local class = require("Lib/30log")

local Thread = {}

Thread.Yielder = class("Yielder", {_expire = 0, _budget = 1/60})

function Thread.Yielder:init(budget)
	self._budget = budget
	self._expire = self:reset()
end

function Thread.Yielder:reset()
	self._expire = os.clock() + self._budget
end

function Thread.Yielder:maybe()
	if os.clock() >= self._expire then
		task.wait()
		self:reset()
	end
end

Thread.Timer = class("Timer", {_start = 0, _elapsed = 0, stopped = true})

function Thread.Timer:_updateElapsed()
	if not self.stopped then
		self._elapsed = self._elapsed + os.clock() - self._start
		self._start = os.clock()
	end
end

function Thread.Timer:stop()
	self:_updateElapsed()
	self.stopped = true
end

function Thread.Timer:start()
	self.stopped = false
	self._start = os.clock()
end

function Thread.Timer:elapsed()
	self:_updateElapsed()
	return self._elapsed
end

function Thread.Timer:reset()
	self._elapsed = 0
	self._start = os.clock()
end

return Thread