float (float num, float shift) bshift_left = {
	float ret = num;
	for (float i = 0; i < shift; i ++) {
		ret = ret * 2;
	}
	return ret;
};

float (float num, float shift) bshift_right = {
	float ret = num;
	for (float i = 0; i < shift; i ++) {
		ret = ret / 2;
	}
	return ret;
};

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
		runeflags[level] = runeflags[level] & (~chosenbit);
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
	
	return runeflags[level] & chosenbit;
};

//Sets whether a player has a rune or not.
float (float level, float rune, float value) set_rune = {
	if (level > NUMLEVELS-1 || level < 0) {
		bprint("[Error] set_rune function expects a level value between 0 and ");
		bprint(ftos(NUMLEVELS-1));
		bprint(". Received a value of ");
		bprint(ftos(level));
		bprint(".\n");
		return 0;
	}
	if (rune > RUNESPERLEVEL - 1 || rune < 0) {
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
	if (level > NUMLEVELS-1 || level < 0) {
		bprint("[Error] get_rune function expects a level value between 0 and ");
		bprint(ftos(NUMLEVELS-1));
		bprint(". Received a value of ");
		bprint(ftos(level));
		bprint(".\n");
		return 0;
	}
	if (rune > RUNESPERLEVEL - 1 || rune < 0) {
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
		return runeflags[level] & 4194304;
	} else {
		//Return whether the 23rd bit is set
		return runeflags[level] & 8388608;
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
		//Return whether the 22nd bit is set
		runeflags[level] = runeflags[level] | 4194304;
	} else {
		//Return whether the 23rd bit is set
		runeflags[level] = runeflags[level] | 8388608;
	}
}

//Counts the total number of runes collected in a certain level.
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
	
	for (float i = 0; i < NUMLEVELS-1; i ++) {
		total += count_level_runes(i);
	}
	return total;
};

void() debugFunc = {
	count_level_runes(55);
}



