.float hb_val;
.float hb_contents[25];

float() three_pattern = {
	return 0;
}

float() row_pattern = {
	float i = 0;
	for (; i < 5; i ++) {
		float j = 0;
		float found = 0;
		for (; j < 5; j ++) {
			if (self.hb_contents[(5 * i) + j]) {
				found ++;
			}
		}
		if (found >= 5) {
			return 1;
		}
	}
	return 0;
}

float() cross_pattern = {
	return 0;
}

float() column_pattern = {
	float i = 0;
	for (; i < 5; i ++) {
		float j = 0;
		float found = 0;
		for (; j < 5; j ++) {
			if (self.hb_contents[(5 * j) + i]) {
				found ++;
			}
		}
		if (found >= 5) {
			return 1;
		}
	}
	return 0;
}

float() ring_pattern = {
	return 0;
}

float() twelve_pattern = {
	float i = 0;
	float found = 0;
	for (; i < 25; i ++) {
		if (self.hb_contents[i]) {
			found ++;
		}
	}
	if (found >= 12) {
		return 1;
	}
	return 0;
}



void() hellboard_check = {
	if (three_pattern()) {
		self.target = "gate1";
		SUB_UseTargets();
	}
	if (row_pattern()) {
		self.target = "gate2";
		SUB_UseTargets();
	}
	if (cross_pattern()) {
		self.target = "gate3";
		SUB_UseTargets();
	}
	if (column_pattern()) {
		self.target = "gate4";
		SUB_UseTargets();
	}
	if (ring_pattern()) {
		self.target = "gate5";
		SUB_UseTargets();
	}
	if (twelve_pattern()) {
		self.target = "gate6";
		SUB_UseTargets();
	}
}

void() hellboard_use = {
	//Only players can activate it.
	if (activator.classname != "player") {
		return;
	}
	
	//If it was actually just the update trigger, do that instead.
	if (other.targetname == "helltrigger") {
		hellboard_check();
		return;
	}
	
	//Otherwise, it was the board that was activated.
	//Only teleport the player if they aren't currently in a room.
	float selected = other.hb_val;
	if (!activator.hb_val) {
		//Only teleport a player if the room hasn't been completed yet.
		if (!self.hb_contents[selected]) {
			//Marks the player as being in a room currently.
			activator.hb_val = 1;
			//Teleports the player.
			teleport_object(activator, ftos(selected + 200), 0);
			//Marks the room as complete.
			self.hb_contents[selected] = 1;
			//Closes the shutter assocated with the room.
			self.target = ftos(selected + 300);
			SUB_UseTargets();
		}
	}
}

void() misc_hellboard = {
	self.use = hellboard_use;
};

void() hellboardreturn_use = {
	other.hb_val = 0;
}

void() effect_hellboardreturn = {
	self.use = hellboardreturn_use;
}