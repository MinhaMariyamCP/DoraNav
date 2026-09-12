"""
DoraNav World Map Generator - v2 (Clean, no emoji dependency)
Creates a colorful, Dora-themed PNG map from the world data.
Uses text markers instead of emoji for cross-platform compatibility.
"""

import json
import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import FancyBboxPatch
from pathlib import Path
import numpy as np
from matplotlib import patheffects

# ============================================================
# LOAD DATA
# ============================================================

data_dir = Path("doranav_world")

with open(data_dir / "locations.json", "r", encoding="utf-8") as f:
    locations = json.load(f)

with open(data_dir / "roads.json", "r", encoding="utf-8") as f:
    roads = json.load(f)

id_to_loc = {loc["id"]: loc for loc in locations}


# ============================================================
# ZONE CLASSIFICATION
# ============================================================

def classify_zone(name, x, y):
    n = name.lower()
    if any(k in n for k in ["snow", "north pole", "polar", "tallest", "highest"]):
        return "snow"
    if any(k in n for k in ["dragon", "crystal cave", "crystal kingdom"]):
        return "dragon"
    if any(k in n for k in ["cloud", "wizard", "moonbeam"]):
        return "cloud"
    if any(k in n for k in ["castle", "king", "troll"]):
        return "castle"
    if any(k in n for k in ["volcano", "cactus", "desert", "sandy", "ancient", "hidden", "lost city"]):
        return "desert"
    if any(k in n for k in ["beach", "pirate", "treasure", "seashell", "mermaid"]):
        return "ocean"
    if any(k in n for k in ["stream", "river", "rainbow bridge", "sparkling", "crystal lake", "waterfall"]):
        return "water"
    if any(k in n for k in ["mountain", "big hill", "blueberry", "big mountain"]):
        return "mountain"
    if any(k in n for k in ["jungle", "dora", "camp", "adventure", "nutty", "mango", "picnic"]):
        return "jungle"
    if any(k in n for k in ["flower", "butterfly", "garden", "flowery", "rainbow meadow"]):
        return "garden"
    if any(k in n for k in ["tree", "forest", "treehouse", "barn", "chocolate", "station", "school",
                             "music", "amusement", "animal", "rescue"]):
        return "forest"
    return "general"


ZONE_BG = {
    "jungle":   "#388E3C", "forest":   "#43A047", "garden":   "#C2185B",
    "mountain": "#6D4C41", "snow":     "#81D4FA", "water":    "#1E88E5",
    "ocean":    "#FFB300", "desert":   "#E64A19", "castle":   "#7B1FA2",
    "dragon":   "#D32F2F", "cloud":    "#AB47BC", "general":  "#546E7A",
}


# ============================================================
# NODE STYLING
# ============================================================

NODE_COLORS = {
    "start":        "#FF1744",
    "destination":  "#AA00FF",
    "junction":     "#FF6D00",
    "landmark":     "#00C853",
    "bridge":       "#2962FF",
    "harbor":       "#00ACC1",
    "tunnel":       "#5D4037",
    "path":         "#757575",
    "intermediate": "#78909C",
}

NODE_SIZES = {
    "start": 400, "destination": 260, "junction": 130,
    "landmark": 110, "bridge": 110, "harbor": 110,
    "tunnel": 100, "path": 80, "intermediate": 65,
}

MARKER_SHAPES = {
    "start":        "*",   # star
    "destination":  "D",   # diamond
    "junction":     "s",   # square
    "landmark":     "o",   # circle
    "bridge":       "^",   # triangle up
    "harbor":       "p",   # pentagon
    "tunnel":       "h",   # hexagon
    "path":         "d",   # thin diamond
    "intermediate": ".",   # point
}


# ============================================================
# ROAD STYLING
# ============================================================

