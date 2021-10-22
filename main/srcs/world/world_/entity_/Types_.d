module world_.entity_.Types_;

import math.linear.vector;
import math.linear.point;
 
//---POSITIONAL
alias WorldPos = PVec2!WorldPosT;	alias WorldPosT = long;
alias WorldVel = Vec2!WorldVelT;	alias WorldVelT = int;

//-rel
alias RelT = float;
alias RelPos = PVec2!RelT;
alias RelVel = Vec2!RelT;

alias Imp = Vec2!ImpT;	alias ImpT = RelT;


//---ROTATIONAL
alias Ori = ushort;
alias Anv = int;
alias Ana = Anv;

//-radians
alias Radians = float;

alias Ani = Radians;
