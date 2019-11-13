//Code written by ZungryWare

//lostsoul.qc File Description:
/* 
	Defines the behavior of the Lost Soul monster.
 */

//Animation definition code from Arcane Dimensions mon_lostsoul.qc
// moving jaw up and down (talking)
$frame hover1 hover2 hover3 hover4 hover5 hover6

// Tilt head backwards to look up
$frame idleB1 idleB2 idleB3 idleB4 idleB5 idleB6

// Tilt head downwards to look below
$frame idleF1 idleF2 idleF3 idleF4 idleF5 idleF6

// Keep looking left or right
$frame idleleft1 idleleft2 idleleft3 idleleft4 idleleft5 idleleft6
$frame idleright1 idleright2 idleright3 idleright4 idleright5 idleright6

// Turn head left or right 30 degrees
$frame idleturnl1 idleturnl2 idleturnl3 idleturnl4 idleturnl5 idleturnl6
$frame idleturnr1 idleturnr2 idleturnr3 idleturnr4 idleturnr5 idleturnr6

// mouth wide open and head tilted back
$frame charge1 charge2 charge3 charge4 charge5 charge6

// obvious chewing motion
$frame chew1 chew2 chew3 chew4 chew5 chew6

// mouth open and rotated Backward or Forward
$frame pain1 pain2 pain3 pain4 pain5 pain6
$frame painb1 painb2 painb3 painb4 painb5 painb6

// Spawning from nothing
$frame grow1 grow2 grow3 grow4 grow5 grow6 grow7 grow8 grow9 grow10

#define old_velocity mangle
#define MODE_STEP 0
#define MODE_FLY 1

void() Soul_Charge_Touch;
void() Soul_Charge;
void() Soul_Bounce;
void() Soul_Reel;
void(float mode) soul_mode;

void() soul_idlesound = {
	float rand = random();
	if (rand < .1) {
		sound (self, CHAN_VOICE, "lostsoul/idle1.wav", 1, ATTN_IDLE);
	} else if (rand < .2) {
		sound (self, CHAN_VOICE, "lostsoul/idle2.wav", 1, ATTN_IDLE);
	}
}

void() soul_stand1 = [ $hover1, soul_stand2 ] {ai_stand();};
void() soul_stand2 = [ $hover2, soul_stand3 ] {ai_stand();};
void() soul_stand3 = [ $hover3, soul_stand4 ] {ai_stand();};
void() soul_stand4 = [ $hover4, soul_stand5 ] {ai_stand();};
void() soul_stand5 = [ $hover5, soul_stand6 ] {ai_stand();};
void() soul_stand6 = [ $hover6, soul_stand1 ] {ai_stand();soul_idlesound();};

void() soul_walk1 = [ $hover1, soul_walk2 ] {ai_walk(1);};
void() soul_walk2 = [ $hover2, soul_walk3 ] {ai_walk(1);};
void() soul_walk3 = [ $hover3, soul_walk4 ] {ai_walk(1);};
void() soul_walk4 = [ $hover4, soul_walk5 ] {ai_walk(1);};
void() soul_walk5 = [ $hover5, soul_walk6 ] {ai_walk(1);};
void() soul_walk6 = [ $hover6, soul_walk1 ] {ai_walk(1);soul_idlesound();};

void() soul_run1 = [ $hover1, soul_run2 ] {ai_run(1);};
void() soul_run2 = [ $hover2, soul_run3 ] {ai_run(1);};
void() soul_run3 = [ $hover3, soul_run4 ] {ai_run(1);};
void() soul_run4 = [ $hover4, soul_run5 ] {ai_run(1);};
void() soul_run5 = [ $hover5, soul_run6 ] {ai_run(1);};
void() soul_run6 = [ $hover6, soul_run1 ] {ai_run(1);soul_idlesound();};