ROAD_STYLES = {
    "main_trail":  {"color": "#E65100", "lw": 4.0, "ls": "-",  "alpha": 0.9, "z": 3},
    "trail":       {"color": "#795548", "lw": 2.2, "ls": "-",  "alpha": 0.65, "z": 2},
    "bridge":      {"color": "#1565C0", "lw": 2.8, "ls": "--", "alpha": 0.75, "z": 3},
    "tunnel":      {"color": "#3E2723", "lw": 2.0, "ls": ":",  "alpha": 0.55, "z": 2},
    "alternate":   {"color": "#BDBDBD", "lw": 1.3, "ls": "-.", "alpha": 0.45, "z": 1},
    "normal":      {"color": "#9E9E9E", "lw": 1.5, "ls": "-",  "alpha": 0.45, "z": 1},
}


# ============================================================
# CREATE FIGURE
# ============================================================

fig, ax = plt.subplots(1, 1, figsize=(30, 24))
ax.set_facecolor('#F1F8E9')

# Gradient background
gradient = np.linspace(0, 1, 256).reshape(1, -1)
gradient = np.vstack([gradient] * 256)
ax.imshow(gradient.T,
          extent=[-8, 208, -8, 218],
          aspect='auto',
          cmap=plt.cm.YlGn,
          alpha=0.10,
          zorder=0)


# ============================================================
# DRAW ZONE BACKGROUND REGIONS
# ============================================================

zone_locs = {}
for loc in locations:
    z = classify_zone(loc["name"], loc["x"], loc["y"])
    zone_locs.setdefault(z, []).append((loc["x"], loc["y"]))

for z, pts in zone_locs.items():
    if len(pts) < 2:
        continue
    xs, ys = zip(*pts)
    cx, cy = np.mean(xs), np.mean(ys)
    rx = max(max(xs) - min(xs), 18) * 0.75
    ry = max(max(ys) - min(ys), 18) * 0.75
    c = ZONE_BG.get(z, "#546E7A")
    ax.add_patch(mpatches.Ellipse(
        (cx, cy), rx * 2, ry * 2,
        alpha=0.07, facecolor=c, edgecolor=c,
        linewidth=1.8, linestyle=':', zorder=0
    ))


# ============================================================
# DRAW ROADS
# ============================================================

for road in roads:
    a = id_to_loc[road["from"]]
    b = id_to_loc[road["to"]]
    rt = road["metadata"].get("road_type", "normal")
    s = ROAD_STYLES.get(rt, ROAD_STYLES["normal"])

    ax.plot(
        [a["x"], b["x"]], [a["y"], b["y"]],
        color=s["color"], linewidth=s["lw"],
        linestyle=s["ls"], alpha=s["alpha"],
        zorder=s["z"], solid_capstyle='round'
    )


# ============================================================
# DRAW NODES
# ============================================================

draw_order = ["intermediate", "path", "tunnel", "harbor", "bridge",
              "junction", "landmark", "destination", "start"]

for lt in draw_order:
    for loc in locations:
        if loc["type"] != lt:
            continue

        x, y = loc["x"], loc["y"]
        c = NODE_COLORS.get(lt, "#78909C")
        sz = NODE_SIZES.get(lt, 65)
        mk = MARKER_SHAPES.get(lt, "o")

        # Glow for destinations / start
        if lt in ("destination", "start"):
            ax.scatter(x, y, s=sz * 3.5, c=c, alpha=0.12, zorder=9, marker='o')
            ax.scatter(x, y, s=sz * 2,   c=c, alpha=0.22, zorder=9, marker='o')

        ax.scatter(x, y, s=sz, c=c, marker=mk,
                   edgecolors='white', linewidths=1.8,
                   zorder=10, alpha=0.95)


# ============================================================
# LABEL OFFSET STRATEGY
# ============================================================

# Pre-compute all label positions, then nudge overlapping ones
label_data = []

