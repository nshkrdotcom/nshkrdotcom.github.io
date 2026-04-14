#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
FIXTURES_DIR="$SCRIPT_DIR/fixtures"
TMP_ROOT="$(mktemp -d)"

cleanup() {
    rm -rf "$TMP_ROOT"
}
trap cleanup EXIT

source "$PROJECT_DIR/scripts/sync_repos_to_hugo.sh"

LOGOS_DIR="$TMP_ROOT/logos"
mkdir -p "$LOGOS_DIR"
LOGO_CACHE_CHANGED=0

fail() {
    echo "test_sync_repos_to_hugo.sh: $*" >&2
    exit 1
}

assert_eq() {
    local expected=$1
    local actual=$2
    local message=$3

    if [[ "$expected" != "$actual" ]]; then
        fail "$message: expected '$expected', got '$actual'"
    fi
}

assert_ne() {
    local left=$1
    local right=$2
    local message=$3

    if [[ "$left" == "$right" ]]; then
        fail "$message: both values were '$left'"
    fi
}

assert_exists() {
    local path=$1
    local message=$2

    [[ -f "$path" ]] || fail "$message: missing $path"
}

assert_not_exists() {
    local path=$1
    local message=$2

    [[ ! -e "$path" ]] || fail "$message: unexpected $path"
}

assert_fails() {
    local message=$1
    shift

    if "$@"; then
        fail "$message: command unexpectedly succeeded"
    fi
}

assert_file_count() {
    local expected=$1
    local actual=""

    actual=$(find "$LOGOS_DIR" -maxdepth 1 -type f | wc -l | tr -d ' ')
    assert_eq "$expected" "$actual" "unexpected cached logo count"
}

sync_fixture_logo() {
    local repo_name=$1
    local fixture_path=$2
    local temp_path=""

    temp_path=$(mktemp)
    cp "$fixture_path" "$temp_path"
    cache_logo_artifact "$repo_name" "$fixture_path" "$temp_path"
}

repo_name="fixture-repo"
logo_v1="$FIXTURES_DIR/logo-v1.svg"
logo_v2="$FIXTURES_DIR/logo-v2.svg"

same_path_first=$(sync_fixture_logo "$repo_name" "$logo_v1")
same_path_second=$(sync_fixture_logo "$repo_name" "$logo_v1")
[[ "$same_path_first" == *.png ]] || fail "SVG source logos should be rasterized to PNG"
[[ "$same_path_second" == *.png ]] || fail "SVG source logos should be rasterized to PNG"
assert_eq "$same_path_first" "$same_path_second" "same source logo should reuse the hashed cache path"
assert_file_count 1

changed_path=$(sync_fixture_logo "$repo_name" "$logo_v2")
assert_ne "$same_path_first" "$changed_path" "changed source logo should produce a new hashed cache path"
assert_exists "$LOGOS_DIR/$(basename "$changed_path")" "new hashed logo should exist"
assert_not_exists "$LOGOS_DIR/$(basename "$same_path_first")" "stale hashed logo should be pruned after content changes"
assert_file_count 1

ffmpeg_stub_dir="$(mktemp -d)"
cat > "$ffmpeg_stub_dir/convert" <<'SH'
#!/bin/sh
exit 1
SH
cat > "$ffmpeg_stub_dir/ffmpeg" <<'SH'
#!/bin/sh
output_path=""
while [ "$#" -gt 0 ]; do
    output_path="$1"
    shift
done
printf '%s' 'fake-png' > "$output_path"
exit 0
SH
chmod +x "$ffmpeg_stub_dir/convert" "$ffmpeg_stub_dir/ffmpeg"

old_path="$PATH"
PATH="$ffmpeg_stub_dir:$old_path"
LOGO_RASTER_SIZE=64
fallback_output="$(mktemp)"
if ! rasterize_svg_logo "$logo_v1" "$fallback_output"; then
    PATH="$old_path"
    fail "rasterize_svg_logo should fall back to ffmpeg when convert fails"
