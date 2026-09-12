import json
import math
from pathlib import Path
from collections import defaultdict, deque

# ============================================================
# DORANAV WORLD DATA GENERATOR
# Generates:
#   locations.json
#   roads.json
#   default_paths.json
# ============================================================

# ------------------------------------------------------------
# 1. DEFAULT ROUTES FROM THE SPECIFICATION
# ------------------------------------------------------------

routes = {
    "Dora's House": [
        "Dora's House"
    ],

    "Benny's Barn": [
        "Jungle Entrance",
        "Jungle Camp",
        "Flower Field",
        "Benny's Barn"
    ],

    "Blueberry Hill": [
        "Jungle Entrance",
        "Nutty Forest",
        "Big Hill",
        "Blueberry Hill"
    ],

    "Snowy Mountain": [
        "Jungle Entrance",
        "Adventure Forest",
        "Big Hill",
        "Big Mountain",
        "Highest Hill",
        "Tallest Mountain",
        "Snowy Mountain"
    ],

    "Beach": [
        "Jungle Entrance",
        "Small Stream",
        "Giant River",
        "Rainbow Bridge",
        "Desert Oasis",
        "Beach"
    ],

    "Chocolate Tree": [
        "Jungle Entrance",
        "Nutty Forest",
        "Big Tree",
        "Chocolate Tree"
    ],

    "Big Yellow Station": [
        "Jungle Entrance",
        "Jungle Camp",
        "Flower Field",
        "Big Tree",
        "Big Yellow Station"
    ],

    "Flowery Garden": [
        "Jungle Entrance",
        "Adventure Forest",
        "Forest Garden",
        "Butterfly Garden",
        "Flowery Garden"
    ],

    "Animal Rescue Center": [
        "Jungle Entrance",
        "Jungle Camp",
        "Nutty Forest",
        "Treehouse",
        "Animal Rescue Center"
    ],

    "School": [
        "Jungle Entrance",
        "Flower Field",
        "Big Tree",
        "Big Yellow Station",
        "School"
    ],

    "Music Box": [
        "Jungle Entrance",
        "Adventure Forest",
        "Forest Garden",
        "High Tower",
        "Music Box"
    ],

    "King's Castle": [
        "Jungle Entrance",
        "Adventure Forest",
        "Forest Garden",
        "Troll Bridge",
        "Castle Bridge",
        "Castle Gate",
        "King's Castle"
    ],

    "Wizard's Castle": [
        "Jungle Entrance",
        "Nutty Forest",
        "Big Hill",
        "Moonbeam Mountain",
        "High Tower",
        "Cloud Path",
        "Wizard's Castle"
    ],

    "Dragon's Cave": [
        "Jungle Entrance",
        "Adventure Forest",
        "Big Mountain",
        "Dragon Mountain",
        "Dragon's Forest",
        "Dragon's Cave"
    ],

    "Volcano": [
        "Jungle Entrance",
        "Small Stream",
        "Giant River",
        "Desert Oasis",
        "Cactus Valley",
        "Volcano Path",
        "Volcano"
    ],

    "Treasure Island": [
        "Jungle Entrance",
        "Small Stream",
        "Giant River",
        "Rainbow Bridge",
        "Beach",
        "Pirate Harbor",
        "Treasure Island"
    ],

    "Mermaid Kingdom": [
        "Jungle Entrance",
        "Small Stream",
        "Giant River",
        "Sparkling Lake",
        "Crystal Lake",
        "Mermaid Kingdom"
    ],

    "Cloud Castle": [
        "Jungle Entrance",
        "Nutty Forest",
        "Big Hill",
        "Moonbeam Mountain",
        "Cloud Path",
        "Cloud Castle"
    ],

    "Amusement Park": [
        "Jungle Entrance",
        "Jungle Camp",
        "Big Tree",
        "Big Yellow Station",
        "Amusement Park"
    ],

    "Waterfall": [
        "Jungle Entrance",
        "Adventure Forest",
        "Forest Garden",
        "Small Stream",
        "Giant River",
        "Waterfall"
    ],

    "North Pole": [
        "Jungle Entrance",
        "Big Hill",
        "Big Mountain",
        "Highest Hill",
        "Tallest Mountain",
        "Snowy Mountain",
        "North Pole"
    ],

    "Crystal Kingdom": [
        "Jungle Entrance",
        "Adventure Forest",
        "Big Mountain",
        "Dragon Mountain",
        "Crystal Cave",
        "Crystal Kingdom"
    ],

    "Pirate Island": [
        "Jungle Entrance",
        "Small Stream",
        "Giant River",
        "Beach",
        "Pirate Harbor",
        "Pirate Island"
    ],

    "Butterfly Festival": [
        "Jungle Entrance",
        "Adventure Forest",
        "Forest Garden",
        "Butterfly Garden",
        "Flower Field",
        "Butterfly Festival"
    ],

    "Lost City": [
        "Jungle Entrance",
        "Nutty Forest",
        "Big Hill",
        "Desert Oasis",
        "Sandy Dunes",
        "Ancient Temple",
        "Hidden Tunnel",
        "Lost City"
    ]
}

