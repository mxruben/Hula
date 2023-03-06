local Collection = require("Source/Collection")
--local Memory = require("Memory")
--local Thread = require("Thread")

local function printGrid3D(g)
    local str = ""
    local line = ""
    for i, v in g:iteratePairs() do
        line = line..v
        if i % g.width == 0 then
            str = '\n'..line..str
            line = ""
            if i % (g.width * g.height) == 0 then
                str = '\n'..str
            end
        end
    end
    print(str)
end

local grid = Collection.Grid3D(8, 8, 4)

grid:mutatePairs(function(i, v)
    return tostring(i)..' '

    --[[
    if i % 2 == 0 then
        return '#'
    else
        return ' '
    end
    ]]
end)

printGrid3D(grid)
--[[
function printGrid(g)
    local str = ""
    local line = ""
    for i, v in g:iteratePairs() do
        line = line..v
        if i % g.width == 0 then
            str = '\n'..line..str
            line = ""
        end
    end
    print(str)
end

local grid = Collection.Grid2D(16, 16)
grid:mutatePairs(function(i, v)
    if math.sin(i) > 0.5 then
        return 'X'
    else
        return '.'
    end
end)

printGrid(grid)

grid:mutateRegion(2, 2, 10, 10, function(x, y, value)
    if value == 'X' then
        return '#'
    else
        return '?'
    end
end)

printGrid(grid)
]]