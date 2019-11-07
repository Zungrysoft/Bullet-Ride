#define eye_entity trigger_field

#define MAX_ROTATE_HORIZ 33
#define MAX_ROTATE_VERT 17
void(vector pos) eye_position = {
	//Position the eye
	makevectors(self.angles);
	self.eye_entity.origin = self.origin + v_forward*pos_y + v_up*pos_z + v_right*pos_x;
	setorigin(self.eye_entity,self.eye_entity.origin);
	
	//Rotate the eye
	vector forward_eye = vectoangles(v_forward);
	if (self.enemy) {
		//Point the eye toward the enemy
		vector eye_dir = vectoangles(self.enemy.origin - self.origin);
		
		//bprint(ftos(eye_dir_x));
		//bprint("\n");
		
		//Limit the eye's vertical rotation
		//If the eye is looking too far up
		if (360 - eye_dir_x > MAX_ROTATE_VERT && eye_dir_x > 180) {
			eye_dir_x = 360 - MAX_ROTATE_VERT;
		}
		//If the eye is looking too far down
		if (eye_dir_x > MAX_ROTATE_VERT && eye_dir_x <= 180) {
			
			eye_dir_x = MAX_ROTATE_VERT;
		}
		
		//Limit the eye's horitzontal rotation
		float diff = eye_dir_y - forward_eye_y;
		//Keep the diff within a range of -180 < diff < 180
		if (diff > 180) {
			diff -= 360;
		}
		if (diff < -180) {
			diff += 360;
		}
		if (diff > MAX_ROTATE_HORIZ) {
			eye_dir_y = forward_eye_y + MAX_ROTATE_HORIZ;
		}
		if (diff < (MAX_ROTATE_HORIZ * -1)) {
			eye_dir_y = forward_eye_y - MAX_ROTATE_HORIZ;
		}
		
		self.eye_entity.angles = eye_dir;
	} else {
		//Just point the eye forward if no targets.
		self.eye_entity.angles = forward_eye;
	}
	
	//Ensures animation interpolation is done correctly.
	self.eye_entity.frame = 1 - self.eye_entity.frame;
	self.eye_entity.nextthink = time + .1;
	self.eye_entity.think = SUB_Null;
}

void() eye_spawn = {
	entity 	eye;
	
	eye = spawn ();
	self.eye_entity = eye;
	eye.owner = self;

	eye.movetype = MOVETYPE_STEP;
	eye.flags = eye.flags | FL_FLY;
	precache_model2 ("progs/paineye.mdl");
	setmodel (eye, "progs/paineye.mdl");

	setsize (eye, '0 0 0', '0 0 0');
	
	eye_position('0 0 0');
}

$frame hover1 hover2 hover3 hover4 hover5 hover6 hover7 hover8 hover9 hover10 hover11 hover12

$frame lswipe1 lswipe2 lswipe3 lswipe4 lswipe5 lswipe6 lswipe7 lswipe8 lswipe9 lswipe10 lswipe11 lswipe12 lswipe13

$frame rswipe1 rswipe2 rswipe3 rswipe4 rswipe5 rswipe6 rswipe7 rswipe8 rswipe9 rswipe10 rswipe11 rswipe12 rswipe13

$frame paina1 paina2 paina3 paina4 paina5 paina6 paina7 paina8 paina9

$frame attacka1 attacka2 attacka3 attacka4 attacka5 attacka6 attacka7 attacka8 attacka9 attacka10 attacka11

$frame attackb1 attackb2 attackb3 attackb4 attackb5 attackb6 attackb7 attackb8 attackb9 attackb10 attackb11

void() painelem_run1;

void() painelem_idlesound = {
	//self.waitmin = time + 2;
	if (random() > .1) {
	 	//sound (self, CHAN_VOICE, "painelem/idle.wav", 1,  ATTN_IDLE);
	}
};

