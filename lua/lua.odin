package lua

import "core:c"
import "core:c/libc"
import "core:mem"

foreign import lua54 "lua54.lib"

VERSION_MAJOR :: "5"
VERSION_MINOR :: "4"
VERSION_RELEASE :: "4"

VERSION_NUM :: 504
VERSION_RELEASE_NUM :: (VERSION_NUM * 100 + 4)

VERSION :: "Lua " + VERSION_MAJOR + "." + VERSION_MINOR
RELEASE :: VERSION + "." + VERSION_RELEASE
COPYRIGHT :: RELEASE + "  Copyright (C) 1994-2022 Lua.org, PUC-Rio"
AUTHORS :: "R. Ierusalimschy, L. H. de Figueiredo, W. Celes"

SIGNATURE :: "\x1bLua"
MULTRET :: -1

// pseudo indices
REGISTRYINDEX :: -LUAI_MAXSTACK - 1000
upvalueindex :: #force_inline proc "c" (i: int) -> int {
	return REGISTRYINDEX - i
}

// thread status
OK :: 0
YIELD :: 1
ERRRUN :: 2
ERRSYNTAX :: 3
ERRMEM :: 4
ERRERR :: 5

State :: distinct rawptr

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
NUMTYPES :: 9

MIN_STACK :: 20

// registry values
RIDX_MAINTHREAD :: 1
RIDX_GLOBALS :: 2
RIDX_LAST :: RIDX_GLOBALS

// c api types
Number :: distinct LUA_NUMBER
Integer :: distinct LUA_INTEGER
Unsigned :: distinct LUA_UNSIGNED
KContext :: distinct LUA_KCONTEXT

CFunction :: proc "c" (L: State) -> c.int
KFunction :: proc "c" (L: State, status: c.int, ctx: KContext) -> c.int
Reader :: proc "c" (L: State, ud: rawptr, sz: c.size_t) -> cstring
Writer :: proc "c" (L: State, p: rawptr, sz: c.size_t, ud: rawptr) -> c.int
Alloc :: proc "c" (ud: rawptr, ptr: rawptr, osize: c.size_t, nsize: c.size_t) -> rawptr
WarnFunction :: proc "c" (ud: rawptr, msg: cstring, tocont: c.int)

@(link_prefix = "lua_")
foreign lua54 {
	ident: [^]u8
}

@(default_calling_convention = "c", link_prefix = "lua_")
foreign lua54 {
	// state
	newstate :: proc(f: Alloc, ud: rawptr) -> State ---
	close :: proc(L: State) ---
	newthread :: proc(L: State) -> State ---
	resetthread :: proc(L: State) -> c.int ---

	atpanic :: proc(L: State, panicf: CFunction) -> CFunction ---
	version :: proc(L: State) -> Number ---

	// stack
	absindex :: proc(L: State, idx: c.int) -> c.int ---
	gettop :: proc(L: State) -> c.int ---
	settop :: proc(L: State, idx: c.int) ---
	pushvalue :: proc(L: State, idx: c.int) ---
	rotate :: proc(L: State, idx: c.int, n: c.int) ---
	copy :: proc(L: State, fromidx: c.int, toidx: c.int) ---
	checkstack :: proc(L: State, n: c.int) -> c.int ---

	xmove :: proc(from: State, to: State, n: c.int) ---

	// access
	isnumber :: proc(L: State, idx: c.int) -> c.int ---
	isstring :: proc(L: State, idx: c.int) -> c.int ---
	iscfunction :: proc(L: State, idx: c.int) -> c.int ---
	isinteger :: proc(L: State, idx: c.int) -> c.int ---
	isuserdata :: proc(L: State, idx: c.int) -> c.int ---
	type :: proc(L: State, idx: c.int) -> c.int ---
	typename :: proc(L: State, tp: c.int) -> cstring ---

	tonumberx :: proc(L: State, idx: c.int, isnum: ^c.int) -> Number ---
	tointegerx :: proc(L: State, idx: c.int, isnum: ^c.int) -> Integer ---
	toboolean :: proc(L: State, idx: c.int) -> c.int ---
	tolstring :: proc(L: State, idx: c.int, len: ^c.size_t) -> cstring ---
	rawlen :: proc(L: State, idx: c.int) -> Unsigned ---
	tocfunction :: proc(L: State, idx: c.int) -> CFunction ---
	touserdata :: proc(L: State, idx: c.int) -> rawptr ---
	tothread :: proc(L: State, idx: c.int) -> State ---
	topointer :: proc(L: State, idx: c.int) -> rawptr ---
}

// compare and arithmetic
OPADD :: 0
OPSUB :: 1
OPMUL :: 2
OPMOD :: 3
OPPOW :: 4
OPDIV :: 5
OPIDIV :: 6
OPBAND :: 7
OPBOR :: 8
OPBXOR :: 9
OPSHL :: 10
OPSHR :: 11
OPUNM :: 12
OPBNOT :: 13

