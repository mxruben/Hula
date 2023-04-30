local Collection = require("Source/Collection")
--local Memory = require("Memory")
--local Thread = require("Thread")

-- TODO: Add proper tests

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

local function testWeightedArray()
    local arr = Collection.WeightedArray()
    arr:insert({value = "banana", weight = 100})
    arr:insert({value = "apple", weight = 50})
    arr:insert({value = "orange", weight = 10})
    local results = {banana = 0, apple = 0, orange = 0}
    local output = ""
    for _ = 1, 10 do
        local result = arr:random()
        results[result] += 1
        output ..= result..", "
    end
    output = string.sub(output, 1, string.len(output) - 2)
    print("WeightedArray:\n--------------------")
    print(output)
    print(`Bananas: {results.banana}`)
    print(`Apples: {results.apple}`)
    print(`Oranges: {results.orange}`)
end

local function testQueue()
    local q = Collection.Queue()
    assert(q:isEmpty(), "Queue isEmpty() failed")
    q:push(1)
    assert(not q:isEmpty(), "Queue isEmpty() failed")
    q:push(2)
    q:push(3)
    q:push(4)
    q:push(5)
    q:push(6)
    print(q:pop())
    for i in q do
        print(i)
    end
end

local function testStack()
    local stack = Collection.Stack()
    assert(stack:isEmpty(), "Stack isEmpty() failed")
    stack:push("cheese")
    assert(not stack:isEmpty(), "Stack isEmpty() failed")
    stack:push("tortilla")
    stack:push("potato")
    stack:push("meat")
    print(stack:pop())
    for i in stack do
        print(i)
    end
end

local function testPriorityQueue()
    local pq = Collection.PriorityQueue()

    pq:put("durian", 5)
    pq:put("lemon", 6)
    pq:put("apple", 1)
    pq:put("banana", 1)
    pq:put("orange", 3)

    for i, p in pq do
        print(i, p)
    end
end

testPriorityQueue()
--testStack()
--testQueue()
--testWeightedArray()
--testGrid2D()
--testGrid3D()