void() painelem_stand1 = [ $hover1, painelem_stand2 ] {ai_stand();eye_position('0 16.741 37.384');};
void() painelem_stand2 = [ $hover2, painelem_stand3 ] {ai_stand();eye_position('0 16.741 37.122');};
void() painelem_stand3 = [ $hover3, painelem_stand4 ] {ai_stand();eye_position('0 16.741 36.467');};
void() painelem_stand4 = [ $hover4, painelem_stand5 ] {ai_stand();eye_position('0 16.741 35.616');};
void() painelem_stand5 = [ $hover5, painelem_stand6 ] {ai_stand();eye_position('0 16.741 34.765');};
void() painelem_stand6 = [ $hover6, painelem_stand7 ] {ai_stand();eye_position('0 16.741 34.110');};
void() painelem_stand7 = [ $hover7, painelem_stand8 ] {ai_stand();eye_position('0 16.741 33.848');};
void() painelem_stand8 = [ $hover8, painelem_stand9 ] {ai_stand();eye_position('0 16.741 34.183');};
void() painelem_stand9 = [ $hover9, painelem_stand10 ] {ai_stand();eye_position('0 16.741 34.981');};
void() painelem_stand10 = [ $hover10, painelem_stand11 ] {ai_stand();eye_position('0 16.741 35.934');};
void() painelem_stand11 = [ $hover11, painelem_stand12 ] {ai_stand();eye_position('0 16.741 36.732');};
void() painelem_stand12 = [ $hover12, painelem_stand1 ] {ai_stand();eye_position('0 16.741 37.067');
	painelem_idlesound();
};

void() painelem_walk1 = [ $hover1, painelem_walk2 ] {ai_walk(6);};
void() painelem_walk2 = [ $hover2, painelem_walk3 ] {ai_walk(6);};
void() painelem_walk3 = [ $hover3, painelem_walk4 ] {ai_walk(6);};
void() painelem_walk4 = [ $hover4, painelem_walk5 ] {ai_walk(6);};
void() painelem_walk5 = [ $hover5, painelem_walk6 ] {ai_walk(6);};
void() painelem_walk6 = [ $hover6, painelem_walk7 ] {ai_walk(6);};
void() painelem_walk7 = [ $hover7, painelem_walk8 ] {ai_walk(6);};
void() painelem_walk8 = [ $hover8, painelem_walk9 ] {ai_walk(6);};
void() painelem_walk9 = [ $hover9, painelem_walk10 ] {ai_walk(6);};
void() painelem_walk10 = [ $hover10, painelem_walk11 ] {ai_walk(6);};
void() painelem_walk11 = [ $hover11, painelem_walk12 ] {ai_walk(6);};
void() painelem_walk12 = [ $hover12, painelem_walk1 ] {ai_walk(6);
	painelem_idlesound();
};

void() painelem_run1 = [ $hover1, painelem_run2 ] {ai_run(12);eye_position('0 16.741 37.384');};
void() painelem_run2 = [ $hover2, painelem_run3 ] {ai_run(12);eye_position('0 16.741 37.122');};
void() painelem_run3 = [ $hover3, painelem_run4 ] {ai_run(12);eye_position('0 16.741 36.467');};
void() painelem_run4 = [ $hover4, painelem_run5 ] {ai_run(12);eye_position('0 16.741 35.616');};
void() painelem_run5 = [ $hover5, painelem_run6 ] {ai_run(12);eye_position('0 16.741 34.765');};
void() painelem_run6 = [ $hover6, painelem_run7 ] {ai_run(12);eye_position('0 16.741 34.110');};
void() painelem_run7 = [ $hover7, painelem_run8 ] {ai_run(12);eye_position('0 16.741 33.848');};
void() painelem_run8 = [ $hover8, painelem_run9 ] {ai_run(12);eye_position('0 16.741 34.183');};
void() painelem_run9 = [ $hover9, painelem_run10 ] {ai_run(12);eye_position('0 16.741 34.981');};
void() painelem_run10 = [ $hover10, painelem_run11 ] {ai_run(12);eye_position('0 16.741 35.934');};
void() painelem_run11 = [ $hover11, painelem_run12 ] {ai_run(12);eye_position('0 16.741 36.732');};
void() painelem_run12 = [ $hover12, painelem_run1 ] {ai_run(12);eye_position('0 16.741 37.067');
	painelem_idlesound();
};

