
/*QUAKED info_null (0 0.5 0) (-4 -4 -4) (4 4 4)
Used as a positional target for spotlights, etc.
*/
void() info_null =
{
	remove(self);
};

/*QUAKED info_notnull (0 0.5 0) (-4 -4 -4) (4 4 4)
Used as a positional target for lightning.
*/
void() info_notnull =
{
};

//============================================================================

float START_OFF = 1;

void() light_use =
{
	if (self.spawnflags & START_OFF)
	{
		lightstyle(self.style, "m");
		self.spawnflags = self.spawnflags - START_OFF;
	}
	else
	{
		lightstyle(self.style, "a");
		self.spawnflags = self.spawnflags + START_OFF;
	}
};

/*QUAKED light (0 1 0) (-8 -8 -8) (8 8 8) START_OFF
Non-displayed light.
Default light value is 300
Default style is 0
If targeted, it will toggle between on or off.
*/
void() light =
{
	if (!self.targetname)
	{	// inert light
		remove(self);
		return;
	}
	
	if (self.style >= 32)
	{
		self.use = light_use;
		if (self.spawnflags & START_OFF)
			lightstyle(self.style, "a");
		else
			lightstyle(self.style, "m");
	}
};

/*QUAKED light_fluoro (0 1 0) (-8 -8 -8) (8 8 8) START_OFF
Non-displayed light.
Default light value is 300
Default style is 0
If targeted, it will toggle between on or off.
Makes steady fluorescent humming sound
*/
void() light_fluoro =
{
	if (self.style >= 32)
	{
		self.use = light_use;
		if (self.spawnflags & START_OFF)
			lightstyle(self.style, "a");
		else
			lightstyle(self.style, "m");
	}
	
	precache_sound ("ambience/fl_hum1.wav");
	ambientsound (self.origin, "ambience/fl_hum1.wav", 0.5, ATTN_STATIC);
};

/*QUAKED light_fluorospark (0 1 0) (-8 -8 -8) (8 8 8)
Non-displayed light.
Default light value is 300
Default style is 10
Makes sparking, broken fluorescent sound
*/
void() light_fluorospark =
{
	if (!self.style)
		self.style = 10;

	precache_sound ("ambience/buzz1.wav");
	ambientsound (self.origin, "ambience/buzz1.wav", 0.5, ATTN_STATIC);
};

/*QUAKED light_globe (0 1 0) (-8 -8 -8) (8 8 8)
Sphere globe light.
Default light value is 300
Default style is 0
*/
void() light_globe =
{
	precache_model ("progs/s_light.spr");
	setmodel (self, "progs/s_light.spr");
	makestatic (self);
};

void() FireAmbient =
{
	precache_sound ("ambience/fire1.wav");
// attenuate fast
	ambientsound (self.origin, "ambience/fire1.wav", 0.5, ATTN_STATIC);
};

/*QUAKED light_torch_small_walltorch (0 .5 0) (-10 -10 -20) (10 10 20)
Short wall torch
Default light value is 200
Default style is 0
*/
void() light_torch_small_walltorch =
{
	precache_model ("progs/flame.mdl");
	setmodel (self, "progs/flame.mdl");
	FireAmbient ();
	makestatic (self);
};

/*QUAKED light_flame_large_yellow (0 1 0) (-10 -10 -12) (12 12 18)
Large yellow flame ball
*/
void() light_flame_large_yellow =
{
	precache_model ("progs/flame2.mdl");
	setmodel (self, "progs/flame2.mdl");
	self.frame = 1;
	FireAmbient ();
	makestatic (self);
};

/*QUAKED light_flame_small_yellow (0 1 0) (-8 -8 -8) (8 8 8) START_OFF
Small yellow flame ball
*/
void() light_flame_small_yellow =
{
	precache_model ("progs/flame2.mdl");
	setmodel (self, "progs/flame2.mdl");
	FireAmbient ();
	makestatic (self);
};

/*QUAKED light_flame_small_white (0 1 0) (-10 -10 -40) (10 10 40) START_OFF
Small white flame ball
*/
void() light_flame_small_white =
{
	precache_model ("progs/flame2.mdl");
	setmodel (self, "progs/flame2.mdl");
	FireAmbient ();
	makestatic (self);
};

