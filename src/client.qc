
// prototypes
void () W_WeaponFrame;
void() W_SetCurrentAmmo;
void(entity attacker, float damage) player_pain;
void() player_stand1;
void (vector org) spawn_tfog;
void (vector org, entity death_owner) spawn_tdeath;

float	modelindex_eyes, modelindex_player;

/*
=============================================================================

				LEVEL CHANGING / INTERMISSION

=============================================================================
*/

float	intermission_running;
float	intermission_exittime;

/*QUAKED info_intermission (1 0.5 0.5) (-16 -16 -16) (16 16 16)
This is the camera point for the intermission.
Use mangle instead of angle, so you can set pitch or roll as well as yaw.  'pitch roll yaw'
*/
void() info_intermission =
{	
	if (self.angles) {
		self.mangle = self.angles;
	}
};

void() SetChangeParms = {
	//Sets game started to 1.
	set_specialflag(22,1);
	
	//Copies rune and unlockable data over to parms
	parm1 = runeflags[0];
	parm2 = runeflags[1];
	parm3 = runeflags[2];
	parm4 = runeflags[3];
	parm5 = runeflags[4];
	parm6 = runeflags[5];
	parm7 = runeflags[6];
	parm8 = runeflags[7];
	parm9 = runeflags[8];
	parm10 = runeflags[9];
	parm11 = runeflags[10];
	parm12 = runeflags[11];
	parm13 = runeflags[12];
	parm14 = runeflags[13];
	parm15 = runeflags[14];
	//The bottom six bits will be set to the current level's level_id, so the start map will know what level the player is coming from.
	//The other bits are set as normal.
	parm1 = (runeflags[0] & ~(63)) | (world.level_id & 63);
};

//Empty, but here for compatibility reasons
void() SetNewParms =
{};

void() ghostRunes = {
	entity t = world;
	while (1) {
		t = find (t, classname, "item_rune");
		if (!t) {
			break;
		}
		
		if (t.spawnflags & 4) {
			if (!get_rune(t.level_id, t.rune_id)) {
				remove(t);
			}
		} else {
			if (get_rune(t.level_id, t.rune_id)) {
				t.alpha = .4;
			}
		}
		
	}
}

void(string checkclass, float checkid) ghostWeapon = {
	entity t = world;
	while (1) {
		t = find (t, classname, checkclass);
		if (!t) {
			break;
		}
		if ((!(t.spawnflags & 1)) && (!get_specialflag(checkid))) {
			t.alpha = .4;
			t.touch = SUB_Null;
		} else {
			t.alpha = 1;
			t.touch = weapon_touch;
		}
	}
}

void() ghostWeapons = {
	ghostWeapon("weapon_supershotgun", 6);
	ghostWeapon("weapon_nailgun", 7);
	ghostWeapon("weapon_supernailgun", 8);
	ghostWeapon("weapon_grenadelauncher", 9);
	ghostWeapon("weapon_rocketlauncher", 10);
	ghostWeapon("weapon_lightning", 11);
	ghostWeapon("weapon_railgun", 12);
	ghostWeapon("weapon_flamethrower", 13);
	ghostWeapon("weapon_bfg", 14);
	ghostWeapon("weapon_shadowblade", 15);
}

void() ghostKeys = {
	entity t = world;
	if (get_key(world.level_id, 0)) {
		while (1) {
			t = find (t, classname, "item_key1");
			if (!t) {
				break;
			}
			remove(t);
		}
	}
	if (get_key(world.level_id, 1)) {
		while (1) {
			t = find (t, classname, "item_key2");
			if (!t) {
				break;
			}
			remove(t);
		}
	}
}

//Turns runes that have already been collected semitransparent.
//Also makes weapons uncollectable and semitransparent if they haven't been unlocked.
//Also also removes keys if you already have them.
//TODO: Change their skin too once I implement other skins.
void() ghostItems = {
	ghostRunes();
	
	//ghostWeapons();
	
	ghostKeys();
}

void() DecodeLevelParms =
{
	runeflags[0] |= parm1;
	runeflags[1] |= parm2;
	runeflags[2] |= parm3;
	runeflags[3] |= parm4;
	runeflags[4] |= parm5;
	runeflags[5] |= parm6;
	runeflags[6] |= parm7;
	runeflags[7] |= parm8;
	runeflags[8] |= parm9;
	runeflags[9] |= parm10;
	runeflags[10] |= parm11;
	runeflags[11] |= parm12;
	runeflags[12] |= parm13;
	runeflags[13] |= parm14;
	runeflags[14] |= parm15;
	runeflags[15] |= parm16;
	
	
	SetNewParms();
	
	//Give starting items
	if (world.items | world.items2 | world.ammo_shells | world.ammo_nails | world.ammo_rockets | world.ammo_cells) {
		self.items = world.items;
		self.items2 = world.items2;
		self.ammo_shells = world.ammo_shells;
		self.ammo_nails = world.ammo_nails;
		self.ammo_rockets = world.ammo_rockets;
		self.ammo_cells = world.ammo_cells;
	} else {
		self.items = IT_SHOTGUN | IT_AXE;
		self.health = 100;
		self.ammo_shells = 25;
	}
	
	//Turns runes and weapons ghostly if they've already been collected.
	ghostItems();
	
	//Gives the player their key if they have it.
	if (get_key(world.level_id, 0)) {
		self.items = self.items | IT_KEY1;
	}
	if (get_key(world.level_id, 1)) {
		self.items = self.items | IT_KEY2;
	}
	
	total_secrets = world.global_rune_total;
	found_secrets = count_runes();
	update_secrets();
};

/*
============
FindIntermission

Returns the entity to view from
============
*/
entity() FindIntermission =
{
	local	entity spot;

// look for info_intermission first
	while (1) {
		spot = find (spot, classname, "info_intermission");
		if (!spot) {
			break;
		}
		if (spot.rune_id == runefound) {
			return spot;
		}
	}

// then look for the start position
	spot = find (world, classname, "info_player_start");
	if (spot)
		return spot;
	
// testinfo_player_start is only found in regioned levels
	spot = find (world, classname, "testplayerstart");
	if (spot)
		return spot;
	
	objerror ("FindIntermission: no spot");
	return world;
};


string nextmap;
void() GotoNextMap =
{
	//total_secrets = ;
	
	
	if (cvar("samelevel"))	// if samelevel is set, stay on same level
		changelevel (mapname);
	else
		changelevel (nextmap);
};