void(float side) Pain_Claw =
{
local vector	delta;

	if (!self.enemy)
		return;
	
	if (self.enemy.health <= 0)
		return;

	delta = self.enemy.origin - self.origin;

	if (vlen(delta) > 100 || self.enemy.origin_z - self.origin_z > 85) {
		return;
	}
		
	T_Damage (self.enemy, self, self, 30);
	sound (self, CHAN_VOICE, "shambler/smack.wav", 1, ATTN_NORM);

	if (side) {
		makevectors (self.angles);
		SpawnMeatSpray (self.origin + v_forward*45, v_right*side);
	}
};

void() painelem_rswipe1;

void() painelem_lswipe1 = [ $lswipe1, painelem_lswipe2 ] {ai_charge(4);eye_position('0 16.741 37.384');};
void() painelem_lswipe2 = [ $lswipe2, painelem_lswipe3 ] {ai_charge(4);eye_position('-0.899 17.828 37.093');};
void() painelem_lswipe3 = [ $lswipe3, painelem_lswipe4 ] {ai_charge(4);eye_position('-3.579 20.162 37.277');};
void() painelem_lswipe4 = [ $lswipe4, painelem_lswipe5 ] {ai_charge(4);eye_position('-7.983 22.359 37.778');};
void() painelem_lswipe5 = [ $lswipe5, painelem_lswipe6 ] {ai_charge(4);eye_position('-11.76 23.215 38.665');};
void() painelem_lswipe6 = [ $lswipe6, painelem_lswipe7 ] {ai_charge(8);eye_position('-5.510 12.578 33.06');};
void() painelem_lswipe7 = [ $lswipe7, painelem_lswipe8 ] {ai_charge(10);eye_position('1.723 -6.132 31.314');Pain_Claw(10);};
void() painelem_lswipe8 = [ $lswipe8, painelem_lswipe9 ] {ai_charge(8);eye_position('1.595 -4.4373 31.74');};
void() painelem_lswipe9 = [ $lswipe9, painelem_lswipe10 ] {ai_charge(4);eye_position('1.277 -0.202 32.806');};
void() painelem_lswipe10 = [ $lswipe10, painelem_lswipe11 ] {ai_charge(4);eye_position('0.864 5.405 35.19');};
void() painelem_lswipe11 = [ $lswipe11, painelem_lswipe12 ] {ai_charge(4);eye_position('0.451 10.811 35.575');};
void() painelem_lswipe12 = [ $lswipe12, painelem_lswipe13 ] {ai_charge(4);eye_position('0.13285 15.047 36.64');};
void() painelem_lswipe13 = [ $lswipe13, painelem_run1 ] {ai_charge(4);eye_position('0 16.741 37.384');
	if (range(self.enemy) == RANGE_MELEE && self.enemy.health > 0) {
		self.think = painelem_rswipe1;
	}
};

