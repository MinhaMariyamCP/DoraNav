import json
import math
import heapq

# -------------------------------------------------------------
# 1. DEFINE LOCATIONS (EXACTLY 70)
# -------------------------------------------------------------

# 25 Selectable Destinations (names must match exactly)
destinations_25 = [
    ("Dora’s House", 35, 110, "start", "The cozy home of Dora, Mami, and Papi where every adventure begins!"),
    ("Benny’s Barn", 65, 92, "destination", "Benny the Bull's warm red barn filled with balloons and hay."),
    ("Blueberry Hill", 85, 155, "destination", "A rolling blue hill covered in sweet, giant blueberries."),
    ("Snowy Mountain", 138, 185, "destination", "A majestic snow-peaked mountain with slopes and hot cocoa stops."),
    ("Beach", 28, 22, "destination", "Golden sands with turquoise waves and shell collecting."),
    ("Chocolate Tree", 88, 125, "destination", "A magical tree that grows delicious chocolate treats."),
    ("Big Yellow Station", 95, 90, "destination", "The bustling train station where Azul the Train stops."),
    ("Flowery Garden", 78, 80, "destination", "A fragrant wonderland filled with singing flowers and butterflies."),
    ("Animal Rescue Center", 72, 135, "destination", "Diego's sanctuary where rainforest animals are helped and protected."),
    ("School", 108, 98, "destination", "Dora and Boots' friendly village schoolhouse."),
    ("Music Box", 112, 115, "destination", "A giant musical box with winding keys and cheerful melodies."),
    ("King’s Castle", 162, 130, "destination", "The grand royal castle of the kingdom with soaring towers."),
    ("Wizard’s Castle", 132, 168, "destination", "A mystical floating spire where friendly wizards brew potions."),
    ("Dragon’s Cave", 175, 172, "destination", "The cozy gem-lit lair of the friendly baby dragon."),
    ("Volcano", 145, 32, "destination", "The mighty bubbling volcano surrounded by warm lava rocks."),
    ("Treasure Island", 12, 10, "destination", "A legendary tropical island where hidden pirate treasure rests."),
    ("Mermaid Kingdom", 178, 55, "destination", "An underwater shimmering realm of coral arches and mermaid friends."),
    ("Cloud Castle", 115, 185, "destination", "A castle perched high upon fluffy rainbow clouds in the sky."),
    ("Amusement Park", 110, 80, "destination", "A thrilling funfair with ferris wheels, rollercoasters, and cotton candy."),
    ("Waterfall", 92, 142, "destination", "A cascading jungle waterfall with a sparkling splash pool."),
    ("North Pole", 152, 195, "destination", "The snowy arctic haven of Santa, polar bears, and pine trees."),
    ("Crystal Kingdom", 188, 150, "destination", "A dazzling kingdom carved entirely of rainbow crystal spires."),
    ("Pirate Island", 18, 38, "destination", "The adventurous hideout of the Pirate Piggies with wooden docks."),
    ("Butterfly Festival", 70, 70, "destination", "The grand meadow celebration where thousand wings flutter together."),
    ("Lost City", 165, 40, "destination", "An ancient golden pyramid city full of lost treasures and mysteries.")
]

