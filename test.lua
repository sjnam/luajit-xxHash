
local function test (xxhash)
   print("version number:", xxhash.version())

   local x = xxhash.xxh('abc')
   print(x)

   local xh = xxhash.new()
   xh:update('abc');
   local y = xh:digest()
   print(y)

   assert(x == y)

   xh:reset()

   xh:update('a')
   xh:update('bc')
   local z = xh:digest()
   print(z)

   assert(x == z)

   print(xh:canonicalFromHash())

   assert(x == xh:hashFromCanonical())

   xh:free()
end


local xxhash

-- 32-bit
print("32-bit")
xxhash = require "lib.xxhash32"
test(xxhash)

-- 64-bit
print("\n64-bit")
xxhash = require "lib.xxhash64"
test(xxhash)