void() painelem_rswipe1 = [ $rswipe1, painelem_rswipe2 ] {ai_charge(4);eye_position('0 16.741 37.384');};
void() painelem_rswipe2 = [ $rswipe2, painelem_rswipe3 ] {ai_charge(4);eye_position('0.899 17.828 37.093');};
void() painelem_rswipe3 = [ $rswipe3, painelem_rswipe4 ] {ai_charge(4);eye_position('3.579 20.162 37.277');};
void() painelem_rswipe4 = [ $rswipe4, painelem_rswipe5 ] {ai_charge(4);eye_position('7.983 22.359 37.778');};
void() painelem_rswipe5 = [ $rswipe5, painelem_rswipe6 ] {ai_charge(4);eye_position('11.76 23.215 38.665');};
void() painelem_rswipe6 = [ $rswipe6, painelem_rswipe7 ] {ai_charge(8);eye_position('5.510 12.578 33.06');};
void() painelem_rswipe7 = [ $rswipe7, painelem_rswipe8 ] {ai_charge(10);eye_position('-1.723 -6.132 31.314');Pain_Claw(-10);};
void() painelem_rswipe8 = [ $rswipe8, painelem_rswipe9 ] {ai_charge(8);eye_position('-1.595 -4.4373 31.74');};
void() painelem_rswipe9 = [ $rswipe9, painelem_rswipe10 ] {ai_charge(4);eye_position('-1.277 -0.202 32.806');};
void() painelem_rswipe10 = [ $rswipe10, painelem_rswipe11 ] {ai_charge(4);eye_position('-0.864 5.405 35.19');};
void() painelem_rswipe11 = [ $rswipe11, painelem_rswipe12 ] {ai_charge(4);eye_position('-0.451 10.811 35.575');};
void() painelem_rswipe12 = [ $rswipe12, painelem_rswipe13 ] {ai_charge(4);eye_position('-0.13285 15.047 36.64');};
void() painelem_rswipe13 = [ $rswipe13, painelem_run1 ] {ai_charge(4);eye_position('0 16.741 37.384');
	if (range(self.enemy) == RANGE_MELEE && self.enemy.health > 0) {
		self.think = painelem_lswipe1;
	}
};

//Decides whether to swipe left or swipe right.
//Called on th_melee.
void() painelem_melee = {
	if (random() > .5) {
		painelem_lswipe1();
	} else {
		painelem_rswipe1();
	}
};

//void() painelem_paina1 = [ $paina1, painelem_paina3 ] {};
//void() painelem_paina2 = [ $paina2, painelem_paina3 ] {};
void() painelem_paina1 = [ $paina3, painelem_paina4 ] {eye_position('1.8364 15.723 40.78');};
void() painelem_paina4 = [ $paina4, painelem_paina5 ] {eye_position('1.8364 15.723 40.78');};
void() painelem_paina5 = [ $paina5, painelem_paina6 ] {eye_position('1.8364 15.723 40.78');};
void() painelem_paina6 = [ $paina6, painelem_paina7 ] {eye_position('1.549 15.822 40.2');};
void() painelem_paina7 = [ $paina7, painelem_paina8 ] {eye_position('0.915 16.232 38.923');};
void() painelem_paina8 = [ $paina8, painelem_paina9 ] {eye_position('0.282 16.582 37.647');};
void() painelem_paina9 = [ $paina9, painelem_run1 ] {eye_position('0 16.741 37.067');};

