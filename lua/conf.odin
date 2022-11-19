package lua

import "core:c"

LUA_NUMBER :: f64
LUA_UNSIGNED :: u64
LUA_INTEGER :: i64
LUA_KCONTEXT :: c.ptrdiff_t
LUAI_MAXSTACK :: 1000000
LUA_EXTRASPACE :: size_of(rawptr)
LUA_IDSIZE :: 60
LUAL_BUFFERSIZE :: 16 * size_of(rawptr) * size_of(Number)
LUAI_MAXALIGN :: max(
	align_of(Number),
	align_of(f64),
	align_of(rawptr),
	align_of(Integer),
	align_of(c.long),
)

// support deprecated int conversion
LUA_COMPAT_APIINTCASTS :: true
