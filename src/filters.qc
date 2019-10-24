//Code written by ZungryWare

void(float ret) filter_output = {
	if (ret && !(self.spawnflags & 1)) {
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
	if (self.count >= ENT_DATA_SIZE*23) {
		filter_output(0);
		return;
	}
	if (activator.classname != "player") {
		filter_output(0);
		return;
	}
	
	//Figure out which edict the player is
	entity t = world;
	float c = 0;
	do {
		t = nextent(t);
		c ++;
		if (activator == t) {
			break;
		}
	} while (t != world && c < 16);
	
	
	if (get_ent_data(c)) {
		//If the value at the player's edict is 1, then they have already been selected
		filter_output(0);
		return;
	} else {
		//If the value is 0, then set it so they have been selected.
		set_ent_data(c, 1);
		filter_output(1);
	}
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

void() filter_switchable_use = {
	bprint(ftos(self.spawnflags & 1));
	if (activator.target_mod) {
		if (self.spawnflags & 1) {
			self.spawnflags = self.spawnflags - 1;
		} else {
			self.spawnflags = self.spawnflags | 1;
		}
	} else {
		filter_output(self.spawnflags & 1);
	}
}

void() filter_switchable = {
	self.use = filter_switchable_use;
}

void() filter_runecount_use = {
	filter_output(count_runes() >= self.count);
}

void() filter_runecount = {
	self.use = filter_runecount_use;
}

void() filter_newgame_use = {
	filter_output(!get_specialflag(22));
}

void() filter_newgame = {
	self.use = filter_newgame_use;
}
