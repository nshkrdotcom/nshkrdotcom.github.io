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
assert_eq "$same_path_first" "$same_path_second" "same source logo should reuse the hashed cache path"
assert_file_count 1

changed_path=$(sync_fixture_logo "$repo_name" "$logo_v2")
assert_ne "$same_path_first" "$changed_path" "changed source logo should produce a new hashed cache path"
assert_exists "$LOGOS_DIR/$(basename "$changed_path")" "new hashed logo should exist"
assert_not_exists "$LOGOS_DIR/$(basename "$same_path_first")" "stale hashed logo should be pruned after content changes"
assert_file_count 1

prune_stale_cached_logos "$repo_name"
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

echo "sync_repos_to_hugo.sh tests passed"
