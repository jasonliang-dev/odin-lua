package luajit

import "core:c"
import "core:c/libc"
import "core:mem"

foreign import lua51 "lua51.lib"

VERSION :: "Lua 5.1"
RELEASE :: "Lua 5.1.4"
VERSION_NUM :: 501
COPYRIGHT :: "Copyright (C) 1994-2008 Lua.org, PUC-Rio"
AUTHORS :: "R. Ierusalimschy, L. H. de Figueiredo, W. Celes"

SIGNATURE :: "\x1bLua"
MULTRET :: -1

// pseudo indices
REGISTRYINDEX :: -10000
ENVIRONINDEX :: -10001
GLOBALSINDEX :: -10002
upvalueindex :: #force_inline proc "c" (i: int) -> int {
	return GLOBALSINDEX - i
}

// thread status
OK :: 0
YIELD :: 1
ERRRUN :: 2
ERRSYNTAX :: 3
ERRMEM :: 4
ERRERR :: 5

State :: distinct rawptr

CFunction :: proc "c" (L: State) -> c.int
Reader :: proc "c" (L: State, ud: rawptr, sz: c.size_t) -> cstring
Writer :: proc "c" (L: State, p: rawptr, sz: c.size_t, ud: rawptr) -> c.int
Alloc :: proc "c" (ud: rawptr, ptr: rawptr, osize: c.size_t, nsize: c.size_t) -> rawptr

// lua types
TNONE :: -1
TNIL :: 0
TBOOLEAN :: 1
TLIGHTUSERDATA :: 2
TNUMBER :: 3
TSTRING :: 4
TTABLE :: 5
TFUNCTION :: 6
TUSERDATA :: 7
TTHREAD :: 8

MIN_STACK :: 20

// c api types
Number :: distinct LUA_NUMBER
Integer :: distinct LUA_INTEGER

@(default_calling_convention = "c", link_prefix = "lua_")
foreign lua51 {
	// state
	newstate :: proc(f: Alloc, ud: rawptr) -> State ---
	close :: proc(L: State) ---
	newthread :: proc(L: State) -> State ---

	atpanic :: proc(L: State, panicf: CFunction) -> CFunction ---

	// stack
	gettop :: proc(L: State) -> c.int ---
	settop :: proc(L: State, idx: c.int) ---
	pushvalue :: proc(L: State, idx: c.int) ---
	remove :: proc(L: State, idx: c.int) ---
	insert :: proc(L: State, idx: c.int) ---
	replace :: proc(L: State, idx: c.int) ---
	checkstack :: proc(L: State, n: c.int) -> c.int ---

	xmove :: proc(from: State, to: State, n: c.int) ---

	// access
	isnumber :: proc(L: State, idx: c.int) -> c.int ---
	isstring :: proc(L: State, idx: c.int) -> c.int ---
	iscfunction :: proc(L: State, idx: c.int) -> c.int ---
	isuserdata :: proc(L: State, idx: c.int) -> c.int ---
	type :: proc(L: State, idx: c.int) -> c.int ---
	typename :: proc(L: State, tp: c.int) -> cstring ---

	lua_equal :: proc(L: State, idx1: c.int, idx2: c.int) -> c.int ---
	lua_rawequal :: proc(L: State, idx1: c.int, idx2: c.int) -> c.int ---
	lua_lessthan :: proc(L: State, idx1: c.int, idx2: c.int) -> c.int ---

	tonumber :: proc(L: State, idx: c.int) -> Number ---
	tointeger :: proc(L: State, idx: c.int) -> Integer ---
	toboolean :: proc(L: State, idx: c.int) -> c.int ---
	tolstring :: proc(L: State, idx: c.int, len: ^c.size_t) -> cstring ---
	objlen :: proc(L: State, idx: c.int) -> c.size_t ---
	tocfunction :: proc(L: State, idx: c.int) -> CFunction ---
	touserdata :: proc(L: State, idx: c.int) -> rawptr ---
	tothread :: proc(L: State, idx: c.int) -> State ---
	topointer :: proc(L: State, idx: c.int) -> rawptr ---
}

