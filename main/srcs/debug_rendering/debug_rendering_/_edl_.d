module debug_rendering_._edl_;

import std.traits;
import std.meta;
import std.string;
import std.uni;
import std.ascii : isDigit;
import std.range;
import std.algorithm;
import std.conv;
import std.typecons;

import bindbc.sdl;
import bindbc.sdl.image;

private:


enum members = [
	__traits(allMembers, bindbc.sdl.bind.sdl	),
	__traits(allMembers, bindbc.sdl.bind.sdlassert	),
	__traits(allMembers, bindbc.sdl.bind.sdlatomic	),
	__traits(allMembers, bindbc.sdl.bind.sdlaudio	),
	__traits(allMembers, bindbc.sdl.bind.sdlblendmode	),
	__traits(allMembers, bindbc.sdl.bind.sdlclipboard	),
	__traits(allMembers, bindbc.sdl.bind.sdlcpuinfo	),
	__traits(allMembers, bindbc.sdl.bind.sdlerror	),
	__traits(allMembers, bindbc.sdl.bind.sdlevents	),
	__traits(allMembers, bindbc.sdl.bind.sdlfilesystem	),
	__traits(allMembers, bindbc.sdl.bind.sdlgamecontroller	),
	__traits(allMembers, bindbc.sdl.bind.sdlgesture	),
	__traits(allMembers, bindbc.sdl.bind.sdlhaptic	),
	__traits(allMembers, bindbc.sdl.bind.sdlhints	),
	__traits(allMembers, bindbc.sdl.bind.sdljoystick	),
	__traits(allMembers, bindbc.sdl.bind.sdlkeyboard	),
	__traits(allMembers, bindbc.sdl.bind.sdlkeycode	),
	__traits(allMembers, bindbc.sdl.bind.sdlloadso	),
	__traits(allMembers, bindbc.sdl.bind.sdllog	),
	__traits(allMembers, bindbc.sdl.bind.sdlmessagebox	),
	__traits(allMembers, bindbc.sdl.bind.sdlmouse	),
	__traits(allMembers, bindbc.sdl.bind.sdlmutex	),
	__traits(allMembers, bindbc.sdl.bind.sdlpixels	),
	__traits(allMembers, bindbc.sdl.bind.sdlplatform	),
	__traits(allMembers, bindbc.sdl.bind.sdlpower	),
	__traits(allMembers, bindbc.sdl.bind.sdlrect	),
	__traits(allMembers, bindbc.sdl.bind.sdlrender	),
	__traits(allMembers, bindbc.sdl.bind.sdlrwops	),
	__traits(allMembers, bindbc.sdl.bind.sdlscancode	),
	__traits(allMembers, bindbc.sdl.bind.sdlshape	),
	__traits(allMembers, bindbc.sdl.bind.sdlstdinc	),
	__traits(allMembers, bindbc.sdl.bind.sdlsurface	),
	__traits(allMembers, bindbc.sdl.bind.sdlsystem	),
	__traits(allMembers, bindbc.sdl.bind.sdlsyswm	),
	__traits(allMembers, bindbc.sdl.bind.sdlthread	),
	__traits(allMembers, bindbc.sdl.bind.sdltimer	),
	__traits(allMembers, bindbc.sdl.bind.sdltouch	),
	__traits(allMembers, bindbc.sdl.bind.sdlversion	),
	__traits(allMembers, bindbc.sdl.bind.sdlvideo	),
	__traits(allMembers, bindbc.sdl.bind.sdlvulkan	),
].filter!(a=>a.startsWith("SDL_")).map!(a=>a[4..$]);


////enum enumMembers = members.filter!(a=>a.toUpper==a);
////
////static foreach(mem; enumMembers.filter!(a=>a.canFind("_")).map!(a=>a.until("_").array).uniq) {
////	static if (mem != "AUDIO") {
////		pragma(msg, mem);
////mixin("enum "~mem.to!string.capitalize~" {
////"~enumMembers.filter!(a=>a.startsWith(mem)).map!((a){
////	string mem = a[mem.length+1..$].split("_")[0].toLower ~ a[mem.length+1..$].split("_")[1..$].map!capitalize.join;
////	if (mem == "break")
////		mem ~= "_";
////	return "\t"~mem~" = SDL_"~a~",";
////}).join("\n")~"
////}");
////	}
////}

