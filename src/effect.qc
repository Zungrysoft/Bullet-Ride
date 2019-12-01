//Code written by ZungryWare

void() unlockitem_use = {
	if (!get_specialflag(self.rune_id)) {
		SUB_UseTargets();
	}
	set_specialflag(self.rune_id, 1);
	ghostWeapons();
}

void() effect_unlockitem = {
	self.use = unlockitem_use;
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

/*void() missionlist_use = {
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
};*/

//Changed to trigger_hint in triggers.qc
/*void() hint_use = {
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
};*/

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
	update_monsters();
}

void() effect_countkill = {
	total_monsters += self.count;
	update_monsters();
	self.use = countkill_use;
}

void() effect_teleport_use = {
	if (self.message) {
		teleport_object(find(world, targetname, self.message), self.target, 0);
	} else {
		teleport_object(activator, self.target, 0);
	}
	
}

void() effect_teleport = {
	self.use = effect_teleport_use;
}

void() random_list_use = {
	local float choice;
	if (self.spawnflags & 1) {
		float num_avail = 0;
		for (float j = 0; j < self.count; j ++) {
			if (!get_ent_data(j)) {
				num_avail ++;
			}
		}
		if (num_avail == 0) {
			self.target = self.target1;
			SUB_UseTargets();
			remove(self);
		}
		choice = floor(random() * num_avail);
		for (float i = 0; i < choice + 1; i ++) {
			if (get_ent_data(i)) {
				choice ++;
			}
		}
		if (get_ent_data(choice)) {
			bprint("SOMETHING IS WRONG\n");
		}
		set_ent_data(choice,1);
	} else {
		choice = floor(random() * self.count);
	}
	self.target = ftos(self.height + choice);
	SUB_UseTargets();
}

void() effect_random_list = {
	self.use = random_list_use;
	self.target1 = self.target;
}

void() ordered_list_use = {
	if (self.lefty < self.count) {
		self.target = ftos(self.height + self.lefty);
		self.lefty ++;
		SUB_UseTargets();
	}
	if (self.lefty >= self.count) {
		self.target = self.target1;
		SUB_UseTargets();
		remove(self);
	}
}

void() effect_ordered_list = {
	self.use = random_list_use;
	self.target1 = self.target;
}