void() ExitIntermission =
{
// skip any text in deathmatch
	if (deathmatch)
	{
		GotoNextMap ();
		return;
	}
	
	intermission_exittime = time + 1;
	intermission_running = intermission_running + 1;

//
// run some text if at the end of an episode
//
	if (intermission_running == 2)
	{
		if (world.model == "maps/e1m7.bsp")
		{
			WriteByte (MSG_ALL, SVC_CDTRACK);
			WriteByte (MSG_ALL, 2);
			WriteByte (MSG_ALL, 3);
			if (!cvar("registered"))
			{
				WriteByte (MSG_ALL, SVC_FINALE);
				WriteString (MSG_ALL, "As the corpse of the monstrous entity\nChthon sinks back into the lava whence\nit rose, you grip the Rune of Earth\nMagic tightly. Now that you have\nconquered the Dimension of the Doomed,\nrealm of Earth Magic, you are ready to\ncomplete your task in the other three\nhaunted lands of Quake. Or are you? If\nyou don't register Quake, you'll never\nknow what awaits you in the Realm of\nBlack Magic, the Netherworld, and the\nElder World!");
			}
			else
			{
				WriteByte (MSG_ALL, SVC_FINALE);
				WriteString (MSG_ALL, "As the corpse of the monstrous entity\nChthon sinks back into the lava whence\nit rose, you grip the Rune of Earth\nMagic tightly. Now that you have\nconquered the Dimension of the Doomed,\nrealm of Earth Magic, you are ready to\ncomplete your task. A Rune of magic\npower lies at the end of each haunted\nland of Quake. Go forth, seek the\ntotality of the four Runes!");
			}
			return;
		}
		else if (world.model == "maps/e2m6.bsp")
		{
			WriteByte (MSG_ALL, SVC_CDTRACK);
			WriteByte (MSG_ALL, 2);
			WriteByte (MSG_ALL, 3);

			WriteByte (MSG_ALL, SVC_FINALE);
			WriteString (MSG_ALL, "The Rune of Black Magic throbs evilly in\nyour hand and whispers dark thoughts\ninto your brain. You learn the inmost\nlore of the Hell-Mother; Shub-Niggurath!\nYou now know that she is behind all the\nterrible plotting which has led to so\nmuch death and horror. But she is not\ninviolate! Armed with this Rune, you\nrealize that once all four Runes are\ncombined, the gate to Shub-Niggurath's\nPit will open, and you can face the\nWitch-Goddess herself in her frightful\notherworld cathedral.");
			return;
		}
		else if (world.model == "maps/e3m6.bsp")
		{
			WriteByte (MSG_ALL, SVC_CDTRACK);
			WriteByte (MSG_ALL, 2);
			WriteByte (MSG_ALL, 3);

			WriteByte (MSG_ALL, SVC_FINALE);
			WriteString (MSG_ALL, "The charred viscera of diabolic horrors\nbubble viscously as you seize the Rune\nof Hell Magic. Its heat scorches your\nhand, and its terrible secrets blight\nyour mind. Gathering the shreds of your\ncourage, you shake the devil's shackles\nfrom your soul, and become ever more\nhard and determined to destroy the\nhideous creatures whose mere existence\nthreatens the souls and psyches of all\nthe population of Earth.");
			return;
		}
		else if (world.model == "maps/e4m7.bsp")
		{
			WriteByte (MSG_ALL, SVC_CDTRACK);
			WriteByte (MSG_ALL, 2);
			WriteByte (MSG_ALL, 3);

			WriteByte (MSG_ALL, SVC_FINALE);
			WriteString (MSG_ALL, "Despite the awful might of the Elder\nWorld, you have achieved the Rune of\nElder Magic, capstone of all types of\narcane wisdom. Beyond good and evil,\nbeyond life and death, the Rune\npulsates, heavy with import. Patient and\npotent, the Elder Being Shub-Niggurath\nweaves her dire plans to clear off all\nlife from the Earth, and bring her own\nfoul offspring to our world! For all the\ndwellers in these nightmare dimensions\nare her descendants! Once all Runes of\nmagic power are united, the energy\nbehind them will blast open the Gateway\nto Shub-Niggurath, and you can travel\nthere to foil the Hell-Mother's plots\nin person.");
			return;
		}

		GotoNextMap();
	}
	
	if (intermission_running == 3)
	{
		if (!cvar("registered"))
		{	// shareware episode has been completed, go to sell screen
			WriteByte (MSG_ALL, SVC_SELLSCREEN);
			return;
		}
		
		if ( (serverflags&15) == 15)
		{
			WriteByte (MSG_ALL, SVC_FINALE);
			WriteString (MSG_ALL, "Now, you have all four Runes. You sense\ntremendous invisible forces moving to\nunseal ancient barriers. Shub-Niggurath\nhad hoped to use the Runes Herself to\nclear off the Earth, but now instead,\nyou will use them to enter her home and\nconfront her as an avatar of avenging\nEarth-life. If you defeat her, you will\nbe remembered forever as the savior of\nthe planet. If she conquers, it will be\nas if you had never been born.");
			return;
		}
		
	}

	GotoNextMap();
};

/*
============
IntermissionThink

When the player presses attack or jump, change to the next level
============
*/
void() IntermissionThink =
{
	if (time < intermission_exittime)
		return;

	if (!self.button0 && !self.button1 && !self.button2)
		return;
	
	ExitIntermission ();
};

void() execute_changelevel =
{
	local entity	pos;

	intermission_running = 1;
	
// enforce a wait time before allowing changelevel
	if (deathmatch)
		intermission_exittime = time + 5;
	else
		intermission_exittime = time + 2;

	WriteByte (MSG_ALL, SVC_CDTRACK);
	WriteByte (MSG_ALL, 3);
	WriteByte (MSG_ALL, 3);
	
	pos = FindIntermission ();

	other = find (world, classname, "player");
	while (other != world)
	{
		other.view_ofs = '0 0 0';
		other.angles = other.v_angle = pos.mangle;
		other.fixangle = TRUE;		// turn this way immediately
		other.nextthink = time + 0.5;
		other.takedamage = DAMAGE_NO;
		other.solid = SOLID_NOT;
		other.movetype = MOVETYPE_NONE;
		other.modelindex = 0;
		setorigin (other, pos.origin);
		other = find (other, classname, "player");
	}	

	WriteByte (MSG_ALL, SVC_INTERMISSION);
};


void() changelevel_touch =
{
	if (other.classname != "player")
		return;

	if ((cvar("noexit") == 1) || ((cvar("noexit") == 2) && (mapname != "start")))
	{
		T_Damage (other, self, self, 50000);
		return;
	}

	if (coop || deathmatch)
	{
		bprint (other.netname);
		bprint (" exited the level\n");
	}
	
	runefound = -1;
	
	nextmap = self.map;

	SUB_UseTargets ();

	if ( (self.spawnflags & 1) && (deathmatch == 0) )
	{	// NO_INTERMISSION
		GotoNextMap();
		return;
	}
	
	self.touch = SUB_Null;

// we can't move people right now, because touch functions are called
// in the middle of C movement code, so set a think time to do it
	self.think = execute_changelevel;
	self.nextthink = time + 0.1;
};

/*QUAKED trigger_changelevel (0.5 0.5 0.5) ? NO_INTERMISSION
When the player touches this, he gets sent to the map listed in the "map" variable.  Unless the NO_INTERMISSION flag is set, the view will go to the info_intermission spot and display stats.
*/
void() trigger_changelevel =
{
	if (!self.map)
		objerror ("changelevel trigger doesn't have map");
	
	InitTrigger ();
	self.touch = changelevel_touch;
};

void() rune_touch =
{
	if (other.classname != "player") {
		return;
	}
	if (other.health <= 0) {
		return;
	}
	
	runefound = self.rune_id;
	float edited = set_rune(self.level_id, self.rune_id, 1);
	if (edited) {
		found_secrets = count_runes();
		WriteByte (MSG_ALL, SVC_FOUNDSECRET);
	}
	
	self.solid = SOLID_NOT;
	self.model = string_null;
	self.classname = "";
	
	//centerprint(other,ftos(runefound));
	
	sound (other, CHAN_ITEM, self.noise, 1, ATTN_NORM);
	//If this is a secret rune, don't exit the level and print a message.
	if (self.spawnflags & 2) {
		centerprint (other, "You found a bonus rune!");
		sound (other, CHAN_ITEM, self.noise, 1, ATTN_NORM);
		stuffcmd (other, "bf\n");
		return;
	}
	
	//Changes level
	if ((cvar("noexit") == 1) || ((cvar("noexit") == 2) && (mapname != "start"))) {
		return;
	}

	if (coop || deathmatch) {
		bprint (other.netname);
		bprint (" exited the level\n");
	}
	
	if (!self.map) {
		nextmap = "start";
	} else {
		nextmap = self.map;
	}

	if ((self.spawnflags & 1) && (deathmatch == 0) ) {	// NO_INTERMISSION
		GotoNextMap();
		return;
	}
	
	self.touch = SUB_Null;

// we can't move people right now, because touch functions are called
// in the middle of C movement code, so set a think time to do it
	self.think = execute_changelevel;
	self.nextthink = time + 0.1;
};

