//Code written by ZungryWare

//File Description:
/* Defines the trap_crucifix entity, which will periodically resurrect dead monsters within its boundaries.
Designed specifically for use in Balt Ghadlef */

// Performs the resurrection
void() crucifix_think;

//Class initialization
void() trap_crucifix = {
	InitTrigger();
	self.use = crucifix_think;
	if (!self.wait) {
		if (cvar("skill") >= 2) {
			self.wait = 4;
		} else if (cvar("skill") >= 1) {
			self.wait = 7;
		} else {
			self.wait = 10;
		}
	}
	if (self.wait != -1) {
		self.think = crucifix_think;
		self.nextthink = time + self.wait;
	}
}

void() crucifix_think = {
	//List of found entities
	local entity found[8];
	//Counter that tracks which slot to put the entity in
	local float counter = 0;
	//Which entity it is currently looping through
	local entity t = world;
	//Which monster was chosen to be revived
	local entity choice;
	//The entity the lightning will come from
	local entity src;
	
	//Loop through each entity
	//Also stop when the list is filled.
	do {
		t = nextent(t);
		//Check if it's a dead entity that has a revive function
		if (t.th_revive && t.death_anim != 0) {
			//Make sure it's within the trigger's bounds
			if (t.origin_x >= self.absmin_x && t.origin_x <= self.absmax_x) {
				if (t.origin_y >= self.absmin_y && t.origin_y <= self.absmax_y) {
					if (t.origin_z >= self.absmin_z && t.origin_z <= self.absmax_z) {
						//The crucifix shouldn't revive anything immediately
						//Once it finds something to resurrect, it wakes up, then starts its resurrection cycle
						if (self.count == 0) {
							self.count = 1;
							//Set the nextthink
							if (self.wait != -1) {
								self.nextthink = time + (self.wait / 3);
							}
							return;
						} else {
							//If the crucifix is already awake, add the monster to the list
							found[counter] = t;
							counter ++;
						}
						
						
					}
				}
			}
		}
	} while (t != world && counter < 8);
	
	
	if (counter == 0) {
		//If no monsters were found, set the crucifix to sleep mode
		self.count = 0;
		//Set the nextthink
		if (self.wait != -1) {
			self.nextthink = time + (self.wait / 5);
		}
	} else {
		//If it found at least one monster, revive one of them
		//Pick one from the list at random
		choice = found[floor(random() * counter)];
		
		//Revive the monster
		if (revive(choice)) {
			//If the monster was successfully revived, play a lightning effect
			//Make sure it has a target before attempting to cast lightning
			if (self.target) {
				src = find(world, targetname, self.target);
				//Make sure an entity was found
				if (src) {
					//Lightning effect
					WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
					WriteByte (MSG_BROADCAST, TE_LIGHTNING1);
					WriteEntity (MSG_BROADCAST, self);
					WriteCoord (MSG_BROADCAST, src.origin_x);
					WriteCoord (MSG_BROADCAST, src.origin_y);
					WriteCoord (MSG_BROADCAST, src.origin_z);
					WriteCoord (MSG_BROADCAST, choice.origin_x);
					WriteCoord (MSG_BROADCAST, choice.origin_y);
					WriteCoord (MSG_BROADCAST, choice.origin_z);
					
					//Lightning sound
					sound (self, CHAN_WEAPON, "weapons/lhit.wav", 1, ATTN_NORM);
				}
			}
		}
		//Set the nextthink
		//Use the full duration if a monster was found
		if (self.wait != -1) {
			self.nextthink = time + self.wait;
		}
	}
}