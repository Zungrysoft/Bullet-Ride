//Code written by ZungryWare

#define NORTH 0
#define EAST 1
#define SOUTH 2
#define WEST 3

//Stores the spaces of the maze
//Each space is given the same index as the walls immediately south and east of it
float maze_spaces[256];
//Stores the vertical walls of the maze
float maze_walls_vert[256];
//stores the horizontal walls of the maze
float maze_walls_horiz[256];

//The number of spaces wide the maze is
.float maze_width;
//The number of spaces tall the maze is
.float maze_height;
//The size of the maze. This value is set automatically
float maze_size;
//What space is currently being edited
.float current_space;
//Where the exit is. Used with the initial maze.
.float exit_space;

//Changes the states of the walls in the map to form the maze
void(float level) update_maze;
//A wrapper for update_maze that passes in a value of zero.
void() update_maze_0;
//Generates the maze the map starts with
void() generate_maze;
//Generates one level of the maze.
void(float level, float num_spaces, float use_weight) generate_level;
//Sets all of the maze's spaces and walls back to -1
void() reset_maze;
//Used for various targeting functions. target_mod is used to specify what to do
//-1: Randomizes the maze
//0: Drops all maze walls
//n: Drops maze walls of a specific value
void() maze_use;
//Gets the space in the specified direction
//-1 means no valid space
float(float space, float dir) get_space_to;
//Picks a random valid empty space adjacent to the selected space
//weight_space is a space the randomizer should be more likely to go towards
//weight_amt is how likely to pick that space over a randomly generated space 0-1
//A return value of -1 means no spaces were valid
float(float space, float weight_space, float weight_amt) pick_direction;
//Gets the horizontal position of the space on the grid
float(float space) get_space_x;
//Gets the vertical position of the space on the grid
float(float space) get_space_y;
//Returns a new space to build off of
void() hunt_space;
//Builds a new space off of the current space in the specified direction
//Level is the level to give the space
void(float dir, float level) build_space;
//Gives values to the remaining walls
//chance is the chance of giving a wall a number other than the maximum
void(float chance, float max_level) set_leftover_walls;


void() misc_maze = {
	if (!self.maze_width) {
		self.maze_width = 9;
	}
	if (!self.maze_height) {
		self.maze_height = 9;
	}
	
	maze_size = self.maze_width * self.maze_height;
	
	
	if (!self.exit_space) {
		self.exit_space = (maze_size) - 1;
	}
	if (maze_size > 255) {
		objerror("Maze above maximum size");
	}
	
	self.use = maze_use;
	
	reset_maze();
	
	if (self.spawnflags & 1) {
		reset_maze();
		generate_level(0, maze_size, 0);
		set_leftover_walls(.1, 1);
	} else {
		//generate_maze();
	}
	
	self.think = update_maze_0;
	self.nextthink = 3;
}

float(float space) get_space_x = {
	return mod(self.maze_width, space);
}

float(float space) get_space_y = {
	return floor((space / (self.maze_height * self.maze_width)) * self.maze_height);
}

void() reset_maze = {
	for (float i = 0; i < maze_size; i ++) {
		maze_spaces[i] = -1;
		maze_walls_vert[i] = -1;
		maze_walls_horiz[i] = -1;
	}
}

float(float space, float weight_space, float weight_amt) pick_direction = {
	float test_space;
	
	//If the weighted space is picked, pick the direction towards it
	if (random() < weight_amt) {
		//Figure out which direction would be best to go toward the weighted space
		//Goes through all four directions and determines which one to move in
		float greatest_direction = NORTH;
		float greatest_value = 0;
		float diff;
		
		//If the weight space has greater x value, it is to the EAST
		diff = get_space_x(weight_space) - get_space_x(space);
		if (diff > greatest_value) {
			greatest_value = diff;
			greatest_direction = EAST;
		}
		
		//If the weight space has lesser x value, it is to the WEST
		diff = get_space_x(space) - get_space_x(weight_space);
		if (diff > greatest_value) {
			greatest_value = diff;
			greatest_direction = WEST;
		}
		
		//If the weight space has greater y value, it is to the SOUTH
		diff = get_space_y(weight_space) - get_space_y(space);
		if (diff > greatest_value) {
			greatest_value = diff;
			greatest_direction = SOUTH;
		}
		
		//If the weight space has lesser y value, it is to the NORTH
		diff = get_space_y(space) - get_space_y(weight_space);
		if (diff > greatest_value) {
			greatest_direction = NORTH;
		}
		
		//Make sure the tested space is a valid space
		test_space = get_space_to(space, greatest_direction);
		if (test_space != -1) {
			if (maze_spaces[test_space] == -1) {
				return greatest_direction;
			}
		}
		//If it isn't valid, just pick a random space
	}
	
	//If not using the weighted direction, pick a space at complete random
	//Offset is used to randomly pick which direction to check first
	float start = floor(random() * 4);
	for (float i = 0; i < 4; i ++) {
		//Make sure the tested space is a valid space
		test_space = get_space_to(space,mod(i+start,4));
		if (test_space != -1) {
			if (maze_spaces[test_space] == -1) {
				return mod(i+start,4);
			}
			
		}
	}
	return -1;
}

