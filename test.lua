
local function test (x, xhc)
   xhc:update('abc');
   local y = xhc:digest()
   print(y)

   assert(x == y)
   
   xhc:reset()

   xhc:update('a')
   xhc:update('b')
   xhc:update('c')
   local z = xhc:digest()
   print(z)

   assert(x == z)

   print("canonical:", xhc:canonicalFromHash())

   assert(x == xhc:hashFromCanonical())

   xhc:free()
end


local xxhash = require "lib.resty.xxhash"

print("version number:", xxhash.version())

-- 32-bit
print("32-bit")
test(xxhash.xxh32('abc'), xxhash.new(32))

-- 64-bit
print("\n64-bit")
test(xxhash.xxh64('abc'), xxhash.new(64))
