import json
import math

with open('assets/data/locations.json', encoding='utf-8') as f:
    locations = json.load(f)

with open('assets/data/roads.json', encoding='utf-8') as f:
    roads = json.load(f)

with open('assets/data/default_paths.json', encoding='utf-8') as f:
    default_paths = json.load(f)

print("--- VALIDATION REPORT ---")
print(f"Locations count: {len(locations)} (Expected: 70)")
assert len(locations) == 70

loc_ids = [l['id'] for l in locations]
assert len(set(loc_ids)) == 70, "Duplicate location IDs!"
loc_names = [l['name'] for l in locations]
assert len(set(loc_names)) == 70, "Duplicate location names!"

selectables = [l for l in locations if l['selectable']]
print(f"Selectable count: {len(selectables)} (Expected: 25)")
assert len(selectables) == 25

starts = [l for l in locations if l.get('start') == True]
print(f"Start count: {len(starts)} (Expected: 1)")
assert len(starts) == 1
start_node = starts[0]
print(f"Start location: {start_node['name']} (ID: {start_node['id']})")

loc_dict = {l['id']: l for l in locations}

road_ids = [r['id'] for r in roads]
assert len(set(road_ids)) == len(roads), "Duplicate road IDs!"

road_lookup = set()
for r in roads:
    u = r['from']
    v = r['to']
    assert u in loc_dict, f"Missing node {u}"
    assert v in loc_dict, f"Missing node {v}"
    u_loc = loc_dict[u]
    v_loc = loc_dict[v]
    euclid = round(math.hypot(u_loc['x'] - v_loc['x'], u_loc['y'] - v_loc['y']), 2)
    assert abs(r['length'] - euclid) < 0.01, f"Road {r['id']} length mismatch: {r['length']} vs {euclid}"
    road_lookup.add((u, v))
    if r.get('bidirectional', True):
        road_lookup.add((v, u))

print(f"Roads count: {len(roads)} (all verified with Euclidean lengths)")

print(f"Default paths count: {len(default_paths)} (Expected: 25)")
assert len(default_paths) == 25

for dest_name, path in default_paths.items():
    assert path[0]['id'] == start_node['id'], f"{dest_name} must start at Dora’s House"
    assert path[-1]['name'] == dest_name, f"{dest_name} must end at {dest_name}"
    for i in range(len(path) - 1):
        pair = (path[i]['id'], path[i+1]['id'])
        assert pair in road_lookup, f"No road between {path[i]['name']} and {path[i+1]['name']} in path to {dest_name}"

print("All 25 default paths are 100% valid consecutive roads!")
print("All validation tests PASSED successfully!")
