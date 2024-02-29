--!strict
local Grid2D = require("lib/collection/Grid2D")

do
    print("Create a 4x4 grid from a table with incrementing numbers")

    local data = {}
    for i = 1, 16 do
        data[i] = i
    end

    local grid = Grid2D.fromData(4, 4, data)
    print(grid)

    print(`Value at (2, 4) is: {grid:at(2, 4)}`)
end

do
    print("Create a 5x5 grid filled with the value '0'")
    local grid = Grid2D.new(5, 5, 0)
    print(grid)

    print(`Coordinate (5, 7) is in bounds: {grid:isCoordinateInBounds(5, 7)}`)
    print(`Coordinate (2, 2) is in bounds: {grid:isCoordinateInBounds(2, 2)}`)

    print("Set (4, 2) to 3")
    grid:set(4, 2, 3)
    print(grid)

    print("Set (3, 3) to 2 with bounds checking")
    grid:setUnchecked(3, 3, 2)
    print(grid)

    do
        print("Neighbors at (3, 2)")
        local neighbors = grid:neighborsAt(3, 2)
        print(`top: {neighbors.top}\nbottom: {neighbors.bottom}\nleft: {neighbors.left}\nright: {neighbors.right}`)
    end
    do
        print("Neighbors at (5, 2)")
        local neighbors = grid:neighborsAt(5, 2)
        print(`top: {neighbors.top}\nbottom: {neighbors.bottom}\nleft: {neighbors.left}\nright: {neighbors.right}`)
    end
    do
        print("Region from (3, 2) to (4, 3)")
        local region = grid:region(3, 2, 4, 3)
        print(region)
    end

    print("Iterate over grid by reference and add 1")
    for x, y, ref in grid:iterRef() do
        ref.value += 1
    end
    print(grid)
end
