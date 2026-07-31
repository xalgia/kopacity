#!/bin/sh
set -eu

project_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
controller="$project_dir/package/contents/code/kopacityctl"
backend="$project_dir/package/contents/code/kwin/main.js"
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT HUP INT TERM

config_file="$test_dir/kwinrc"
runtime_dir="$test_dir/runtime"
mock_state="$test_dir/mock-state"
mock_qdbus="$test_dir/qdbus6"
mkdir -p "$runtime_dir" "$mock_state"
printf 'false\n' > "$mock_state/loaded"

cat > "$mock_qdbus" <<'MOCK'
#!/bin/sh
set -eu

method=${3:-}

case "$method" in
    org.kde.kwin.Scripting.isScriptLoaded)
        cat "$KOPACITY_TEST_STATE/loaded"
        ;;
    org.kde.kwin.Scripting.unloadScript)
        printf 'false\n' > "$KOPACITY_TEST_STATE/loaded"
        printf 'true\n'
        ;;
    org.kde.kwin.Scripting.loadScript)
        if [ -f "$KOPACITY_TEST_STATE/fail-load" ]; then
            exit 1
        fi
        printf 'true\n' > "$KOPACITY_TEST_STATE/pending"
        printf '1\n'
        ;;
    org.kde.kwin.Scripting.start)
        if [ -f "$KOPACITY_TEST_STATE/pending" ]; then
            printf 'true\n' > "$KOPACITY_TEST_STATE/loaded"
            rm -f "$KOPACITY_TEST_STATE/pending"
        fi
        ;;
    *)
        printf 'Unexpected mock D-Bus method: %s\n' "$method" >&2
        exit 1
        ;;
esac
MOCK
chmod 755 "$mock_qdbus"

run_controller() {
    env \
        XDG_RUNTIME_DIR="$runtime_dir" \
        KOPACITY_CONFIG_FILE="$config_file" \
        KOPACITY_SCRIPT_MAIN="$backend" \
        KOPACITY_QDBUS="$mock_qdbus" \
        KOPACITY_TEST_STATE="$mock_state" \
        "$controller" "$@"
}

assert_contains() {
    output=$1
    expected=$2
    case "$output" in
        *"$expected"*)
            ;;
        *)
            printf 'Expected output to contain: %s\nActual output: %s\n' "$expected" "$output" >&2
            exit 1
            ;;
    esac
}

assert_config() {
    key=$1
    expected=$2
    actual=$(kreadconfig6 \
        --file "$config_file" \
        --group Script-io.github.xalgia.kopacity.backend \
        --key "$key" \
        --default '<unset>')
    if [ "$actual" != "$expected" ]; then
        printf 'Expected %s=%s, got %s\n' "$key" "$expected" "$actual" >&2
        exit 1
    fi
}

output=$(run_controller status)
assert_contains "$output" "enabled=false"
assert_contains "$output" "opacity=75"
assert_contains "$output" "effective=100"
assert_contains "$output" "normal=true"
assert_contains "$output" "dialogs=true"
assert_contains "$output" "panels=false"

output=$(run_controller set 60)
assert_contains "$output" "enabled=true"
assert_contains "$output" "effective=60"
assert_contains "$output" "loaded=true"
assert_config Opacity 60
assert_config Enabled true

output=$(run_controller scope panels on)
assert_contains "$output" "panels=true"
assert_contains "$output" "loaded=true"
assert_config IncludePanels true

output=$(run_controller off)
assert_contains "$output" "enabled=false"
assert_contains "$output" "opacity=60"
assert_contains "$output" "effective=100"
assert_contains "$output" "loaded=false"

output=$(run_controller on)
assert_contains "$output" "enabled=true"
assert_contains "$output" "effective=60"
assert_contains "$output" "loaded=true"

output=$(run_controller set 100)
assert_contains "$output" "enabled=false"
assert_contains "$output" "opacity=60"
assert_contains "$output" "effective=100"
assert_contains "$output" "loaded=false"

output=$(run_controller dec)
assert_contains "$output" "enabled=true"
assert_contains "$output" "opacity=95"
assert_contains "$output" "effective=95"

output=$(run_controller set 30)
assert_contains "$output" "opacity=50"
assert_contains "$output" "effective=50"

if run_controller set invalid >/dev/null 2>&1; then
    printf '%s\n' "An invalid opacity unexpectedly succeeded." >&2
    exit 1
fi
assert_config Opacity 50

run_controller set 60 >/dev/null
touch "$mock_state/fail-load"
if run_controller set 70 >/dev/null 2>&1; then
    printf '%s\n' "A simulated backend load failure unexpectedly succeeded." >&2
    exit 1
fi
assert_config Opacity 60
assert_config Enabled true
rm -f "$mock_state/fail-load"

output=$(run_controller sync)
assert_contains "$output" "enabled=true"
assert_contains "$output" "effective=60"
assert_contains "$output" "loaded=true"

run_controller scope normal off >/dev/null
run_controller scope dialogs off >/dev/null
output=$(run_controller scope panels off)
assert_contains "$output" "enabled=true"
assert_contains "$output" "normal=false"
assert_contains "$output" "dialogs=false"
assert_contains "$output" "panels=false"
assert_contains "$output" "loaded=false"

output=$(run_controller scope normal on)
assert_contains "$output" "normal=true"
assert_contains "$output" "loaded=true"

printf '%s\n' "controller tests passed"
