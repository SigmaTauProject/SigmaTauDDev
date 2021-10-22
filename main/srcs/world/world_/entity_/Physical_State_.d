module world_.entity_.Physical_State_;

import world_.entity_.Types_;

struct Physical {
	union {
		Positional positional;
		struct {
			WorldPos	pos	;
			WorldVel	vel	;
		}
	}
	union {
		Rotational rotational;
		struct {
			Ori	ori	;
			Anv	anv	;
			Ana	ana	;
		}
	}
}
struct Positional {
	WorldPos	pos	;
	WorldVel	vel	;
}
struct Rotational {
	Ori	ori	;
	Anv	anv	;
	Ana	ana	;
}