# 31 Intermediate Nodes required by the default paths
# (Note: Beach, Snowy Mountain, and Big Yellow Station are in destinations_25)
intermediates_31 = [
    ("Jungle Entrance", 48, 112, "junction", "The vibrant archway entrance leading into the lush rainforest."),
    ("Jungle Camp", 56, 102, "intermediate", "A cozy clearing with camping gear, hammocks, and lanterns."),
    ("Flower Field", 68, 82, "intermediate", "A bright clearing carpeted with yellow and violet wildflowers."),
    ("Nutty Forest", 62, 128, "intermediate", "A dense canopy where friendly squirrels gather golden acorns."),
    ("Big Hill", 82, 148, "junction", "A famous panoramic lookout atop a gentle grassy mountain."),
    ("Adventure Forest", 60, 118, "intermediate", "An enchanted forest path filled with singing birds and hidden trails."),
    ("Big Mountain", 112, 162, "intermediate", "The towering granite ridge overlooking the entire valley."),
    ("Highest Hill", 124, 174, "intermediate", "The steep upper slope before the snowy alpine peaks."),
    ("Tallest Mountain", 132, 180, "intermediate", "The sheer rocky summit piercing through chilly mountain clouds."),
    ("Small Stream", 42, 85, "intermediate", "A cheerful bubbling stream where playful frogs leap across pebbles."),
    ("Giant River", 40, 60, "junction", "The great wide river flowing through the heart of Dora's world."),
    ("Rainbow Bridge", 34, 45, "landmark", "An arched rainbow stone bridge spanning across the river."),
    ("Desert Oasis", 52, 38, "junction", "A lush palm tree sanctuary surrounded by shimmering desert sands."),
    ("Big Tree", 84, 110, "junction", "The ancient mammoth oak tree with climbing vines and leafy hollows."),
    ("Forest Garden", 74, 98, "intermediate", "A manicured grove of fruit bushes, vines, and stone benches."),
    ("Butterfly Garden", 76, 86, "intermediate", "A sunny sanctuary where colorful butterflies dance in spirals."),
    ("Treehouse", 68, 138, "landmark", "Boots' secret wooden treehouse with rope ladders and lookouts."),
    ("High Tower", 102, 120, "landmark", "A stone watchtower with a telescope facing the four horizons."),
    ("Troll Bridge", 120, 105, "landmark", "The wooden plank bridge where the Grumpy Old Troll asks riddles."),
    ("Castle Bridge", 140, 118, "landmark", "A grand arched drawbridge with royal banners over the moat."),
    ("Castle Gate", 152, 124, "junction", "The imposing oak and iron gates guarding the Royal Castle courtyard."),
    ("Moonbeam Mountain", 98, 165, "intermediate", "A mystical mountain that sparkles softly under moonlight."),
    ("Cloud Path", 118, 175, "intermediate", "A whimsical staircase of solid cumulus clouds floating in the sky."),
    ("Dragon Mountain", 150, 160, "intermediate", "A craggy red rock crest with warm thermal vents."),
    ("Dragon’s Forest", 164, 166, "intermediate", "A glowing forest of ember trees leading to the dragon's cave."),
    ("Cactus Valley", 78, 32, "intermediate", "A sun-baked canyon framed by giant saguaro cacti."),
    ("Volcano Path", 115, 30, "intermediate", "A winding pumice path lined with warm volcanic cobblestones."),
    ("Pirate Harbor", 22, 26, "landmark", "The weathered wooden docks where pirate ships drop anchor."),
    ("Sparkling Lake", 120, 52, "intermediate", "A crystal-clear lake that glitters like diamonds in the sun."),
    ("Crystal Lake", 155, 60, "landmark", "A serene lake surrounded by naturally glowing quartz crystals."),
    ("Crystal Cave", 168, 158, "landmark", "A subterranean cavern shimmering with iridescent stalactites."),
    ("Sandy Dunes", 110, 36, "intermediate", "Rolling golden dunes that shift gently with the desert breeze."),
    ("Ancient Temple", 135, 42, "landmark", "Weathered Mesoamerican pyramid steps covered in jungle creepers."),
    ("Hidden Tunnel", 152, 38, "intermediate", "A secret underground passageway carved with ancient petroglyphs.")
]

