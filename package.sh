darklua process lib package/roblox/lib -c roblox.darklua.json
darklua minify package/roblox/lib package/roblox/lib
darklua process package/roblox/lib package/roblox/lib -c copyright.darklua.json
mv package/roblox/lib/Hula.luau package/roblox/lib/init.luau
cp wally.toml package/roblox/wally.toml
cp LICENSE package/roblox/LICENSE
cp README.md package/roblox/README.md

darklua minify lib package/luau/lib
darklua process package/luau/lib package/luau/lib -c copyright.darklua.json
cp LICENSE package/luau/LICENSE
cp README.md package/luau/README.md