void() rune_mdlset = {
	switch(self.rune_mdl) {
		case 0:
		precache_model("progs/rune0.mdl");
		setmodel (self, "progs/rune0.mdl");
		break;

		case 1:
		precache_model("progs/rune1.mdl");
		setmodel (self, "progs/rune1.mdl");
		break;

		case 2:
		precache_model("progs/rune2.mdl");
		setmodel (self, "progs/rune2.mdl");
		break;

		case 3:
		precache_model("progs/rune3.mdl");
		setmodel (self, "progs/rune3.mdl");
		break;

		case 4:
		precache_model("progs/rune4.mdl");
		setmodel (self, "progs/rune4.mdl");
		break;

		case 5:
		precache_model("progs/rune5.mdl");
		setmodel (self, "progs/rune5.mdl");
		break;

		case 6:
		precache_model("progs/rune6.mdl");
		setmodel (self, "progs/rune6.mdl");
		break;

		case 7:
		precache_model("progs/rune7.mdl");
		setmodel (self, "progs/rune7.mdl");
		break;

		case 8:
		precache_model("progs/rune8.mdl");
		setmodel (self, "progs/rune8.mdl");
		break;

		case 9:
		precache_model("progs/rune9.mdl");
		setmodel (self, "progs/rune9.mdl");
		break;

		case 10:
		precache_model("progs/rune10.mdl");
		setmodel (self, "progs/rune10.mdl");
		break;

		case 11:
		precache_model("progs/rune11.mdl");
		setmodel (self, "progs/rune11.mdl");
		break;

		case 12:
		precache_model("progs/rune12.mdl");
		setmodel (self, "progs/rune12.mdl");
		break;

		case 13:
		precache_model("progs/rune13.mdl");
		setmodel (self, "progs/rune13.mdl");
		break;

		case 14:
		precache_model("progs/rune14.mdl");
		setmodel (self, "progs/rune14.mdl");
		break;

		case 15:
		precache_model("progs/rune15.mdl");
		setmodel (self, "progs/rune15.mdl");
		break;

		case 16:
		precache_model("progs/rune16.mdl");
		setmodel (self, "progs/rune16.mdl");
		break;

		case 17:
		precache_model("progs/rune17.mdl");
		setmodel (self, "progs/rune17.mdl");
		break;

		case 18:
		precache_model("progs/rune18.mdl");
		setmodel (self, "progs/rune18.mdl");
		break;

		case 19:
		precache_model("progs/rune19.mdl");
		setmodel (self, "progs/rune19.mdl");
		break;

		case 20:
		precache_model("progs/rune20.mdl");
		setmodel (self, "progs/rune20.mdl");
		break;

		case 21:
		precache_model("progs/rune21.mdl");
		setmodel (self, "progs/rune21.mdl");
		break;

		case 22:
		precache_model("progs/rune22.mdl");
		setmodel (self, "progs/rune22.mdl");
		break;

		case 23:
		precache_model("progs/rune23.mdl");
		setmodel (self, "progs/rune23.mdl");
		break;

		case 24:
		precache_model("progs/rune24.mdl");
		setmodel (self, "progs/rune24.mdl");
		break;

		case 25:
		precache_model("progs/rune25.mdl");
		setmodel (self, "progs/rune25.mdl");
		break;

		case 26:
		precache_model("progs/rune26.mdl");
		setmodel (self, "progs/rune26.mdl");
		break;

		case 27:
		precache_model("progs/rune27.mdl");
		setmodel (self, "progs/rune27.mdl");
		break;

		case 28:
		precache_model("progs/rune28.mdl");
		setmodel (self, "progs/rune28.mdl");
		break;

		case 29:
		precache_model("progs/rune29.mdl");
		setmodel (self, "progs/rune29.mdl");
		break;

		case 30:
		precache_model("progs/rune30.mdl");
		setmodel (self, "progs/rune30.mdl");
		break;

		case 31:
		precache_model("progs/rune31.mdl");
		setmodel (self, "progs/rune31.mdl");
		break;

		case 32:
		precache_model("progs/rune32.mdl");
		setmodel (self, "progs/rune32.mdl");
		break;

		case 33:
		precache_model("progs/rune33.mdl");
		setmodel (self, "progs/rune33.mdl");
		break;

		case 34:
		precache_model("progs/rune34.mdl");
		setmodel (self, "progs/rune34.mdl");
		break;

		case 35:
		precache_model("progs/rune35.mdl");
		setmodel (self, "progs/rune35.mdl");
		break;

		case 36:
		precache_model("progs/rune36.mdl");
		setmodel (self, "progs/rune36.mdl");
		break;

		case 37:
		precache_model("progs/rune37.mdl");
		setmodel (self, "progs/rune37.mdl");
		break;

		case 38:
		precache_model("progs/rune38.mdl");
		setmodel (self, "progs/rune38.mdl");
		break;

		case 39:
		precache_model("progs/rune39.mdl");
		setmodel (self, "progs/rune39.mdl");
		break;

		case 40:
		precache_model("progs/rune40.mdl");
		setmodel (self, "progs/rune40.mdl");
		break;

		case 41:
		precache_model("progs/rune41.mdl");
		setmodel (self, "progs/rune41.mdl");
		break;

		case 42:
		precache_model("progs/rune42.mdl");
		setmodel (self, "progs/rune42.mdl");
		break;

		case 43:
		precache_model("progs/rune43.mdl");
		setmodel (self, "progs/rune43.mdl");
		break;

		case 44:
		precache_model("progs/rune44.mdl");
		setmodel (self, "progs/rune44.mdl");
		break;

		case 45:
		precache_model("progs/rune45.mdl");
		setmodel (self, "progs/rune45.mdl");
		break;

		case 46:
		precache_model("progs/rune46.mdl");
		setmodel (self, "progs/rune46.mdl");
		break;

		case 47:
		precache_model("progs/rune47.mdl");
		setmodel (self, "progs/rune47.mdl");
		break;

		case 48:
		precache_model("progs/rune48.mdl");
		setmodel (self, "progs/rune48.mdl");
		break;

		case 49:
		precache_model("progs/rune49.mdl");
		setmodel (self, "progs/rune49.mdl");
		break;

		case 50:
		precache_model("progs/rune50.mdl");
		setmodel (self, "progs/rune50.mdl");
		break;

		case 51:
		precache_model("progs/rune51.mdl");
		setmodel (self, "progs/rune51.mdl");
		break;

		case 52:
		precache_model("progs/rune52.mdl");
		setmodel (self, "progs/rune52.mdl");
		break;

		case 53:
		precache_model("progs/rune53.mdl");
		setmodel (self, "progs/rune53.mdl");
		break;

		case 54:
		precache_model("progs/rune54.mdl");
		setmodel (self, "progs/rune54.mdl");
		break;

		case 55:
		precache_model("progs/rune55.mdl");
		setmodel (self, "progs/rune55.mdl");
		break;

		case 56:
		precache_model("progs/rune56.mdl");
		setmodel (self, "progs/rune56.mdl");
		break;

		case 57:
		precache_model("progs/rune57.mdl");
		setmodel (self, "progs/rune57.mdl");
		break;

		case 58:
		precache_model("progs/rune58.mdl");
		setmodel (self, "progs/rune58.mdl");
		break;

		case 59:
		precache_model("progs/rune59.mdl");
		setmodel (self, "progs/rune59.mdl");
		break;

		case 60:
		precache_model("progs/rune60.mdl");
		setmodel (self, "progs/rune60.mdl");
		break;

		case 61:
		precache_model("progs/rune61.mdl");
		setmodel (self, "progs/rune61.mdl");
		break;

		case 62:
		precache_model("progs/rune62.mdl");
		setmodel (self, "progs/rune62.mdl");
		break;

		case 63:
		precache_model("progs/rune63.mdl");
		setmodel (self, "progs/rune63.mdl");
		break;

		case 64:
		precache_model("progs/rune64.mdl");
		setmodel (self, "progs/rune64.mdl");
		break;

		case 65:
		precache_model("progs/rune65.mdl");
		setmodel (self, "progs/rune65.mdl");
		break;

		case 66:
		precache_model("progs/rune66.mdl");
		setmodel (self, "progs/rune66.mdl");
		break;

		case 67:
		precache_model("progs/rune67.mdl");
		setmodel (self, "progs/rune67.mdl");
		break;

		case 68:
		precache_model("progs/rune68.mdl");
		setmodel (self, "progs/rune68.mdl");
		break;

		case 69:
		precache_model("progs/rune69.mdl");
		setmodel (self, "progs/rune69.mdl");
		break;

		case 70:
		precache_model("progs/rune70.mdl");
		setmodel (self, "progs/rune70.mdl");
		break;

		case 71:
		precache_model("progs/rune71.mdl");
		setmodel (self, "progs/rune71.mdl");
		break;

		case 72:
		precache_model("progs/rune72.mdl");
		setmodel (self, "progs/rune72.mdl");
		break;

		case 73:
		precache_model("progs/rune73.mdl");
		setmodel (self, "progs/rune73.mdl");
		break;

		case 74:
		precache_model("progs/rune74.mdl");
		setmodel (self, "progs/rune74.mdl");
		break;

		case 75:
		precache_model("progs/rune75.mdl");
		setmodel (self, "progs/rune75.mdl");
		break;

		case 76:
		precache_model("progs/rune76.mdl");
		setmodel (self, "progs/rune76.mdl");
		break;

		case 77:
		precache_model("progs/rune77.mdl");
		setmodel (self, "progs/rune77.mdl");
		break;

		case 78:
		precache_model("progs/rune78.mdl");
		setmodel (self, "progs/rune78.mdl");
		break;

		case 79:
		precache_model("progs/rune79.mdl");
		setmodel (self, "progs/rune79.mdl");
		break;

		case 80:
		precache_model("progs/rune80.mdl");
		setmodel (self, "progs/rune80.mdl");
		break;

		case 81:
		precache_model("progs/rune81.mdl");
		setmodel (self, "progs/rune81.mdl");
		break;

		case 82:
		precache_model("progs/rune82.mdl");
		setmodel (self, "progs/rune82.mdl");
		break;

		case 83:
		precache_model("progs/rune83.mdl");
		setmodel (self, "progs/rune83.mdl");
		break;

		case 84:
		precache_model("progs/rune84.mdl");
		setmodel (self, "progs/rune84.mdl");
		break;

		case 85:
		precache_model("progs/rune85.mdl");
		setmodel (self, "progs/rune85.mdl");
		break;

		case 86:
		precache_model("progs/rune86.mdl");
		setmodel (self, "progs/rune86.mdl");
		break;

		case 87:
		precache_model("progs/rune87.mdl");
		setmodel (self, "progs/rune87.mdl");
		break;

		case 88:
		precache_model("progs/rune88.mdl");
		setmodel (self, "progs/rune88.mdl");
		break;

		case 89:
		precache_model("progs/rune89.mdl");
		setmodel (self, "progs/rune89.mdl");
		break;

		case 90:
		precache_model("progs/rune90.mdl");
		setmodel (self, "progs/rune90.mdl");
		break;

		case 91:
		precache_model("progs/rune91.mdl");
		setmodel (self, "progs/rune91.mdl");
		break;

		case 92:
		precache_model("progs/rune92.mdl");
		setmodel (self, "progs/rune92.mdl");
		break;

		case 93:
		precache_model("progs/rune93.mdl");
		setmodel (self, "progs/rune93.mdl");
		break;

		case 94:
		precache_model("progs/rune94.mdl");
		setmodel (self, "progs/rune94.mdl");
		break;

		case 95:
		precache_model("progs/rune95.mdl");
		setmodel (self, "progs/rune95.mdl");
		break;

		case 96:
		precache_model("progs/rune96.mdl");
		setmodel (self, "progs/rune96.mdl");
		break;

		case 97:
		precache_model("progs/rune97.mdl");
		setmodel (self, "progs/rune97.mdl");
		break;

		case 98:
		precache_model("progs/rune98.mdl");
		setmodel (self, "progs/rune98.mdl");
		break;

		case 99:
		precache_model("progs/rune99.mdl");
		setmodel (self, "progs/rune99.mdl");
		break;

		case 100:
		precache_model("progs/rune100.mdl");
		setmodel (self, "progs/rune100.mdl");
		break;

		case 101:
		precache_model("progs/rune101.mdl");
		setmodel (self, "progs/rune101.mdl");
		break;

		case 102:
		precache_model("progs/rune102.mdl");
		setmodel (self, "progs/rune102.mdl");
		break;

		case 103:
		precache_model("progs/rune103.mdl");
		setmodel (self, "progs/rune103.mdl");
		break;

		case 104:
		precache_model("progs/rune104.mdl");
		setmodel (self, "progs/rune104.mdl");
		break;

		case 105:
		precache_model("progs/rune105.mdl");
		setmodel (self, "progs/rune105.mdl");
		break;

		case 106:
		precache_model("progs/rune106.mdl");
		setmodel (self, "progs/rune106.mdl");
		break;

		case 107:
		precache_model("progs/rune107.mdl");
		setmodel (self, "progs/rune107.mdl");
		break;

		case 108:
		precache_model("progs/rune108.mdl");
		setmodel (self, "progs/rune108.mdl");
		break;

		case 109:
		precache_model("progs/rune109.mdl");
		setmodel (self, "progs/rune109.mdl");
		break;

		case 110:
		precache_model("progs/rune110.mdl");
		setmodel (self, "progs/rune110.mdl");
		break;

		case 111:
		precache_model("progs/rune111.mdl");
		setmodel (self, "progs/rune111.mdl");
		break;

		case 112:
		precache_model("progs/rune112.mdl");
		setmodel (self, "progs/rune112.mdl");
		break;

		case 113:
		precache_model("progs/rune113.mdl");
		setmodel (self, "progs/rune113.mdl");
		break;

		case 114:
		precache_model("progs/rune114.mdl");
		setmodel (self, "progs/rune114.mdl");
		break;

		case 115:
		precache_model("progs/rune115.mdl");
		setmodel (self, "progs/rune115.mdl");
		break;

		case 116:
		precache_model("progs/rune116.mdl");
		setmodel (self, "progs/rune116.mdl");
		break;

		case 117:
		precache_model("progs/rune117.mdl");
		setmodel (self, "progs/rune117.mdl");
		break;

		case 118:
		precache_model("progs/rune118.mdl");
		setmodel (self, "progs/rune118.mdl");
		break;

		case 119:
		precache_model("progs/rune119.mdl");
		setmodel (self, "progs/rune119.mdl");
		break;

		case 120:
		precache_model("progs/rune120.mdl");
		setmodel (self, "progs/rune120.mdl");
		break;

		case 121:
		precache_model("progs/rune121.mdl");
		setmodel (self, "progs/rune121.mdl");
		break;

		case 122:
		precache_model("progs/rune122.mdl");
		setmodel (self, "progs/rune122.mdl");
		break;

		case 123:
		precache_model("progs/rune123.mdl");
		setmodel (self, "progs/rune123.mdl");
		break;

		case 124:
		precache_model("progs/rune124.mdl");
		setmodel (self, "progs/rune124.mdl");
		break;

		case 125:
		precache_model("progs/rune125.mdl");
		setmodel (self, "progs/rune125.mdl");
		break;

		case 126:
		precache_model("progs/rune126.mdl");
		setmodel (self, "progs/rune126.mdl");
		break;

		case 127:
		precache_model("progs/rune127.mdl");
		setmodel (self, "progs/rune127.mdl");
		break;


	}
}

