module debug_rendering_.debug_rendering_; 

import std.stdio;

import std.algorithm;

import bindbc.sdl;
import debug_rendering_._edl_;

import world_;
import math.linear.vector;
import math.linear.point;

import updaterate_;

alias ScreenPos = PVec2!ScreenPosT;	alias ScreenPosT = int;

struct RRect {
	union {
		struct {
			int x;
			int y;
			int w;
			int h;
		}
		struct {
			ScreenPos pos;
			int[2] size;
		}
		Rect rect;
	}
}

class DebugRendering {
	Window* window;
	Renderer* renderer;
	
	View view;
	Selector selector;
	
	class View {
		float zoom;
		RelPos pos;
		
		this() {
			pos = pvec(0f,0);
			zoom = 0.0001;
		}
		
		void event(Event event) {
			if (event.type == mousewheel) {
				if (event.wheel.y > 0) {
					zoom *= 1.5;
				}
				else {
					zoom *= 2/3f;
				}
			}
			else if (event.type == mousemotion) {
				if (event.motion.state & buttonLmask) {
					view.pos.x -= event.motion.xrel/zoom*2;
					view.pos.y -= event.motion.yrel/zoom*2;
				}
			}
		}
		
		ScreenPos toScreenPos(WorldPos pos) {
			return	point(((pos-view.pos.vector).vector * view.zoom).castType!int+renderSize/2);
		}
		WorldPos fromScreenPos(ScreenPos pos) {
			return point(((pos-renderSize/2).vector / view.zoom + view.pos.vector).castType!WorldPosT);
		}
	}
	class Selector {
		Entity[] selected;
		void event(Event event) {
			if (event.type == mousebuttondown) {
				selected.length = 0;  selected.assumeSafeAppend;
				auto pos = view.fromScreenPos(pvec(event.button.x, event.button.y));
				foreach (entity; world.physicsWorld.entities) {
					auto r = max(2, cast(int)(entity.object.broadRadius*0.7));
					if (pos.x >= entity.pos.x-r && pos.x <= entity.pos.x+r && pos.y >= entity.pos.y-r && pos.y <= entity.pos.y+r) {
						writeln(entity);
						selected ~= entity;
					}
				}
			}
		}
	}
	
	Vec2!int renderSize;
	
	World world;
	
	bool paused;
	
	this(World world) {
		this.world = world;
		view = new View;
		selector = new Selector;
		
		window = createWindow("Stigma", 
			SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,
			640*2, 480*2,
			WindowFlags.resizable
		);
		renderer = createRenderer(
			window,
			-1,
			RendererFlags.accelerated,
		);
		
		renderer.getRendererOutputSize(&renderSize.x, &renderSize.y);
	}
	~this() {
		window.destroyWindow;
		quit;
	}
	
	void update() {
		for (Event event; pollEvent(&event);) {
			if (event.type == cast(SDL_EventType) EventType.quit) {
			}
			else if (event.type == windowevent) {
				if (event.window.event == windoweventResized) {
					window.setWindowSize(event.window.data1, event.window.data2);
					renderer.getRendererOutputSize(&renderSize.x,&renderSize.y);
				}
			}
			else {
				if (event.type == keydown) {
					if (event.key.keysym.sym == SDLK_e) {
						import std.stdio;
						writeln(world.physicsWorld.entities.length);
					}
					else if (event.key.keysym.sym == SDLK_p) {
						paused = !paused;
						import std.stdio;
						writeln(paused?"paused":"unpaused");
					}
					else if (event.key.keysym.sym == SDLK_s) {
						if (paused)
							return;
					}
					else if (event.key.keysym.sym == SDLK_UP) {
						updaterate = updaterate*2/3;
						import std.stdio;
						writeln(updaterate);
					}
					else if (event.key.keysym.sym == SDLK_DOWN) {
						updaterate = updaterate*3/2;
						import std.stdio;
						writeln(updaterate);
					}
				}
				view.event(event);
				selector.event(event);
			}
		}
		
		renderer.setRenderDrawColor(0,0,0, 255);
		renderer.renderClear;
		
		foreach (entity; world.physicsWorld.entities) {
			renderer.setRenderDrawColor(0,255,255, 255);
			drawSpot(entity.pos, max(2, cast(int)(entity.object.broadRadius*view.zoom*1.4)), selector.selected.canFind(entity));
			if (entity.object == fineShipObject) {
				////import std.stdio; if (entity.trajectory.length == 0) writeln("Fully recreating trajectory!");
				foreach_reverse (i,traj; entity.traject(world.physicsWorld.gravityWells, 16*16*16)) {
					renderer.setRenderDrawColor(cast(ubyte)max(16,min(255*2 - cast(long)i/2, 255)),cast(ubyte)max(0,255 - cast(long)i/2),0, 255);
					drawSpot(traj, 2);
				}
			}
		}
		
		renderer.renderPresent;
		
		if (paused)
			update;
	}
	
	void drawSpot(WorldPos pos, int size, bool fill=false) {
		RRect r;
		r.pos = view.toScreenPos(pos) - size/2;
		r.w = size; r.h = size;
		
		if (fill)
			renderer.renderFillRect(&r.rect);
		else
			renderer.renderDrawRect(&r.rect);
	}
}
