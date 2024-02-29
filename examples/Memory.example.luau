--!strict
local Memory = require("lib/Memory")

do
    print(`Table '\{"tomato", 2, true}' is deep: {Memory.isDeep({"tomato", 2, true})}`)
    print(`Table '\{"tomato", 2, true numbers = \{3, 2, 5}}' is deep: {Memory.isDeep({"tomato", 2, true, numbers = {3, 2, 5}})}`)
end