//============================================================================


/*QUAKED misc_fireball (0 .5 .8) (-8 -8 -8) (8 8 8)
Lava Balls
*/

void() fire_fly;
void() fire_touch;
void() misc_fireball =
{
	
	precache_model ("progs/lavaball.mdl");
	self.classname = "fireball";
	self.nextthink = time + (random() * 5);
	self.think = fire_fly;
	if (!self.speed)
		self.speed == 1000;
};

void() fire_fly =
{
local entity	fireball;

	fireball = spawn();
	fireball.solid = SOLID_TRIGGER;
	fireball.movetype = MOVETYPE_TOSS;
	fireball.velocity = '0 0 1000';
	fireball.velocity_x = (random() * 100) - 50;
	fireball.velocity_y = (random() * 100) - 50;
	fireball.velocity_z = self.speed + (random() * 200);
	fireball.classname = "fireball";
	setmodel (fireball, "progs/lavaball.mdl");
	setsize (fireball, '0 0 0', '0 0 0');
	setorigin (fireball, self.origin);
	fireball.nextthink = time + 5;
	fireball.think = SUB_Remove;
	fireball.touch = fire_touch;
	
	self.nextthink = time + (random() * 5) + 3;
	self.think = fire_fly;
};


void() fire_touch =
{
	T_Damage (other, self, self, 20);
	remove(self);
};

//============================================================================

void() barrel_explode =
{
	self.takedamage = DAMAGE_NO;
	self.classname = "explo_box";
	// did say self.owner
	T_RadiusDamage (self, self, 160, world);
	sound (self, CHAN_VOICE, "weapons/r_exp3.wav", 1, ATTN_NORM);
	particle (self.origin, '0 0 0', 75, 255);
	//SUB_UseTargets();

	self.origin_z = self.origin_z + 32;
	BecomeExplosion ();
};



/*QUAKED misc_explobox (0 .5 .8) (0 0 0) (32 32 64)
TESTING THING
*/

void() misc_explobox =
{
	local float	oldz;
	
	self.solid = SOLID_BBOX;
	self.movetype = MOVETYPE_NONE;
	precache_model ("maps/b_explob.bsp");
	setmodel (self, "maps/b_explob.bsp");
	precache_sound ("weapons/r_exp3.wav");
	self.health = 20;
	self.th_die = barrel_explode;
	self.takedamage = DAMAGE_AIM;

	self.origin_z = self.origin_z + 2;
	oldz = self.origin_z;
	droptofloor();
	if (oldz - self.origin_z > 250)
	{
		dprint ("item fell out of level at ");
		dprint (vtos(self.origin));
		dprint ("\n");
		remove(self);
	}
};




/*QUAKED misc_explobox2 (0 .5 .8) (0 0 0) (32 32 64)
Smaller exploding box, REGISTERED ONLY
*/

void() misc_explobox2 =
{
	local float	oldz;
	
	self.solid = SOLID_BBOX;
	self.movetype = MOVETYPE_NONE;
	precache_model2 ("maps/b_exbox2.bsp");
	setmodel (self, "maps/b_exbox2.bsp");
	precache_sound ("weapons/r_exp3.wav");
	self.health = 20;
	self.th_die = barrel_explode;
	self.takedamage = DAMAGE_AIM;

	self.origin_z = self.origin_z + 2;
	oldz = self.origin_z;
	droptofloor();
	if (oldz - self.origin_z > 250)
	{
		dprint ("item fell out of level at ");
		dprint (vtos(self.origin));
		dprint ("\n");
		remove(self);
	}
};

//============================================================================

float SPAWNFLAG_SUPERSPIKE	= 1;
float SPAWNFLAG_LASER = 2;

void(vector org, vector vec) LaunchLaser;

void() spikeshooter_use =
{
	if (self.spawnflags & SPAWNFLAG_LASER)
	{
		sound (self, CHAN_VOICE, "enforcer/enfire.wav", 1, ATTN_NORM);
		LaunchLaser (self.origin, self.movedir);
	}
	else
	{
		sound (self, CHAN_VOICE, "weapons/spike2.wav", 1, ATTN_NORM);
		launch_spike (self.origin, self.movedir);
		newmis.velocity = self.movedir * 500;
		if (self.spawnflags & SPAWNFLAG_SUPERSPIKE)
			newmis.touch = superspike_touch;
	}
};

