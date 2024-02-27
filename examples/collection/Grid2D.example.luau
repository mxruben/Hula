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
    
    
end
