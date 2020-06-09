module world_.game_time_;

struct GameTime {
	long time;
	
	GameTime opBinary(string op)(GameDuration rhs)
	if (op=="+"||op=="-")
	{
		return GameTime(mixin("time"~op~"rhs.duration"));
	}
	GameTime opBinaryRight(string op)(GameDuration lhs)
	if (op=="+")
	{
		return GameTime(mixin("lhs.duration"~op~"time"));
	}
}
alias GameDur = GameDuration;
struct GameDuration {
	int duration;
	
	GameDuration opUnary(string op)() {
		return GameDuration(mixin(op~"duration"));
	}
	GameDuration opBinary(string op)(GameDuration rhs) {
		return GameDuration(mixin("duration"~op~"rhs.duration"));
	}
	bool opEquals(GameDuration rhs) {
		return duration==rhs.duration;
	}
	bool opCmp(string op)(GameDuration rhs) {
		return mixin("duration"~op~"rhs.duration");
	}
}

GameDuration gameDur(string unit)(int dur)
if (unit=="secs" || unit=="msecs")
{
	static if (unit=="secs")
		return GameDuration(dur*1000);
	static if (unit=="msecs")
		return GameDuration(dur);
	assert(false);
}
 