void() shooter_think =
{
	spikeshooter_use ();
	self.nextthink = time + self.wait;
	newmis.velocity = self.movedir * 500;
};


/*QUAKED trap_spikeshooter (0 .5 .8) (-8 -8 -8) (8 8 8) superspike laser
When triggered, fires a spike in the direction set in QuakeEd.
Laser is only for REGISTERED.
*/

void() trap_spikeshooter =
{
	SetMovedir ();
	self.use = spikeshooter_use;
	if (self.spawnflags & SPAWNFLAG_LASER)
	{
		precache_model2 ("progs/laser.mdl");
		
		precache_sound2 ("enforcer/enfire.wav");
		precache_sound2 ("enforcer/enfstop.wav");
	}
	else
		precache_sound ("weapons/spike2.wav");
};


/*QUAKED trap_shooter (0 .5 .8) (-8 -8 -8) (8 8 8) superspike laser
Continuously fires spikes.
"wait" time between spike (1.0 default)
"nextthink" delay before firing first spike, so multiple shooters can be stagered.
*/
void() trap_shooter =
{
	trap_spikeshooter ();
	
	if (self.wait == 0)
		self.wait = 1;
	self.nextthink = self.nextthink + self.wait + self.ltime;
	self.think = shooter_think;
};



/*
===============================================================================


===============================================================================
*/


void() make_bubbles;
void() bubble_remove;
void() bubble_bob;

/*QUAKED air_bubbles (0 .5 .8) (-8 -8 -8) (8 8 8)

testing air bubbles
*/

void() air_bubbles =

{
	if (deathmatch)
	{
		remove (self);
		return;
	}
	precache_model ("progs/s_bubble.spr");
	self.nextthink = time + 1;
	self.think = make_bubbles;
};

void() make_bubbles =
{
local entity	bubble;

	bubble = spawn();
	setmodel (bubble, "progs/s_bubble.spr");
	setorigin (bubble, self.origin);
	bubble.movetype = MOVETYPE_NOCLIP;
	bubble.solid = SOLID_NOT;
	bubble.velocity = '0 0 15';
	bubble.nextthink = time + 0.5;
	bubble.think = bubble_bob;
	bubble.touch = bubble_remove;
	bubble.classname = "bubble";
	bubble.frame = 0;
	bubble.cnt = 0;
	setsize (bubble, '-8 -8 -8', '8 8 8');
	self.nextthink = time + random() + 0.5;
	self.think = make_bubbles;
};

void() bubble_split =
{
local entity	bubble;
	bubble = spawn();
	setmodel (bubble, "progs/s_bubble.spr");
	setorigin (bubble, self.origin);
	bubble.movetype = MOVETYPE_NOCLIP;
	bubble.solid = SOLID_NOT;
	bubble.velocity = self.velocity;
	bubble.nextthink = time + 0.5;
	bubble.think = bubble_bob;
	bubble.touch = bubble_remove;
	bubble.classname = "bubble";
	bubble.frame = 1;
	bubble.cnt = 10;
	setsize (bubble, '-8 -8 -8', '8 8 8');
	self.frame = 1;
	self.cnt = 10;
	if (self.waterlevel != 3)
		remove (self);
};

void() bubble_remove =
{
	if (other.classname == self.classname)
	{
//		dprint ("bump");
		return;
	}
	remove(self);
};

void() bubble_bob =
{
local float		rnd1, rnd2, rnd3;
local vector	vtmp1, modi;

	self.cnt = self.cnt + 1;
	if (self.cnt == 4)
		bubble_split();
	if (self.cnt == 20)
		remove(self);

	rnd1 = self.velocity_x + (-10 + (random() * 20));
	rnd2 = self.velocity_y + (-10 + (random() * 20));
	rnd3 = self.velocity_z + 10 + random() * 10;

	if (rnd1 > 10)
		rnd1 = 5;
	if (rnd1 < -10)
		rnd1 = -5;
		
	if (rnd2 > 10)
		rnd2 = 5;
	if (rnd2 < -10)
		rnd2 = -5;
		
	if (rnd3 < 10)
		rnd3 = 15;
	if (rnd3 > 30)
		rnd3 = 25;
	
	self.velocity_x = rnd1;
	self.velocity_y = rnd2;
	self.velocity_z = rnd3;
		
	self.nextthink = time + 0.5;
	self.think = bubble_bob;
};

