//Code written by ZungryWare

//maze.qc File Description:
/* Defines the boss_ooze entity, a boss monster that the player must chase down with their melee weapon while it spawns monsters for you to fight.
Designed specifically for use in The Dredge Arena*/

//If set, it never dies and instead keeps a high score.
#define FL_HIGHSCORE 1
//If set, it selects a random waypoint to visit instead of following a path
#define FL_RANDOM 2

void() boss_ooze = {
	//TODO sounds
	
	precache_model("progs/ooze.mdl");
	setmodel (self, "progs/ooze.mdl");

	setsize (self, '-16 -16 -24', '16 16 40');
	
	//Sets the ooze's initial health
	if (self.spawnflags & FL_HIGHSCORE) {
		self.health = 40000;
	} else {
		if (!self.health) {
			self.health = 3;
		}
	}

	/*self.th_stand = ooze_stand;
	self.th_walk = ooze_walk1;
	self.th_missile = ooze_missile;
	self.th_pain = ooze_pain;
	self.th_die = ooze_die;*/
	
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_FLY;
	self.takedamage = DAMAGE_AIM;
	self.flags = self.flags | FL_FLY;
}







