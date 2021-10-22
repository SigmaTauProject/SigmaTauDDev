module debug_rendering_.debug_rendering_; 

import bindbc.sdl;
import debug_rendering_._edl_;

import math.linear.vector;
import math.linear.point;

import world_.world_;

////extern(C) int SDL_RenderGeometry(void* renderer,
////                                               void* texture,
////                                               void* vertices, int num_vertices,
////                                               int* indices, int num_indices);

class DebugRendering {
	Window* window;
	Renderer* renderer;
	
	float zoom;
	Vec2!float pos;
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
		pos = vec(0f,0);
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
				viewer.event(event);
			}
		}
		
		renderer.setRenderDrawColor(0,0,0, 255);
		renderer.renderClear;
		
		renderer.setRenderDrawColor(0, 255, 255, 255);
		foreach (entity; world.physicsWorld.entities) {
			int s = cast(int)(entity.object.broadRadius*zoom*1.4);
			Rect rect = {cast(int)((entity.pos.x-pos.x)*zoom-s/2)+renderSize[0]/2, cast(int)((entity.pos.y-pos.y)*zoom-s/2)+renderSize[1]/2, s, s};
			renderer.renderDrawRect(&rect);
		}
		
		renderer.renderPresent;
	}
	
}