void() Fireball_Touch = {
	if (other == self.owner) {
		return;
	}
	
	if (pointcontents(self.origin) == CONTENT_SKY) {
		remove(self);
		return;
	}
	
	T_RadiusDamage (self, self.owner, 40, world);
	sound (self, CHAN_VOICE, "weapons/r_exp3.wav", 1, ATTN_NORM);

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

void() painelem_Shoot =
{
	entity missile;
	
	//sound (self, CHAN_WEAPON, "painelem/fire.wav", 1, ATTN_NORM);
	
	missile = spawn();
	missile.owner = self;
	missile.movetype = MOVETYPE_FLY;
	missile.solid = SOLID_BBOX;
	missile.effects = EF_DIMLIGHT;

	setmodel (missile, "progs/laser.mdl");
	setsize (missile, '0 0 0', '0 0 0');		
	missile.origin = self.origin + '0 0 16';
	setorigin (missile, missile.origin);

	missile.velocity = 500 * normalize(self.enemy.origin - self.origin);
	missile.angles = vectoangles(missile.velocity);

	missile.nextthink = time + 10;
	missile.think = SUB_Remove;
	missile.touch = Fireball_Touch;
};

void() painelem_Deploy = {
	
}

void() painelem_attacka1 = [ $attacka1, painelem_attacka2 ] {ai_face();eye_position('0 16.741 37.384');};
void() painelem_attacka2 = [ $attacka2, painelem_attacka3 ] {ai_face();eye_position('0 16.276 37.687');};
void() painelem_attacka3 = [ $attacka3, painelem_attacka4 ] {ai_face();eye_position('0 15.412 38.839');};
void() painelem_attacka4 = [ $attacka4, painelem_attacka5 ] {ai_face();eye_position('0 14.947 39.459');painelem_Shoot();};
void() painelem_attacka5 = [ $attacka5, painelem_attacka6 ] {ai_face();eye_position('0 14.947 39.459');};
void() painelem_attacka6 = [ $attacka6, painelem_attacka7 ] {ai_face();eye_position('0 14.947 39.459');};
void() painelem_attacka7 = [ $attacka7, painelem_attacka8 ] {ai_face();eye_position('0 14.947 39.459');};
void() painelem_attacka8 = [ $attacka8, painelem_attacka9 ] {ai_face();eye_position('0 15.277 39.085');};
void() painelem_attacka9 = [ $attacka9, painelem_attacka10 ] {ai_face();eye_position('0 15.844 38.263');};
void() painelem_attacka10 = [ $attacka10, painelem_attacka11 ] {ai_face();eye_position('0 16.461 37.44');};
void() painelem_attacka11 = [ $attacka11, painelem_run1 ] {ai_face();eye_position('0 16.741 37.384');SUB_AttackFinished(2);};

void() painelem_attackb1 = [ $attackb1, painelem_attackb2 ] {ai_face();eye_position('0 16.741 37.384');};
void() painelem_attackb2 = [ $attackb2, painelem_attackb3 ] {ai_face();eye_position('0 16.276 37.384');};
void() painelem_attackb3 = [ $attackb3, painelem_attackb4 ] {ai_face();eye_position('0 15.412 37.384');};
void() painelem_attackb4 = [ $attackb4, painelem_attackb5 ] {ai_face();eye_position('0 14.947 37.384');painelem_Deploy();};
void() painelem_attackb5 = [ $attackb5, painelem_attackb6 ] {ai_face();eye_position('0 14.947 37.384');};
void() painelem_attackb6 = [ $attackb6, painelem_attackb7 ] {ai_face();eye_position('0 14.947 37.384');};
void() painelem_attackb7 = [ $attackb7, painelem_attackb8 ] {ai_face();eye_position('0 14.947 37.384');};
void() painelem_attackb8 = [ $attackb8, painelem_attackb9 ] {ai_face();eye_position('0 15.277 37.384');};
void() painelem_attackb9 = [ $attackb9, painelem_attackb10 ] {ai_face();eye_position('0 15.844 37.384');};
void() painelem_attackb10 = [ $attackb10, painelem_attackb11 ] {ai_face();eye_position('0 16.461 37.384');};
void() painelem_attackb11 = [ $attackb11, painelem_run1 ] {ai_face();eye_position('0 16.741 37.384');SUB_AttackFinished(2);};

void()	painelem_death1	= [ $paina1, painelem_death2 ] {
	makevectors(self.angles);
	self.velocity = v_forward * -40;
	sound (self, CHAN_VOICE, "painelem/death.wav", 1, ATTN_NORM);
};
void()	painelem_death2	= [ $paina2, painelem_death3 ] {};
void()	painelem_death3	= [ $paina3, painelem_death4 ] {};
void()	painelem_death4	= [ $paina3, painelem_death5 ] {};
void()	painelem_death5	= [ $paina3, painelem_death6 ] {};
void()	painelem_death6	= [ $paina3, painelem_death7 ] {};
void()	painelem_death7	= [ $paina3, painelem_death8 ] {};
void()	painelem_death8	= [ $paina3, painelem_death8 ] {
	remove(self.eye_entity);
	ThrowHead ("progs/paineye.mdl", self.health);
	//ThrowGib ("progs/painchunk2.mdl", self.health);
	ThrowGib ("progs/gib2.mdl", self.health);
	ThrowGib ("progs/gib2.mdl", self.health);
};

//Determine whether it was gibbed instantly, or it should run the death sequence and then gib.
//Called on th_die.
void() painelem_die = {
	if (self.health < -120) {
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		remove(self.eye_entity);
		ThrowHead ("progs/paineye.mdl", self.health);
		//ThrowGib ("progs/painchunk2.mdl", self.health);
		ThrowGib ("progs/gib2.mdl", self.health);
		ThrowGib ("progs/gib2.mdl", self.health);
		return;
	}
	painelem_death1 ();
};

//Calculate whether it should flinch.
//Called on th_pain.
void(entity attacker, float damage) painelem_pain =
{
	if (random() > .15) {
		return;		// didn't flinch
	}
	sound (self, CHAN_VOICE, "painelem/pain.wav", 1, ATTN_NORM);
	painelem_paina1 ();
};

//Decides whether to shoot a fireball or a Lost Soul.
//Called on th_missile.
void() painelem_missile = {
	if (self.classname == "monster_agony_elemental") {
		painelem_attacka1();
	} else {
		if (self.lefty == 0) {
			self.lefty = 1;
			self.waitmin = self.waitmin + 3;
			painelem_attackb1();
		} else {
			self.lefty = 0;
			painelem_attacka1();
		}
	}
};

void() monster_pain_elemental = {
	if (deathmatch) {
		remove(self);
		return;
	}
	precache_model ("progs/painelem.mdl");
	precache_model ("progs/laser.mdl");
	precache_sound ("painelem/pain.wav");
	precache_sound ("painelem/wake.wav");
	//precache_sound ("painelem/idle.wav");
	precache_sound ("painelem/death.wav");
	precache_sound ("shambler/smack.wav");
	
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel (self, "progs/painelem.mdl");
	
	setsize (self, VEC_HULL2_MIN, VEC_HULL2_MAX);
	self.health = 500;
	
	self.th_stand = painelem_stand1;
	self.th_walk = painelem_walk1;
	self.th_run = painelem_run1;
	self.th_melee = painelem_melee;
	self.th_missile = painelem_missile;
	self.th_pain = painelem_pain;
	self.th_die = painelem_die;
		
	eye_spawn();
	
	flymonster_start();
}

/*void() monster_agony_elemental = {
	if (deathmatch) {
		remove(self);
		return;
	}
	precache_model ("progs/painelem.mdl");
	
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel (self, "progs/painelem.mdl");
	self.skin = 1;
	
	setsize (self, '-85 -103 -60', '65 103 60');
	self.health = 500;
	
	self.th_stand = painelem_stand1;
	self.th_walk = painelem_walk1;
	self.th_run = painelem_run1;
	self.th_missile = painelem_missile;
	self.th_pain = painelem_Pain;
	self.th_die = painelem_die;
	self.th_revive = painelem_revive;
		
	eye_spawn();
	
	flymonster_start();
}*/

/*
=================
PainelemCheckAttack
=================
*/
float()	PainelemCheckAttack =
{
	local vector	spot1, spot2;	
	local entity	targ;
	local float		chance;
	
	//If the enemy is in melee range, use a melee attack.
	if (enemy_range == RANGE_MELEE) {
		self.attack_state = AS_MELEE;
		return TRUE;
	}
	
	if (time < self.attack_finished) {
		return FALSE;
	}
	if (!enemy_vis) {
		return FALSE;
	}
	
	//See if there's anything in the way of the shot.	
	targ = self.enemy;
	
	spot1 = self.origin + self.view_ofs;
	spot2 = targ.origin + targ.view_ofs;

	traceline (spot1, spot2, FALSE, self);

	//If you don't have a clear shot, don't bother to shoot.
	if (trace_ent != targ) {
		return FALSE;
	}
	
	if (enemy_range == RANGE_NEAR) {
		chance = 0.6;
	} else if (enemy_range == RANGE_MID) {
		chance = 0.4;
	} else {
		chance = 0;
	}
	
	//There has to be a wait time between shooting lost souls. So check for that.
	if (self.waitmin > time && self.lefty == 0) {
		return FALSE;
	}
	
	if (random () < chance) {
		self.attack_state = AS_MISSILE;
		return TRUE;
	}
	
	return FALSE;
};