DESTINATIONS = list(routes.keys())


# ------------------------------------------------------------
# 2. COORDINATES
# ------------------------------------------------------------

coordinates = {

    # Start / Jungle
    "Dora's House": (10, 105),
    "Jungle Entrance": (25, 105),
    "Jungle Camp": (35, 115),
    "Flower Field": (48, 110),
    "Nutty Forest": (42, 95),
    "Adventure Forest": (58, 115),
    "Big Tree": (62, 100),
    "Treehouse": (52, 88),

    # Jungle / mountain connection
    "Big Hill": (82, 120),
    "Blueberry Hill": (70, 135),
    "Big Mountain": (105, 145),
    "Highest Hill": (125, 165),
    "Tallest Mountain": (145, 180),
    "Snowy Mountain": (165, 195),
    "North Pole": (190, 200),

    # Mountain / fantasy
    "Dragon Mountain": (135, 150),
    "Dragon's Forest": (150, 135),
    "Dragon's Cave": (170, 125),

    "Moonbeam Mountain": (125, 125),
    "High Tower": (145, 110),
    "Cloud Path": (165, 125),
    "Cloud Castle": (185, 140),

    # Garden / castle
    "Forest Garden": (75, 105),
    "Butterfly Garden": (65, 90),
    "Flowery Garden": (85, 85),
    "Troll Bridge": (100, 100),
    "Castle Bridge": (120, 95),
    "Castle Gate": (145, 90),
    "King's Castle": (170, 85),

    # River / water
    "Small Stream": (30, 65),
    "Giant River": (45, 50),
    "Rainbow Bridge": (65, 45),
    "Sparkling Lake": (75, 55),
    "Crystal Lake": (90, 60),
    "Waterfall": (100, 45),

    # Beach / pirate
    "Beach": (80, 30),
    "Pirate Harbor": (100, 25),
    "Treasure Island": (120, 15),
    "Pirate Island": (140, 25),

    # Desert
    "Desert Oasis": (105, 60),
    "Cactus Valley": (120, 50),
    "Volcano Path": (135, 60),
    "Volcano": (155, 45),
    "Sandy Dunes": (125, 80),
    "Ancient Temple": (145, 70),
    "Hidden Tunnel": (160, 65),
    "Lost City": (180, 60),

    # Main destinations
    "Benny's Barn": (58, 125),
    "Chocolate Tree": (75, 100),
    "Big Yellow Station": (85, 95),
    "School": (100, 90),
    "Music Box": (160, 105),
    "Animal Rescue Center": (65, 75),
    "Amusement Park": (110, 85),
    "Mermaid Kingdom": (105, 35),
    "Crystal Cave": (150, 115),
    "Crystal Kingdom": (175, 110),
    "Wizard's Castle": (180, 130),
    "Butterfly Festival": (55, 105),

}


# ------------------------------------------------------------
# 3. ADD 11 EXTRA LOCATIONS
# ------------------------------------------------------------

