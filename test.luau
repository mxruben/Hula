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
    for x, y, z, v in g do
        line = line..v
        if x == g.width then
            str = '\n'..line..str
            line = ""
            if y == g.height then
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
    printGrid3D(grid)
    local region = grid:getRegion(3, 3, 1, 3, 4, 2)
    print("Region:\n--------------------")
    printGrid3D(region)

    grid:mutateRegion(4, 2, 1, 4, 4, 1, function(x, y, z, value)
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
    for x, y, v in g do
        line = line..v
        if x == g.width then
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

    print("Original grid (16x16):\n--------------------")
    printGrid2D(grid)
    print("\nNeighbors at (2, 2):\n--------------------")
    printNeighbors(grid:getNeighbors(2, 2))

    local region = grid:getRegion(2, 3, 4, 4)
    print("\nRegion:\n--------------------")
    printGrid2D(region)

    grid:mutateRegion(5, 2, 3, 2, function(x, y, value)
        if value == 'X' then
            return '#'
        else
            return '?'
        end
    end)

    print("\nMutate region:\n--------------------")
    printGrid2D(grid)
end

local function randomGrid(w, h)
    local grid = Collection.Grid2D(w, h)

    math.randomseed(os.time())

    grid:mutatePairs(function(i, v)
        return math.random()
    end)

    return grid
end

local function testDither()
    -- Create example world
    local width = 60
    local height = 60
    local world = Collection.Grid2D(width, height)
    local biome1 = {top = "~ ", mid = "X ", deep = "# "}
    local biome2 = {top = "- ", mid = "W ", deep = "@ "}
    world:fill("  ")
    for x = 1, width do
        -- Top material
        if x > width / 2 then
            world:set(x, height, biome2.top)
        else
            world:set(x, height, biome1.top)
        end
        for y = height - 1, 1, -1 do
            if y > height - 6 then
                -- Mid material
                if x > width / 2 then
                    world:set(x, y, biome2.mid)
                else
                    world:set(x, y, biome1.mid)
                end
            else
                -- Deep material
                if x > height / 2 then
                    world:set(x, y, biome2.deep)
                else
                    world:set(x, y, biome1.deep)
                end
            end
        end
    end
    --print("World:")
    --printGrid2D(world)

    -- Dither
    local range = 15
    local border = width / 2
    local ditherMatrix = randomGrid(width, height)
    local ditherVis = Collection.Grid2D(width, height)
    ditherVis:fill(". ")
    --print("Dither matrix:")
    --printGrid2D(ditherMatrix)
    world:mutateRegion(border - range, 1, range * 2, height, function(x, y, v)
        if v == "  " then return v end
        local distance = math.abs(border - x)
        --local threshold = distance / range / 2 + 0.5
        --local threshold = -0.25 * math.cos(distance / range * math.pi) + 0.75
        local threshold = (distance / range + 0.1)^0.2
        local b1
        local b2
        if x > border then
            b1 = biome2
            b2 = biome1
        else
            b1 = biome1
            b2 = biome2
        end
        if ditherMatrix:get(x, y) >= threshold then
            ditherVis:set(x, y, "# ")
            if v == b1.top then
                return b2.top
            elseif v == b1.mid then
                return b2.mid
            elseif v == b1.deep then
                return b2.deep
            end
        end
        return v
    end)
    print("Points dithered:")
    printGrid2D(ditherVis)
    print("Dithered world:")
    printGrid2D(world)
end

local function testWeightedArray()
    local arr = Collection.WeightedArray()
    arr:insert({value = "banana", weight = 100})
    arr:insert({value = "apple", weight = 50})
    arr:insert({value = "orange", weight = 10})
    local results = {banana = 0, apple = 0, orange = 0}
    local output = ""
    for _ = 1, 20 do
        local result = arr:random()
        results[result] += 1
        output ..= result..", "
    end
    output = string.sub(output, 1, string.len(output) - 2)
    print("WeightedArray:\n--------------------")
    print(output)
    print("Bananas: "..results.banana)
    print("Apples: "..results.apple)
    print("Oranges: "..results.orange)
end

testWeightedArray()
--testGrid2D()
--testGrid3D()
--testDither()