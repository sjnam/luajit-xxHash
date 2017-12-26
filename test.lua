
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

   assert(y == z)

   print(xh:canonicalFromHash())

   assert(x == tostring(xh:hashFromCanonical()))

   xh:free()
end


-- 32-bit
print("32-bit")
test(require"lib.xxhash32")

-- 64-bit
print("\n64-bit")
test(require"lib.xxhash64")