/*~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>
~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~*/

/*QUAKED viewthing (0 .5 .8) (-8 -8 -8) (8 8 8)

Just for the debugging level.  Don't use
*/

void() viewthing =

{
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	precache_model ("progs/player.mdl");
	setmodel (self, "progs/player.mdl");
};


/*
==============================================================================

SIMPLE BMODELS

==============================================================================
*/

void() func_wall_use =
{	// change to alternate textures
	self.frame = 1 - self.frame;
};

/*QUAKED func_wall (0 .5 .8) ?
This is just a solid wall if not inhibitted
*/
void() func_wall =
{
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_PUSH;	// so it doesn't get pushed by anything
	self.solid = SOLID_BSP;
	self.use = func_wall_use;
	setmodel (self, self.model);
};


/*QUAKED func_illusionary (0 .5 .8) ?
A simple entity that looks solid but lets you walk through it.
*/
void() func_illusionary =

{
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	setmodel (self, self.model);
	makestatic ();
};

/*QUAKED func_episodegate (0 .5 .8) ? E1 E2 E3 E4
This bmodel will appear if the episode has allready been completed, so players can't reenter it.
*/
void() func_episodegate =

{
	if (!(serverflags & self.spawnflags))
		return;			// can still enter episode

	self.angles = '0 0 0';
	self.movetype = MOVETYPE_PUSH;	// so it doesn't get pushed by anything
	self.solid = SOLID_BSP;
	self.use = func_wall_use;
	setmodel (self, self.model);
};

/*QUAKED func_bossgate (0 .5 .8) ?
This bmodel appears unless players have all of the episode sigils.
*/
void() func_bossgate =

{
	if ( (serverflags & 15) == 15)
		return;		// all episodes completed
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_PUSH;	// so it doesn't get pushed by anything
	self.solid = SOLID_BSP;
	self.use = func_wall_use;
	setmodel (self, self.model);
};

//============================================================================
/*QUAKED ambient_suck_wind (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/
void() ambient_suck_wind =
{
	precache_sound ("ambience/suck1.wav");
	ambientsound (self.origin, "ambience/suck1.wav", 1, ATTN_STATIC);
};

/*QUAKED ambient_drone (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/
void() ambient_drone =
{
	precache_sound ("ambience/drone6.wav");
	ambientsound (self.origin, "ambience/drone6.wav", 0.5, ATTN_STATIC);
};

/*QUAKED ambient_flouro_buzz (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/
void() ambient_flouro_buzz =
{
	precache_sound ("ambience/buzz1.wav");
	ambientsound (self.origin, "ambience/buzz1.wav", 1, ATTN_STATIC);
};
/*QUAKED ambient_drip (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/
void() ambient_drip =
{
	precache_sound ("ambience/drip1.wav");
	ambientsound (self.origin, "ambience/drip1.wav", 0.5, ATTN_STATIC);
};
/*QUAKED ambient_comp_hum (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/
void() ambient_comp_hum =
{
	precache_sound ("ambience/comp1.wav");
	ambientsound (self.origin, "ambience/comp1.wav", 1, ATTN_STATIC);
};
/*QUAKED ambient_thunder (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/
void() ambient_thunder =
{
	precache_sound ("ambience/thunder1.wav");
	ambientsound (self.origin, "ambience/thunder1.wav", 0.5, ATTN_STATIC);
};
/*QUAKED ambient_light_buzz (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/
void() ambient_light_buzz =
{
	precache_sound ("ambience/fl_hum1.wav");
	ambientsound (self.origin, "ambience/fl_hum1.wav", 0.5, ATTN_STATIC);
};
/*QUAKED ambient_swamp1 (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/
void() ambient_swamp1 =
{
	precache_sound ("ambience/swamp1.wav");
	ambientsound (self.origin, "ambience/swamp1.wav", 0.5, ATTN_STATIC);
};
/*QUAKED ambient_swamp2 (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/
void() ambient_swamp2 =
{
	precache_sound ("ambience/swamp2.wav");
	ambientsound (self.origin, "ambience/swamp2.wav", 0.5, ATTN_STATIC);
};

//============================================================================

void() noise_think =
{
	self.nextthink = time + 0.5;
	sound (self, 1, "enforcer/enfire.wav", 1, ATTN_NORM);
	sound (self, 2, "enforcer/enfstop.wav", 1, ATTN_NORM);
	sound (self, 3, "enforcer/sight1.wav", 1, ATTN_NORM);
	sound (self, 4, "enforcer/sight2.wav", 1, ATTN_NORM);
	sound (self, 5, "enforcer/sight3.wav", 1, ATTN_NORM);
	sound (self, 6, "enforcer/sight4.wav", 1, ATTN_NORM);
	sound (self, 7, "enforcer/pain1.wav", 1, ATTN_NORM);
};

/*QUAKED misc_noisemaker (1 0.5 0) (-10 -10 -10) (10 10 10)

For optimzation testing, starts a lot of sounds.
*/

