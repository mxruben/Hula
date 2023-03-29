local class = require("Lib/30log")

local Iterator = {}

-- Iterates over a range of numbers from i to j, top inclusive
-- Example usage: for i in Range(1, 10) do print(i) end
Iterator.Range = class("RangeIterator")

function Iterator.Range:init(i: number, j: number)
    self.i = i
    self.j = j
end

function Iterator.Range:__iter()
    if self.i < self.j then
        self.i -= 1
        return function()
            self.i += 1
            if self.i > self.j then
                return
            end
            return self.i
        end
    else
        self.i += 1
        return function()
            self.i -= 1
            if self.i < self.j then
                return
            end
            return self.i
        end
    end
    
end

return Iterator