fi
PATH="$old_path"
assert_exists "$fallback_output" "rasterization fallback should create an output file"
rm -f "$fallback_output"
rm -rf "$ffmpeg_stub_dir"

failure_stub_dir="$(mktemp -d)"
cat > "$failure_stub_dir/convert" <<'SH'
#!/bin/sh
exit 1
SH
cat > "$failure_stub_dir/ffmpeg" <<'SH'
#!/bin/sh
exit 1
SH
cat > "$failure_stub_dir/rsvg-convert" <<'SH'
#!/bin/sh
exit 1
SH
chmod +x "$failure_stub_dir/convert" "$failure_stub_dir/ffmpeg" "$failure_stub_dir/rsvg-convert"

PATH="$failure_stub_dir:$old_path"
failed_temp="$(mktemp)"
cp "$logo_v1" "$failed_temp"
failed_raster_path="$(cache_logo_artifact "svg-fallback" "$logo_v1" "$failed_temp")"
PATH="$old_path"
[[ "$failed_raster_path" == *.svg ]] || fail "failed rasterization should keep the original SVG"
assert_exists "$LOGOS_DIR/$(basename "$failed_raster_path")" "failed rasterization should keep the SVG asset"
rm -rf "$failure_stub_dir"

prune_stale_cached_logos "$repo_name"
prune_stale_cached_logos "svg-fallback"
assert_file_count 0

keep_path=$(sync_fixture_logo "$repo_name" "$logo_v1")
drop_path=$(sync_fixture_logo "other-repo" "$logo_v2")
manifest_file="$TMP_ROOT/manifest.yml"
cat > "$manifest_file" <<EOF
repos:
  fixture:
    logo: "$keep_path"
EOF
prune_unreferenced_cached_logos "$manifest_file"
assert_exists "$LOGOS_DIR/$(basename "$keep_path")" "referenced logo should survive prune_unreferenced_cached_logos"
assert_not_exists "$LOGOS_DIR/$(basename "$drop_path")" "unreferenced logo should be pruned"
validate_referenced_logo_assets "$manifest_file"

cat > "$manifest_file" <<'EOF'
repos:
  missing:
    logo: "/logos/missing-logo.svg"
EOF
assert_fails "validate_referenced_logo_assets should fail when a referenced logo is missing" \
    validate_referenced_logo_assets "$manifest_file"

markdown_logo_path=$(extract_logo_path_from_readme_content "$(cat "$FIXTURES_DIR/README.md.fixture")")
assert_eq "docs/_static/brand-mark.svg" "$markdown_logo_path" "markdown README should resolve docs-hosted logo paths"

rst_logo_path=$(extract_logo_path_from_readme_content "$(cat "$FIXTURES_DIR/README.rst.fixture")")
assert_eq "docs/_static/brand-mark.svg" "$rst_logo_path" "reStructuredText README should resolve docs-hosted logo paths"

elixirscope_false_positive=$(
    printf '%s\n' "test_apps/phoenix_scope_player/priv/static/images/logo.svg" \
        | select_logo_path_from_repo_tree_paths "ElixirScope" ""
)
assert_eq "" "$elixirscope_false_positive" "tree fallback should ignore demo and test app logos"

explicit_demo_logo=$(
    printf '%s\n' "test_apps/phoenix_scope_player/priv/static/images/logo.svg" \
        | select_logo_path_from_repo_tree_paths "ElixirScope" "test_apps/phoenix_scope_player/priv/static/images/logo.svg"
)
assert_eq "test_apps/phoenix_scope_player/priv/static/images/logo.svg" "$explicit_demo_logo" "README-selected logo paths should win even in ignored directories"

strong_repo_logo=$(
    printf '%s\n' \
        "images/logo.svg" \
        "assets/elixirscope-logo.svg" \
        "priv/static/images/elixirscope.svg" \
        | select_logo_path_from_repo_tree_paths "ElixirScope" ""
)
assert_eq "assets/elixirscope-logo.svg" "$strong_repo_logo" "repo-specific root logo should outrank generic logo files"

echo "sync_repos_to_hugo.sh tests passed"