static foreach (mem; members) {
	static if (is(mixin("SDL_"~mem)) && is(mixin("SDL_"~mem) == enum)) {
		////pragma(msg, "enum: "~mem);
		static if (!["bool"].canFind(mem)) {
			static if (__traits(allMembers, mixin("SDL_"~mem))[0].count("_")>=2)
public
mixin("enum "~mem~" : SDL_"~mem~" {
"~[__traits(allMembers, mixin("SDL_"~mem))].map!(a=>tuple(a.capsToCamelChop2.unkeyword,a)).map!(a=>"\t"~a[0]~" = "~a[1]~",").join("\n")~"
}");
			else
public
mixin("enum "~mem~" : SDL_"~mem~" {
"~[__traits(allMembers, mixin("SDL_"~mem))].map!(a=>tuple(a.capsToCamelChop1.unkeyword,a)).map!(a=>"\t"~a[0]~" = "~a[1]~",").join("\n")~"
}");
		}
	}
	else static if (is(typeof(mixin("SDL_"~mem))) && isFunction!(typeof(mixin("SDL_"~mem))) && mem.toUpper != mem) {
		////pragma(msg, "function: "~mem);
////		static if (is(ReturnType!(mixin("SDL_"~mem)) == void))
////mixin("void "~mem.toLowerFirst~"(Parameters!(SDL_"~mem~") args) {
////	SDL_"~mem~"(args);
////}");
////		else
public
mixin("auto "~mem.toLowerFirst~"(Parameters!(SDL_"~mem~") args) {
	return SDL_"~mem~"(args);
}");
	}
	else static if ((is(mixin("SDL_"~mem) == struct) || is(mixin("SDL_"~mem) == union))) {
		////pragma(msg, "struct: "~mem);
		static if (mem[0].isUpper)
			public
			mixin("alias "~mem~" = SDL_"~mem~";");
	}
	else static if (is(typeof(mixin("SDL_"~mem))) && !isFunction!(typeof(mixin("SDL_"~mem))) && !["HAPTIC_PAUSE","QUIT",].canFind(mem)) {
		public
		mixin("alias "~mem.capsToCamel.unkeyword~" = SDL_"~mem~";");
	}
}




string toUpperFirst(string s) {
	if (s.length==0)
		return s;
	return s[0].toUpper.to!char ~ s[1..$];
}
string toLowerFirst(string s) {
	if (s.length==0)
		return s;
	return s[0].toLower.to!char ~ s[1..$];
}

string unkeyword(string s) {
	if (["break","try","return","delete","out","static","default","override","true","false",].canFind(s))
		s ~= "_";
	else if (s[0].isDigit)
		s = "n" ~ s;
	return s;
}

string capsToCamel(string s) {
	if (s.length==0)
		return s;
	return s.split("_")[0].toLower ~ s.split("_")[1..$].map!capitalize.join;
}

string capsToCamelChop1(string s) {
	if (s.length==0)
		return s;
	return s.split("_")[1].toLower ~ s.split("_")[2..$].map!capitalize.join;
}
string capsToCamelChop2(string s) {
	if (s.length==0)
		return s;
	return s.split("_")[2].toLower ~ s.split("_")[3..$].map!capitalize.join;
}


////[members]
////static foreach(m; members) {
////	static if (m.startsWith("SDL_")) {
////		static if (m[4..$].toUpper == m[4..$]) {
////			pragma(msg, m[4..$].split("_")[0].toLower~m[4..$][1..$].split("_").map!capitalize.join);
////			////static if (m[4..$].canFind("_")) {
////			////	pragma(msg, m[4..$].until("_").array);
////			////}
////		}
////	}
////}




////alias edl(string name) = edl!(mixin("SDL_"~name));
////template edl(alias f) {
////	pragma(msg, Parameters!f);
////	auto edl(Parameters!f args) {
////		static if (is(ReturnType!f==void)) {
////			f(args);
////		}
////		else {
////			auto rd = f(args);
////			static if (isPointer!(typeof(rd))) if (rd == null) {
////				throw new EdlError("Call failed: "~SDL_GetError.fromStringz.idup);
////			}
////			static if (is(typeof(rd)==int)) if (rd != 0) {
////				throw new EdlError("Call failed: "~SDL_GetError.fromStringz.idup);
////			}
////			return rd;
////		}
////	}
////}
////
////
////alias EDL(string name) = Self!(mixin("SDL_"~name));
////alias EDL(alias E) = E;
////private template Self(alias s) {
////	alias Self = s;
////}
////
////
////alias Edl(string name) = Edl!(mixin("Vk"~name));
////template Edl(T) {
////	alias Edl = T;
////}
////
////
////class EdlError : Exception {
////	this(string msg, string file = __FILE__, size_t line = __LINE__) {
////		super(msg, file, line);
////	}
////}