void() hunt_space = {
	//Offset is used to randomly pick which space to start looking at
	float offset = floor(random() * maze_size);
	for (float i = 0; i < maze_size; i ++) {
		float check = mod(i+offset, maze_size);
		if (maze_spaces[check] != -1) {
			if (pick_direction(check,0,0) != -1) {
				self.current_space = check;
				return;
			}
		}
	}
	self.current_space = -1;
	return;
}

void(float dir, float level) build_space = {
	//The new space to build on
	float other_space = get_space_to(self.current_space, dir);
	
	//If either space is invalid, then don't do anything
	if (self.current_space < 0 || self.current_space >= maze_size) {
		return;
	}
	if (other_space < 0 || other_space >= maze_size) {
		return;
	}
	
	//Set the value of the newly carved space
	maze_spaces[other_space] = level;
	
	//Determine what value the wall between the two spaces should have
	//If the spaces have the same value, there should be no wall between the two
	//If the spaces have different values, the wall should be the value of the greater one
	float wall_value;
	if (maze_spaces[self.current_space] == maze_spaces[other_space]) {
		wall_value = 0;
	} else {
		wall_value = maze_spaces[self.current_space] > maze_spaces[other_space] ? maze_spaces[self.current_space] : maze_spaces[other_space];
	}
	
	//Set the value of the wall
	//Build on the space of lesser value
	float build_on = self.current_space < other_space ? self.current_space : other_space;
	if (dir == NORTH || dir == SOUTH) {
		maze_walls_horiz[build_on] = wall_value;
	} else {
		maze_walls_vert[build_on] = wall_value;
	}
	
	//The next space becomes the new current one.
	self.current_space = other_space;
}

void(float level, float num_spaces, float use_weight) generate_level = {
	if (self.current_space < 0 || self.current_space >= maze_size) {
		self.current_space = 0;
	}
	
	if (maze_spaces[self.current_space] == -1) {
		maze_spaces[self.current_space] = level;
	}
	
	float gen = 0;
	//If, after hunting for a space, there still aren't any valid spaces, that means the maze is full.
	//Loop until the target number of spaces have generated.
	//Or until the maze is full.
	while (gen < num_spaces && self.current_space != -1) {
		//Determine the weight. The longer it's been generating, the larger the weight should be.
		//Only use weight if enabled
		float weight;
		if (maze_spaces[self.exit_space] == 0 && use_weight) {
			weight = gen / (num_spaces * .8);
		} else {
			weight = 0;
		}
		
		//Find a space
		float dir = pick_direction(self.current_space, self.exit_space, weight);
		
		bprint("Going from Space ");
		bprint(ftos(self.current_space));
		bprint(" to space ");
		bprint(ftos(get_space_to(self.current_space,dir)));
		bprint(" at level ");
		bprint(ftos(level));
		bprint("\n");
		
		//If there are no valid adjacent spaces, hunt for a new random space to build off of
		//In order to prevent passages from being too windy and linear, it sometimes do this at random
		if (dir == -1 || random() < .1) {
			hunt_space();
			//If a call to this function results in current_space being -1, then the maze is full
			//So the while loop will end
		} else {
			//Build the space on the maze
			build_space(dir, level);
			gen ++;
		}
	}
}

