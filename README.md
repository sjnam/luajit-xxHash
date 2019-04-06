# luajit-xxHash
luajit version for [xxHash](http://cyan4973.github.io/xxHash/)

Installation
============
To install `luajit-xxHash` you need to install
[xxHash](https://github.com/Cyan4973/xxHash)
with shared libraries firtst.
Then you can install `luajit-xxHash` by placing `lib/resty/xxhash.lua` to
your lua library path.

Synopsis
========
```lua
local xxhash = require "xxhash"

local f = assert(io.open(filename, r))
local t = f:read("*all")
local x = xxhash.xxh64(t)
print(x)

-- goto start position of the file
f:seek("set", 0)

local xxh = xxhash.new(64)

while true do
   local lines, rest = f:read(1024, "*line")
   if not lines then break end
   if rest then lines = lines .. rest .. "\n" end
   xxh:update(lines)
end
local y = xxh:digest()
print(y)
print("canonical form: ", xxh:canonicalFromHash())

-- check
assert(x == y)

xxh:free()

f:close()
```

Methods
=======

xx32
----
`syntax: xxhash.xx32(input, seed?)`

xx64
----
`syntax: xxhash.xx32(input, seed?)`

new
---
`syntax: xxh, err = xxhash.new(bits, seed?)`

Creates a xxhash object. 

update
------
`syntax: xxh:update(input)`

digest
------
`syntax: s = xxh:digest()`

canonicalFromHash
-----------------
`syntax: xxh:canonicalFromHash()`

The canonical representation uses human-readable write convention,
aka big-endian (large digits first).

free
----
`syntax: xxh:free()`

Author
======
Soojin Nam jsunam@gmail.com

License
=======
Public Domain
