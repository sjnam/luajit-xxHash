
-- xxHash ffi bounding
-- Written by Soojin Nam. Public Domain.


local ffi = require "ffi"

local C = ffi.C
local ffi_str = ffi.string
local ffi_new = ffi.new
local ffi_typeof = ffi.typeof
local tostring = tostring
local sformat = string.format
local setmetatable = setmetatable


ffi.cdef[[
int sprintf(char *str, const char *format, ...);

unsigned XXH_versionNumber (void);
typedef enum { XXH_OK=0, XXH_ERROR } XXH_errorcode;

/* 32-bit hash */
typedef unsigned int XXH32_hash_t;
XXH32_hash_t XXH32 (const void* input, size_t length, unsigned int seed);

/*======   Streaming   ======*/
typedef struct XXH32_state_s XXH32_state_t;   /* incomplete type */
XXH32_state_t* XXH32_createState(void);
XXH_errorcode  XXH32_freeState(XXH32_state_t* statePtr);
void XXH32_copyState(XXH32_state_t* dst_state, const XXH32_state_t* src_state);
XXH_errorcode XXH32_reset  (XXH32_state_t* statePtr, unsigned int seed);
XXH_errorcode XXH32_update (XXH32_state_t* statePtr, const void* input, size_t length);
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


/* 64-bit hash */
typedef unsigned long long XXH64_hash_t;
XXH64_hash_t XXH64 (const void* input, size_t length, unsigned long long seed);

/*======   Streaming   ======*/
typedef struct XXH64_state_s XXH64_state_t;   /* incomplete type */
XXH64_state_t* XXH64_createState(void);
XXH_errorcode XXH64_freeState(XXH64_state_t* statePtr);
void XXH64_copyState(XXH64_state_t* dst_state, const XXH64_state_t* src_state);
XXH_errorcode XXH64_reset  (XXH64_state_t* statePtr, unsigned long long seed);
XXH_errorcode XXH64_update (XXH64_state_t* statePtr, const void* input, size_t length);
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


-- 32-bit hash

local _xxhash32 = {}


local canonical32_t = ffi_typeof("XXH32_canonical_t[1]")


local function reset (self)
   return xxhash.XXH32_reset(self._state, self.seed)
end

_xxhash32.reset = reset


function _xxhash32:new (seed)
   local obj = {
      seed = seed or 0,
      _state = xxhash.XXH32_createState(),
   }
   reset(obj)
   setmetatable(obj, self)
   self.__index = self
   return obj
end


function _xxhash32:update (input)
   return xxhash.XXH32_update(self._state, input, #input)
end


function _xxhash32:digest ()
   self._hash = xxhash.XXH32_digest(self._state)
   return tostring(self._hash)
end


function _xxhash32:canonicalFromHash (hash)
   local dst = ffi_new(canonical32_t)
   xxhash.XXH32_canonicalFromHash(dst, hash or self._hash)
   self._dst = dst
   local digest = dst[0].digest
   return sformat("%02x", digest[0])..sformat("%02x", digest[1])
      ..sformat("%02x", digest[2])..sformat("%02x", digest[3])
end


function _xxhash32:hashFromCanonical (src)
   return tostring(xxhash.XXH32_hashFromCanonical(src or self._dst))
end


function _xxhash32:free ()
   xxhash.XXH32_freeState(self._state)
end


-- 64-bit hash

local _xxhash64 = {}


local canonical64_t = ffi_typeof("XXH64_canonical_t[1]")


local function _ull (n)
   local tmp = ffi.new("char[64]")
   C.sprintf(tmp, "%llu", n)
   return ffi_str(tmp)
end


local function reset (self)
   return _ull(xxhash.XXH64_reset(self._state, self.seed))
end

_xxhash64.reset = reset


function _xxhash64:new (seed)
   local obj = {
      seed = seed or 0,
      _state = xxhash.XXH64_createState(),
   }
   reset(obj)
   setmetatable(obj, self)
   self.__index = self
   return obj
end


function _xxhash64:update (input)
   return xxhash.XXH64_update(self._state, input, #input)
end


function _xxhash64:digest ()
   self._hash = xxhash.XXH64_digest(self._state)
   return _ull(self._hash)
end


function _xxhash64:canonicalFromHash (hash)
   local dst = ffi_new(canonical64_t)
   xxhash.XXH64_canonicalFromHash(dst, hash or self._hash)
   self._dst = dst
   local digest = dst[0].digest
   return sformat("%02x", digest[0])..sformat("%02x", digest[1])
      ..sformat("%02x", digest[2])..sformat("%02x", digest[3])
      ..sformat("%02x", digest[4])..sformat("%02x", digest[5])
      ..sformat("%02x", digest[6])..sformat("%02x", digest[7])
end


function _xxhash64:hashFromCanonical (src)
   return _ull(xxhash.XXH64_hashFromCanonical(src or self._dst))
end


function _xxhash64:free ()
   xxhash.XXH64_freeState(self._state)
end


-- xxhash

local _M = {
   _VERSION = '0.1.5',
   [32] = _xxhash32,
   [64] = _xxhash64,
}


function _M.version ()
   return xxhash.XXH_versionNumber()
end


function _M.xxh32 (input, seed)
   return tostring(xxhash.XXH32(input, #input, seed or 0))
end


function _M.xxh64 (input, seed)
   return _ull(xxhash.XXH64(input, #input, seed or 0))
end


function _M.new (bits, seed)
   if bits ~= 32 and bits ~= 64 then
      seed = bits
      bits = 32
   end
   return _M[bits]:new(seed)
end


return _M
