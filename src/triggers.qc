
entity s;


void() trigger_reactivate =
{
	self.solid = SOLID_TRIGGER;
};

//=============================================================================

float	SPAWNFLAG_NOMESSAGE = 1;
float	SPAWNFLAG_NOTOUCH = 1;

// the wait time has passed, so set back up for another activation
void() multi_wait =
{
	if (self.max_health)
	{
		self.health = self.max_health;
		self.takedamage = DAMAGE_YES;
		self.solid = SOLID_BBOX;
	}
};


// the trigger was just touched/killed/used
// self.enemy should be set to the activator so it can be held through a delay
// so wait for the delay time before firing
void() multi_trigger =
{
	if (self.nextthink > time)
	{
		return;		// allready been triggered
	}

	if (self.noise)
		sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);

// don't trigger again until reset
	self.takedamage = DAMAGE_NO;

	activator = self.enemy;
	
	SUB_UseTargets();

	if (self.wait > 0)	
	{
		self.think = multi_wait;
		self.nextthink = time + self.wait;
	}
	else
	{	// we can't just remove (self) here, because this is a touch function
		// called wheil C code is looping through area links...
		self.touch = SUB_Null;
		self.nextthink = time + 0.1;
		self.think = SUB_Remove;
	}
};

void() multi_killed =
{
	self.enemy = damage_attacker;
	multi_trigger();
};

void() multi_use =
{
	self.enemy = activator;
	multi_trigger();
};

void() multi_touch =
{
	if (other.classname != "player")
		return;
	
// if the trigger has an angles field, check player's facing direction
	if (self.movedir != '0 0 0')
	{
		makevectors (other.angles);
		if (v_forward * self.movedir < 0)
			return;		// not facing the right way
	}
	
	self.enemy = other;
	multi_trigger ();
};

/*QUAKED trigger_multiple (.5 .5 .5) ? notouch
Variable sized repeatable trigger.  Must be targeted at one or more entities.  If "health" is set, the trigger must be killed to activate each time.
If "delay" is set, the trigger waits some time after activating before firing.
"wait" : Seconds between triggerings. (.2 default)
If notouch is set, the trigger is only fired by other entities, not by touching.
NOTOUCH has been obsoleted by trigger_relay!
sounds
1)	secret
2)	beep beep
3)	large switch
4)
set "message" to text string
*/
void() trigger_multiple =
{
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
	
	if (!self.wait)
		self.wait = 0.2;
	self.use = multi_use;

	InitTrigger ();

	if (self.health)
	{
		if (self.spawnflags & SPAWNFLAG_NOTOUCH)
			objerror ("health and notouch don't make sense\n");
		self.max_health = self.health;
		self.th_die = multi_killed;
		self.takedamage = DAMAGE_YES;
		self.solid = SOLID_BBOX;
		setorigin (self, self.origin);	// make sure it links into the world
	}
	else
	{
		if ( !(self.spawnflags & SPAWNFLAG_NOTOUCH) )
		{
			self.touch = multi_touch;
		}
	}
};


/*QUAKED trigger_once (.5 .5 .5) ? notouch
Variable sized trigger. Triggers once, then removes itself.  You must set the key "target" to the name of another object in the level that has a matching
"targetname".  If "health" is set, the trigger must be killed to activate.
If notouch is set, the trigger is only fired by other entities, not by touching.
if "killtarget" is set, any objects that have a matching "target" will be removed when the trigger is fired.
if "angle" is set, the trigger will only fire when someone is facing the direction of the angle.  Use "360" for an angle of 0.
sounds
1)	secret
2)	beep beep
3)	large switch
4)
set "message" to text string
*/
void() trigger_once =
{
	self.wait = -1;
	trigger_multiple();
};

//=============================================================================

/*QUAKED trigger_relay (.5 .5 .5) (-8 -8 -8) (8 8 8)
This fixed size trigger cannot be touched, it can only be fired by other events.  It can contain killtargets, targets, delays, and messages.
*/
void() trigger_relay =
{
	self.use = SUB_UseTargets;
};


//=============================================================================

//Bullet Ride uses trigger_secret to warn players that they are playing on the wrong mod
//trigger_secret won't do anything if everything goes smoothly
void() trigger_secret = {
	remove(self);
}

//=============================================================================