void() item_rune = {
	if (self.level_id < 0 || self.level_id > RUNESPERLEVEL-1) {
		objerror ("Invalid level_id for item_rune.");
	}
	if (self.rune_id < 0 || self.rune_id > RUNESPERLEVEL-1) {
		objerror ("Invalid rune_id for item_rune.");
	}
	
	if (deathmatch == 2) {
		remove(self);
		return;
	}
	
	precache_sound ("misc/runekey.wav");
	self.noise = "misc/runekey.wav";
	
	rune_mdlset();
	
	if (!self.level_id) {
		self.level_id = world.level_id;
	}
	if (self.level_id == -1) {
		self.level_id = 0;
	}
	
	if (self.spawnflags & 4) {
		self.touch = SUB_Null;
	} else {
		self.touch = rune_touch;
	}
	
	setsize (self, '-16 -16 -24', '16 16 32');
	//setsize (self, '-8 -8 -24', '8 8 32');
	StartItem();
};


/*
=============================================================================

				PLAYER GAME EDGE FUNCTIONS

=============================================================================
*/

void() set_suicide_frame;

// called by ClientKill and DeadThink
void() respawn =
{
	if (coop)
	{
		// make a copy of the dead body for appearances sake
		CopyToBodyQue (self);
		// get the spawn parms as they were at level start
		setspawnparms (self);
		// respawn		
		PutClientInServer ();
	}
	else if (deathmatch)
	{
		// make a copy of the dead body for appearances sake
		CopyToBodyQue (self);
		// set default spawn parms
		SetNewParms ();
		// respawn		
		PutClientInServer ();
	}
	else
	{	// restart the entire server
		//localcmd ("restart\n");
		
		// put serverflags back to map's initial setting
		//serverflags = startingserverflags;
		// request a reset to the parms
		//reset_flag = TRUE;
		// "change" to the same level
		set_specialflag(18, 1);
		localcmd ("changelevel start\n");
	}
};


