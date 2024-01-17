import argparse
import os
import simplejson as json
import re

parser = argparse.ArgumentParser("Add files to JSON")

parser.add_argument("--jsons", nargs="+", required=True)
parser.add_argument("--bolds", nargs="*", required=True)

args = parser.parse_args()

# IntendedFor values are relative to session dir

if len(args.bolds) > 0:
    # IntendedFor string should start with ses-*/func/...
    bold_str = [re.search("ses-.*/func/.*.nii.gz", f).group(0) 
                for f in args.bolds]
else:
    bold_str = []

print(f"  Found {len(args.jsons)} JSONs")
print(f"  Found {len(bold_str)} BOLDs")

for j in args.jsons:

    with open(j) as json_data:
        data = json.load(json_data)

    data["IntendedFor"] = bold_str

    with open(j, "w") as f:
        json.dump(data, f, indent=4)

    print(f"    Done editing JSON {j}")