void() misc_noisemaker =

{
	precache_sound2 ("enforcer/enfire.wav");
	precache_sound2 ("enforcer/enfstop.wav");
	precache_sound2 ("enforcer/sight1.wav");
	precache_sound2 ("enforcer/sight2.wav");
	precache_sound2 ("enforcer/sight3.wav");
	precache_sound2 ("enforcer/sight4.wav");
	precache_sound2 ("enforcer/pain1.wav");
	precache_sound2 ("enforcer/pain2.wav");
	precache_sound2 ("enforcer/death1.wav");
	precache_sound2 ("enforcer/idle1.wav");

	self.nextthink = time + 0.1 + random();
	self.think = noise_think;
};

void() unlockitem_use = {
	set_specialflag(self.rune_id, 1);
	ghostItems();
}

void() effect_unlockitem = {
	self.use = unlockitem_use;
	
	if (!self.rune_id) {
		self.level_id = 5;
	}
}

void() striptomelee_use = {
	if (activator.classname != "player") {
		return;
	}
	activator.items = IT_AXE;
	activator.ammo_shells = 0;
	activator.ammo_nails = 0;
	activator.ammo_rockets = 0;
	activator.ammo_cells = 0;
}

void() effect_striptomelee = {
	self.use = striptomelee_use;
}

void() breakable_die = {
	SUB_UseTargets();
	sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);
	float volume = (self.absmax_x - self.absmin_x) * (self.absmax_y - self.absmin_y) * (self.absmax_z - self.absmin_z);
	float i = volume > 3 ? volume : 3;
	for (; i > 0; i -= 40000) {
		ThrowGib ("progs/gib_metal1.mdl", self.health + 20);
	}
	remove(self);
}

void() breakable_use = {
	self.takedamage = DAMAGE_YES;
	T_Damage(self,self,self,100);
}

void() func_breakable = {
	precache_model ("progs/gib_metal1.mdl");
	
	if (self.sounds == 0)
	{
		precache_sound ("break/stone.wav");
		self.noise = "break/stone.wav";
	}
	else if (self.sounds == 1)
	{
		precache_sound ("break/glass.wav");
		self.noise = "break/glass.wav";
	}
	else if (self.sounds == 2)
	{
		precache_sound ("break/metal.wav");
		self.noise = "break/metal.wav";
	}
	
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_PUSH;	// so it doesn't get pushed by anything
	self.solid = SOLID_BSP;
	setmodel (self, self.model);
	
	if (!self.health) {
		self.health = 1;
	}
	
	if (!(self.spawnflags & 1)) {
		self.takedamage = DAMAGE_YES;
	}
	self.use = breakable_use;
	self.th_die = breakable_die;
	
	setorigin (self, self.origin);
};