extra_locations = {
    "Picnic Meadow": (55, 120),
    "Mango Grove": (48, 85),
    "Rainbow Meadow": (75, 115),
    "Forest Junction": (70, 105),
    "Mountain Junction": (95, 135),
    "River Junction": (55, 60),
    "Seashell Cove": (90, 20),
    "Desert Junction": (115, 70),
    "Castle Junction": (135, 100),
    "Cloud Meadow": (155, 145),
    "Polar Camp": (175, 175),
}

coordinates.update(extra_locations)


# ------------------------------------------------------------
# 4. VERIFY EXACTLY 70 LOCATIONS
# ------------------------------------------------------------

assert len(coordinates) == 70, (
    f"Expected 70 locations, got {len(coordinates)}"
)

assert len(set(coordinates.keys())) == 70


# ------------------------------------------------------------
# 5. LOCATION TYPES
# ------------------------------------------------------------

destination_set = set(DESTINATIONS)

special_types = {
    "Dora's House": "start",

    "Jungle Entrance": "junction",
    "Jungle Camp": "landmark",
    "Flower Field": "landmark",
    "Nutty Forest": "landmark",
    "Adventure Forest": "landmark",
    "Big Tree": "landmark",
    "Treehouse": "landmark",

    "Big Hill": "junction",
    "Big Mountain": "landmark",
    "Highest Hill": "landmark",
    "Tallest Mountain": "landmark",
    "Snowy Mountain": "landmark",

    "Small Stream": "landmark",
    "Giant River": "landmark",
    "Rainbow Bridge": "bridge",
    "Sparkling Lake": "landmark",
    "Crystal Lake": "landmark",

    "Desert Oasis": "landmark",
    "Cactus Valley": "landmark",
    "Volcano Path": "path",

    "Pirate Harbor": "harbor",
    "Castle Bridge": "bridge",
    "Troll Bridge": "bridge",
    "Hidden Tunnel": "tunnel",
}


# ------------------------------------------------------------
# 6. BUILD locations.json
# ------------------------------------------------------------

locations = []

name_to_id = {}

for index, name in enumerate(coordinates.keys(), start=1):

    location_id = f"L{index:03d}"
    name_to_id[name] = location_id

    is_destination = name in destination_set
    is_start = name == "Dora's House"

    if is_start:
        location_type = "start"
    elif is_destination:
        location_type = "destination"
    else:
        location_type = special_types.get(name, "intermediate")

    locations.append({
        "id": location_id,
        "name": name,
        "x": coordinates[name][0],
        "y": coordinates[name][1],
        "selectable": is_destination,
        "start": is_start,
        "active": True,
        "type": location_type,
        "metadata": {
            "description": f"DoraNav location: {name}"
        }
    })


# ------------------------------------------------------------
# 7. ROAD HELPERS
# ------------------------------------------------------------

roads = []
road_pairs = set()


def euclidean(a, b):
    return math.sqrt(
        (a[0] - b[0]) ** 2 +
        (a[1] - b[1]) ** 2
    )


def add_road(from_name, to_name, metadata=None):

    if from_name == to_name:
        return

    pair = tuple(sorted([from_name, to_name]))

    # Prevent duplicate roads
    if pair in road_pairs:
        return

    road_pairs.add(pair)

    distance = euclidean(
        coordinates[from_name],
        coordinates[to_name]
    )

    road_id = f"R{len(roads) + 1:03d}"

    roads.append({
        "id": road_id,
        "from": name_to_id[from_name],
        "to": name_to_id[to_name],
        "bidirectional": True,
        "length": round(distance, 2),
        "blocked": False,
        "metadata": metadata or {
            "road_type": "normal"
        }
    })


# ------------------------------------------------------------
# 8. BUILD ROADS FROM DEFAULT ROUTES
# ------------------------------------------------------------

# Dora's House -> Jungle Entrance
add_road(
    "Dora's House",
    "Jungle Entrance",
    {
        "road_type": "main_trail",
        "scenic": True
    }
)


