local tests = {
    require("tests/collection/Grid2D.test")
}

for _, test in tests do
    local success, err = test.run()

    if success then
        print(`{test.name} passed`)
    else
        print(`{test.name} failed: {err}`)
    end
end
