/*
==============================================================================

LOST SOUL

==============================================================================
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

void() Soul_Charge_Touch;
void() Soul_Bounce;
void() Soul_Bite;
void() Soul_Charge;

void() soul_idlesound = {
	if (random() > .6) {
		sound (self, CHAN_VOICE, "lostsoul/idle1.wav", 1, ATTN_IDLE);
	} else {
		sound (self, CHAN_VOICE, "lostsoul/idle2.wav", 1, ATTN_IDLE);
	}
}

void() soul_hover1 = [ $hover1, soul_hover2 ] {ai_stand();};
void() soul_hover2 = [ $hover2, soul_hover3 ] {ai_stand();};
void() soul_hover3 = [ $hover3, soul_hover4 ] {ai_stand();};
void() soul_hover4 = [ $hover4, soul_hover5 ] {ai_stand();};
void() soul_hover5 = [ $hover5, soul_hover6 ] {ai_stand();};
void() soul_hover6 = [ $hover6, soul_hover1 ] {ai_stand();};

void()	lost_standby1 = [ $hover1, lost_standby1 ] {
	self.movetype = MOVETYPE_STEP;
	ai_run(8);
};

void() soul_standby1 = [ $hover1, soul_standby2 ] {ai_run(1);};
void() soul_standby2 = [ $hover2, soul_standby3 ] {ai_run(1);};
void() soul_standby3 = [ $hover3, soul_standby4 ] {ai_run(1);};
void() soul_standby4 = [ $hover4, soul_standby5 ] {ai_run(1);};
void() soul_standby5 = [ $hover5, soul_standby6 ] {ai_run(1);};
void() soul_standby6 = [ $hover6, soul_standby1 ] {ai_run(1);};

void() soul_charge1 = [ $charge1, soul_charge2 ] {ai_face();};
void() soul_charge2 = [ $charge2, soul_charge3 ] {ai_face();};
void() soul_charge3 = [ $charge3, soul_charge4 ] {ai_face();};
void() soul_charge4 = [ $charge4, soul_charge5 ] {ai_face();Soul_Charge();};
void() soul_charge5 = [ $charge5, soul_charge6 ] {};
void() soul_charge6 = [ $charge6, soul_charge7 ] {};
void() soul_charge7 = [ $charge6, soul_standby1 ] {};

void() soul_pain1 = [ $pain1, soul_pain2 ] {};
void() soul_pain2 = [ $pain2, soul_pain3 ] {};
void() soul_pain3 = [ $pain3, soul_pain4 ] {};
void() soul_pain4 = [ $pain4, soul_pain5 ] {};
void() soul_pain5 = [ $pain5, soul_pain6 ] {};
void() soul_pain6 = [ $pain6, soul_standby1 ] {};

void() soul_painb1 = [ $painb1, soul_painb2 ] {};
void() soul_painb2 = [ $painb2, soul_painb3 ] {};
void() soul_painb3 = [ $painb3, soul_painb4 ] {};
void() soul_painb4 = [ $painb4, soul_painb5 ] {};
void() soul_painb5 = [ $painb5, soul_painb6 ] {};
void() soul_painb6 = [ $painb6, soul_standby1 ] {};

void() soul_chew1 = [ $chew1, soul_chew2 ] {};
void() soul_chew2 = [ $chew2, soul_chew3 ] {};
void() soul_chew3 = [ $chew3, soul_chew4 ] {};
void() soul_chew4 = [ $chew4, soul_chew5 ] {};
void() soul_chew5 = [ $chew5, soul_chew6 ] {};
void() soul_chew6 = [ $chew6, soul_standby1 ] {Soul_Bite();};

void() soul_grow1 = [ $grow1, soul_grow2 ] {};
void() soul_grow2 = [ $grow2, soul_grow3 ] {};
void() soul_grow3 = [ $grow3, soul_grow4 ] {};
void() soul_grow4 = [ $grow4, soul_grow5 ] {};
void() soul_grow5 = [ $grow5, soul_grow6 ] {};
void() soul_grow6 = [ $grow6, soul_grow7 ] {};
void() soul_grow7 = [ $grow7, soul_grow8 ] {};
void() soul_grow8 = [ $grow8, soul_grow9 ] {};
void() soul_grow9 = [ $grow9, soul_grow10 ] {};
void() soul_grow10 = [ $grow10, soul_standby1 ] {};

void()	soul_walk1 = {
	soul_hover1();
};

void(entity attacker, float damage)	soul_pain =
{
	if (self.pain_finished <= time) {
		self.pain_finished = time + 1;
		sound (self, CHAN_VOICE, "lostsoul/pain1.wav", 1, ATTN_NORM);
	}
	
	self.velocity = 0;
	self.movetype = MOVETYPE_STEP;
	self.attack_finished = time + 1.3;
	
	if (random() > .5) {
		soul_pain1 ();
	} else {
		soul_painb1 ();
	}
};

void() soul_die =
{
	sound (self, CHAN_VOICE, "lostsoul/death.wav", 1, ATTN_NORM);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);

	self.velocity = '0 0 0';
	self.touch = SUB_Null;
	setmodel (self, "progs/s_explod.spr");
	self.solid = SOLID_NOT;
	s_explode1 ();
};

/*
==============================================================================

DEMON

==============================================================================
*/