//Starts by facing the player, then it calls the charge function and loops repeatedly.
void() soul_precharge1 = [ $hover1, soul_precharge2 ] {ai_face();};
void() soul_precharge2 = [ $hover2, soul_precharge3 ] {ai_face();};
void() soul_precharge3 = [ $hover3, soul_precharge4 ] {ai_face();};
void() soul_precharge4 = [ $charge6, soul_charge1 ] {Soul_Charge();};
void() soul_charge1 = [ $charge1, soul_charge2 ] {};
void() soul_charge2 = [ $charge2, soul_charge3 ] {};
void() soul_charge3 = [ $charge3, soul_charge4 ] {};
void() soul_charge4 = [ $charge4, soul_charge5 ] {};
void() soul_charge5 = [ $charge5, soul_charge6 ] {};
void() soul_charge6 = [ $charge6, soul_charge1 ] {};

//The Lost Soul just hit its target and is reeling backwards.
void() soul_reel1 = [ $hover1, soul_reel2 ] {Soul_Reel();};
void() soul_reel2 = [ $hover2, soul_reel3 ] {Soul_Reel();};
void() soul_reel3 = [ $hover3, soul_reel4 ] {Soul_Reel();};
void() soul_reel4 = [ $hover4, soul_reel5 ] {Soul_Reel();};
void() soul_reel5 = [ $hover5, soul_reel6 ] {Soul_Reel();};
void() soul_reel6 = [ $hover6, soul_reel1 ] {Soul_Reel();};

//The Lost Soul just took a hit.
//void() soul_pain1 = [ $pain1, soul_pain2 ] {};
//void() soul_pain2 = [ $pain2, soul_pain3 ] {};
//void() soul_pain3 = [ $pain3, soul_pain4 ] {};
void() soul_pain1 = [ $pain4, soul_pain5 ] {};
void() soul_pain5 = [ $pain5, soul_pain6 ] {};
void() soul_pain6 = [ $pain6, soul_run1 ] {};

//void() soul_painb1 = [ $painb1, soul_painb2 ] {};
//void() soul_painb2 = [ $painb2, soul_painb3 ] {};
//void() soul_painb3 = [ $painb3, soul_painb4 ] {};
void() soul_painb1 = [ $painb4, soul_painb5 ] {};
void() soul_painb5 = [ $painb5, soul_painb6 ] {};
void() soul_painb6 = [ $painb6, soul_run1 ] {};

void(entity attacker, float damage)	soul_pain = {
	if (self.pain_finished <= time) {
		self.pain_finished = time + 1;
		sound (self, CHAN_VOICE, "lostsoul/pain1.wav", 1, ATTN_NORM);
	}
	
	soul_mode(MODE_STEP);
	
	self.attack_finished = time + .5;
	
	if (random() > .5) {
		soul_pain1 ();
	} else {
		soul_painb1 ();
	}
};

void() soul_die = {
	sound (self, CHAN_VOICE, "lostsoul/death.wav", 1, ATTN_NORM);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);
	
	self.touch = SUB_Null;
	setmodel (self, "progs/s_explod.spr");
	self.solid = SOLID_NOT;
	s_explode1 ();
};


//===========================================================================

void() Soul_Charge = {
	sound (self, CHAN_VOICE, "lostsoul/charge.wav", 1, ATTN_NORM);
	soul_mode(MODE_FLY);
	//makevectors(self.angles);
	//self.velocity = 500 * v_forward;
	self.velocity = 500 * normalize((self.enemy.origin + '0 0 16') - self.origin);
	self.old_velocity = self.velocity;
	self.touch = Soul_Charge_Touch;
}

#define BOUNCE_SPEED 190
#define SOUL_BOUNCE_ANGLE_X 20
#define SOUL_BOUNCE_ANGLE_Y 100
void() Soul_Bounce = {
	//Bounce away from what it just hit.
	//vector ang = vectoangles(other.origin - (self.origin + '0 0 -32'));
	vector ang;
	vector vel;
	
	vel = self.old_velocity;
	vel_x = vel_x * -1;
	vel_y = vel_y * -1;
	ang = vectoangles(vel);
	
	//Randomize the angle
	ang_x += (random() * SOUL_BOUNCE_ANGLE_X) - (SOUL_BOUNCE_ANGLE_X/2);
	ang_y += (random() * SOUL_BOUNCE_ANGLE_Y) - (SOUL_BOUNCE_ANGLE_Y/2);
	
	//Set the velocity
	makevectors(ang);
	self.velocity = v_forward * BOUNCE_SPEED;
	
	//The Lost Soul is now reeling from the attack it landed.
	self.attack_finished = time + .7;
	soul_reel1();
}

