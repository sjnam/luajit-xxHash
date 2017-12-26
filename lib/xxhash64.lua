
local ffi = require "ffi"

local C = ffi.C
local ffi_str = ffi.string
local ffi_new = ffi.new
local ffi_typeof = ffi.typeof
local tconcat = table.concat
local sformat = string.format
local setmetatable = setmetatable


ffi.cdef[[
int sprintf(char *str, const char *format, ...);

unsigned XXH_versionNumber (void);

/* 64-bit hash */
typedef unsigned long long XXH64_hash_t;
XXH64_hash_t XXH64 (const void* input, size_t length, unsigned long long seed);

/*======   Streaming   ======*/
typedef struct XXH64_state_s XXH64_state_t;   /* incomplete type */
XXH64_state_t* XXH64_createState(void);
int XXH64_freeState(XXH64_state_t* statePtr);
void XXH64_copyState(XXH64_state_t* dst_state, const XXH64_state_t* src_state);
int XXH64_reset  (XXH64_state_t* statePtr, unsigned long long seed);
int XXH64_update (XXH64_state_t* statePtr, const void* input, size_t length);
XXH64_hash_t  XXH64_digest (const XXH64_state_t* statePtr);

/*======   Canonical representation   ======*/
typedef struct { unsigned char digest[8]; } XXH64_canonical_t;
void XXH64_canonicalFromHash(XXH64_canonical_t* dst, XXH64_hash_t hash);
XXH64_hash_t XXH64_hashFromCanonical(const XXH64_canonical_t* src);

struct XXH64_state_s {
   unsigned long long total_len;
   unsigned long long v1;
   unsigned long long v2;
   unsigned long long v3;
   unsigned long long v4;
   unsigned long long mem64[4];   /* buffer defined as U64 for alignment */
   unsigned memsize;
   unsigned reserved[2];          /* never read nor write, will be removed in a future version */
};   /* typedef'd to XXH64_state_t */
]]


local xxhash = ffi.load "xxhash"


local _M = {}

local mt = { __index = _M }


local canonical_t = ffi_typeof("XXH64_canonical_t[1]")


function _M.version (self)
   return xxhash.XXH_versionNumber()
end


-- 64-bit hash

local function _ull (n)
   local tmp = ffi.new("char[64]")
   C.sprintf(tmp, "%llu", n)
   return ffi_str(tmp)
end

function _M.xxh (input, seed)
   return _ull(xxhash.XXH64(input, #input, seed or 0))
end


local function reset (self)
   return _ull(xxhash.XXH64_reset(self._state, self.seed))
end

_M.reset = reset


function _M.new (seed)
   local obj = {
      seed = seed or 0,
      _state = xxhash.XXH64_createState(),
   }
   reset(obj)
   
   return setmetatable(obj, mt)
end


function _M.update (self, input)
   return xxhash.XXH64_update(self._state, input, #input)
end


function _M.digest (self)
   self._hash = xxhash.XXH64_digest(self._state)
   return _ull(self._hash)
end


function _M.canonicalFromHash (self, hash)
   local dst = ffi_new(canonical_t)
   xxhash.XXH64_canonicalFromHash(dst, hash or self._hash)
   local str = {}
   local digest = dst[0].digest
   for i=0,7 do
      str[#str+1] = sformat("%02x", digest[i]) 
   end
   self._dst = dst
   
   return tconcat(str)
end


function _M.hashFromCanonical (self, src)
   return _ull(xxhash.XXH64_hashFromCanonical(src or self._dst))
end


function _M.free (self)
   xxhash.XXH64_freeState(self._state)
end


return _M