@(default_calling_convention = "c", link_prefix = "lua_")
foreign lua54 {
	arith :: proc(L: State, op: c.int) ---
}

OPEQ :: 0
OPLT :: 1
OPLE :: 2

@(default_calling_convention = "c", link_prefix = "lua_")
foreign lua54 {
	rawequal :: proc(L: State, idx1: c.int, idx2: c.int) -> c.int ---
	compare :: proc(L: State, idx1: c.int, idx2: c.int, op: c.int) -> c.int ---

	// push
	pushnil :: proc(L: State) ---
	pushnumber :: proc(L: State, n: Number) ---
	pushinteger :: proc(L: State, n: Integer) ---
	pushlstring :: proc(L: State, s: cstring, len: c.size_t) -> cstring ---
	pushstring :: proc(L: State, s: cstring) -> cstring ---
	pushvfstring :: proc(L: State, fmt: cstring, argp: ^libc.va_list) -> cstring ---
	pushfstring :: proc(L: State, fmt: cstring, args: ..any) -> cstring ---
	pushcclosure :: proc(L: State, fn: CFunction, n: c.int) ---
	pushboolean :: proc(L: State, b: c.int) ---
	pushlightuserdata :: proc(L: State, p: rawptr) ---
	pushthread :: proc(L: State) -> int ---

	// get
	getglobal :: proc(L: State, name: cstring) -> c.int ---
	gettable :: proc(L: State, idx: c.int) -> c.int ---
	getfield :: proc(L: State, idx: c.int, k: cstring) -> c.int ---
	geti :: proc(L: State, idx: c.int, n: Integer) -> c.int ---
	rawget :: proc(L: State, idx: c.int) -> c.int ---
	rawgeti :: proc(L: State, idx: c.int, n: Integer) -> c.int ---
	rawgetp :: proc(L: State, idx: c.int, p: rawptr) -> c.int ---

	createtable :: proc(L: State, narr: c.int, nrec: c.int) ---
	newuserdatauv :: proc(L: State, sz: c.size_t, nuvalue: c.int) -> rawptr ---
	getmetatable :: proc(L: State, objindex: c.int) -> c.int ---
	getiuservalue :: proc(L: State, idx: c.int, n: c.int) -> c.int ---

	// set
	setglobal :: proc(L: State, name: cstring) ---
	settable :: proc(L: State, idx: c.int) ---
	setfield :: proc(L: State, idx: c.int, k: cstring) ---
	seti :: proc(L: State, idx: c.int, n: Integer) ---
	rawset :: proc(L: State, idx: c.int) ---
	rawseti :: proc(L: State, idx: c.int, n: Integer) ---
	rawsetp :: proc(L: State, idx: c.int, p: rawptr) ---
	setmetatable :: proc(L: State, objindex: c.int) -> c.int ---
	setiuservalue :: proc(L: State, idx: c.int, n: c.int) -> c.int ---
}

// load and run
@(default_calling_convention = "c", link_prefix = "lua_")
foreign lua54 {
	callk :: proc(L: State, nargs: c.int, nresults: c.int, ctx: KContext, k: KFunction) -> c.int ---
	pcallk :: proc(L: State, nargs: c.int, nresults: c.int, errfunc: c.int, ctx: KContext, k: KFunction) -> c.int ---
	load :: proc(L: State, reader: Reader, dt: rawptr, chunkname: cstring, mode: cstring) -> c.int ---
	dump :: proc(L: State, writer: Writer, data: rawptr, strip: c.int) -> c.int ---
}
call :: #force_inline proc "c" (L: State, n: c.int, r: c.int) -> c.int {
	return callk(L, n, r, 0, nil)
}
pcall :: #force_inline proc "c" (L: State, n: c.int, r: c.int, f: c.int) -> c.int {
	return pcallk(L, n, r, f, 0, nil)
}

// coroutine
@(default_calling_convention = "c", link_prefix = "lua_")
foreign lua54 {
	yieldk :: proc(L: State, nresults: c.int, ctx: KContext, k: KFunction) -> c.int ---
	resume :: proc(L: State, from: State, narg: c.int, nres: ^c.int) -> c.int ---
	status :: proc(L: State) -> c.int ---
	isyieldable :: proc(L: State) -> c.int ---
}
yield :: #force_inline proc "c" (L: State, n: c.int) -> c.int {
	return yieldk(L, n, 0, nil)
}