void() globalmsg_use = {
	entity t;
	
	if (self.message != "") {
		t = world;
		while ( 1 ) {
			t = find (t, classname, "player");
			if (!t) {
				return;
			}
			
			centerprint (t, self.message);
			if (self.noise) {
				sound (t, CHAN_VOICE, self.noise, 1, ATTN_NORM);
			}
		}
	}
};

void() effect_globalmsg = {
	if (self.sounds == 1)
	{
		precache_sound ("misc/secret.wav");
		self.noise = "misc/secret.wav";
	}
	else if (self.sounds == 2)
	{
		precache_sound ("misc/talk.wav");
		self.noise = "misc/talk.wav";
	}
	else if (self.sounds == 3)
	{
		precache_sound ("misc/trigger1.wav");
		self.noise = "misc/trigger1.wav";
	}
	
	self.use = globalmsg_use;
};

void() stuffcmd_use = {
	stuffcmd(activator,self.message);
	stuffcmd(activator,"\n");
};

void() effect_stuffcmd = {
	if (!self.message) {
		remove(self);
		return;
	}
	self.use = stuffcmd_use;
};

void() localcmd_use = {
	localcmd(self.message);
	localcmd("\n");
};

void() effect_localcmd = {
	if (!self.message) {
		remove(self);
		return;
	}
	self.use = localcmd_use;
};

void() changemusic_use = {
	WriteByte (MSG_ALL, SVC_CDTRACK);
	WriteByte (MSG_ALL, self.sounds);
	WriteByte (MSG_ALL, 3);
};

void() effect_changemusic = {
	self.use = changemusic_use;
};

void() missionlist_use = {
	if (other.scroll_direction == 0) {
		if (self.count == self.topMission) {
			self.count = 0;
		} else {
			self.count ++;
		}
	} else if (other.scroll_direction == 1) {
		if (self.count == 0) {
			self.count = self.topMission;
		} else {
			self.count --;
		}
	}
	self.message = self.missions[self.count];
}

void() effect_missionlist = {
	if (!self.mission1) {
		return;
	}
	precache_sound ("misc/talk.wav");
	self.noise = "misc/talk.wav";
	self.use = missionlist_use;
	self.count = 0;
	
	self.missions[0] = self.mission0;
	self.missions[1] = self.mission1;
	self.missions[2] = self.mission2;
	self.missions[3] = self.mission3;
	self.missions[4] = self.mission4;
	self.missions[5] = self.mission5;
	self.missions[6] = self.mission6;
	self.missions[7] = self.mission7;
	self.missions[8] = self.mission8;
	self.missions[9] = self.mission9;
	self.missions[10] = self.mission10;
	self.missions[11] = self.mission11;
	self.missions[12] = self.mission12;
	self.missions[13] = self.mission13;
	self.missions[14] = self.mission14;
	self.missions[15] = self.mission15;
	
	self.topMission = 0;
	while (self.topMission < 16) {
		self.topMission ++;
		if (!self.missions[self.topMission]) {
			self.topMission --;
			break;
		}
	}
	self.count = self.topMission;
};

void() hint_use = {
	float i = 0;
	while (i < 16) {
		if (!get_rune(self.level_id, i)) {
			break;
		}
		i ++;
	}
	if (!self.missions[i]) {
		return;
	}
	
	centerprint (activator, self.missions[i]);
	sound (activator, CHAN_VOICE, "misc/talk.wav", 1, ATTN_NORM);
}

void() effect_hint = {
	if (!self.mission1) {
		return;
	}
	precache_sound ("misc/talk.wav");
	self.noise = "misc/talk.wav";
	self.use = hint_use;
	
	if (!self.level_id) {
		self.level_id = world.level_id;
	}
	
	self.missions[0] = self.mission0;
	self.missions[1] = self.mission1;
	self.missions[2] = self.mission2;
	self.missions[3] = self.mission3;
	self.missions[4] = self.mission4;
	self.missions[5] = self.mission5;
	self.missions[6] = self.mission6;
	self.missions[7] = self.mission7;
	self.missions[8] = self.mission8;
	self.missions[9] = self.mission9;
	self.missions[10] = self.mission10;
	self.missions[11] = self.mission11;
	self.missions[12] = self.mission12;
	self.missions[13] = self.mission13;
	self.missions[14] = self.mission14;
	self.missions[15] = self.mission15;
};

