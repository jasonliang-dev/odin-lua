⚠️ Odin now has Lua in the vendor library collection. https://github.com/odin-lang/Odin/tree/master/vendor/lua

# odin-lua

Lua 5.4.4 and LuaJIT bindings for the Odin programming language.

```odin
// main.odin

import lua "shared:luajit"
import "shared:luajit/luaL"
import "shared:luajit/lualib"
import "shared:luajit/luajit"

main :: proc() {
  L := luaL.newstate()
  defer lua.close(L)

  luajit.VERSION_SYM()
  lualib.openlibs(L)

  luaL.dofile(L, "main.lua")
}
```

```lua
-- main.lua

local ffi = require "ffi"
local c = ffi.C

ffi.cdef [[
  int printf(const char *fmt, ...);
  int MessageBoxA(void *hwnd, const char *text, const char *caption, int type);
]]

io.write "what is your name? "
local name = io.read()

c.printf("hello %s!\n", name)
c.MessageBoxA(nil, "hello " .. name .. "!", "Message", 0)
```

## Install

Copy the `lua` or `luajit` directory to a sutable location:

```sh
git clone https://github.com/jasonliang-dev/odin-lua.git

cp -R odin-lua/lua /path/to/Odin/shared
# or
cp -R odin-lua/lua /path/to/your/project
```

If you're using LuaJIT on Windows, you'll need to copy `luajit/lua51.dll` and
put it in the same location as your executable.

## Building library files

This repo has prebuilt `.lib`, `.dll`, `.a`, and `.so` files for Windows and
Linux. Follow the instructions below if you want to build these files on your
own.

### Lua

Lua's GitHub mirror has a file `onelua.c` which includes all other source
files. Get the [latest release](https://github.com/lua/lua/releases), then:

```sh
# windows
cl /DMAKE_LIB /c /O2 onelua.c
lib onelua.obj /out:lua54.lib

# linux
clang -DMAKE_LIB -DLUA_USE_LINUX -c -O2 onelua.c
ar rcs liblua54.a onelua.o
```

### LuaJIT

Get the source with `git clone https://luajit.org/git/luajit.git`, then:

```sh
# windows
cd src
msvcbuild.bat # produces lua51.lib and lua51.dll

# linux
make # produces libluajit.a and libluajit.so
```

## Differences from C

This library tries to be pretty close to the Lua C API, but there are a few
notable differences:

- Functions recieve Lua state by value and not by pointer. Lua state is
  defined as `State :: distinct rawptr`.

  > A better name would've been `StateHandle`. `State` is shorter. Done out of
    laziness.
- The `lua`, `luaopen`, and `luaL` prefixes are trimmed off. Types and
  functions are namespaced by package name.
- Names from `luaconf.h` keeps their prefixes
- Since `where` is a keyword in Odin, you'll have to type `luaL.luaL_where`
- `newlib` and `newlibtable` (5.4 only, not in LuaJIT) takes a slice instead
  of a c style array
