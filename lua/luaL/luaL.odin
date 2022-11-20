package lua_luaL

import "core:c"
import "core:c/libc"
import "core:builtin"
import lua ".."

when ODIN_OS == .Windows {
	foreign import lua54 "../lua54.lib"
} else when ODIN_OS == .Linux {
	foreign import lua54 "../liblua54.a"
}

State :: lua.State

GNAME :: "_G"

ERRFILE :: lua.ERRERR + 1
LOADED_TABLE :: "_LOADED"
PRELOAD_TABLE :: "_PRELOAD"

Reg :: struct {
	name: cstring,
	func: lua.CFunction,
}

NUMSIZES :: size_of(lua.Integer) * 16 + size_of(lua.Number)

@(default_calling_convention = "c", link_prefix = "luaL_")
foreign lua54 {
	checkversion_ :: proc(L: State, ver: lua.Number, sz: c.size_t) ---
}
checkversion :: #force_inline proc "c" (L: State) {
	checkversion_(L, lua.VERSION_NUM, NUMSIZES)
}

@(default_calling_convention = "c", link_prefix = "luaL_")
foreign lua54 {
	getmetafield :: proc(L: State, obj: c.int, e: cstring) -> c.int ---
	callmeta :: proc(L: State, obj: c.int, e: cstring) -> c.int ---
	tolstring :: proc(L: State, idx: c.int, len: ^c.size_t) -> cstring ---
	argerror :: proc(L: State, arg: c.int, extramsg: cstring) -> c.int ---
	typeerror :: proc(L: State, arg: c.int, tname: cstring) -> c.int ---
	checklstring :: proc(L: State, arg: c.int, l: ^c.size_t) -> cstring ---
	optlstring :: proc(L: State, arg: c.int, def: cstring, l: ^c.size_t) -> cstring ---
	checknumber :: proc(L: State, arg: c.int) -> lua.Number ---
	optnumber :: proc(L: State, arg: c.int, def: lua.Number) -> lua.Number ---

	checkinteger :: proc(L: State, arg: c.int) -> lua.Integer ---
	optinteger :: proc(L: State, arg: c.int, def: lua.Integer) -> lua.Integer ---

	checkstack :: proc(L: State, sz: c.int, msg: cstring) ---
	checktype :: proc(L: State, arg: c.int, t: c.int) ---
	checkany :: proc(L: State, arg: c.int) ---

	newmetatable :: proc(L: State, tname: cstring) -> c.int ---
	setmetatable :: proc(L: State, tname: cstring) ---
	testudata :: proc(L: State, ud: c.int, tname: cstring) -> rawptr ---
	checkudata :: proc(L: State, ud: c.int, tname: cstring) -> rawptr ---

	@(link_name = "luaL_where")
	luaL_where :: proc(L: State, lvl: c.int) ---
	error :: proc(L: State, fmt: cstring, args: ..any) -> c.int ---

	checkoption :: proc(L: State, arg: c.int, def: cstring, lst: [^]cstring) -> c.int ---

	fileresult :: proc(L: State, stat: c.int, fname: cstring) -> c.int ---
	execresult :: proc(L: State, stat: c.int) -> c.int ---
}

NOREF :: -2
REFNIL :: -1

@(default_calling_convention = "c", link_prefix = "luaL_")
foreign lua54 {
	ref :: proc(L: State, t: c.int) -> c.int ---
	unref :: proc(L: State, t: c.int, ref: c.int) ---

	loadfilex :: proc(L: State, filename: cstring, mode: cstring) -> c.int ---
}
loadfile :: #force_inline proc "c" (L: State, f: cstring) -> c.int {
	return loadfilex(L, f, nil)
}

@(default_calling_convention = "c", link_prefix = "luaL_")
foreign lua54 {
	loadbufferx :: proc(L: State, buff: cstring, sz: c.size_t, name: cstring, mode: cstring) -> c.int ---
	loadstring :: proc(L: State, s: cstring) -> c.int ---

	newstate :: proc() -> State ---

	len :: proc(L: State, idx: c.int) -> lua.Integer ---

	addgsub :: proc(b: ^Buffer, s: cstring, p: cstring, r: cstring) ---
	gsub :: proc(L: State, s: cstring, p: cstring, r: cstring) -> cstring ---

	setfuncs :: proc(L: State, l: [^]Reg, nup: c.int) ---

	getsubtable :: proc(L: State, idx: c.int, fname: cstring) -> c.int ---

	traceback :: proc(L: State, L1: State, msg: cstring, level: c.int) ---

	requiref :: proc(L: State, modname: cstring, openf: lua.CFunction, glb: c.int) ---
}

newlibtable :: #force_inline proc "c" (L: State, l: []Reg) {
	lua.createtable(L, 0, c.int(builtin.len(l)) - 1)
}

