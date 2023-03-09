local Collection = require("Source/Collection")
--local Memory = require("Memory")
--local Thread = require("Thread")

local function printNeighbors(t)
    for k, v in pairs(t) do
        print(k..": "..tostring(v))
    end
end


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

local function testGrid3D()
    local grid = Collection.Grid3D(8, 8, 2)

    grid:mutatePairs(function(i, v)
        return tostring(i)..' '
    end)
    print("Original grid:\n--------------------")
    grid:set(1, 1, 1, "# ")
    printGrid3D(grid)

    local region = grid:getRegion(3, 3, 1, 3, 4, 2)
    print("Region:\n--------------------")
    printGrid3D(region)

    grid:mutateRegion(2, 2, 1, 4, 4, 1, function(x, y, z, value)
        return '# '
    end)
    print("\nMutate region:\n--------------------")
    printGrid3D(grid)

    print("\nNeighbors at (2, 2, 2):\n--------------------")
    printNeighbors(grid:getNeighbors(2, 2, 2))
end

local function printGrid2D(g)
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

local function testGrid2D()
    local grid = Collection.Grid2D(16, 16)
    grid:mutatePairs(function(i, v)
        if math.sin(i) > 0.5 then
            return 'X'
        else
            return '.'
        end
    end)

    print("Original grid (16, 16):\n--------------------")
    printGrid2D(grid)
    print("\nNeighbors at (2, 2):\n--------------------")
    printNeighbors(grid:getNeighbors(2, 2))

    grid:mutateRegion(2, 2, 10, 10, function(x, y, value)
        if value == 'X' then
            return '#'
        else
            return '?'
        end
    end)

    print("\nMutate region from (2, 2) through (11, 11):\n--------------------")
    printGrid2D(grid)
end

--testGrid2D()
testGrid3D()