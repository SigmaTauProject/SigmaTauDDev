module debug_rendering_.debug_rendering_; 

import std.algorithm;

import bindbc.sdl;
import debug_rendering_._edl_;

import world_;
import math.linear.vector;
import math.linear.point;

class DebugRendering {
	Window* window;
	Renderer* renderer;
	
	float zoom;
	RelPos pos;
	Viewer viewer;
	
	class Viewer {
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
					pos.x -= event.motion.xrel/zoom*2;
					pos.y -= event.motion.yrel/zoom*2;
				}
			}
		}
	}
	
	int[2] renderSize;
	
	World world;
	
	this(World world) {
		this.world = world;
		pos = pvec(0f,0);
		zoom = 0.0001;
		viewer = new Viewer;
		
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
		
		renderer.getRendererOutputSize(&renderSize[0],&renderSize[1]);
	}
	~this() {
		window.destroyWindow;
		quit;
	}
	
	void update() {
		for (Event event; pollEvent(&event);) {
			if (event.type == cast(SDL_EventType)EventType.quit) {
			}
			else if (event.type == windowevent) {
				if (event.window.event == windoweventResized) {
					window.setWindowSize(event.window.data1, event.window.data2);
					renderer.getRendererOutputSize(&renderSize[0],&renderSize[1]);
				}
			}
			else {
				if (event.type == keydown) {
					if (event.key.keysym.sym == SDLK_e) {
						import std.stdio;
						writeln(world.physicsWorld.entities.length);
					}
				}
				viewer.event(event);
			}
		}
		
		renderer.setRenderDrawColor(0,0,0, 255);
		renderer.renderClear;
		
		foreach (entity; world.physicsWorld.entities) {
			renderer.setRenderDrawColor(0,255,255, 255);
			drawSpot(entity.pos, max(2, cast(int)(entity.object.broadRadius*zoom*1.4)));
			if (entity.object == fineShipObject) {
				import std.stdio; if (entity.trajectory.length == 0) writeln("Fully recreating trajectory!");
				foreach_reverse (i,traj; entity.traject(world.physicsWorld.gravityWells, 16*16*16)) {
					renderer.setRenderDrawColor(cast(ubyte)max(16,min(255*2 - cast(long)i/2, 255)),cast(ubyte)max(0,255 - cast(long)i/2),0, 255);
					drawSpot(traj, 2);
				}
			}
		}
		
		renderer.renderPresent;
	}
	
	void drawSpot(WorldPos p, int size) {
		Rect rect = {cast(int)((p.x-pos.x)*zoom-size/2)+renderSize[0]/2, cast(int)((p.y-pos.y)*zoom-size/2)+renderSize[1]/2, size, size};
		renderer.renderDrawRect(&rect);
	}
}