newlib :: #force_inline proc "c" (L: State, l: []Reg) {
	checkversion(L)
	newlibtable(L, l)
	setfuncs(L, &l[0], 0)
}

argcheck :: #force_inline proc "c" (L: State, cond: bool, arg: c.int, extramsg: cstring) -> c.int {
	return 1 if cond else argerror(L, arg, extramsg)
}

argexpected :: #force_inline proc "c" (L: State, cond: bool, arg: c.int, tname: cstring) -> c.int {
	return 1 if cond else typeerror(L, arg, tname)
}

checkstring :: #force_inline proc "c" (L: State, n: c.int) -> cstring {
	return checklstring(L, n, nil)
}

optstring :: #force_inline proc "c" (L: State, n: c.int, d: cstring) -> cstring {
	return optlstring(L, n, d, nil)
}

typename :: #force_inline proc "c" (L: State, i: c.int) -> cstring {
	return lua.typename(L, lua.type(L, i))
}

dofile :: #force_inline proc "c" (L: State, fn: cstring) -> c.int {
	res := loadfile(L, fn)
	if res == lua.OK {
		return lua.pcall(L, 0, lua.MULTRET, 0)
	}
	return res
}

dostring :: #force_inline proc "c" (L: State, s: cstring) -> c.int {
	res := loadstring(L, s)
	if res == lua.OK {
		return lua.pcall(L, 0, lua.MULTRET, 0)
	}
	return res
}

getmetatable :: #force_inline proc "c" (L: State, n: cstring) -> c.int {
	return lua.getfield(L, lua.REGISTRYINDEX, n)
}

opt :: #force_inline proc "c" (L: State, f: proc(_: State, _: c.int) -> $T, n: c.int, d: T) {
	return d if lua.isnoneornil(L, n) else f(L, n)
}

loadbuffer :: #force_inline proc "c" (L: State, s: cstring, sz: c.size_t, n: cstring) -> c.int {
	return loadbufferx(L, s, sz, n, nil)
}

pushfail :: #force_inline proc "c" (L: State) {
	lua.pushnil(L)
}

Buffer :: struct {
	b:    [^]c.char,
	size: c.size_t,
	n:    c.size_t,
	L:    State,
	init: struct #raw_union #align lua.LUAI_MAXALIGN {
		b: [lua.LUAL_BUFFERSIZE]c.char,
	},
}

bufflen :: #force_inline proc "c" (bf: ^Buffer) -> c.size_t {return bf.n}
buffaddr :: #force_inline proc "c" (bf: ^Buffer) -> [^]c.char {return bf.b}

addchar :: #force_inline proc "c" (B: ^Buffer, c: c.char) {
	if B.n >= B.size {
		prepbuffsize(B, 1)
	}
	B.b[B.n] = c
	B.n += 1
}

addsize :: #force_inline proc "c" (B: ^Buffer, s: uint) {B.n += s}
buffsub :: #force_inline proc "c" (B: ^Buffer, s: uint) {B.n -= s}

@(default_calling_convention = "c", link_prefix = "luaL_")
foreign lua54 {
	buffinit :: proc(L: State, B: ^Buffer) ---
	prepbuffsize :: proc(B: ^Buffer, sz: c.size_t) -> [^]c.char ---
	addlstring :: proc(B: ^Buffer, s: cstring, l: c.size_t) ---
	addstring :: proc(B: ^Buffer, s: cstring) ---
	addvalue :: proc(B: ^Buffer) ---
	pushresult :: proc(B: ^Buffer) ---
	pushresultsize :: proc(B: ^Buffer, sz: c.size_t) ---
	buffinitsize :: proc(L: State, B: Buffer, sz: c.size_t) -> [^]c.char ---
}

prepbuffer :: #force_inline proc "c" (B: ^Buffer) {
	prepbuffsize(B, lua.LUAL_BUFFERSIZE)
}

FILEHANDLE :: "FILE*"

Stream :: struct {
	f:      ^libc.FILE,
	closef: lua.CFunction,
}

writestring :: #force_inline proc "c" (s: rawptr, l: uint) -> uint {
	return libc.fwrite(s, size_of(c.char), l, libc.stdout)
}

writeline :: #force_inline proc "c" () {
	str := "\n"
	writestring(raw_data(str), 1)
	libc.fflush(libc.stdout)
}

writestringerror :: #force_inline proc "c" (s: cstring, args: ..any) {
	libc.fprintf(libc.stderr, s, args)
	libc.fflush(libc.stderr)
}

// compatibility
when lua.LUA_COMPAT_APIINTCASTS {
	checkunsigned :: #force_inline proc "c" (L: State, a: c.int) -> lua.Unsigned {
		return lua.Unsigned(checkinteger(L, a))
	}
	optunsigned :: #force_inline proc "c" (L: State, a: c.int, d: lua.Unsigned) -> lua.Unsigned {
		return lua.Unsigned(optinteger(L, a, lua.Integer(d)))
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
}