void() counter_use =
{
	self.count = self.count - 1;
	if (self.count < 0)
		return;
	
	if (self.count != 0)
	{
		if (activator.classname == "player" && (self.spawnflags & SPAWNFLAG_NOMESSAGE) == 0)
		{
			if (self.count >= 4) {
				if (self.spawnflags & 2) {
					centerprint (activator, "There are more to go...");
				} else {
					threeprint (activator, "There are ", ftos(self.count), " more to go...");
				}
			} else if (self.count == 3) {
				centerprint (activator, "Only 3 more to go...");
			} else if (self.count == 2) {
				centerprint (activator, "Only 2 more to go...");
			} else {
				centerprint (activator, "Only 1 more to go...");
			}
		}
		return;
	}
	
	if (activator.classname == "player" && (self.spawnflags & SPAWNFLAG_NOMESSAGE) == 0) 
	{
		centerprint(activator, "Sequence completed!");
	}
	self.enemy = activator;
	multi_trigger ();
};

/*QUAKED trigger_counter (.5 .5 .5) ? nomessage
Acts as an intermediary for an action that takes multiple inputs.

If nomessage is not set, t will print "1 more.. " etc when triggered and "sequence complete" when finished.

After the counter has been triggered "count" times (default 2), it will fire all of it's targets and remove itself.
*/
void() trigger_counter =
{
	self.wait = -1;
	if (!self.count)
		self.count = 2;

	self.use = counter_use;
};


/*
==============================================================================

TELEPORT TRIGGERS

==============================================================================
*/

float	PLAYER_ONLY	= 1;
float	SILENT = 2;

void() play_teleport =
{
	local	float v;
	local	string tmpstr;

	v = random() * 5;
	if (v < 1)
		tmpstr = "misc/r_tele1.wav";
	else if (v < 2)
		tmpstr = "misc/r_tele2.wav";
	else if (v < 3)
		tmpstr = "misc/r_tele3.wav";
	else if (v < 4)
		tmpstr = "misc/r_tele4.wav";
	else
		tmpstr = "misc/r_tele5.wav";

	sound (self, CHAN_VOICE, tmpstr, 1, ATTN_NORM);
	remove (self);
};

void(vector org) spawn_tfog =
{
	s = spawn ();
	s.origin = org;
	s.nextthink = time + 0.2;
	s.think = play_teleport;

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_TELEPORT);
	WriteCoord (MSG_BROADCAST, org_x);
	WriteCoord (MSG_BROADCAST, org_y);
	WriteCoord (MSG_BROADCAST, org_z);
};


void() tdeath_touch =
{
	if (other == self.owner)
		return;

// frag anyone who teleports in on top of an invincible player
	if (other.classname == "player")
	{
		if (other.invincible_finished > time)
			self.classname = "teledeath2";
		if (self.owner.classname != "player")
		{	// other monsters explode themselves
			T_Damage (self.owner, self, self, 50000);
			return;
		}
		
	}

	if (other.health)
	{
		T_Damage (other, self, self, 50000);
	}
};


void(vector org, entity death_owner) spawn_tdeath =
{
local entity	death;

	death = spawn();
	death.classname = "teledeath";
	death.movetype = MOVETYPE_NONE;
	death.solid = SOLID_TRIGGER;
	death.angles = '0 0 0';
	setsize (death, death_owner.mins - '1 1 1', death_owner.maxs + '1 1 1');
	setorigin (death, org);
	death.touch = tdeath_touch;
	death.nextthink = time + 0.2;
	death.think = SUB_Remove;
	death.owner = death_owner;
	
	force_retouch = 2;		// make sure even still objects get hit
};

void() teleport_touch =
{
	if (self.targetname)
	{
		if (self.nextthink < time && self.nextthink != -1)
		{
			return;		// not fired yet
		}
	}

	if (self.spawnflags & PLAYER_ONLY)
	{
		if (other.classname != "player")
			return;
	}

// only teleport living creatures and runes
	if ((other.health > 0 && other.solid == SOLID_SLIDEBOX) || other.classname == "item_rune") {
		SUB_UseTargets();
		teleport_object(other, self.target, 0);
	}
};

/*QUAKED info_teleport_destination (.5 .5 .5) (-8 -8 -8) (8 8 32)
This is the destination marker for a teleporter.  It should have a "targetname" field with the same value as a teleporter's "target" field.
*/
void() info_teleport_destination =
{
// this does nothing, just serves as a target spot
	self.mangle = self.angles;
	self.angles = '0 0 0';
	self.model = "";
	self.origin = self.origin + '0 0 27';
	if (!self.targetname)
		objerror ("no targetname");
};

void() teleport_use =
{
	if (self.wait == -1) {
		self.nextthink = -1;
	} else {
		self.nextthink = time + self.wait;
	}
	
	force_retouch = 2;		// make sure even still objects get hit
	self.think = SUB_Null;
};