for loc in locations:
    x, y = loc["x"], loc["y"]
    name = loc["name"]
    lt = loc["type"]

    # Default: above
    dx, dy = 0, 3

    # Manual nudges for known crowded spots
    nudges = {
        "Dora's House":         (-3, -4),
        "Jungle Entrance":      (0, 3.5),
        "Jungle Camp":          (-6, 3),
        "Adventure Forest":     (4, 3),
        "Nutty Forest":         (-6, -3),
        "Flower Field":         (0, -4),
        "Big Tree":             (5, -3),
        "Forest Garden":        (6, 2),
        "Butterfly Garden":     (-6, -3),
        "Small Stream":         (-6, -2),
        "Giant River":          (-6, 2),
        "Big Hill":             (4, 3),
        "Treehouse":            (-6, -2),
        "Crystal Lake":         (0, -4),
        "Desert Oasis":         (6, 2),
        "Pirate Harbor":        (0, -4),
        "Big Mountain":         (6, 2),
        "Cactus Valley":        (0, -4),
        "High Tower":           (-6, -2),
        "Moonbeam Mountain":    (-9, 2),
        "Castle Bridge":        (0, -4),
        "Castle Gate":          (0, -4),
        "Big Yellow Station":   (6, -3),
        "School":               (6, -3),
        "Animal Rescue Center": (0, -4),
        "Forest Junction":      (6, -2),
        "Chocolate Tree":       (6, -2),
        "Rainbow Meadow":       (6, 2),
        "Butterfly Festival":   (-6, 2),
        "Wizard's Castle":      (6, -3),
        "Mango Grove":          (-6, 2),
        "River Junction":       (-6, -2),
        "Seashell Cove":        (0, -4),
        "Mountain Junction":    (6, 2),
        "Desert Junction":      (0, -4),
        "Cloud Meadow":         (6, 2),
        "Polar Camp":           (6, -3),
        "Picnic Meadow":        (-6, 3),
        "Castle Junction":      (0, -4),
    }

    if name in nudges:
        dx, dy = nudges[name]

    # Font params
    if lt == "start":
        fs, fw = 9, 'bold'
    elif lt == "destination":
        fs, fw = 7.5, 'bold'
    elif lt in ("junction", "landmark"):
        fs, fw = 6, 'normal'
    else:
        fs, fw = 5.5, 'normal'

    label_data.append((x, y, dx, dy, name, lt, fs, fw))


# Draw labels
for (x, y, dx, dy, name, lt, fs, fw) in label_data:

    use_box = lt in ("start", "destination")
    use_arrow = abs(dx) > 4 or abs(dy) > 4

    bbox_props = None
    if use_box:
        box_color = '#FFFFFF'
        edge_color = NODE_COLORS.get(lt, '#B0BEC5')
        bbox_props = dict(
            boxstyle='round,pad=0.25',
            facecolor=box_color,
            edgecolor=edge_color,
            alpha=0.88,
            linewidth=1.0
        )

    arrow_props = None
    if use_arrow:
        arrow_props = dict(
            arrowstyle='-',
            color='#90A4AE',
            lw=0.6,
            connectionstyle='arc3,rad=0.08'
        )

    pe = None
    if not use_box:
        pe = [patheffects.withStroke(linewidth=2.5, foreground='white')]

    ax.annotate(
        name,
        xy=(x, y),
        xytext=(x + dx, y + dy),
        fontsize=fs,
        fontweight=fw,
        ha='center',
        va='bottom',
        color='#1A237E' if lt in ("start", "destination") else '#37474F',
        zorder=15,
        arrowprops=arrow_props,
        bbox=bbox_props,
        path_effects=pe,
    )


# ============================================================
# NUMBER BADGES FOR DESTINATIONS
# ============================================================