void(float ratio, float max_level) set_leftover_walls = {
	float val1;
	float val2;
	float val_greater;
	
	for (float i = 0; i < maze_size; i ++) {
		//Go through the vertical walls first
		//The vertical walls closest to the EAST side of the maze don't exist, so skip them
		if (mod(i, self.maze_width) != self.maze_width - 1) {
			if (maze_walls_vert[i] == -1 && random() < ratio) {
				val1 = maze_spaces[i];
				val2 = maze_spaces[i+1];
				val_greater = val1 > val2 ? val1 : val2;
				maze_walls_vert[i] = floor(random_range(val_greater, max_level));
			}
		}
		//Then go through the horizontal walls
		//The horizontal walls closest to the SOUTH side of the maze don't exist, so skip them
		if (i < maze_size - self.maze_width) {
			if (maze_walls_horiz[i] == -1 && random() < ratio) {
				
				val1 = maze_spaces[i];
				val2 = maze_spaces[i+self.maze_width];
				val_greater = val1 > val2 ? val1 : val2;
				maze_walls_horiz[i] = floor(random_range(val_greater, max_level));
			}
		}
	}
}

void() generate_maze = {
	//Generate level 0
	//Continue generating until the exit space has a level of 0
	//If the exit space has a level of 0, that means it has been generated, which means there is a continuous path between the entrance and exit
	float ctemp = self.current_space;
	
	while (maze_spaces[self.exit_space] != 0) {
		bprint("GENERATING LEVEL 0\n");
		reset_maze();
		bprint(ftos(maze_spaces[10]));
		self.current_space = ctemp;
		generate_level(0, random_range(maze_size/2, maze_size/3), 1);
	}
	
	generate_level(1, maze_size/8, 0);
	generate_level(2, maze_size/8, 0);
	generate_level(3, maze_size/8, 0);
	generate_level(4, maze_size/8, 0);
	generate_level(5, maze_size, 0);
	
	set_leftover_walls(.07, 5);
}

void() maze_use = {
	if (other.target_mod == 0) {
		//0 drops all walls
		self.target_mod = 1;
		for (float i = 0; i < maze_size; i ++) {
			self.target = ftos(2000 + i);
			SUB_UseTargets();
			self.target = ftos(3000 + i);
			SUB_UseTargets();
		}
		self.target_mod = 0;
		self.target = __NULL__;
	} else if (other.target_mod < 0) {
		//-1 randomizes the maze
		reset_maze();
		generate_level(0, maze_size, 0);
		set_leftover_walls(.1,1);
		update_maze(0);
	} else {
		//Default: update the maze to the selected level
		update_maze(other.target_mod);
	}
}

void() update_maze_0 = {
	generate_maze();
	update_maze(0);
}

void(float level) update_maze = {
	for (float i = 0; i < maze_size; i ++) {
		//If the space is low level (and not -1), then drop it.
		//Otherwise, raise it.
		if (level < maze_walls_horiz[i] || maze_walls_horiz[i] == -1) {
			self.target_mod = 0;
		} else {
			self.target_mod = 1;
		}
		
		self.target = ftos(2000 + i);
		SUB_UseTargets();
		
		//Repeat the process for the vertical walls
		if (level < maze_walls_vert[i] || maze_walls_vert[i] == -1) {
			self.target_mod = 0;
		} else {
			self.target_mod = 1;
		}
		
		self.target = ftos(3000 + i);
		SUB_UseTargets();
	}
	
	
	self.target_mod = 0;
	self.target = __NULL__;
}

float(float space, float dir) get_space_to = {
	float ret;
	if (dir == NORTH) {
		ret = space - self.maze_width;
	} else if (dir == SOUTH) {
		ret = space + self.maze_width;
	} else if (dir == EAST) {
		if (mod(space, self.maze_width) == self.maze_width - 1) {
			//Space is outside the maze
			return -1;
		}
		ret = space + 1;
	} else if (dir == WEST) {
		if (mod(space, self.maze_width) == 0) {
			//Space is outside the maze
			return -1;
		}
		ret = space - 1;
	} else {
		//Invalid direction
		return -1;
	}
	
	if (ret < 0 || ret >= maze_size) {
		//Space is outside the maze
		return -1;
	}
	
	//It is a valid space, so return it.
	return ret;
}