@(default_calling_convention = "c", link_prefix = "lua_")
foreign lua51 {
	// push
	pushnil :: proc(L: State) ---
	pushnumber :: proc(L: State, n: Number) ---
	pushinteger :: proc(L: State, n: Integer) ---
	pushlstring :: proc(L: State, s: cstring, len: c.size_t) ---
	pushstring :: proc(L: State, s: cstring) ---
	pushvfstring :: proc(L: State, fmt: cstring, argp: ^libc.va_list) -> cstring ---
	pushfstring :: proc(L: State, fmt: cstring, args: ..any) -> cstring ---
	pushcclosure :: proc(L: State, fn: CFunction, n: c.int) ---
	pushboolean :: proc(L: State, b: c.int) ---
	pushlightuserdata :: proc(L: State, p: rawptr) ---
	pushthread :: proc(L: State) -> int ---

	// get
	gettable :: proc(L: State, idx: c.int) ---
	getfield :: proc(L: State, idx: c.int, k: cstring) ---
	rawget :: proc(L: State, idx: c.int) ---
	rawgeti :: proc(L: State, idx: c.int, n: c.int) ---

	createtable :: proc(L: State, narr: c.int, nrec: c.int) ---
	newuserdata :: proc(L: State, sz: c.size_t) -> rawptr ---
	getmetatable :: proc(L: State, objindex: c.int) -> c.int ---
	getfenv :: proc(L: State, idx: c.int) ---

	// set
	settable :: proc(L: State, idx: c.int) ---
	setfield :: proc(L: State, idx: c.int, k: cstring) ---
	rawset :: proc(L: State, idx: c.int) ---
	rawseti :: proc(L: State, idx: c.int, n: c.int) ---
	setmetatable :: proc(L: State, objindex: c.int) -> c.int ---
	setfenv :: proc(L: State, idx: c.int) -> c.int ---
}

// load and run
@(default_calling_convention = "c", link_prefix = "lua_")
foreign lua51 {
	call :: proc(L: State, nargs: c.int, nresults: c.int) ---
	pcall :: proc(L: State, nargs: c.int, nresults: c.int, errfunc: c.int) -> c.int ---
	cpcall :: proc(L: State, func: CFunction, ud: rawptr) -> c.int ---
	load :: proc(L: State, reader: Reader, dt: rawptr, chunkname: cstring) -> c.int ---
	dump :: proc(L: State, writer: Writer, data: rawptr) -> c.int ---
}

// coroutine
@(default_calling_convention = "c", link_prefix = "lua_")
foreign lua51 {
	yield :: proc(L: State, nresults: c.int) -> c.int ---
	resume :: proc(L: State, narg: c.int) -> c.int ---
	status :: proc(L: State) -> c.int ---
}

// garbage collection
GCSTOP :: 0
GCRESTART :: 1
GCCOLLECT :: 2
GCCOUNT :: 3
GCCOUNTB :: 4
GCSTEP :: 5
GCSETPAUSE :: 6
GCSETSTEPMUL :: 7
GCISRUNNING :: 9

@(default_calling_convention = "c", link_prefix = "lua_")
foreign lua51 {
	gc :: proc(L: State, what: c.int, data: c.int) -> c.int ---

	// misc
	error :: proc(L: State) -> c.int ---
	next :: proc(L: State, idx: c.int) -> c.int ---
	concat :: proc(L: State, n: c.int) ---
	getallocf :: proc(L: State, ud: ^rawptr) -> Alloc ---
	setallocf :: proc(L: State, f: Alloc, ud: rawptr) ---
}

// some useful functions

pop :: #force_inline proc "c" (L: State, n: c.int) {
	settop(L, -n - 1)
}

newtable :: #force_inline proc "c" (L: State) {
	createtable(L, 0, 0)
}

register :: #force_inline proc "c" (L: State, n: cstring, f: CFunction) {
	pushcfunction(L, f)
	setglobal(L, n)
}

pushcfunction :: #force_inline proc "c" (L: State, f: CFunction) {
	pushcclosure(L, f, 0)
}

strlen :: #force_inline proc "c" (L: State, i: c.int) -> c.size_t {
	return objlen(L, i)
}

