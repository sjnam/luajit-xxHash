
-- 32-bit
print("32-bit")

local xxhash = require "lib.xxhash32"

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
print("\n64-bit")

xxhash = require "lib.xxhash64"

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
