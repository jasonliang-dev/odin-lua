package luajit

import "core:c"

LUA_NUMBER :: f64
LUA_INTEGER :: i64
LUA_IDSIZE :: 60
LUAL_BUFFERSIZE :: 16 * size_of(rawptr) * size_of(Number)