// warning
@(default_calling_convention = "c", link_prefix = "lua_")
foreign lua54 {
	setwarnf :: proc(L: State, f: WarnFunction, ud: rawptr) ---
	warning :: proc(L: State, msg: cstring, tocont: c.int) ---
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
GCGEN :: 10
GCINC :: 11

@(default_calling_convention = "c", link_prefix = "lua_")
foreign lua54 {
	gc :: proc(L: State, what: c.int, args: ..any) -> c.int ---

	// misc
	error :: proc(L: State) -> c.int ---
	next :: proc(L: State, idx: c.int) -> c.int ---
	concat :: proc(L: State, n: c.int) ---
	len :: proc(L: State, idx: c.int) ---
	stringtonumber :: proc(L: State, s: cstring) -> c.size_t ---
	getallocf :: proc(L: State, ud: ^rawptr) -> Alloc ---
	setallocf :: proc(L: State, f: Alloc, ud: rawptr) ---
	toclose :: proc(L: State, idx: c.int) ---
	closeslot :: proc(L: State, idx: c.int) ---
}

// some useful functions

getextraspace :: #force_inline proc "c" (L: State) -> rawptr {
	return rawptr(mem.ptr_offset((^u8)(L), -LUA_EXTRASPACE))
}

tonumber :: #force_inline proc "c" (L: State, i: c.int) -> Number {
	return tonumberx(L, i, nil)
}
tointeger :: #force_inline proc "c" (L: State, i: c.int) -> Integer {
	return tointegerx(L, i, nil)
}

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

pushliteral :: pushstring

pushglobaltable :: #force_inline proc "c" (L: State) {
	rawgeti(L, REGISTRYINDEX, RIDX_GLOBALS)
}

tostring :: #force_inline proc "c" (L: State, i: c.int) -> cstring {
	return tolstring(L, i, nil)
}

insert :: #force_inline proc "c" (L: State, idx: c.int) {
	rotate(L, idx, 1)
}

remove :: #force_inline proc "c" (L: State, idx: c.int) {
	rotate(L, idx, -1)
	pop(L, 1)
}

replace :: #force_inline proc "c" (L: State, idx: c.int) {
	copy(L, -1, idx)
	pop(L, 1)
}

// compatibility
when LUA_COMPAT_APIINTCASTS {
	pushunsigned :: #force_inline proc "c" (L: State, n: Unsigned) {pushinteger(L, Integer(n))}
	tounsignedx :: #force_inline proc "c" (L: State, i: c.int, is: ^c.int) -> Unsigned {
		return Unsigned(tointegerx(L, i, is))
	}
	tounsigned :: #force_inline proc "c" (L: State, i: c.int) {tounsignedx(L, i, nil)}
}

newuserdata :: #force_inline proc "c" (L: State, s: c.size_t) -> rawptr {
	return newuserdatauv(L, s, 1)
}
getuservalue :: #force_inline proc "c" (L: State, idx: c.int) -> c.int {
	return getiuservalue(L, idx, 1)
}
setuservalue :: #force_inline proc "c" (L: State, idx: c.int) -> c.int {
	return setiuservalue(L, idx, 1)
}

NUMTAGS :: NUMTYPES

// debug
HOOKCALL :: 0
HOOKRET :: 1
HOOKLINE :: 2
HOOKCOUNT :: 3
HOOKTAILCALL :: 4

MASKCALL :: 1 << HOOKCALL
MASKRET :: 1 << HOOKRET
MASKLINE :: 1 << HOOKLINE
MASKCOUNT :: 1 << HOOKCOUNT

Hook :: proc "c" (L: State, ar: ^Debug)

@(default_calling_convention = "c", link_prefix = "lua_")
foreign lua54 {
	lua_getstack :: proc(L: State, level: c.int, ar: ^Debug) -> c.int ---

	getinfo :: proc(L: State, what: cstring, ar: ^Debug) -> int ---
	getlocal :: proc(L: State, ar: ^Debug, n: c.int) -> cstring ---
	setlocal :: proc(L: State, ar: ^Debug, n: c.int) -> cstring ---
	getupvalue :: proc(L: State, funcindex: c.int, n: c.int) -> cstring ---
	setupvalue :: proc(L: State, funcindex: c.int, n: c.int) -> cstring ---
	upvalueid :: proc(L: State, fidx: c.int, n: c.int) -> rawptr ---
	upvaluejoin :: proc(L: State, fidx1: c.int, n1: c.int, fidx2: c.int, n2: c.int) ---
	sethook :: proc(L: State, func: Hook, mask: c.int, count: c.int) ---
	gethook :: proc(L: State) -> Hook ---
	gethookmask :: proc(L: State) -> int ---
	gethookcount :: proc(L: State) -> int ---
	setcstacklimit :: proc(L: State, limit: c.uint) -> int ---
}

Debug :: struct {
	event:           c.int,
	name:            cstring,
	namewhat:        cstring,
	what:            cstring,
	source:          cstring,
	srclen:          c.size_t,
	currentline:     c.int,
	linedefined:     c.int,
	lastlinedefined: c.int,
	nups:            u8,
	nparams:         u8,
	isvararg:        i8,
	istailcall:      i8,
	ftransfer:       c.ushort,
	ntransfer:       c.ushort,
	short_src:       [LUA_IDSIZE]c.char,
	// private
	i_ci:            rawptr, // ^CallInfo
}