/*
==============
CheckSoulMelee

Returns TRUE if a melee attack would hit right now
==============
*/
float()	CheckSoulMelee =
{
	if (enemy_range == RANGE_MELEE)
	{	// FIXME: check canreach
		self.attack_state = AS_MELEE;
		return TRUE;
	}
	return FALSE;
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
	
	//Check distance
	dist = self.enemy.origin - self.origin;
	dist_z = 0;
	
	d = vlen(dist);
	
	if (d < 50) {
		return FALSE;
	}
		
	if (d > 400) {
		if (random() < 0.9) {
			return FALSE;
		}
	}
		
	return TRUE;
};

float()	SoulCheckAttack = {
	//Don't attack if it's already flying
	if (self.movetype == MOVETYPE_FLYMISSILE) {
		return FALSE;
	}
	
	// if close enough for biting, go for it
	if (CheckSoulMelee ())
	{
		self.attack_state = AS_MELEE;
		return TRUE;
	}
	
	if (CheckSoulCharge ())
	{
		self.attack_state = AS_MISSILE;
        //sound (self, CHAN_VOICE, "demon/djump.wav", 1, ATTN_NORM);
		return TRUE;
	}
	
	return FALSE;
};


//===========================================================================

void() Soul_Bite = {
	local vector	delta;
	
	ai_face ();
	walkmove (self.ideal_yaw, 12);
	
	delta = self.enemy.origin - self.origin;

	if (vlen(delta) > 32) {
		return;
	}
	if (!CanDamage (self.enemy, self)) {
		return;
	}
	
    sound (self, CHAN_WEAPON, "lostsoul/bite.wav", 1, ATTN_NORM);
	T_Damage (self.enemy, self, self, 20);	

	makevectors (self.angles);
	SpawnMeatSpray (self.origin + v_forward*16, 0);
};

void() Soul_Charge = {
	sound (self, CHAN_VOICE, "lostsoul/charge.wav", 1, ATTN_NORM);
	self.movetype = MOVETYPE_FLYMISSILE;
	//makevectors(self.angles);
	//self.velocity = 500 * v_forward;
	self.velocity = 500 * normalize((self.enemy.origin + '0 0 16') - self.origin);
	self.nextthink = time + 10;
	self.think = soul_charge5;
}

void() Soul_Charge_Touch = {
	if (self.movetype != MOVETYPE_FLYMISSILE) {
		return;
	}
	
	if (other.takedamage && other.classname != "monster_lostsoul")
	{
		if ( vlen(self.velocity) > 300 ) {
			T_Damage (other, self, self, 10);	
		}
	}
	bprint("COLLISION\n");
	self.velocity = 0;
	self.movetype = MOVETYPE_STEP;
	self.attack_finished = time + 1.3;
	//self.attack_state = AS_
	
	Soul_Bounce();
};

void() Soul_Bounce = {
	vector dir;
	dir_z = random() * 360;
	makevectors(dir);
	self.velocity = 100 * v_forward;
	soul_standby1();
}

void() soul_melee = {
	soul_chew1();
}

void() soul_missile = {
	soul_charge1();
}

/*QUAKED monster_soul (1 0 0) (-32 -32 -24) (32 32 64) Ambush

*/
void() monster_lostsoul =
{
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
	self.movetype = MOVETYPE_STEP;

	setmodel (self, "progs/lostsoul.mdl");

	setsize (self, '-7 -7 -7', '7 7 7');
	self.health = 50;

	self.th_stand = soul_hover1;
	self.th_walk = soul_walk1;
	self.th_run = soul_standby1;
	self.th_die = soul_die;
	self.th_melee = soul_melee;		// one of two attacks
	self.th_missile = soul_missile;			// jump attack
	self.th_pain = soul_pain;
	self.touch = Soul_Charge_Touch;
		
	flymonster_start ();
};