/*
============
ClientKill

Player entered the suicide command
============
*/
void() ClientKill =
{
	bprint (self.netname);
	bprint (" suicides\n");
	set_suicide_frame ();
	self.modelindex = modelindex_player;
	self.frags = self.frags - 2;	// extra penalty
	respawn ();
};

float(vector v) CheckSpawnPoint =
{
	return FALSE;
};

/*
============
SelectSpawnPoint

Returns the entity to spawn at
============
*/
entity() SelectSpawnPoint =
{
	local	entity spot;
	local 	float haslooped = 0;
	
	if (coop) {
		if (mapname == "start" && get_specialflag(22)) {
			//On start maps in coop when returning from a level, cycle through info_player_coop_return entities that match the previous level. 
			//Do not select info_player_start entities, since the air tubes could have weird interactions with multiple players.
			while(1) {
				lastspawn = find(lastspawn, classname, "info_player_coop_return");
				if (!lastspawn) {
					if (haslooped) {
						//If it has looped through the entities a full time without finding any valid spawns, just spawn at the default info_player_start entity.
						bprint("Error: Could not find proper spawn point. Going to default spawn.\n");
						break;
					}
					haslooped = 1;
				}
				
				//Check if the info_player_start matches the previous level.
				if (lastspawn.level_id == (runeflags[0] & 63)) {
					return lastspawn;
				}
			}
		} else {
			//On non-start maps in coop, cycle through info_player_coop entities, end with info_player_start, then start over.
			lastspawn = find(lastspawn, classname, "info_player_coop");
			if (lastspawn) {
				return lastspawn;
			}
		}
	}
	//No deathmatch support in this mod
	
	//On start maps in singleplayer when returning from a level, cycle through info_player_start_return entities that match the previous level. 
	if (mapname == "start" && get_specialflag(22)) {
		spot = world;
		while(1) {
			spot = find(spot, classname, "info_player_start_return");
			if (!spot) {
				break;
			}
			
			//Check if the info_player_start matches the previous level.
			if (spot.level_id == (runeflags[0] & 31)) {
				return spot;
			}
		}
	}
	
	//If it's a regular map or the game has just started, go to the regular info_player_start
	spot = find (world, classname, "info_player_start");
	
	if (!spot) {
		error ("PutClientInServer: no info_player_start on level");
	}
	
	return spot;
};

/*
===========
PutClientInServer

called each time a player is spawned
============
*/
void() DecodeLevelParms;
void() PlayerDie;


void() PutClientInServer =
{
	local	entity spot;
	
	DecodeLevelParms ();
	spot = SelectSpawnPoint ();

	self.classname = "player";
	self.health = 100;
	self.takedamage = DAMAGE_AIM;
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_WALK;
	self.show_hostile = 0;
	self.max_health = 100;
	self.flags = FL_CLIENT;
	self.air_finished = time + 12;
	self.dmg = 2;   		// initial water damage
	self.super_damage_finished = 0;
	self.radsuit_finished = 0;
	self.invisible_finished = 0;
	self.invincible_finished = 0;
	self.effects = 0;
	self.invincible_time = 0;
	
	W_SetCurrentAmmo ();

	self.attack_finished = time;
	self.th_pain = player_pain;
	self.th_die = PlayerDie;
	
	self.deadflag = DEAD_NO;
// paustime is set by teleporters to keep the player from moving a while
	self.pausetime = 0;
	
//	spot = SelectSpawnPoint ();

	self.origin = spot.origin + '0 0 1';
	self.angles = spot.angles;
	if (get_specialflag(18)) {
		set_specialflag(18,0);
		self.angles_y = self.angles_y + 180;
	}
	self.fixangle = TRUE;		// turn this way immediately

// oh, this is a hack!
	setmodel (self, "progs/eyes.mdl");
	modelindex_eyes = self.modelindex;

	setmodel (self, "progs/player.mdl");
	modelindex_player = self.modelindex;

	setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);
	
	self.view_ofs = '0 0 22';

	player_stand1 ();
	
	if (deathmatch || coop)
	{
		makevectors(self.angles);
		spawn_tfog (self.origin + v_forward*20);
	}

	spawn_tdeath (self.origin, self);
};


/*
=============================================================================

				QUAKED FUNCTIONS

=============================================================================
*/


/*QUAKED info_player_start (1 0 0) (-16 -16 -24) (16 16 24)
The normal starting point for a level.
*/
void() info_player_start = {};

