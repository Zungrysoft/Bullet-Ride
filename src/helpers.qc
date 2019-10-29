//Code written by ZungryWare

float (float num, float shift) bshift_left = {
	float ret = num;
	for (float i = 0; i < shift; i ++) {
		ret = ret * 2;
	}
	return ret;
}

float (float num, float shift) bshift_right = {
	float ret = num;
	for (float i = 0; i < shift; i ++) {
		ret = ret / 2;
	}
	return ret;
}

float mod(float dividend, float divisor) {
	return dividend - (floor(dividend / divisor) * divisor);
}

//Returns a value min <= x < max
float random_range(float min, float max) = {
	return min + (random() * (max - min));
}

//Sets a bit in the runeflags array
//I recommend that you use set_rune, set_specialflag, or set_key instead if you don't know what you're doing.
float (float level, float rune, float value) set_runeflag = {
	if (level > 15 || level < 0) {
		bprint("[Error] set_runeflag function expects a level value between 0 and 15. Received a value of ");
		bprint(ftos(level));
		bprint(".\n");
		return 0;
	}
	if (rune > 23 || rune < 0) {
		bprint("[Error] set_runeflag function expects a rune value between 0 and 23. Received a value of ");
		bprint(ftos(rune));
		bprint(".\n");
		return 0;
	}
	
	float chosenbit = 1;
	chosenbit = bshift_left(chosenbit, rune);
	
	float before = runeflags[level];
	if (value == 0) {
		if (runeflags[level] & chosenbit) {
			runeflags[level] = runeflags[level] - chosenbit;
		}
	} else {
		runeflags[level] = runeflags[level] | chosenbit;
	}
	if (before == runeflags[level]) {
		return 0;
	} else {
		return 1;
	}
};

//Gets a bit in the runeflags array
//I recommend that you use get_rune, get_specialflag, or get_key instead if you don't know what you're doing.
float (float level, float rune) get_runeflag = {
	if (level > 15 || level < 0) {
		bprint("[Error] get_runeflag function expects a level value between 0 and 15. Received a value of ");
		bprint(ftos(level));
		bprint(".\n");
		return 0;
	}
	if (rune > 23 || rune < 0) {
		bprint("[Error] get_runeflag function expects a rune value between 0 and 23. Received a value of ");
		bprint(ftos(rune));
		bprint(".\n");
		return 0;
	}
	
	float chosenbit = 1;
	chosenbit = bshift_left(chosenbit, rune);
	
	if (runeflags[level] & chosenbit) {
		return 1;
	}
	return 0;
};

//Sets whether a player has a rune or not.
float (float level, float rune, float value) set_rune = {
	if (level >= NUMLEVELS || level < 0) {
		bprint("[Error] set_rune function expects a level value between 0 and ");
		bprint(ftos(NUMLEVELS-1));
		bprint(". Received a value of ");
		bprint(ftos(level));
		bprint(".\n");
		return 0;
	}
	if (rune >= RUNESPERLEVEL || rune < 0) {
		bprint("[Error] set_rune function expects a rune value between 0 and ");
		bprint(ftos(RUNESPERLEVEL-1));
		bprint(". Received a value of ");
		bprint(ftos(rune));
		bprint(".\n");
		return 0;
	}
	return set_runeflag(level, rune, value);
};

//Gets whether the player has a rune
float (float level, float rune) get_rune = {
	if (level >= NUMLEVELS || level < 0) {
		bprint("[Error] get_rune function expects a level value between 0 and ");
		bprint(ftos(NUMLEVELS-1));
		bprint(". Received a value of ");
		bprint(ftos(level));
		bprint(".\n");
		return 0;
	}
	if (rune >= RUNESPERLEVEL || rune < 0) {
		bprint("[Error] get_rune function expects a rune value between 0 and ");
		bprint(ftos(RUNESPERLEVEL-1));
		bprint(". Received a value of ");
		bprint(ftos(rune));
		bprint(".\n");
		return 0;
	}
	
	return get_runeflag(level, rune);
};

//Sets a special flag
float (float rune, float value) set_specialflag = {
	if (rune > 23 || rune < 0) {
		bprint("[Error] set_specialflag function expects a rune value between 0 and 23. Received a value of ");
		bprint(ftos(rune));
		bprint(".\n");
		return 0;
	}
	return set_runeflag(15, rune, value);
};

//Gets whether a special flag is set
float (float rune) get_specialflag = {
	if (rune > 23 || rune < 0) {
		bprint("[Error] get_specialflag function expects a rune value between 0 and 23. Received a value of ");
		bprint(ftos(rune));
		bprint(".\n");
		return 0;
	}
	
	return get_runeflag(15, rune);
};

//Determines whether a key has been collected in a level.
float (float level, float key) get_key = {
	if (level < 0 || level > 14) {
		bprint("[Error] get_key function expects a level value between 0 and ");
		bprint(ftos(NUMLEVELS-1));
		bprint(". Received a value of ");
		bprint(ftos(level));
		bprint(".\n");
		return 0;
	}
	
	if (key == 0) {
		//Return whether the 22nd bit is set
		return get_runeflag(level, 22);
	} else {
		//Return whether the 23rd bit is set
		return get_runeflag(level, 23);
	}
}