void() Soul_Charge_Touch = {
	//Deal the touch damage
	if (other.takedamage && other.classname != "monster_lostsoul")
	{
		if (vlen(self.velocity) > 300) {
			T_Damage (other, self, self, 13);	
		}
	}
	self.owner = world;
	
	if (other.flags & FL_MONSTER || other.classname == "player") {
		//If it hits a player or monster, bounce directly away from it.
		//The waiting is necessary to allow the engine to set the proper values from the collision.
		self.nextthink = time + .01;
		self.think = Soul_Bounce;
	} else {
		//If it hits anything else, return to regular mode.
		soul_mode(MODE_STEP);
		self.th_run();
	}
};

#define decel 27
void() Soul_Reel = {
	//Once the Lost Soul's recover period is over, it should decelerate and get return to attack mode.
	if (self.attack_finished > time) {
		return;
	}
	float spd = vlen(self.velocity);
	spd = spd - decel;
	if (spd <= 0) {
		soul_mode(MODE_STEP);
		self.th_run();
	} else {
		self.velocity = normalize(self.velocity) * spd;
	}
};

void(float mode) soul_mode = {
	if (mode == MODE_STEP) {
		//MODE_STEP
		self.movetype = MOVETYPE_STEP;
		self.touch = SUB_Null;
		self.flags = self.flags | FL_FLY;
	} else {
		//MODE_FLY
		self.touch = Soul_Charge_Touch;
		self.flags = self.flags - (self.flags & FL_ONGROUND);
		self.movetype = MOVETYPE_FLY;
	}
}

void() soul_missile = {
	soul_precharge1();
}

void() monster_lostsoul = {
	if (deathmatch)
	{
		remove(self);
		return;
	}
	
	precache_model ("progs/lostsoul.mdl");
	precache_sound ("lostsoul/bite.wav");
	precache_sound ("lostsoul/charge.wav");
	precache_sound ("lostsoul/death.wav");
	precache_sound ("lostsoul/idle1.wav");
	precache_sound ("lostsoul/idle2.wav");
	precache_sound ("lostsoul/pain1.wav");

	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_FLY;

	setmodel (self, "progs/lostsoul.mdl");
	
	setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);
	self.health = 50;

	self.th_stand = soul_stand1;
	self.th_walk = soul_walk1;
	self.th_run = soul_run1;
	self.th_die = soul_die;
	self.th_missile = soul_missile;
	self.th_pain = soul_pain;
	self.touch = SUB_Null;
		
	flymonster_start ();
};

/*
==============
CheckSoulCharge

==============
*/
float()	CheckSoulCharge =
{
	local	vector	dist;
	local	float	d;
	
	if (self.attack_finished > time) {
		return FALSE;
	}
	
	if (random() < 0.5) {
		return FALSE;
	}
	
	//TODO: Don't charge if facing away from target
	
	//Check distance
	dist = self.enemy.origin - self.origin;
	dist_z = 0;
	
	d = vlen(dist);
	
	if (d < 50) {
		return FALSE;
	}
		
	if (d > 700) {
		if (random() < 0.9) {
			return FALSE;
		}
	}
		
	return TRUE;
};

float()	SoulCheckAttack = {
	//Don't attack if it's already charging
	if (self.touch == Soul_Charge_Touch) {
		return FALSE;
	}
	
	if (CheckSoulCharge ())
	{
		self.attack_state = AS_MISSILE;
		return TRUE;
	}
	
	return FALSE;
};
