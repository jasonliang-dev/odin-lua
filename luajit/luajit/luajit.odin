package luajit_luajit

import "core:c"
import lua ".."

when ODIN_OS == .Windows {
	foreign import lua51 "../lua51.lib"
} else when ODIN_OS == .Linux {
	foreign import lua51 "../libluajit.a"
}

VERSION :: "LuaJIT 2.1.0-beta3"
VERSION_NUM :: 20100
VERSION_SYM :: version_2_1_0_beta3
COPYRIGHT :: "Copyright (C) 2005-2017 Mike Pall"
URL :: "http://luajit.org/"

MODE_MASK :: 0x00ff

MODE_ENGINE :: 0
MODE_DEBUG :: 1
MODE_FUNC :: 2
MODE_ALLFUNC :: 3
MODE_ALLSUBFUNC :: 4
MODE_TRACE :: 5
MODE_WRAPFUNC :: 16
MODE_MAX :: 17

MODE_OFF :: 0x0000
MODE_ON :: 0x0100
MODE_FLUSH :: 0x0200

profile_callback :: proc "c" (data: rawptr, L: lua.State, samples: c.int, vmstate: c.int)

@(default_calling_convention = "c", link_prefix = "luaJIT_")
foreign lua51 {
	setmode :: proc(L: lua.State, idx: c.int, mode: c.int) -> c.int ---

	profile_start :: proc(L: lua.State, mode: cstring, cb: profile_callback, data: rawptr) ---
	profile_stop :: proc(L: lua.State) ---
	profile_dumpstack :: proc(L: lua.State, fmt: cstring, depth: c.int, len: c.size_t) -> cstring ---

	version_2_1_0_beta3 :: proc() ---
}