# 11 Additional Authentic Landmark Locations (matching the world map poster)
# 25 destinations + 34 intermediates + 11 landmarks = exactly 70 locations!
landmarks_11 = [
    ("Boots' Trees", 42, 125, "landmark", "Boots the monkey's favorite palm trees with climbing vines."),
    ("Picnic Place", 30, 95, "landmark", "A sunny hill with checkered picnic blankets and wooden tables."),
    ("Rock Path", 102, 150, "intermediate", "A winding stone walkway leading up toward the snowy alpine heights."),
    ("Ice Cave", 148, 180, "landmark", "A glistening subterranean chamber of frozen icicles and blue ice."),
    ("Magic Pond", 126, 110, "landmark", "A mystical round pond whose waters ripple with rainbow rings."),
    ("Farm", 20, 80, "landmark", "A cheerful family farm with red tractors, friendly sheep, and haystacks."),
    ("Windmill", 32, 75, "landmark", "A tall classic windmill whose giant sails turn in the sea breeze."),
    ("Pirate Ship", 12, 30, "landmark", "The Pirate Piggies' galleon anchored off the sandy coast."),
    ("Golden Sands", 65, 18, "landmark", "A sun-drenched beach with warm golden pebbles and seashell treasures."),
    ("Hidden Cave", 98, 25, "landmark", "A mysterious carved sandstone cavern hidden behind desert palms."),
    ("Fairy Forest", 142, 92, "landmark", "An enchanted twilight woodland illuminated by dancing fairy lights.")
]

all_location_tuples = destinations_25 + intermediates_31 + landmarks_11
assert len(all_location_tuples) == 70, f"Expected 70 locations, got {len(all_location_tuples)}"

locations = []
name_to_id = {}
name_to_loc = {}

for idx, (name, x, y, loc_type, desc) in enumerate(all_location_tuples, start=1):
    loc_id = f"L{idx:03d}"
    is_dest = idx <= 25
    is_start = (name == "Dora’s House")
    
    loc_obj = {
        "id": loc_id,
        "name": name,
        "x": x,
        "y": y,
        "selectable": is_dest,
        "start": is_start,
        "active": True,
        "type": loc_type,
        "metadata": {
            "description": desc,
            "region": "Jungle" if y >= 70 and x <= 80 else (
                "Mountains" if y >= 140 else (
                    "Coast" if x <= 35 and y <= 60 else (
                        "Desert" if x >= 70 and y <= 60 else "Valley"
                    )
                )
            )
        }
    }
    locations.append(loc_obj)
    name_to_id[name] = loc_id
    name_to_loc[name] = loc_obj

print(f"Total Locations Created: {len(locations)}")
print(f"Selectable Destinations: {sum(1 for l in locations if l['selectable'])}")
print(f"Start Location: {[l['name'] for l in locations if l['start']]}")