# Every route becomes a valid graph path.
for destination, path in routes.items():

    # Every destination other than Dora's House starts
    # from Jungle Entrance.
    if destination != "Dora's House":

        full_path = ["Jungle Entrance"] + path

        for a, b in zip(full_path, full_path[1:]):
            metadata = {
                "road_type": "trail"
            }

            if "Bridge" in a or "Bridge" in b:
                metadata["road_type"] = "bridge"

            if "Tunnel" in a or "Tunnel" in b:
                metadata["road_type"] = "tunnel"

            add_road(a, b, metadata)


# ------------------------------------------------------------
# 9. ADD REDUNDANT CONNECTIONS
# ------------------------------------------------------------

extra_roads = [

    # Jungle redundancy
    ("Jungle Camp", "Picnic Meadow"),
    ("Picnic Meadow", "Flower Field"),
    ("Jungle Camp", "Mango Grove"),
    ("Mango Grove", "Nutty Forest"),
    ("Nutty Forest", "Forest Junction"),
    ("Forest Junction", "Big Tree"),
    ("Adventure Forest", "Forest Junction"),
    ("Adventure Forest", "Rainbow Meadow"),
    ("Rainbow Meadow", "Big Hill"),

    # Mountain redundancy
    ("Big Hill", "Mountain Junction"),
    ("Mountain Junction", "Big Mountain"),
    ("Big Mountain", "Highest Hill"),
    ("Big Mountain", "Dragon Mountain"),

    # Garden redundancy
    ("Flower Field", "Forest Garden"),
    ("Forest Garden", "Forest Junction"),
    ("Butterfly Garden", "Forest Junction"),

    # River redundancy
    ("Small Stream", "River Junction"),
    ("River Junction", "Giant River"),
    ("River Junction", "Sparkling Lake"),
    ("Giant River", "Waterfall"),
    ("Giant River", "Desert Oasis"),

    # Sea redundancy
    ("Rainbow Bridge", "Seashell Cove"),
    ("Seashell Cove", "Beach"),
    ("Beach", "Pirate Harbor"),
    ("Pirate Harbor", "Seashell Cove"),

    # Desert redundancy
    ("Desert Oasis", "Desert Junction"),
    ("Desert Junction", "Sandy Dunes"),
    ("Desert Junction", "Cactus Valley"),
    ("Sandy Dunes", "Ancient Temple"),

    # Castle redundancy
    ("High Tower", "Castle Junction"),
    ("Castle Junction", "Castle Bridge"),
    ("Castle Junction", "Castle Gate"),
    ("Cloud Path", "Cloud Meadow"),
    ("Cloud Meadow", "Cloud Castle"),

    # Crystal / mountain redundancy
    ("Dragon Mountain", "Crystal Cave"),
    ("Crystal Cave", "Crystal Kingdom"),
    ("Mountain Junction", "Moonbeam Mountain"),

    # Polar redundancy
    ("Tallest Mountain", "Polar Camp"),
    ("Polar Camp", "North Pole"),

    # Lost City redundancy
    ("Hidden Tunnel", "Lost City"),
]

for a, b in extra_roads:
    metadata = {
        "road_type": "alternate"
    }

    if "Bridge" in a or "Bridge" in b:
        metadata["road_type"] = "bridge"

    if "Tunnel" in a or "Tunnel" in b:
        metadata["road_type"] = "tunnel"

    add_road(a, b, metadata)


# ------------------------------------------------------------
# 10. BUILD default_paths
# ------------------------------------------------------------

default_paths = {}

for destination, route in routes.items():

    if destination == "Dora's House":
        path_names = ["Dora's House"]
    else:
        path_names = [
            "Dora's House",
            "Jungle Entrance"
        ] + route[1:]

    default_paths[destination] = [
        {
            "id": name_to_id[name],
            "name": name
        }
        for name in path_names
    ]


# ------------------------------------------------------------
# 11. GRAPH VALIDATION
# ------------------------------------------------------------

location_ids = {loc["id"] for loc in locations}

# Check all road IDs
road_ids = [road["id"] for road in roads]

assert len(road_ids) == len(set(road_ids)), \
    "Duplicate road IDs detected"


# Check every road references valid nodes
for road in roads:
    assert road["from"] in location_ids
    assert road["to"] in location_ids