isfunction :: #force_inline proc "c" (L: State, n: c.int) -> bool {return type(L, n) == TFUNCTION}
istable :: #force_inline proc "c" (L: State, n: c.int) -> bool {return type(L, n) == TTABLE}
islightuserdata :: #force_inline proc "c" (L: State, n: c.int) -> bool {
	return type(L, n) == TLIGHTUSERDATA
}
isnil :: #force_inline proc "c" (L: State, n: c.int) -> bool {return type(L, n) == TNIL}
isboolean :: #force_inline proc "c" (L: State, n: c.int) -> bool {return type(L, n) == TBOOLEAN}
isthread :: #force_inline proc "c" (L: State, n: c.int) -> bool {return type(L, n) == TTHREAD}
isnone :: #force_inline proc "c" (L: State, n: c.int) -> bool {return type(L, n) == TNONE}
isnoneornil :: #force_inline proc "c" (L: State, n: c.int) -> bool {return type(L, n) <= 0}

pushliteral :: #force_inline proc "c" (L: State, str: cstring) {
	pushlstring(L, str, len(str))
}

setglobal :: #force_inline proc "c" (L: State, s: cstring) {
	setfield(L, GLOBALSINDEX, s)
}
getglobal :: #force_inline proc "c" (L: State, s: cstring) {
	getfield(L, GLOBALSINDEX, s)
}

tostring :: #force_inline proc "c" (L: State, i: c.int) -> cstring {
	return tolstring(L, i, nil)
}

// compatibility

open :: newstate

getregistry :: #force_inline proc "c" (L: State) {
	pushvalue(L, REGISTRYINDEX)
}

getgccount :: #force_inline proc "c" (L: State) -> c.int {
	return gc(L, GCCOUNT, 0)
}

Chunkreader :: Reader
Chunkwriter :: Writer

// hack
@(default_calling_convention = "c", link_prefix = "lua_")
foreign lua51 {
	setlevel :: proc(from: State, to: State) ---
}

// debug
HOOKCALL :: 0
HOOKRET :: 1
HOOKLINE :: 2
HOOKCOUNT :: 3
HOOKTAILRET :: 4

MASKCALL :: 1 << HOOKCALL
MASKRET :: 1 << HOOKRET
MASKLINE :: 1 << HOOKLINE
MASKCOUNT :: 1 << HOOKCOUNT

Hook :: proc "c" (L: State, ar: ^Debug)

@(default_calling_convention = "c", link_prefix = "lua_")
foreign lua51 {
	lua_getstack :: proc(L: State, level: c.int, ar: ^Debug) -> c.int ---

	getinfo :: proc(L: State, what: cstring, ar: ^Debug) -> int ---
	getlocal :: proc(L: State, ar: ^Debug, n: c.int) -> cstring ---
	setlocal :: proc(L: State, ar: ^Debug, n: c.int) -> cstring ---
	getupvalue :: proc(L: State, funcindex: c.int, n: c.int) -> cstring ---
	setupvalue :: proc(L: State, funcindex: c.int, n: c.int) -> cstring ---
	sethook :: proc(L: State, func: Hook, mask: c.int, count: c.int) ---
	gethook :: proc(L: State) -> Hook ---
	gethookmask :: proc(L: State) -> int ---
	gethookcount :: proc(L: State) -> int ---

	// lua 5.2
	upvalueid :: proc(L: State, idx: c.int, n: c.int) -> rawptr ---
	upvaluejoin :: proc(L: State, idx1: c.int, n1: c.int, idx2: c.int, n2: c.int) ---
	loadx :: proc(L: State, reader: Reader, dt: rawptr, chunkname: cstring, mode: cstring) -> c.int ---
	version :: proc(L: State) -> Number ---
	copy :: proc(L: State, fromidx: c.int, toidx: c.int) ---
	tonumberx :: proc(L: State, idx: c.int, isnum: ^c.int) -> Number ---
	tointegerx :: proc(L: State, idx: c.int, isnum: ^c.int) -> Integer ---

	// lua 5.3
	isyieldable :: proc(L: State) -> c.int ---
}

Debug :: struct {
	event:           c.int,
	name:            cstring,
	namewhat:        cstring,
	what:            cstring,
	source:          cstring,
	currentline:     c.int,
	nups:            u8,
	linedefined:     c.int,
	lastlinedefined: c.int,
	short_src:       [LUA_IDSIZE]c.char,
	// private
	i_ci:            c.int,
}