# -------------------------------------------------------------
# 2. DEFINE THE 25 DEFAULT PATHS AS SEQUENCES OF NAMES
# -------------------------------------------------------------
raw_paths = {
    "Dora’s House": ["Dora’s House"],
    "Benny’s Barn": ["Dora’s House", "Jungle Entrance", "Jungle Camp", "Flower Field", "Benny’s Barn"],
    "Blueberry Hill": ["Dora’s House", "Jungle Entrance", "Nutty Forest", "Big Hill", "Blueberry Hill"],
    "Snowy Mountain": ["Dora’s House", "Jungle Entrance", "Adventure Forest", "Big Hill", "Big Mountain", "Highest Hill", "Tallest Mountain", "Snowy Mountain"],
    "Beach": ["Dora’s House", "Jungle Entrance", "Small Stream", "Giant River", "Rainbow Bridge", "Desert Oasis", "Beach"],
    "Chocolate Tree": ["Dora’s House", "Jungle Entrance", "Nutty Forest", "Big Tree", "Chocolate Tree"],
    "Big Yellow Station": ["Dora’s House", "Jungle Entrance", "Jungle Camp", "Flower Field", "Big Tree", "Big Yellow Station"],
    "Flowery Garden": ["Dora’s House", "Jungle Entrance", "Adventure Forest", "Forest Garden", "Butterfly Garden", "Flowery Garden"],
    "Animal Rescue Center": ["Dora’s House", "Jungle Entrance", "Jungle Camp", "Nutty Forest", "Treehouse", "Animal Rescue Center"],
    "School": ["Dora’s House", "Jungle Entrance", "Flower Field", "Big Tree", "Big Yellow Station", "School"],
    "Music Box": ["Dora’s House", "Jungle Entrance", "Adventure Forest", "Forest Garden", "High Tower", "Music Box"],
    "King’s Castle": ["Dora’s House", "Jungle Entrance", "Adventure Forest", "Forest Garden", "Troll Bridge", "Castle Bridge", "Castle Gate", "King’s Castle"],
    "Wizard’s Castle": ["Dora’s House", "Jungle Entrance", "Nutty Forest", "Big Hill", "Moonbeam Mountain", "High Tower", "Cloud Path", "Wizard’s Castle"],
    "Dragon’s Cave": ["Dora’s House", "Jungle Entrance", "Adventure Forest", "Big Mountain", "Dragon Mountain", "Dragon’s Forest", "Dragon’s Cave"],
    "Volcano": ["Dora’s House", "Jungle Entrance", "Small Stream", "Giant River", "Desert Oasis", "Cactus Valley", "Volcano Path", "Volcano"],
    "Treasure Island": ["Dora’s House", "Jungle Entrance", "Small Stream", "Giant River", "Rainbow Bridge", "Beach", "Pirate Harbor", "Treasure Island"],
    "Mermaid Kingdom": ["Dora’s House", "Jungle Entrance", "Small Stream", "Giant River", "Sparkling Lake", "Crystal Lake", "Mermaid Kingdom"],
    "Cloud Castle": ["Dora’s House", "Jungle Entrance", "Nutty Forest", "Big Hill", "Moonbeam Mountain", "Cloud Path", "Cloud Castle"],
    "Amusement Park": ["Dora’s House", "Jungle Entrance", "Jungle Camp", "Big Tree", "Big Yellow Station", "Amusement Park"],
    "Waterfall": ["Dora’s House", "Jungle Entrance", "Adventure Forest", "Forest Garden", "Small Stream", "Giant River", "Waterfall"],
    "North Pole": ["Dora’s House", "Jungle Entrance", "Big Hill", "Big Mountain", "Highest Hill", "Tallest Mountain", "Snowy Mountain", "North Pole"],
    "Crystal Kingdom": ["Dora’s House", "Jungle Entrance", "Adventure Forest", "Big Mountain", "Dragon Mountain", "Crystal Cave", "Crystal Kingdom"],
    "Pirate Island": ["Dora’s House", "Jungle Entrance", "Small Stream", "Giant River", "Beach", "Pirate Harbor", "Pirate Island"],
    "Butterfly Festival": ["Dora’s House", "Jungle Entrance", "Adventure Forest", "Forest Garden", "Butterfly Garden", "Flower Field", "Butterfly Festival"],
    "Lost City": ["Dora’s House", "Jungle Entrance", "Nutty Forest", "Big Hill", "Desert Oasis", "Sandy Dunes", "Ancient Temple", "Hidden Tunnel", "Lost City"]
}

# -------------------------------------------------------------
# 3. BUILD ROADS (EDGES)
# -------------------------------------------------------------
# Every consecutive pair in each default path MUST have a road.
# Plus redundant and landmark roads to make the graph rich and reroutable by Swiper.

edge_dict = {}

def add_edge(u_name, v_name, meta=None):
    if u_name not in name_to_id or v_name not in name_to_id:
        raise ValueError(f"Unknown node: {u_name} or {v_name}")
    u_id = name_to_id[u_name]
    v_id = name_to_id[v_name]
    pair = tuple(sorted([u_id, v_id]))
    if pair not in edge_dict:
        edge_dict[pair] = meta or {}
    else:
        edge_dict[pair].update(meta or {})

# 3a. Add edges from default paths
for dest_name, path in raw_paths.items():
    for i in range(len(path) - 1):
        add_edge(path[i], path[i+1], {"role": "default_route"})

