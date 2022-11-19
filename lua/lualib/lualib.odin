package luajit_lualib

import "core:c"
import lua ".."

foreign import lua54 "../lua54.lib"

VERSUFFIX :: "_" + lua.VERSION_MAJOR + "_" + lua.VERSION_MINOR

@(default_calling_convention = "c", link_prefix = "lua")
foreign lua54 {
	open_base :: proc(L: lua.State) -> c.int ---
	open_coroutine :: proc(L: lua.State) -> c.int ---
	open_table :: proc(L: lua.State) -> c.int ---
	open_io :: proc(L: lua.State) -> c.int ---
	open_os :: proc(L: lua.State) -> c.int ---
	open_string :: proc(L: lua.State) -> c.int ---
	open_utf8 :: proc(L: lua.State) -> c.int ---
	open_math :: proc(L: lua.State) -> c.int ---
	open_debug :: proc(L: lua.State) -> c.int ---
	open_package :: proc(L: lua.State) -> c.int ---
}

@(default_calling_convention = "c", link_prefix = "luaL_")
foreign lua54 {
	openlibs :: proc(L: lua.State) ---
}