void() info_player_start_return = {};
void() info_player_coop_return = {};


/*QUAKED info_player_start2 (1 0 0) (-16 -16 -24) (16 16 24)
Only used on start map for the return point from an episode.
*/
void() info_player_start2 =
{
};


/*
saved out by quaked in region mode
*/
void() testplayerstart =
{
};

/*QUAKED info_player_deathmatch (1 0 1) (-16 -16 -24) (16 16 24)
potential spawning position for deathmatch games
*/
void() info_player_deathmatch =
{
};

/*QUAKED info_player_coop (1 0 1) (-16 -16 -24) (16 16 24)
potential spawning position for coop games
*/
void() info_player_coop =
{
};

/*
===============================================================================

RULES

===============================================================================
*/

/*
go to the next level for deathmatch
only called if a time or frag limit has expired
*/
void() NextLevel =
{
	local entity o;

	if (mapname == "start")
	{
		if (!cvar("registered"))
		{
			mapname = "e1m1";
		}
		else if (!(serverflags & 1))
		{
			mapname = "e1m1";
			serverflags = serverflags | 1;
		}
		else if (!(serverflags & 2))
		{
			mapname = "e2m1";
			serverflags = serverflags | 2;
		}
		else if (!(serverflags & 4))
		{
			mapname = "e3m1";
			serverflags = serverflags | 4;
		}
		else if (!(serverflags & 8))
		{
			mapname = "e4m1";
			serverflags = serverflags - 7;
		}

		o = spawn();
		o.map = mapname;
	}
	else
	{
		// find a trigger changelevel
		o = find(world, classname, "trigger_changelevel");

		// go back to start if no trigger_changelevel
		if (!o)
		{
			mapname = "start";
			o = spawn();
			o.map = mapname;
		}
	}

	nextmap = o.map;
	gameover = TRUE;
	
	if (o.nextthink < time)
	{
		o.think = execute_changelevel;
		o.nextthink = time + 0.1;
	}
};

/*
============
CheckRules

Exit deathmatch games upon conditions
============
*/
void() CheckRules =
{
	local	float		timelimit;
	local	float		fraglimit;
	
	if (gameover)	// someone else quit the game already
		return;
		
	timelimit = cvar("timelimit") * 60;
	fraglimit = cvar("fraglimit");
	
	if (timelimit && time >= timelimit)
	{
		NextLevel ();
		return;
	}
	
	if (fraglimit && self.frags >= fraglimit)
	{
		NextLevel ();
		return;
	}	
};

//============================================================================

void() PlayerDeathThink =
{
	local float		forward;

	if ((self.flags & FL_ONGROUND))
	{
		forward = vlen (self.velocity);
		forward = forward - 20;
		if (forward <= 0)
			self.velocity = '0 0 0';
		else	
			self.velocity = forward * normalize(self.velocity);
	}

// wait for all buttons released
	if (self.deadflag == DEAD_DEAD)
	{
		if (self.button2 || self.button1 || self.button0)
			return;
		self.deadflag = DEAD_RESPAWNABLE;
		return;
	}

// wait for any button down
	if (!self.button2 && !self.button1 && !self.button0)
		return;

	self.button0 = 0;
	self.button1 = 0;
	self.button2 = 0;
	respawn();
};


void() PlayerJump =
{
	if (self.flags & FL_WATERJUMP)
		return;
	
	if (self.waterlevel >= 2)
	{
		if (self.watertype == CONTENT_WATER)
			self.velocity_z = 100;
		else if (self.watertype == CONTENT_SLIME)
			if (world.world_properties & HONEYSLIME) {
				self.velocity_z = 10;
			} else {
				self.velocity_z = 80;
			}
		else
			self.velocity_z = 50;

// play swiming sound
		if (self.swim_flag < time)
		{
			self.swim_flag = time + 1;
			if (random() < 0.5)
				sound (self, CHAN_BODY, "misc/water1.wav", 1, ATTN_NORM);
			else
				sound (self, CHAN_BODY, "misc/water2.wav", 1, ATTN_NORM);
		}

		return;
	}

	if (!(self.flags & FL_ONGROUND))
		return;

	if ( !(self.flags & FL_JUMPRELEASED) )
		return;		// don't pogo stick

	self.flags = self.flags - (self.flags & FL_JUMPRELEASED);

	self.flags = self.flags - FL_ONGROUND;	// don't stairwalk
	
	self.button2 = 0;
// player jumping sound
	sound (self, CHAN_BODY, "player/plyrjmp8.wav", 1, ATTN_NORM);
	self.velocity_z = self.velocity_z + 270;
};


/*
===========
WaterMove

============
*/
.float	dmgtime;

void() WaterMove =
{
//dprint (ftos(self.waterlevel));
	if (self.movetype == MOVETYPE_NOCLIP)
		return;
	if (self.health < 0)
		return;

	if (self.waterlevel != 3)
	{
		if (self.air_finished < time)
			sound (self, CHAN_VOICE, "player/gasp2.wav", 1, ATTN_NORM);
		else if (self.air_finished < time + 9)
			sound (self, CHAN_VOICE, "player/gasp1.wav", 1, ATTN_NORM);
		self.air_finished = time + 12;
		self.dmg = 2;
	}
	else if (self.air_finished < time)
	{	// drown!
		if (self.pain_finished < time)
		{
			self.dmg = self.dmg + 2;
			if (self.dmg > 15)
				self.dmg = 10;
			T_Damage (self, world, world, self.dmg);
			self.pain_finished = time + 1;
		}
	}
	
	if (!self.waterlevel)
	{
		if (self.flags & FL_INWATER)
		{	
			// play leave water sound
			sound (self, CHAN_BODY, "misc/outwater.wav", 1, ATTN_NORM);
			self.flags = self.flags - FL_INWATER;
		}
		return;
	}

	if (self.watertype == CONTENT_LAVA)
	{	// do damage
		if (self.dmgtime < time)
		{
			if (self.radsuit_finished > time)
				self.dmgtime = time + 1;
			else
				self.dmgtime = time + 0.2;

			T_Damage (self, world, world, 10*self.waterlevel);
		}
	}
	else if (self.watertype == CONTENT_SLIME)
	{	
		//Check if it should act like Slime or Honey.
		if (world.world_properties & HONEYSLIME) {
			//TODO honey
			
		} else {
			//Do damage
			if (self.dmgtime < time && self.radsuit_finished < time) {
				self.dmgtime = time + 1;
				T_Damage (self, world, world, 4*self.waterlevel);
			}
		}
		
	}
	
	if ( !(self.flags & FL_INWATER) )
	{	

// player enter water sound

		if (self.watertype == CONTENT_LAVA)
			sound (self, CHAN_BODY, "player/inlava.wav", 1, ATTN_NORM);
		if (self.watertype == CONTENT_WATER)
			sound (self, CHAN_BODY, "player/inh2o.wav", 1, ATTN_NORM);
		if (self.watertype == CONTENT_SLIME) {
			if (world.world_properties & HONEYSLIME) {
				sound (self, CHAN_BODY, "player/inlava.wav", 1, ATTN_NORM);
			} else {
				sound (self, CHAN_BODY, "player/slimbrn2.wav", 1, ATTN_NORM);
			}
		}
			

		self.flags = self.flags + FL_INWATER;
		self.dmgtime = 0;
	}
	
	if (! (self.flags & FL_WATERJUMP) )
		self.velocity = self.velocity - 0.8*self.waterlevel*frametime*self.velocity;
};