# 3b. Add extra interconnecting roads for network robustness, landmarks, and alternative routes
extra_links = [
    # Dora's House surroundings & west coast
    ("Dora’s House", "Boots' Trees", {"scenic": True}),
    ("Dora’s House", "Picnic Place", {"scenic": True}),
    ("Boots' Trees", "Whispering Woods", {}),
    ("Picnic Place", "Farm", {}),
    ("Farm", "Windmill", {}),
    ("Windmill", "Small Stream", {}),
    ("Windmill", "Desert Oasis", {}),
    ("Beach", "Pirate Ship", {"coastal": True}),
    ("Pirate Ship", "Pirate Harbor", {"coastal": True}),
    ("Beach", "Golden Sands", {"coastal": True}),
    ("Golden Sands", "Cactus Valley", {}),
    
    # Jungle & Forest cross-connections
    ("Jungle Entrance", "Boots' Trees", {}),
    ("Jungle Entrance", "Picnic Place", {}),
    ("Jungle Camp", "Benny’s Barn", {}),
    ("Boots' Trees", "Nutty Forest", {}),
    ("Picnic Place", "Big Hill", {}),
    ("Forest Garden", "Flowery Garden", {}),
    ("Flower Field", "Butterfly Garden", {}),
    ("Butterfly Garden", "Flowery Garden", {}),
    ("Butterfly Festival", "Flower Field", {}),
    
    # Mountain region bypasses & landmarks
    ("Big Hill", "Rock Path", {}),
    ("Rock Path", "Waterfall", {}),
    ("Rock Path", "Big Mountain", {}),
    ("Waterfall", "Treehouse", {}),
    ("Waterfall", "Magic Pond", {}),
    ("Big Mountain", "Ice Cave", {}),
    ("Ice Cave", "Snowy Mountain", {}),
    ("Ice Cave", "North Pole", {}),
    ("Snowy Mountain", "Cloud Castle", {}),
    ("Tallest Mountain", "North Pole", {}),
    
    # Valley, East, & Castle links
    ("Magic Pond", "High Tower", {}),
    ("Magic Pond", "Fairy Forest", {}),
    ("Fairy Forest", "King’s Castle", {}),
    ("Fairy Forest", "Castle Bridge", {}),
    ("Troll Bridge", "High Tower", {}),
    ("School", "Amusement Park", {}),
    ("School", "Music Box", {}),
    ("Amusement Park", "Fairy Forest", {}),
    ("Castle Gate", "Crystal Kingdom", {}),
    ("Dragon Mountain", "Crystal Cave", {}),
    ("Dragon’s Cave", "Crystal Cave", {}),
    
    # Desert, Lake, & South links
    ("Desert Oasis", "Hidden Cave", {}),
    ("Hidden Cave", "Cactus Valley", {}),
    ("Hidden Cave", "Sandy Dunes", {}),
    ("Sandy Dunes", "Volcano Path", {}),
    ("Volcano", "Volcano Path", {}),
    ("Volcano", "Ancient Temple", {}),
    ("Ancient Temple", "Lost City", {}),
    ("Sparkling Lake", "Magic Pond", {}),
    ("Sparkling Lake", "Oasis Pool" if "Oasis Pool" in name_to_id else "Desert Oasis", {}),
    ("Crystal Lake", "Fairy Forest", {}),
    ("Crystal Lake", "Mermaid Kingdom", {}),
    ("Treasure Island", "Pirate Island", {"sea_route": True})
]

for u, v, meta in extra_links:
    if u in name_to_id and v in name_to_id:
        add_edge(u, v, meta)

# Construct roads objects
roads = []
road_id_counter = 1
road_graph = {loc["id"]: [] for loc in locations}

# To ensure road lengths strictly equal Euclidean distance:
for (u_id, v_id), meta in sorted(edge_dict.items(), key=lambda x: (x[0][0], x[0][1])):
    u_loc = next(l for l in locations if l["id"] == u_id)
    v_loc = next(l for l in locations if l["id"] == v_id)
    
    dx = u_loc["x"] - v_loc["x"]
    dy = u_loc["y"] - v_loc["y"]
    dist = round(math.hypot(dx, dy), 2)
    
    road_obj = {
        "id": f"R{road_id_counter:03d}",
        "from": u_id,
        "to": v_id,
        "bidirectional": True,
        "length": dist,
        "blocked": False,
        "metadata": {
            "from_name": u_loc["name"],
            "to_name": v_loc["name"],
            **meta
        }
    }
    roads.append(road_obj)
    road_graph[u_id].append((v_id, dist, road_obj["id"]))
    road_graph[v_id].append((u_id, dist, road_obj["id"]))
    road_id_counter += 1

