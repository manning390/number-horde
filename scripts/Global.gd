extends Node

onready var screen_size = get_viewport().size
var start_time = 5
var node_creation_parent = null
const NAMES = [
	"James",
	"Mary",
	"John",
	"Patricia",
	"Robert",
	"Jennifer",
	"Michael",
	"Linda",
	"William",
	"Elizabeth",
	"David",
	"Barbara",
	"Richard",
	"Susan",
	"Joseph",
	"Jessica",
	"Thomas",
	"Sarah",
	"Charles",
	"Karen",
	"Christopher",
	"Nancy",
	"Daniel",
	"Margaret",
	"Matthew",
	"Lisa",
	"Anthony",
	"Betty",
	"Donald",
	"Dorothy",
	"Mark",
	"Sandra",
	"Paul",
	"Ashley",
	"Steven",
	"Kimberly",
	"Andrew",
	"Donna",
	"Kenneth",
	"Emily",
	"Joshua",
	"Michelle",
	"George",
	"Carol",
	"Kevin",
	"Amanda",
	"Brian",
	"Melissa",
	"Edward",
	"Deborah",
	"Ronald",
	"Stephanie",
	"Timothy",
	"Rebecca",
	"Jason",
	"Laura",
	"Jeffrey",
	"Sharon",
	"Ryan",
	"Cynthia",
	"Jacob",
	"Kathleen",
	"Gary",
	"Helen",
	"Nicholas",
	"Amy",
	"Eric",
	"Shirley",
	"Stephen",
	"Angela",
	"Jonathan",
	"Anna",
	"Larry",
	"Brenda",
	"Justin",
	"Pamela",
	"Scott",
	"Nicole",
	"Brandon",
	"Ruth",
	"Frank",
	"Katherine",
	"Benjamin",
	"Samantha",
	"Gregory",
	"Christine",
	"Samuel",
	"Emma",
	"Raymond",
	"Catherine",
	"Patrick",
	"Debra",
	"Alexander",
	"Virginia",
	"Jack",
	"Rachel",
	"Dennis",
	"Carolyn",
	"Jerry",
	"Janet ",
]

const FLAVOR = [
	"I use to fear the numbers, but now I fear [i]the numbers[/i].",
	"Was it the rot or the math that turned their brains to mush?",
	"I dunno 'bout anyone else but I could really use a drink right now.",
	"Nice shot!",
	"I never did like math class.",
	"Is it getting hot in here or is it just the blood humidity?",
	"It all started with Mr.Hunnicutt PI...",
	"This is [i]not[/i] how my Zombie eroge ends.",
	"Mr.Hunnicutt would be so proud to see his children flourish in the wild.",
	"Arithmetic this!",
	"The mitocondria is the power house of the cell!",
	"X equals the opposite of B plus or minus the square root of B squared - 4 times A C all over 2 A~",
	"If linear algebra has taught me anything the answer is always 0, 1, -1, or 2.",
	"Don't crash now.",
	"I hear there are no zombies over at Khan Academy.",
	"Hey, don't take my kill. It's worth less on the final.",
	"I could use a nap.",
	"Not all math puns are aweful, just sum.",
	"Buffalo use to roam in large numbers.",
	"Graphing is where I draw the line.",
	"I wonder if the programmer put in a very specific if statement to avoid dividing by zero..",
	"If only we could foil Mr.Hunnicutt's plot.",
	"Math was the one subject I wasn't counting on during the apocalypse.",
	"Remember your geometry classes! It will keep you in top shape.",
	"I wonder what people will think of March 14th in a year from now.",
	"Honestly, I'd rather take the giant meteor.",
	"1 + 1 = 10 right? Or am I off base?",
	"Stay positive!",
	"Wait..",
	"I'm reaching my limits.",
	"That was gross.",
	"Mr.Hunnicutt you have doomed us all.",
	"I'm not saying I have a problem with X as a variable name, I'm just saying fluffy clouds is more child friendly.",
	"I don't think the zombies are mean, as long as they stay out of range.",
	"Not in my domain.",
	"I think that one just broke the Y axis rule.",
	"Copying my answers is going to net you less points.",
	"The end is nigh.",
	"While most puns make me feel numb. Math puns make me feel number.",
	"This is all pointless without geometry.",
	"How is any of this rational?",
	"If you were an angle, you'd be pretty acute.",
	"Shuttup David.",
	"1, 2, 3, 4, 5...",
	"2, 4, 8, 16, 32...",
	"Sines of maddness all around.",
	"Pet the corgi for good luck!",
	"We must protect the corgi.",
	"Don't let the corgi escape! It's too short for this.",
	"Have we reached a consensous on the corgi's name?",
	"Y'all are nerds.",
]

const SKIN_TONES = [
	Color("fae7d0"),
	Color("aa724b"),
	Color("dfc183"),
	Color("ffcc99"),
	Color("ceab68"),
	Color("935d37"),
	Color("835d37"),
	Color("feb186"),
	Color("b98865"),
	Color("7b4b2a"),
	Color("c8aca3"),
	Color("c0a183"),
	Color("c18e74"),
	Color("e8cda8"),
	Color("caa661"),
	Color("b58a3f"),
	Color("7b4b2a"),
	Color("573719"),
	Color("483728"),
]

var operators = {
	0: "+",
	1: "-",
	2: "x",
	3: "/",
}
const SKY_COLORS = [ 
	Color("FEB865"), # Yellow
	Color("FE7F64"), # Peach
	Color("FE7F64"), # Pink
	Color("714178"), # Plum
	Color("493465"), # Eggplant
	Color("1A1526"), # Purple
]

func instance_node(node, location, parent):
	var node_instance = node.instance()
	parent.add_child(node_instance)
	node_instance.global_position = location
	return node_instance

func rand_skin():
	randomize()
	return SKIN_TONES[randi() % SKIN_TONES.size()]

func rand_color():
	randomize()
	return Color.from_hsv(randf(), 1, 1)

func rand_name():
	randomize()
	return NAMES[randi() % NAMES.size()]

func get_player_spawn_pos():
	randomize()
	return Vector2(rand_range(20, 250), rand_range((screen_size.y / 2) - 20, screen_size.y - 20))

func get_zombie_spawn_pos():
	randomize()
	return Vector2(screen_size.x + rand_range(20, screen_size.x / 2), rand_range((screen_size.y / 2) - 20, screen_size.y - 20))