/*QUAKED trigger_teleport (.5 .5 .5) ? PLAYER_ONLY SILENT
Any object touching this will be transported to the corresponding info_teleport_destination entity. You must set the "target" field, and create an object with a "targetname" field that matches.

If the trigger_teleport has a targetname, it will only teleport entities when it has been fired.
*/
void() trigger_teleport =
{
	local vector o;

	InitTrigger ();
	self.touch = teleport_touch;
	// find the destination 
	if (!self.target)
		objerror ("no target");
	self.use = teleport_use;
	
	if (!self.wait) {
		self.wait = .2;
	}

	if (!(self.spawnflags & SILENT))
	{
		precache_sound ("ambience/hum1.wav");
		o = (self.mins + self.maxs)*0.5;
		ambientsound (o, "ambience/hum1.wav",0.5 , ATTN_STATIC);
	}
};

/*
==============================================================================

trigger_setskill

==============================================================================
*/

void() trigger_skill_touch =
{
	if (other.classname != "player")
		return;
		
	cvar_set ("skill", self.message);
};

/*QUAKED trigger_setskill (.5 .5 .5) ?
sets skill level to the value of "message".
Only used on start map.
*/
void() trigger_setskill =
{
	InitTrigger ();
	self.touch = trigger_skill_touch;
};


/*
==============================================================================

ONLY REGISTERED TRIGGERS

==============================================================================
*/

void() trigger_onlyregistered_touch =
{
	if (other.classname != "player")
		return;
	if (self.attack_finished > time)
		return;

	self.attack_finished = time + 2;
	if (cvar("registered"))
	{
		self.message = "";
		SUB_UseTargets ();
		remove (self);
	}
	else
	{
		if (self.message != "")
		{
			centerprint (other, self.message);
			sound (other, CHAN_BODY, "misc/talk.wav", 1, ATTN_NORM);
		}
	}
};

/*QUAKED trigger_onlyregistered (.5 .5 .5) ?
Only fires if playing the registered version, otherwise prints the message
*/
void() trigger_onlyregistered =
{
	precache_sound ("misc/talk.wav");
	InitTrigger ();
	self.touch = trigger_onlyregistered_touch;
};

//============================================================================

void() hurt_on =
{
	self.solid = SOLID_TRIGGER;
	self.nextthink = -1;
};

void() hurt_touch =
{
	if (other.takedamage)
	{
		self.solid = SOLID_NOT;
		T_Damage (other, self, self, self.dmg);
		self.think = hurt_on;
		self.nextthink = time + self.delay;
	}

	return;
};

/*QUAKED trigger_hurt (.5 .5 .5) ?
Any object touching this will be hurt
set dmg to damage amount
defalt dmg = 5
*/
void() trigger_hurt =
{
	InitTrigger ();
	self.touch = hurt_touch;
	if (!self.dmg)
		self.dmg = 5;
	if (!self.delay)
		self.delay = 1;
};

//============================================================================

#define PUSH_ONCE 1
#define TWO_WAY 2
#define DISABLED 4

void() trigger_push_touch =
{
	if (self.spawnflags & DISABLED) {
		return;
	}
	if (other.classname == "grenade")
		other.velocity = self.speed * self.movedir * 10;
	else if (other.health > 0)
	{
		other.velocity = self.speed * self.movedir * 10;
		if (other.classname == "player")
		{
			if (other.fly_sound < time)
			{
				other.fly_sound = time + 1.5;
				sound (other, CHAN_AUTO, "ambience/windfly.wav", 1, ATTN_NORM);
			}
		}
	}
	if (self.spawnflags & PUSH_ONCE) {
		remove(self);
	}
};

void() trigger_push_use =
{
	if (self.spawnflags & TWO_WAY) {
		self.speed = self.speed * -1;
	} else {
		if (self.spawnflags & DISABLED) {
			self.spawnflags = self.spawnflags - DISABLED;
		} else {
			self.spawnflags = self.spawnflags | DISABLED;
		}
	}
};


/*QUAKED trigger_push (.5 .5 .5) ? PUSH_ONCE
Pushes the player
*/
void() trigger_push =
{
	InitTrigger ();
	precache_sound ("ambience/windfly.wav");
	
	if (!self.speed)
		self.speed = 1000;
	
	self.touch = trigger_push_touch;
	self.use = trigger_push_use;
};

//============================================================================