dest_idx = 1
for loc in locations:
    if loc["type"] in ("destination", "start"):
        x, y = loc["x"], loc["y"]
        badge_color = NODE_COLORS.get(loc["type"], "#78909C")

        # Small circle badge offset
        bx, by = x - 3, y - 3

        ax.add_patch(plt.Circle((bx, by), 2.2,
                                facecolor=badge_color, edgecolor='white',
                                linewidth=1, zorder=17, alpha=0.9))
        ax.text(bx, by, str(dest_idx),
                fontsize=5.5, fontweight='bold',
                ha='center', va='center',
                color='white', zorder=18)

        dest_idx += 1


# ============================================================
# TITLE
# ============================================================

ax.set_title(
    "DORA NAV  -  World Map\n"
    "70 Locations  |  104 Roads  |  25 Destinations",
    fontsize=24,
    fontweight='bold',
    color='#4A148C',
    pad=25,
    fontfamily='sans-serif'
)


# ============================================================
# LEGEND
# ============================================================

legend_items = [
    mpatches.Patch(fc=NODE_COLORS["start"], ec='white', label="Start (Dora's House)"),
    mpatches.Patch(fc=NODE_COLORS["destination"], ec='white', label='Destinations (25)'),
    mpatches.Patch(fc=NODE_COLORS["junction"], ec='white', label='Junctions'),
    mpatches.Patch(fc=NODE_COLORS["landmark"], ec='white', label='Landmarks'),
    mpatches.Patch(fc=NODE_COLORS["bridge"], ec='white', label='Bridges'),
    mpatches.Patch(fc=NODE_COLORS["harbor"], ec='white', label='Harbor'),
    mpatches.Patch(fc=NODE_COLORS["tunnel"], ec='white', label='Tunnel'),
    plt.Line2D([0], [0], color=ROAD_STYLES["main_trail"]["color"], lw=3.5, label='Main Trail'),
    plt.Line2D([0], [0], color=ROAD_STYLES["trail"]["color"], lw=2, label='Trail'),
    plt.Line2D([0], [0], color=ROAD_STYLES["bridge"]["color"], lw=2, ls='--', label='Bridge Road'),
    plt.Line2D([0], [0], color=ROAD_STYLES["tunnel"]["color"], lw=2, ls=':', label='Tunnel Road'),
    plt.Line2D([0], [0], color=ROAD_STYLES["alternate"]["color"], lw=1.3, ls='-.', label='Alternate Route'),
]

leg = ax.legend(
    handles=legend_items,
    loc='lower left',
    fontsize=9,
    framealpha=0.92,
    facecolor='white',
    edgecolor='#7B1FA2',
    title='LEGEND',
    title_fontsize=12,
    ncol=1,
    borderpad=1.2,
    labelspacing=0.9
)
leg.get_title().set_fontweight('bold')
leg.get_title().set_color('#4A148C')


# ============================================================
# DESTINATION LIST (right side)
# ============================================================

dest_names = [(loc["name"], loc["type"]) for loc in locations
              if loc["selectable"] or loc["start"]]

lines = ["  DESTINATIONS", "  " + "-" * 28]
for i, (name, _) in enumerate(dest_names, 1):
    lines.append(f"  {i:2d}. {name}")

dest_text = "\n".join(lines)

ax.text(
    0.985, 0.03,
    dest_text,
    transform=ax.transAxes,
    fontsize=7,
    fontfamily='monospace',
    verticalalignment='bottom',
    horizontalalignment='right',
    bbox=dict(
        boxstyle='round,pad=0.8',
        facecolor='white',
        edgecolor='#7B1FA2',
        alpha=0.93,
        linewidth=2
    ),
    zorder=20,
    color='#1A237E',
    fontweight='bold'
)


# ============================================================
# COMPASS ROSE
# ============================================================

cx, cy, cr = 195, 207, 5

ax.add_patch(plt.Circle((cx, cy), cr + 1.5,
                         fc='#F3E5F5', ec='#4A148C', lw=2.5, zorder=19, alpha=0.85))

