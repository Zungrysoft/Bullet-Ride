void() crucifix_think = {
	local entity found[15];
	local float counter = 0;
	local entity t;
	
	while (counter < 50) {
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
				t.alpha = .5;
			}
		}
		
	}
}

void() trap_crucifix = {
	if (self.targetname) {
		self.use = crucifix_think;
	} else {
		self.think = crucifix_think;
		self.nextthink = time + 5;
	}
}