void() trigger_monsterjump_touch =
{
	if ( other.flags & (FL_MONSTER | FL_FLY | FL_SWIM) != FL_MONSTER )
		return;

// set XY even if not on ground, so the jump will clear lips
	other.velocity_x = self.movedir_x * self.speed;
	other.velocity_y = self.movedir_y * self.speed;
	
	if ( !(other.flags & FL_ONGROUND) )
		return;
	
	other.flags = other.flags - FL_ONGROUND;

	other.velocity_z = self.height;
};

/*QUAKED trigger_monsterjump (.5 .5 .5) ?
Walking monsters that touch this will jump in the direction of the trigger's angle
"speed" default to 200, the speed thrown forward
"height" default to 200, the speed thrown upwards
*/
void() trigger_monsterjump =
{
	if (!self.speed)
		self.speed = 200;
	if (!self.height)
		self.height = 200;
	if (self.angles == '0 0 0')
		self.angles = '0 360 0';
	InitTrigger ();
	self.touch = trigger_monsterjump_touch;
};

/*void() anything_touch = {
	SUB_UseTargets();
}

void() trigger_anything = {
	InitTrigger ();
	self.touch = anything_touch;
}*/

void() honey_touch = {
	if (/*(other.waterlevel > 0) && (other.watertype == CONTENT_SLIME) && */(world.world_properties & HONEYSLIME) && (other.radsuit_finished < time)) {
		if (vlen(other.velocity) > 60) {
			other.velocity = normalize(other.velocity) * 60;
		}
	}
}

void() trigger_honey = {
	InitTrigger ();
	self.touch = honey_touch;
}

void() hint_message = {
	float i = 0;
	while (i < 16) {
		if (!get_rune(self.owner.level_id, i)) {
			break;
		}
		i ++;
	}
	if (!self.owner.missions[i]) {
		return;
	}
	threeprint(self.enemy,self.owner.message,"\n---\n", self.owner.missions[i]);
	sound (self.enemy, CHAN_VOICE, "misc/talk.wav", 1, ATTN_NORM);
}

void() hint_touch = {
	if (self.count >= ENT_DATA_SIZE*23) {
		return;
	}
	if (other.classname != "player") {
		return;
	}
	
	//Figure out which edict the player is
	entity t = world;
	float c = 0;
	do {
		t = nextent(t);
		c ++;
		if (other == t) {
			break;
		}
	} while (t != world && c < 16);
	
	
	if (get_ent_data(c)) {
		//If the value at the player's edict is 1, then they have already been selected
		return;
	} else {
		//If the value is 0, then set it so they have been selected.
		set_ent_data(c, 1);
		if (self.delay) {
			// create a temp object to fire at a later time
			t = spawn();
			t.classname = "DelayedHint";
			t.nextthink = time + .5;
			t.think = hint_message;
			t.owner = self;
			t.enemy = other;
			return;
		}
	}
}

void() trigger_hint = {
	if (!self.mission0) {
		return;
	}
	precache_sound ("misc/talk.wav");
	self.noise = "misc/talk.wav";
	self.touch = hint_touch;
	
	if (!self.level_id) {
		self.level_id = world.level_id;
	}
	if (!self.message) {
		self.message = world.message;
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
	
	InitTrigger();
};

void() levelstatus_use = {
	if (self.spawnflags & 1) {
		self.spawnflags = self.spawnflags - 1;
	} else {
		self.spawnflags = self.spawnflags | 1;
	}
}

void() levelstatus_touch = {
	if (self.spawnflags & 1) {
		return;
	}
	
	if (other.classname != "player") {
		return;
	}
	
	if (self.movedir != '0 0 0') {
		makevectors (other.angles);
		if (v_forward * self.movedir < 0)
			return;		// not facing the right way
	}
	
	if (time < self.nextthink) {
		return;
	} else {
		self.think = SUB_Null;
		self.nextthink = time + self.wait;
	}
	if (count_level_runes(self.level_id) >= self.count) {
		sixprint (activator, self.message, "\n---\n", ftos(count_level_runes(self.level_id)), "/", ftos(self.count), " Runes!");
	} else {
		sixprint (activator, self.message, "\n---\n", ftos(count_level_runes(self.level_id)), "/", ftos(self.count), " Runes");
	}
	sound (activator, CHAN_VOICE, "misc/talk.wav", 1, ATTN_NORM);
}

void() trigger_levelstatus = {
	if (!self.wait) {
		self.wait = 1.8;
	}
	if (!self.message) {
		self.message = world.message;
	}
	
	precache_sound ("misc/talk.wav");
	self.noise = "misc/talk.wav";
	self.touch = levelstatus_touch;
	self.use = levelstatus_use;
	
	InitTrigger();
};



