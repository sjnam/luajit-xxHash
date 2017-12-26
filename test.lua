
local xxhash = require "xxhash32"

-- 32-bit

print("32-bit")
print(xxhash.version())
print(xxhash.xxh('abc', 0x5bd1e995))


local xh = xxhash.new(0x5bd1e995)
xh:update('abc');
local res = xh:digest()
print(res)

xh:reset()

xh:update('a')
xh:update('bc')
res = xh:digest()
print(res)

print(xh:canonicalFromHash())
print(tostring(xh:hashFromCanonical()))

xh:free()


-- 64-bit
xxhash = require "xxhash64"

print("\n64-bit")
print(xxhash.version())
print(xxhash.xxh('abc', 0x5bd1e995))

local xh = xxhash.new(0x5bd1e995)
xh:update('abc');
local res = xh:digest()
print(res)

xh:reset()

xh:update('a')
xh:update('bc')
res = xh:digest()
print(res)

print(xh:canonicalFromHash())
print(tostring(xh:hashFromCanonical()))

xh:free()
