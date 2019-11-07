//Code written by ZungryWare

.float hb_val;

float() three_pattern_vert = {
	//Checks for vertical solutions
	//i represents the row
	//j represents the column
	//k represents the offset
	float i = 0;
	for (; i < 3; i ++) {
		float j = 0;
		for (; j < 5; j ++) {
			float k = 0;
			float found = 0;
			for (; k < 3; k ++) {
				if (get_ent_data((5 * (i+k)) + j)) {
					found ++;
				}
			}
			if (found >= 3) {
				return 1;
			}
		}
	}
	return 0;
}

float() three_pattern_horiz = {
	//Checks for vertical solutions
	//i represents the row
	//j represents the column
	//k represents the offset
	float i = 0;
	for (; i < 5; i ++) {
		float j = 0;
		for (; j < 3; j ++) {
			float k = 0;
			float found = 0;
			for (; k < 3; k ++) {
				if (get_ent_data((5 * i) + (j+k))) {
					found ++;
				}
			}
			if (found >= 3) {
				return 1;
			}
		}
	}
	return 0;
}

float() three_pattern_diag1 = {
	//Checks for vertical solutions
	//i represents the row
	//j represents the column
	//k represents the offset
	float i = 0;
	for (; i < 3; i ++) {
		float j = 0;
		for (; j < 3; j ++) {
			float k = 0;
			float found = 0;
			for (; k < 3; k ++) {
				if (get_ent_data((5 * (i+k)) + (j+k))) {
					found ++;
				}
			}
			if (found >= 3) {
				return 1;
			}
		}
	}
	return 0;
}

float() three_pattern_diag2 = {
	//Checks for vertical solutions
	//i represents the row
	//j represents the column
	//k represents the offset
	float i = 0;
	for (; i < 3; i ++) {
		float j = 2;
		for (; j < 5; j ++) {
			float k = 0;
			float found = 0;
			for (; k < 3; k ++) {
				if (get_ent_data((5 * (i+k)) + (j-k))) {
					found ++;
				}
			}
			if (found >= 3) {
				return 1;
			}
		}
	}
	return 0;
}

float() row_pattern = {
	float i = 0;
	for (; i < 5; i ++) {
		float j = 0;
		float found = 0;
		for (; j < 5; j ++) {
			if (get_ent_data((5 * i) + j)) {
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
	float i = 0;
	for (; i < 2; i ++) {
		float j = 0;
		for (; j < 3; j ++) {
			if (
				get_ent_data((5 * (i+0)) + (j+1)) &&
				get_ent_data((5 * (i+1)) + (j+0)) &&
				get_ent_data((5 * (i+1)) + (j+1)) &&
				get_ent_data((5 * (i+1)) + (j+2)) &&
				get_ent_data((5 * (i+2)) + (j+1)) &&
				get_ent_data((5 * (i+3)) + (j+1)))
			{
				return 1;
			}
		}
	}
	return 0;
}

float() column_pattern = {
	float i = 0;
	for (; i < 5; i ++) {
		float j = 0;
		float found = 0;
		for (; j < 5; j ++) {
			if (get_ent_data((5 * j) + i)) {
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
	float i = 0;
	for (; i < 3; i ++) {
		float j = 0;
		for (; j < 3; j ++) {
			if (
				get_ent_data((5 * (i+0)) + (j+0)) &&
				get_ent_data((5 * (i+1)) + (j+0)) &&
				get_ent_data((5 * (i+2)) + (j+0)) &&
				get_ent_data((5 * (i+2)) + (j+1)) &&
				get_ent_data((5 * (i+2)) + (j+2)) &&
				get_ent_data((5 * (i+1)) + (j+2)) &&
				get_ent_data((5 * (i+0)) + (j+2)) &&
				get_ent_data((5 * (i+0)) + (j+1)))
			{
				return 1;
			}
		}
	}
	return 0;
}

float() twelve_pattern = {
	float i = 0;
	float found = 0;
	for (; i < 25; i ++) {
		if (get_ent_data(i)) {
			found ++;
		}
	}
	if (found >= 12) {
		return 1;
	}
	return 0;
}

void() hellboard_check = {
	if (three_pattern_vert() || three_pattern_horiz() || three_pattern_diag1() || three_pattern_diag2()) {
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
		if (!get_ent_data(selected-1)) {
			//Marks the player as being in a room currently.
			activator.hb_val = 1;
			//Teleports the player.
			if (!teleport_object(activator, ftos(selected + 200), 0)) {
				//If they didn't teleport anywhere valid, just teleport them to an info_player_start
				teleport_object(activator, "info_player_start", 0);
			}
			//teleport_object(activator, "backout", 0);
			//Marks the room as complete.
			set_ent_data(selected-1, 1);
			//Closes the shutter assocated with the room.
			self.target = ftos(selected + 300);
			SUB_UseTargets();
		}
	}
}

//Class initialization
void() misc_hellboard = {
	self.use = hellboard_use;
};

void() hellboardreturn_use = {
	activator.hb_val = 0;
}

void() effect_hellboardreturn = {
	self.use = hellboardreturn_use;
}