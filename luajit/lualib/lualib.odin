package lua_lualib

import "core:c"
import lua ".."

when ODIN_OS == .Windows {
	foreign import lua51 "../lua51.lib"
} else when ODIN_OS == .Linux {
	foreign import lua51 "../libluajit.a"
}

FILEHANDLE :: "FILE*"

COLIBNAME :: "coroutine"
MATHLIBNAME :: "math"
STRLIBNAME :: "string"
TABLIBNAME :: "table"
IOLIBNAME :: "io"
OSLIBNAME :: "os"
LOADLIBNAME :: "package"
DBLIBNAME :: "debug"
BITLIBNAME :: "bit"
JITLIBNAME :: "jit"
FFILIBNAME :: "ffi"

@(default_calling_convention = "c", link_prefix = "lua")
foreign lua51 {
	open_base :: proc(L: lua.State) -> c.int ---
	open_math :: proc(L: lua.State) -> c.int ---
	open_string :: proc(L: lua.State) -> c.int ---
	open_table :: proc(L: lua.State) -> c.int ---
	open_io :: proc(L: lua.State) -> c.int ---
	open_os :: proc(L: lua.State) -> c.int ---
	open_package :: proc(L: lua.State) -> c.int ---
	open_debug :: proc(L: lua.State) -> c.int ---
	open_bit :: proc(L: lua.State) -> c.int ---
	open_jit :: proc(L: lua.State) -> c.int ---
	open_ffi :: proc(L: lua.State) -> c.int ---
	open_string_buffer :: proc(L: lua.State) -> c.int ---
}

@(default_calling_convention = "c", link_prefix = "luaL_")
foreign lua51 {
	openlibs :: proc(L: lua.State) ---
}
