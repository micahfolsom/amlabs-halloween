#!/usr/bin/python

import os
import json
from operator import itemgetter

path = "/home/" + os.getenv("USER") + "/.local/share/godot/app_userdata/ReflexTest/high_scores.json"
path = "/home/" + os.getenv("USER") + "/.local/share/godot/app_userdata/ww-halloween/high_scores.json"
print(f"Reading scores from {path}\n")

scores = []
with open(path) as json_file:
    for line in json_file:
        data = json.loads(line)
        scores.append(data)
scores_sorted = sorted(scores, key=lambda x: (-x['score'], x['ts']))
i = 1
print("**************** RANKINGS ***********************")
for player in scores_sorted:
    print(f"{i}) {player['initials']} : {player['score']}")
    i += 1

print("\nPress any key to close")
input()