for direction, (ddx, ddy), sz, clr, fw in [
    ('N', (0, cr + 0.5),  12, '#B71C1C', 'bold'),
    ('S', (0, -cr - 1.5), 9,  '#283593', 'normal'),
    ('E', (cr + 1, 0),    9,  '#283593', 'normal'),
    ('W', (-cr - 1, 0),   9,  '#283593', 'normal'),
]:
    ax.text(cx + ddx, cy + ddy, direction, fontsize=sz, fontweight=fw,
            ha='center', va='center', color=clr, zorder=21)

for ddx, ddy, clr, lw in [
    (0, cr - 0.5, '#B71C1C', 2.5),
    (cr - 0.5, 0, '#283593', 1.8),
    (0, -(cr - 0.5), '#283593', 1.8),
    (-(cr - 0.5), 0, '#283593', 1.8),
]:
    ax.annotate('', xy=(cx + ddx, cy + ddy), xytext=(cx, cy),
                arrowprops=dict(arrowstyle='->', color=clr, lw=lw), zorder=20)


# ============================================================
# ZONE LABELS
# ============================================================

zone_labels = {
    "Jungle Zone":   (28, 115),
    "Mountain Zone":  (115, 175),
    "Water Zone":     (50, 42),
    "Desert Zone":    (145, 62),
    "Castle Zone":    (158, 92),
    "Snow Zone":      (178, 198),
    "Dragon Zone":    (152, 145),
    "Ocean Zone":     (110, 22),
    "Garden Zone":    (72, 88),
    "Cloud Zone":     (175, 135),
}

for label, (zx, zy) in zone_labels.items():
    ax.text(zx, zy, label,
            fontsize=10, fontweight='bold',
            ha='center', va='center',
            color='#37474F', alpha=0.35,
            fontstyle='italic', zorder=1,
            path_effects=[patheffects.withStroke(linewidth=3.5, foreground='white')])


# ============================================================
# STATS BOX (top-left)
# ============================================================

stats_text = (
    "  DORANAV WORLD STATS\n"
    "  " + "-" * 25 + "\n"
    "  Locations:     70\n"
    "  Roads:        104\n"
    "  Destinations:  25\n"
    "  Zones:         10\n"
    "  Start: Dora's House"
)

ax.text(
    0.015, 0.97,
    stats_text,
    transform=ax.transAxes,
    fontsize=7.5,
    fontfamily='monospace',
    verticalalignment='top',
    horizontalalignment='left',
    bbox=dict(
        boxstyle='round,pad=0.8',
        facecolor='white',
        edgecolor='#4A148C',
        alpha=0.93,
        linewidth=2
    ),
    zorder=20,
    color='#1A237E',
    fontweight='bold'
)


# ============================================================
# WATERMARK
# ============================================================

ax.text(
    0.5, 0.004,
    "Explore More, Worry Less!  -  DoraNav World Map",
    transform=ax.transAxes,
    fontsize=11,
    ha='center', va='bottom',
    color='#7B1FA2', alpha=0.55,
    fontweight='bold', fontstyle='italic',
    zorder=20
)


# ============================================================
# FRAME & AXES
# ============================================================

ax.set_xlim(-8, 208)
ax.set_ylim(-8, 218)
ax.set_aspect('equal')
ax.axis('off')

# Decorative border
rect = FancyBboxPatch(
    (-6, -6), 212, 222,
    boxstyle="round,pad=2",
    facecolor='none',
    edgecolor='#7B1FA2',
    linewidth=3.5,
    zorder=0
)
ax.add_patch(rect)


# ============================================================
# SAVE
# ============================================================

output_path = Path("doranav_world") / "doranav_map.png"

plt.savefig(
    output_path,
    dpi=200,
    bbox_inches='tight',
    facecolor='#FAFAFA',
    edgecolor='none',
    pad_inches=0.5
)

plt.close()

print(f"\n{'='*60}")
print("MAP GENERATED SUCCESSFULLY")
print(f"{'='*60}")
print(f"Output: {output_path}")
print(f"{'='*60}")
