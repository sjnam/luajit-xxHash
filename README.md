# luajit-xxHash
luajit version for [xxHash](http://cyan4973.github.io/xxHash/)

Installation
============
To install `luajit-xxHash` you need to install
[xxHash](https://github.com/Cyan4973/xxHash)
with shared libraries firtst.
Then you can install `luajit-xxHash` by placing `xxhash{32,64}.lua` to
your lua library path.

Usage
=====
```lua

-- 32-bit
print("32-bit")

local xxhash = require "xxhash32"

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

xxhash = require "xxhash64"

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

```