void() CheckWaterJump =
{
	local vector start, end;

// check for a jump-out-of-water
	makevectors (self.angles);
	start = self.origin;
	start_z = start_z + 8; 
	v_forward_z = 0;
	normalize(v_forward);
	end = start + v_forward*24;
	traceline (start, end, TRUE, self);
	if (trace_fraction < 1)
	{	// solid at waist
		start_z = start_z + self.maxs_z - 8;
		end = start + v_forward*24;
		self.movedir = trace_plane_normal * -50;
		traceline (start, end, TRUE, self);
		if (trace_fraction == 1)
		{	// open at eye level
			self.flags = self.flags | FL_WATERJUMP;
			self.velocity_z = 225;
			self.flags = self.flags - (self.flags & FL_JUMPRELEASED);
			self.teleport_time = time + 2;	// safety net
			return;
		}
	}
};


/*
================
PlayerPreThink

Called every frame before physics are run
================
*/
void() PlayerPreThink =
{
	if (intermission_running)
	{
		IntermissionThink ();	// otherwise a button could be missed between
		return;					// the think tics
	}

	if (self.view_ofs == '0 0 0')
		return;		// intermission or finale

	makevectors (self.v_angle);		// is this still used

	CheckRules ();
	WaterMove ();

	if (self.waterlevel == 2)
		CheckWaterJump ();

	if (self.deadflag >= DEAD_DEAD)
	{
		PlayerDeathThink ();
		return;
	}
	
	if (self.deadflag == DEAD_DYING)
		return;	// dying, so do nothing

	if (self.button2)
	{
		PlayerJump ();
	}
	else
		self.flags = self.flags | FL_JUMPRELEASED;

// teleporters can force a non-moving pause time	
	if (time < self.pausetime)
		self.velocity = '0 0 0';

	if(time > self.attack_finished && self.currentammo == 0 && self.weapon != IT_AXE)
	{
		self.weapon = W_BestWeapon ();
		W_SetCurrentAmmo ();
	}
};
	
/*
================
CheckPowerups

Check for turning off powerups
================
*/
void() CheckPowerups =
{
	if (self.health <= 0)
		return;

// invisibility
	if (self.invisible_finished)
	{
// sound and screen flash when items starts to run out
		if (self.invisible_sound < time)
		{
			sound (self, CHAN_AUTO, "items/inv3.wav", 0.5, ATTN_IDLE);
			self.invisible_sound = time + ((random() * 3) + 1);
		}


		if (self.invisible_finished < time + 3)
		{
			if (self.invisible_time == 1)
			{
				sprint (self, "Ring of Shadows magic is fading\n");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, "items/inv2.wav", 1, ATTN_NORM);
				self.invisible_time = time + 1;
			}
			
			if (self.invisible_time < time)
			{
				self.invisible_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}

		if (self.invisible_finished < time)
		{	// just stopped
			self.items = self.items - IT_INVISIBILITY;
			self.invisible_finished = 0;
			self.invisible_time = 0;
		}
		
	// use the eyes
		self.frame = 0;
		self.modelindex = modelindex_eyes;
	}
	else
		self.modelindex = modelindex_player;	// don't use eyes

// invincibility
	if (self.invincible_finished)
	{
// sound and screen flash when items starts to run out
		if (self.invincible_finished < time + 3)
		{
			if (self.invincible_time == 1)
			{
				sprint (self, "Protection is almost burned out\n");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, "items/protect2.wav", 1, ATTN_NORM);
				self.invincible_time = time + 1;
			}
			
			if (self.invincible_time < time)
			{
				self.invincible_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}
		
		if (self.invincible_finished < time)
		{	// just stopped
			self.items = self.items - IT_INVULNERABILITY;
			self.invincible_time = 0;
			self.invincible_finished = 0;
		}
		if (self.invincible_finished > time)
			self.effects = self.effects | EF_DIMLIGHT;
		else
			self.effects = self.effects - (self.effects & EF_DIMLIGHT);
	}

// super damage
	if (self.super_damage_finished)
	{

// sound and screen flash when items starts to run out

		if (self.super_damage_finished < time + 3)
		{
			if (self.super_time == 1)
			{
				sprint (self, "Quad Damage is wearing off\n");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, "items/damage2.wav", 1, ATTN_NORM);
				self.super_time = time + 1;
			}	  
			
			if (self.super_time < time)
			{
				self.super_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}

		if (self.super_damage_finished < time)
		{	// just stopped
			self.items = self.items - IT_QUAD;
			self.super_damage_finished = 0;
			self.super_time = 0;
		}
		if (self.super_damage_finished > time)
			self.effects = self.effects | EF_DIMLIGHT;
		else
			self.effects = self.effects - (self.effects & EF_DIMLIGHT);
	}	

// suit	
	if (self.radsuit_finished)
	{
		self.air_finished = time + 12;		// don't drown

// sound and screen flash when items starts to run out
		if (self.radsuit_finished < time + 3)
		{
			if (self.rad_time == 1)
			{
				sprint (self, "Air supply in Biosuit expiring\n");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, "items/suit2.wav", 1, ATTN_NORM);
				self.rad_time = time + 1;
			}
			
			if (self.rad_time < time)
			{
				self.rad_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}

		if (self.radsuit_finished < time)
		{	// just stopped
			self.items = self.items - IT_SUIT;
			self.rad_time = 0;
			self.radsuit_finished = 0;
		}
	}	

};


/*
================
PlayerPostThink

Called every frame after physics are run
================
*/
void() PlayerPostThink =
{
	if (self.view_ofs == '0 0 0')
		return;		// intermission or finale
	if (self.deadflag)
		return;
		
// do weapon stuff

	W_WeaponFrame ();

// check to see if player landed and play landing sound	
	if ((self.jump_flag < -300) && (self.flags & FL_ONGROUND) && (self.health > 0))
	{
		if (self.watertype == CONTENT_WATER)
			sound (self, CHAN_BODY, "player/h2ojump.wav", 1, ATTN_NORM);
		else if (self.jump_flag < -650)
		{
			T_Damage (self, world, world, 5); 
			sound (self, CHAN_VOICE, "player/land2.wav", 1, ATTN_NORM);
			self.deathtype = "falling";
		}
		else
			sound (self, CHAN_VOICE, "player/land.wav", 1, ATTN_NORM);

		self.jump_flag = 0;
	}

	if (!(self.flags & FL_ONGROUND))
		self.jump_flag = self.velocity_z;

	CheckPowerups ();
};


/*
===========
ClientConnect

called when a player connects to a server
============
*/
void() ClientConnect =
{
	bprint (self.netname);
	bprint (" entered the game\n");
	
// a client connecting during an intermission can cause problems
	if (intermission_running)
		ExitIntermission ();
};


/*
===========
ClientDisconnect

called when a player disconnects from a server
============
*/
void() ClientDisconnect =
{
	if (gameover)
		return;
	// if the level end trigger has been activated, just return
	// since they aren't *really* leaving

	// let everyone else know
	bprint (self.netname);
	bprint (" left the game with ");
	bprint (ftos(self.frags));
	bprint (" frags\n");
	sound (self, CHAN_BODY, "player/tornoff2.wav", 1, ATTN_NONE);
	set_suicide_frame ();
};