//Sets a player's key in a level.
void (float level, float key, float value) set_key = {
	if (level < 0 || level > 14) {
		bprint("[Error] get_key function expects a level value between 0 and ");
		bprint(ftos(NUMLEVELS-1));
		bprint(". Received a value of ");
		bprint(ftos(level));
		bprint(".\n");
		return 0;
	}
	
	if (key == 0) {
		//Set the 22nd bit
		set_runeflag(level, 22, value);
	} else {
		//Set the 23rd bit
		set_runeflag(level, 23, value);
	}
}

//Counts the number of runes collected in a certain level.
float (float level) count_level_runes = {
	if (level < 0 || level > NUMLEVELS-1) {
		bprint("[Error] count_level_runes function expects a level value between 0 and ");
		bprint(ftos(NUMLEVELS-1));
		bprint(". Received a value of ");
		bprint(ftos(level));
		bprint(".\n");
		return 0;
	}
	
	float total = 0;
	float chosenbit = 1;
	
	for (float i = 0; i < RUNESPERLEVEL; i ++) {
		if (runeflags[level] & chosenbit) {
			total ++;
		}
		chosenbit *= 2;
	}
	return total;
};

//Counts the total number of runes collected between all levels.
float () count_runes = {
	float total = 0;
	
	for (float i = 0; i < NUMLEVELS; i ++) {
		total += count_level_runes(i);
	}
	return total;
};

void() update_secrets = {
	WriteByte(MSG_ALL, 3/*SVC_UPDATESTAT*/);
	WriteByte(MSG_ALL, 11/*STAT_TOTALSECRETS*/);
	WriteLong(MSG_ALL, total_secrets);
	
	WriteByte(MSG_ALL, 3/*SVC_UPDATESTAT*/);
	WriteByte(MSG_ALL, 13/*STAT_FOUNDSECRETS*/);
	WriteLong(MSG_ALL, found_secrets);
}

void() update_monsters = {
	WriteByte(MSG_ALL, 3/*SVC_UPDATESTAT*/);
	WriteByte(MSG_ALL, 12/*STAT_TOTALMONSTERS*/);
	WriteLong(MSG_ALL, total_monsters);
	
	WriteByte(MSG_ALL, 3/*SVC_UPDATESTAT*/);
	WriteByte(MSG_ALL, 14/*STAT_KILLEDMONSTERS*/);
	WriteLong(MSG_ALL, killed_monsters);
}

//Debug function for printing out a float in binary.
void(float num) print_bits= {
	for (float i = 23; i >= 0; i --) {
		if (num & bshift_left(1, i)) {
			bprint("1");
		} else {
			bprint("0");
		}
	}
	bprint("\n");
}

void() debugFunc;
	//bprint(ftos(time));
	//bprint("\n");
	//centerprint(nextent(world),"ERROR\n-----\nYou have installed\nthis mod incorrectly!!\n-----\nPlease read the readme file\nfor more information.");
	//print_bits(2);
	
	/*for (float i = 0; i < 8; i ++) {
		set_rune(14, i, 1);
	}*/
	
	//print_bits(runeflags[14]);
	//centerprint(nextent(world),ftos(get_runeflag(14,1)));
//}



void(float index, float val) set_ent_data = {
	if (index < 0 || index > (ENT_DATA_SIZE * 23)) {
		//return if out of range
		return;
	}
	
	float ind = floor(index / 23);
	float bit = mod(index, 23);
	float bit_val = bshift_left(1,bit);
	
	if (val) {
		self.ent_data[ind] = self.ent_data[ind] | bit_val;
	} else {
		self.ent_data[ind] = (self.ent_data[ind] | bit_val) - bit_val;
	}
}

float(float index) get_ent_data = {
	if (index < 0 || index > (ENT_DATA_SIZE * 23)) {
		//return if out of range
		return -1;
	}
	
	float ind = floor(index / 23);
	float bit = mod(index, 23);
	float bit_val = bshift_left(1,bit);
	
	return self.ent_data[ind] & bit_val;
}

void(vector org) spawn_tfog;
void(vector org, entity death_owner) spawn_tdeath;

void (entity obj, string dest, float no_effects) teleport_object = {
	local vector	org;
	local entity	t;
	
	//Find the destination
	t = find (world, targetname, dest);
	if (!t) {
		objerror ("couldn't find target");
	}
	
	// put a tfog where the player was and in front of the destination
	if (!no_effects) {
		spawn_tfog (other.origin);
		
		makevectors (t.mangle);
		org = t.origin + 32 * v_forward;
		spawn_tfog (org);
		spawn_tdeath(t.origin, other);
	}
	
	// move the player and lock him down for a little while
	if (!obj.health)
	{
		obj.origin = t.origin;
		obj.velocity = (v_forward * obj.velocity_x) + (v_forward * obj.velocity_y);
		return;
	}
	
	setorigin (obj, t.origin);
	obj.angles = t.mangle;
	if (obj.classname == "player") {
		obj.fixangle = 1;		// turn this way immediately
		obj.teleport_time = time + 0.7;
		if (obj.flags & FL_ONGROUND) {
			obj.flags = obj.flags - FL_ONGROUND;
		}
		obj.velocity = v_forward * 300;
	}
	obj.flags = obj.flags - (obj.flags & FL_ONGROUND);
}
