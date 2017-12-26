
local ffi = require "ffi"

local ffi_new = ffi.new
local ffi_typeof = ffi.typeof
local tostring = tostring
local tconcat = table.concat
local sformat = string.format
local setmetatable = setmetatable


ffi.cdef[[
unsigned XXH_versionNumber (void);

/* 32-bit hash */
typedef unsigned int XXH32_hash_t;
XXH32_hash_t XXH32 (const void* input, size_t length, unsigned int seed);

/*======   Streaming   ======*/
typedef struct XXH32_state_s XXH32_state_t;   /* incomplete type */
XXH32_state_t* XXH32_createState(void);
int  XXH32_freeState(XXH32_state_t* statePtr);
void XXH32_copyState(XXH32_state_t* dst_state, const XXH32_state_t* src_state);
int XXH32_reset  (XXH32_state_t* statePtr, unsigned int seed);
int XXH32_update (XXH32_state_t* statePtr, const void* input, size_t length);
XXH32_hash_t  XXH32_digest (const XXH32_state_t* statePtr);

/*======   Canonical representation   ======*/
typedef struct { unsigned char digest[4]; } XXH32_canonical_t;
void XXH32_canonicalFromHash(XXH32_canonical_t* dst, XXH32_hash_t hash);
XXH32_hash_t XXH32_hashFromCanonical(const XXH32_canonical_t* src);

struct XXH32_state_s {
   unsigned total_len_32;
   unsigned large_len;
   unsigned v1;
   unsigned v2;
   unsigned v3;
   unsigned v4;
   unsigned mem32[4];   /* buffer defined as U32 for alignment */
   unsigned memsize;
   unsigned reserved;   /* never read nor write, will be removed in a future version */
};   /* typedef'd to XXH32_state_t */
]]


local xxhash = ffi.load "xxhash"


local _M = {}

local mt = { __index = _M }


local canonical_t = ffi_typeof("XXH32_canonical_t[1]")


function _M.version (self)
   return xxhash.XXH_versionNumber()
end


-- 32-bit hash

function _M.xxh (input, seed)
   return tostring(xxhash.XXH32(input, #input, seed or 0))
end


local function reset (self)
   return xxhash.XXH32_reset(self._state, self.seed)
end

_M.reset = reset


function _M.new (seed)
   local obj = {
      seed = seed or 0,
      _state = xxhash.XXH32_createState(),
      _hash = nil, 
   }
   reset(obj)
   
   return setmetatable(obj, mt)
end


function _M.update (self, input)
   return xxhash.XXH32_update(self._state, input, #input)
end


function _M.digest (self)
   self._hash = xxhash.XXH32_digest(self._state)
   return tostring(self._hash)
end


function _M.canonicalFromHash (self, hash)
   local dst = ffi_new(canonical_t)
   xxhash.XXH32_canonicalFromHash(dst, hash or self._hash)
   local str = {}
   local digest = dst[0].digest
   for i=0,3 do
      str[#str+1] = sformat("%02x", digest[i]) 
   end
   self._dst = dst
   
   return tconcat(str)
end


function _M.hashFromCanonical (self, src)
   return tostring(xxhash.XXH32_hashFromCanonical(src or self._dst))
end


function _M.free (self)
   xxhash.XXH32_freeState(self._state)
end

return _M