/*
===========
ClientObituary

called when a player dies
============
*/
void(entity targ, entity attacker) ClientObituary =
{
	local	float rnum;
	local	string deathstring, deathstring2;
	rnum = random();

	if (targ.classname == "player")
	{
		if (attacker.classname == "teledeath")
		{
			bprint (targ.netname);
			bprint (" was telefragged by ");
			bprint (attacker.owner.netname);
			bprint ("\n");

			attacker.owner.frags = attacker.owner.frags + 1;
			return;
		}

		if (attacker.classname == "teledeath2")
		{
			bprint ("Satan's power deflects ");
			bprint (targ.netname);
			bprint ("'s telefrag\n");

			targ.frags = targ.frags - 1;
			return;
		}

		if (attacker.classname == "player")
		{
			if (targ == attacker)
			{
				// killed self
				attacker.frags = attacker.frags - 1;
				bprint (targ.netname);
				
				if (targ.weapon == 64 && targ.waterlevel > 1)
				{
					bprint (" discharges into the water.\n");
					return;
				}
				if (targ.weapon == IT_GRENADE_LAUNCHER)
					bprint (" tries to put the pin back in\n");
				else
					bprint (" becomes bored with life\n");
				return;
			}
			else if ( (teamplay == 2) && (targ.team > 0)&&(targ.team == attacker.team) )
			{
				if (rnum < 0.25)
					deathstring = " mows down a teammate\n";
				else if (rnum < 0.50)
					deathstring = " checks his glasses\n";
				else if (rnum < 0.75)
					deathstring = " gets a frag for the other team\n";
				else
					deathstring = " loses another friend\n";
				bprint (attacker.netname);
				bprint (deathstring);
				attacker.frags = attacker.frags - 1;
				return;
			}
			else
			{
				attacker.frags = attacker.frags + 1;

				rnum = attacker.weapon;
				if (rnum == IT_AXE)
				{
					deathstring = " was ax-murdered by ";
					deathstring2 = "\n";
				}
				if (rnum == IT_SHOTGUN)
				{
					deathstring = " chewed on ";
					deathstring2 = "'s boomstick\n";
				}
				if (rnum == IT_SUPER_SHOTGUN)
				{
					deathstring = " ate 2 loads of ";
					deathstring2 = "'s buckshot\n";
				}
				if (rnum == IT_NAILGUN)
				{
					if (attacker.items2 & IT_NAILGUN) {
						deathstring = " was punctured by ";
						deathstring2 = "\n";
					} else {
						deathstring = " was nailed by ";
						deathstring2 = "\n";
					}
					
				}
				if (rnum == IT_RAILGUN)
				{
					deathstring = " was sniped by ";
					deathstring2 = "\n";
				}
				if (rnum == IT_GRENADE_LAUNCHER)
				{
					deathstring = " eats ";
					deathstring2 = "'s pineapple\n";
					if (targ.health < -40)
					{
						deathstring = " was gibbed by ";
						deathstring2 = "'s grenade\n";
					}
				}
				if (rnum == IT_ROCKET_LAUNCHER)
				{
					deathstring = " rides ";
					deathstring2 = "'s rocket\n";
					if (targ.health < -40)
					{
						deathstring = " was gibbed by ";
						deathstring2 = "'s rocket\n" ;
					}
				}
				if (rnum == IT_LIGHTNING)
				{
					deathstring = " accepts ";
					if (attacker.waterlevel > 1)
						deathstring2 = "'s discharge\n";
					else
						deathstring2 = "'s shaft\n";
				}
				bprint (targ.netname);
				bprint (deathstring);
				bprint (attacker.netname);
				bprint (deathstring2);
			}
			return;
		}
		else
		{
			targ.frags = targ.frags - 1;
			bprint (targ.netname);

			// killed by a montser?
			if (attacker.flags & FL_MONSTER)
			{
				if (attacker.classname == "monster_army")
					bprint (" was shot by a Grunt\n");
				if (attacker.classname == "monster_demon1")
					bprint (" was eviscerated by a Fiend\n");
				if (attacker.classname == "monster_dog")
					bprint (" was mauled by a Rottweiler\n");
				if (attacker.classname == "monster_enforcer")
					bprint (" was blasted by an Enforcer\n");
				if (attacker.classname == "monster_fish")
					bprint (" was fed to the Rotfish\n");
				if (attacker.classname == "monster_lostsoul")
					bprint (" was shaken by a Lost Soul\n");
				if (attacker.classname == "monster_hell_knight") 
					bprint (" was slain by a Death Knight\n");
				if (attacker.classname == "monster_knight")
					bprint (" was slashed by a Knight\n");
				if (attacker.classname == "monster_ogre")
					bprint (" was destroyed by an Ogre\n");
				if (attacker.classname == "monster_oldone")
					bprint (" became one with Shub-Niggurath\n");
				if (attacker.classname == "monster_shalrath")
					bprint (" was exploded by a Vore\n");
				if (attacker.classname == "monster_shambler")
					bprint (" was smashed by a Shambler\n");
				if (attacker.classname == "monster_tarbaby")
					bprint (" was slimed by a Spawn\n");
				if (attacker.classname == "monster_wizard")
					bprint (" was scragged by a Scrag\n");
				if (attacker.classname == "monster_zombie")
					bprint (" joins the Zombies\n");
				if (attacker.classname == "monster_pain_elemental")
					bprint (" was overwhelmed by a Pain Elemental\n");
				if (attacker.classname == "monster_agony_elemental")
					bprint (" was charred by a Pain Elemental\n");
				return;
			}

			// tricks and traps
			if (attacker.classname == "explo_box")
			{
				bprint (" blew up\n");
				return;
			}
			if (attacker.solid == SOLID_BSP && attacker != world)
			{	
				bprint (" was squished\n");
				return;
			}
			if (attacker.classname == "trap_shooter" || attacker.classname == "trap_spikeshooter")
			{
				bprint (" was spiked\n");
				return;
			}
			if (attacker.classname == "trap_grenade")
			{
				bprint (" was blown to smithereens\n");
				return;
			}
			if (attacker.classname == "trap_rocket")
			{
				bprint (" was blasted to pieces\n");
				return;
			}
			if (attacker.classname == "trap_flamethrower")
			{
				bprint (" was roasted alive\n");
				return;
			}
			if (attacker.classname == "trap_lightning")
			{
				bprint (" was given shock treatment\n");
				return;
			}
			if (attacker.classname == "fireball")
			{
				bprint (" ate a lavaball\n");
				return;
			}
			if (attacker.classname == "trigger_changelevel")
			{
				bprint (" tried to leave\n");
				return;
			}

			// in-water deaths
			rnum = targ.watertype;
			if (rnum == -3)
			{
				if (random() < 0.5)
					bprint (" sleeps with the fishes\n");
				else
					bprint (" sucks it down\n");
				return;
			}
			else if (rnum == -4)
			{
				if (random() < 0.5)
					bprint (" gulped a load of slime\n");
				else
					bprint (" can't exist on slime alone\n");
				return;
			}
			else if (rnum == -5)
			{
				if (targ.health < -15)
				{
					bprint (" burst into flames\n");
					return;
				}
				if (random() < 0.5)
					bprint (" turned into hot slag\n");
				else
					bprint (" visits the Volcano God\n");
				return;
			}

			// fell to their death?
			if (targ.deathtype == "falling")
			{
				targ.deathtype = "";
				bprint (" fell to their death\n");
				return;
			}
			
			if (attacker.classname == "trigger_hurt") {
				if (attacker.dmg == 9999) {
					bprint (" fell to their death\n");
					return;
				}
				if (attacker.dmg == 10000) {
					bprint (" exited reality\n");
					return;
				}
			}

			// hell if I know; he's just dead!!!
			bprint (" died\n");
		}
	}
};
