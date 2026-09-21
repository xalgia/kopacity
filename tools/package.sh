#!/bin/sh
set -eu

project_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$project_dir"

version=$(python3 -c 'import json; print(json.load(open("package/metadata.json"))["KPlugin"]["Version"])')
archive="$project_dir/dist/kopacity-$version.plasmoid"

mkdir -p "$project_dir/dist"
rm -f "$archive"
(
    cd package
    zip -q -r "$archive" .
)

unzip -t "$archive" >/dev/null
unzip -Z1 "$archive" | grep -qx 'metadata.json'
unzip -p "$archive" LICENSE | cmp -s LICENSE -

printf '%s\n' "$archive"