void() effect_progressionbit_use = {
	local float bitSet;
	if (self.count == 1) {
		bitSet = 20;
	} else if (self.count < 1) {
		bitSet = 19;
	} else {
		bitSet = 21;
	}
	
	if (self.spawnflags & 2) {
		//toggle rune state
		if (get_specialflag(bitSet)) {
			set_specialflag(bitSet, 0);
		} else {
			set_specialflag(bitSet, 1);
		}
	} else if (self.spawnflags & 1) {
		set_specialflag(bitSet, 0);
	} else {
		set_specialflag(bitSet, 1);
	}
}

void() effect_progressionbit = {
	self.use = effect_progressionbit_use;
}

void(float ret) filter_output = {
	if (ret && self.spawnflags & 0) {
		SUB_UseTargets();
	}
	if (!ret && self.spawnflags & 1) {
		SUB_UseTargets();
	}
}

void() filter_progressionbit_use = {
	local float bitGet;
	if (self.count == 1) {
		bitGet = 20;
	} else if (self.count < 1) {
		bitGet = 19;
	} else {
		bitGet = 21;
	}
	
	filter_output(get_rune(15,bitGet));
}

void() filter_progressionbit = {
	self.use = filter_progressionbit_use;
}

void() filter_onceperplayer_use = {
	if (self.count >= 16) {
		filter_output(0);
		return;
	}
	if (activator.classname != "player") {
		filter_output(0);
		return;
	}
	local float i;
	for (; i < 8; i ++) {
		if (self.entity_used_list[i] == activator) {
			return;
		}
	}
	
	self.entity_used_list[self.count] = activator;
	self.count ++;
	filter_output(1);
}

void() filter_onceperplayer = {
	self.use = filter_onceperplayer_use;
}

void() filter_hasrune_use = {
	filter_output(get_rune(self.level_id,self.rune_id));
}

void() filter_hasrune = {
	self.use = filter_hasrune_use;
}

void() filter_runecount_use = {
	filter_output(count_runes());
}

void() filter_runecount = {
	self.use = filter_runecount_use;
}

void() trigger_auto = {
	self.nextthink = time + .2;
	self.think = SUB_UseTargets;
}

void() misc_model = {
	if (!self.message) {
		remove(self);
		return;
	}
	precache_model (self.message);
	setmodel (self, self.message);
	if (!(self.spawnflags & 1)) {
		makestatic (self);
	}	
}

void() lightstyle_use = {
	if (self.style && self.message) {
		lightstyle(self.style, self.message);
	}
}

void() effect_lightstyle = {
	if (!self.targetname) {
		lightstyle_use();
	}
	self.use = lightstyle_use;
}

void() revive_use = {
	entity fnd = world;
	while (1) {
		fnd = find(fnd, targetname, self.target);
		if (fnd != world) {
			revive(fnd);
		} else {
			return;
		}
	}
}

void() effect_revive = {
	self.use = revive_use;
}

void() countkill_use = {
	killed_monsters += 1;
	WriteByte(MSG_ALL, 3/*SVC_UPDATESTAT*/);
	WriteByte(MSG_ALL, 14/*STAT_TOTALMONSTERS*/);
	WriteLong(MSG_ALL, killed_monsters);
}

void() effect_countkill = {
	total_monsters += self.count;
	WriteByte(MSG_ALL, 3/*SVC_UPDATESTAT*/);
	WriteByte(MSG_ALL, 12/*STAT_TOTALMONSTERS*/);
	WriteLong(MSG_ALL, total_monsters);
	self.use = countkill_use;
}

/*void() info_wander_extremes = {}

void() wander_setbounds = {
	local entity t1;
	local entity t2;
	
	t1 = find(world, targetname, self.target);
	t2 = find(world, targetname, self.target1);
	
	if (t1 == world || t2 == world) {
		objerror("Could not find info_wander_extremes.");
	}
	
	
	
}

void() func_wander() = {
	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;
	setorigin (self, self.origin);	
	setmodel (self, self.model);
	
	self.think = wander_setbounds;
}*/

