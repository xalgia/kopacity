#!/bin/sh
set -eu

project_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$project_dir"

sh -n package/contents/code/kopacityctl
node --check package/contents/code/kwin/main.js
xmllint --noout package/contents/config/main.xml
python3 -m json.tool package/metadata.json >/dev/null

for qml_file in package/contents/config/config.qml package/contents/ui/*.qml; do
    qmllint "$qml_file"
done

tests/controller_test.sh

printf '%s\n' "all checks passed"
