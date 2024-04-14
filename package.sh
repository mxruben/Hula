# roblox luau
darklua process lib package/roblox/lib -c roblox.darklua.json
darklua process package/roblox/lib package/roblox/lib -c copyright.darklua.json
mv package/roblox/lib/Hula.luau package/roblox/lib/init.luau
sed -i -e 's/.Parent//g' package/roblox/lib/init.luau
cp wally.toml package/roblox/wally.toml
cp LICENSE package/roblox/LICENSE
cp README.md package/roblox/README.md
cp default.project.json package/roblox/default.project.json

# vanilla luau
darklua process lib package/luau/lib -c copyright.darklua.json
cp LICENSE package/luau/LICENSE
cp README.md package/luau/README.md
# remove roblox-specific yielder
rm package/luau/lib/Yielder.luau
sed -i -e 's/Yielder = require("lib\/Yielder"),//g' package/luau/lib/Hula.luau
