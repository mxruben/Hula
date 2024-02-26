local Grid2D = require("lib/collection/Grid2D")

local test = {}

test.name = "Grid2D"

function test.run(): (boolean, string?)
    local grid = Grid2D.new(5, 5, 0)

    local data = table.create(25, 0)
    local grid2 = Grid2D.fromData(5, 5, data)

    if grid._data == table.create(25, 0) then
        return false, debug.traceback("constructor failed")
    end

    return true
end

return test
