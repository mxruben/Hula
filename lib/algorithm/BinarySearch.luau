--!strict
--!native
local Types = require("lib/Types")

local BinarySearch = {}

--[[ Type intersections are broken with metamethods
--   On hold until fixed
function BinarySearch.find<T>(array: {T & Types.Comparable}, value: T & Types.Comparable, low: number?, high: number?): T?
    local low = low or 1
    local high = high or #array
    while low <= high do
        local mid = math.floor((low + high) / 2)
        if array[mid] > value then high = mid - 1 end
    end
    return nil
end
]]

return BinarySearch