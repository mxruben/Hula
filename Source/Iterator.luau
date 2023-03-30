local Iterator = {}

-- Iterates over a range of numbers from i to j, top inclusive
-- Example usage: for i in range(1, 10) do print(i) end
function Iterator.range(i: number, j: number)
    if i < j then
        i -= 1
        return function()
            i += 1
            if i > j then
                return
            end
            return i
        end
    else
        i += 1
        return function()
            i -= 1
            if i < j then
                return
            end
            return i
        end
    end
end

return Iterator