print(f"Total Roads Created: {len(roads)}")

# -------------------------------------------------------------
# 4. BUILD DEFAULT PATHS OBJECT
# -------------------------------------------------------------
default_paths_output = {}

for dest_name, p_names in raw_paths.items():
    step_list = []
    for n in p_names:
        step_list.append({
            "id": name_to_id[n],
            "name": n
        })
    default_paths_output[dest_name] = step_list

# -------------------------------------------------------------
# 5. VALIDATION: A* PATHFINDER & GRAPH CONNECTIVITY
# -------------------------------------------------------------
def heuristic(a_id, b_id):
    loc_a = next(l for l in locations if l["id"] == a_id)
    loc_b = next(l for l in locations if l["id"] == b_id)
    return math.hypot(loc_a["x"] - loc_b["x"], loc_a["y"] - loc_b["y"])

def a_star(start_id, goal_id, blocked_roads=set(), blocked_nodes=set()):
    if start_id in blocked_nodes or goal_id in blocked_nodes:
        return None
    
    open_set = []
    heapq.heappush(open_set, (0.0, start_id))
    came_from = {}
    g_score = {l["id"]: float("inf") for l in locations}
    g_score[start_id] = 0.0
    f_score = {l["id"]: float("inf") for l in locations}
    f_score[start_id] = heuristic(start_id, goal_id)
    
    while open_set:
        current_f, current = heapq.heappop(open_set)
        if current == goal_id:
            path = [current]
            while current in came_from:
                current = came_from[current]
                path.append(current)
            return path[::-1]
        
        for neighbor, weight, r_id in road_graph[current]:
            if r_id in blocked_roads or neighbor in blocked_nodes:
                continue
            tentative_g = g_score[current] + weight
            if tentative_g < g_score[neighbor]:
                came_from[neighbor] = current
                g_score[neighbor] = tentative_g
                f_score[neighbor] = tentative_g + heuristic(neighbor, goal_id)
                heapq.heappush(open_set, (f_score[neighbor], neighbor))
    return None

start_id = name_to_id["Dora’s House"]

# Verify all 70 locations are reachable from Dora's House via A*
unreachable = []
for loc in locations:
    res = a_star(start_id, loc["id"])
    if res is None:
        unreachable.append(loc["name"])

assert len(unreachable) == 0, f"Unreachable locations: {unreachable}"
print("A* verification passed: All 70 locations are reachable from Dora's House!")

# Verify default paths are valid consecutive edges in the graph
for dest_name, steps in default_paths_output.items():
    for i in range(len(steps) - 1):
        u = steps[i]["id"]
        v = steps[i+1]["id"]
        neighbors = [nbr for nbr, _, _ in road_graph[u]]
        assert v in neighbors, f"Missing edge between {steps[i]['name']} and {steps[i+1]['name']} for route {dest_name}"

print("All 25 default path sequences validated: 100% consecutive road edges exist!")

# Save to scratch & assets
with open("scratch/locations.json", "w", encoding="utf-8") as f:
    json.dump(locations, f, indent=2, ensure_ascii=False)

with open("scratch/roads.json", "w", encoding="utf-8") as f:
    json.dump(roads, f, indent=2, ensure_ascii=False)

with open("scratch/default_paths.json", "w", encoding="utf-8") as f:
    json.dump(default_paths_output, f, indent=2, ensure_ascii=False)

# Also save into assets/data/ for DoraNav app usage
import os
os.makedirs("assets/data", exist_ok=True)
with open("assets/data/locations.json", "w", encoding="utf-8") as f:
    json.dump(locations, f, indent=2, ensure_ascii=False)
with open("assets/data/roads.json", "w", encoding="utf-8") as f:
    json.dump(roads, f, indent=2, ensure_ascii=False)
with open("assets/data/default_paths.json", "w", encoding="utf-8") as f:
    json.dump(default_paths_output, f, indent=2, ensure_ascii=False)

print("Saved files successfully to scratch/ and assets/data/!")
