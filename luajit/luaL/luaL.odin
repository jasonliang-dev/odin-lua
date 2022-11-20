package luajit_luaL

import "core:c"
import "core:mem"
import "core:c/libc"
import "core:builtin"
import lua ".."

when ODIN_OS == .Windows {
	foreign import lua51 "../lua51.lib"
} else when ODIN_OS == .Linux {
	foreign import lua51 "../libluajit.a"
}

State :: lua.State

getn :: #force_inline proc "c" (L: State, i: c.int) -> c.int {
	return c.int(lua.objlen(L, i))
}
setn :: #force_inline proc "c" (L: State, i: c.int, j: c.int) {
	// no op!
}

@(default_calling_convention = "c", link_prefix = "luaL_")
foreign lua51 {
	openlib :: proc(L: State, libname: cstring, l: [^]Reg, nup: c.int) ---
	register :: proc(L: State, libname: cstring, l: [^]Reg) ---
}

ERRFILE :: lua.ERRERR + 1

Reg :: struct {
	name: cstring,
	func: lua.CFunction,
}

@(default_calling_convention = "c", link_prefix = "luaL_")
foreign lua51 {
	getmetafield :: proc(L: State, obj: c.int, e: cstring) -> c.int ---
	callmeta :: proc(L: State, obj: c.int, e: cstring) -> c.int ---
	typeerror :: proc(L: State, arg: c.int, tname: cstring) -> c.int ---
	argerror :: proc(L: State, arg: c.int, extramsg: cstring) -> c.int ---
	checklstring :: proc(L: State, numArg: c.int, l: ^c.size_t) -> cstring ---
	optlstring :: proc(L: State, numArg: c.int, def: cstring, l: ^c.size_t) -> cstring ---
	checknumber :: proc(L: State, numArg: c.int) -> lua.Number ---
	optnumber :: proc(L: State, nArg: c.int, def: lua.Number) -> lua.Number ---

	checkinteger :: proc(L: State, arg: c.int) -> lua.Integer ---
	optinteger :: proc(L: State, arg: c.int, def: lua.Integer) -> lua.Integer ---

	checkstack :: proc(L: State, sz: c.int, msg: cstring) ---
	checktype :: proc(L: State, narg: c.int, t: c.int) ---
	checkany :: proc(L: State, narg: c.int) ---

	newmetatable :: proc(L: State, tname: cstring) -> c.int ---
	checkudata :: proc(L: State, ud: c.int, tname: cstring) -> rawptr ---

	@(link_name = "luaL_where")
	luaL_where :: proc(L: State, lvl: c.int) ---
	error :: proc(L: State, fmt: cstring, args: ..any) -> c.int ---

	checkoption :: proc(L: State, narg: c.int, def: cstring, lst: [^]cstring) -> c.int ---

	ref :: proc(L: State, t: c.int) -> c.int ---
	unref :: proc(L: State, t: c.int, ref: c.int) ---

	loadfile :: proc(L: State, filename: cstring) -> c.int ---

	loadbuffer :: proc(L: State, buff: cstring, sz: c.size_t, name: cstring) -> c.int ---
	loadstring :: proc(L: State, s: cstring) -> c.int ---

	newstate :: proc() -> State ---
	gsub :: proc(L: State, s: cstring, p: cstring, r: cstring) -> cstring ---
	findtable :: proc(L: State, idx: c.int, fname: cstring, szhint: c.int) -> cstring ---

	// lua 5.2
	fileresult :: proc(L: State, stat: c.int, fname: cstring) -> c.int ---
	execresult :: proc(L: State, stat: c.int) -> c.int ---
	loadfilex :: proc(L: State, filename: cstring, mode: cstring) -> c.int ---
	loadbufferx :: proc(L: State, buff: cstring, sz: c.size_t, name: cstring, mode: cstring) -> c.int ---
	traceback :: proc(L: State, L1: State, msg: cstring, level: c.int) ---
}

argcheck :: #force_inline proc "c" (L: State, cond: bool, arg: c.int, extramsg: cstring) -> c.int {
	return 1 if cond else argerror(L, arg, extramsg)
}

checkstring :: #force_inline proc "c" (L: State, n: c.int) -> cstring {
	return checklstring(L, n, nil)
}

optstring :: #force_inline proc "c" (L: State, n: c.int, d: cstring) -> cstring {
	return optlstring(L, n, d, nil)
}

checkint :: #force_inline proc "c" (L: State, a: c.int) -> c.int {
	return c.int(checkinteger(L, a))
}

optint :: #force_inline proc "c" (L: State, a: c.int, d: c.int) -> c.int {
	return c.int(optinteger(L, a, lua.Integer(d)))
}

checklong :: #force_inline proc "c" (L: State, a: c.int) -> c.long {
	return c.long(checkinteger(L, a))
}

optlong :: #force_inline proc "c" (L: State, a: c.int, d: c.long) -> c.long {
	return c.long(optinteger(L, a, lua.Integer(d)))
}

typename :: #force_inline proc "c" (L: State, i: c.int) -> cstring {
	return lua.typename(L, lua.type(L, i))
}

dofile :: #force_inline proc "c" (L: State, fn: cstring) -> c.int {
	res := loadfile(L, fn)
	if res == 0 {
		return lua.pcall(L, 0, lua.MULTRET, 0)
	}
	return res
}

dostring :: #force_inline proc "c" (L: State, s: cstring) -> c.int {
	res := loadstring(L, s)
	if res == 0 {
		return lua.pcall(L, 0, lua.MULTRET, 0)
	}
	return res
}

getmetatable :: #force_inline proc "c" (L: State, n: cstring) {
	lua.getfield(L, lua.REGISTRYINDEX, n)
}

opt :: #force_inline proc "c" (L: State, f: proc(_: State, _: c.int) -> $T, n: c.int, d: T) {
	return d if lua.isnoneornil(L, n) else f(L, n)
}

Buffer :: struct {
	p:      [^]c.char,
	lvl:    c.int,
	L:      State,
	buffer: [lua.LUAL_BUFFERSIZE]c.char,
}

addchar :: #force_inline proc "c" (B: ^Buffer, c: c.char) {
	if mem.ptr_sub(&B.p[0], &B.buffer[0]) >= lua.LUAL_BUFFERSIZE {
		prepbuffer(B)
	}

	B.p[0] = c
	B.p = &B.p[1]
}

@(default_calling_convention = "c", link_prefix = "luaL_")
foreign lua51 {
	buffinit :: proc(L: State, B: ^Buffer) ---
	prepbuffer :: proc(B: ^Buffer) -> [^]c.char ---
	addlstring :: proc(B: ^Buffer, s: cstring, l: c.size_t) ---
	addstring :: proc(B: ^Buffer, s: cstring) ---
	addvalue :: proc(B: ^Buffer) ---
	pushresult :: proc(B: ^Buffer) ---
}

NOREF :: -2
REFNIL :: -1

lua_ref :: proc(L: State, lock: c.int) -> c.int {
	if lock == 0 {
		lua.pushstring(L, "unlocked references are obsolete")
		lua.error(L)
		return 0
	}

	return ref(L, lua.REGISTRYINDEX)
}

lua_unref :: proc(L: State, ref: c.int) {
	unref(L, lua.REGISTRYINDEX, ref)
}

lua_getref :: proc(L: State, ref: c.int) {
	lua.rawgeti(L, lua.REGISTRYINDEX, ref)
}

reg :: Reg