# Check exactly 25 destinations
selectable = [
    loc for loc in locations
    if loc["selectable"]
]

assert len(selectable) == 25, \
    f"Expected 25 selectable locations, got {len(selectable)}"


# Check exact destination names
actual_destination_names = {
    loc["name"] for loc in selectable
}

assert actual_destination_names == destination_set, \
    "Destination names do not match required destinations"


# Check Dora's House
start_nodes = [
    loc for loc in locations
    if loc["start"]
]

assert len(start_nodes) == 1
assert start_nodes[0]["name"] == "Dora's House"


# ------------------------------------------------------------
# 12. CHECK ROAD LENGTHS
# ------------------------------------------------------------

id_to_location = {
    loc["id"]: loc
    for loc in locations
}

for road in roads:

    a = id_to_location[road["from"]]
    b = id_to_location[road["to"]]

    expected = math.sqrt(
        (a["x"] - b["x"]) ** 2 +
        (a["y"] - b["y"]) ** 2
    )

    assert abs(
        road["length"] - round(expected, 2)
    ) < 0.001, (
        f"Incorrect road length: {road['id']}"
    )


# ------------------------------------------------------------
# 13. CHECK GRAPH CONNECTIVITY
# ------------------------------------------------------------

adjacency = defaultdict(list)

for road in roads:

    a = road["from"]
    b = road["to"]

    adjacency[a].append(b)
    adjacency[b].append(a)


start_id = name_to_id["Dora's House"]

visited = set()
queue = deque([start_id])

while queue:

    current = queue.popleft()

    if current in visited:
        continue

    visited.add(current)

    for neighbour in adjacency[current]:

        if neighbour not in visited:
            queue.append(neighbour)


assert len(visited) == 70, (
    f"Graph is not fully connected. "
    f"Only {len(visited)}/70 nodes are reachable."
)


# ------------------------------------------------------------
# 14. CHECK DEFAULT PATHS
# ------------------------------------------------------------

road_lookup = set()

for road in roads:

    a = road["from"]
    b = road["to"]

    road_lookup.add((a, b))
    road_lookup.add((b, a))


for destination, path in default_paths.items():

    ids = [node["id"] for node in path]

    assert ids[0] == name_to_id["Dora's House"]

    assert ids[-1] == name_to_id[destination]

    for a, b in zip(ids, ids[1:]):

        assert (a, b) in road_lookup, (
            f"Missing road between {a} and {b} "
            f"for destination {destination}"
        )


# ------------------------------------------------------------
# 15. WRITE JSON FILES
# ------------------------------------------------------------

output_directory = Path("doranav_world")
output_directory.mkdir(exist_ok=True)


locations_file = output_directory / "locations.json"
roads_file = output_directory / "roads.json"
paths_file = output_directory / "default_paths.json"


with open(locations_file, "w", encoding="utf-8") as f:
    json.dump(
        locations,
        f,
        indent=2,
        ensure_ascii=False
    )


with open(roads_file, "w", encoding="utf-8") as f:
    json.dump(
        roads,
        f,
        indent=2,
        ensure_ascii=False
    )


with open(paths_file, "w", encoding="utf-8") as f:
    json.dump(
        default_paths,
        f,
        indent=2,
        ensure_ascii=False
    )


# ------------------------------------------------------------
# 16. FINAL VALIDATION REPORT
# ------------------------------------------------------------

print()
print("=" * 60)
print("DORANAV WORLD DATA GENERATED SUCCESSFULLY")
print("=" * 60)

print(f"Locations       : {len(locations)}")
print(f"Roads           : {len(roads)}")
print(f"Destinations    : {len(selectable)}")
print(f"Start location  : {start_nodes[0]['id']} - Dora's House")
print(f"Reachable nodes : {len(visited)}/70")
print("Road lengths    : VALID")
print("Default paths   : VALID")
print("Duplicate IDs   : NONE")
print("Duplicate names : NONE")

print()
print("Files created:")
print(f"  {locations_file}")
print(f"  {roads_file}")
print(f"  {paths_file}")

print()
print("All validation checks passed.")
print("=" * 60)
