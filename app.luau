--!strict
local PriorityQueue = require("lib/collection/PriorityQueue")

local function printGrid3D(g)
    local str = ""
    local line = ""
    for x, y, z, v in g do
        line = line..(v).." "
        if x == g.width then
            str = '\n'..line..str
            line = ""
            if y == g.height then
                str = '\n'..str
            end
        end
    end
    print(str:sub(2, #str))
end

local function printGrid2D(g)
    local str = ""
    local line = ""
    for x, y, v in g do
        line = line..v.." "
        if x == g.width then
            str = '\n'..line..str
            line = ""
        end
    end
    print(str:sub(2, #str))
end