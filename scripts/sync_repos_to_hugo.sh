#!/bin/bash

# Sync all repos from GitHub to Hugo data file with category-based organization
# Uses nshkr-* topic tags for categorization
# Repos with nshkr-archive are hidden from site
# Uncategorized repos appear in "Other Projects"

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CATEGORY_CONFIG="${CATEGORY_CONFIG:-$PROJECT_DIR/config/nshkr_categories.json}"
DATA_FILE="${DATA_FILE:-$PROJECT_DIR/data/repos.yml}"
LOGOS_DIR="${LOGOS_DIR:-$PROJECT_DIR/static/logos}"
TMP_FILE=""
USER_REPOS_FILE=""
ORG_REPOS_FILE=""
DATA_TMP_FILE=""
LOGO_CACHE_CHANGED=0

source "$PROJECT_DIR/scripts/lib/nshkr_categories.sh"
nshkr_load_category_config "$CATEGORY_CONFIG"

initialize_runtime() {
    TMP_FILE="$(mktemp)"
    USER_REPOS_FILE="$(mktemp)"
    ORG_REPOS_FILE="$(mktemp)"
    DATA_TMP_FILE="$(mktemp)"
    LOGO_CACHE_CHANGED=0
    mkdir -p "$LOGOS_DIR"
}

cleanup() {
    rm -f "${TMP_FILE:-}"
    rm -f "${USER_REPOS_FILE:-}"
    rm -f "${ORG_REPOS_FILE:-}"
    rm -f "${DATA_TMP_FILE:-}"
}

# Hash a file for content-addressed logo filenames.
hash_file() {
    local file_path=$1

    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$file_path" | awk '{print substr($1, 1, 12)}'
        return
    fi

    if command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$file_path" | awk '{print substr($1, 1, 12)}'
        return
    fi

    if command -v openssl >/dev/null 2>&1; then
        openssl dgst -sha256 "$file_path" | awk '{print substr($NF, 1, 12)}'
        return
    fi

    echo "Unable to hash logo content: no SHA-256 tool available" >&2
    return 1
}

normalize_logo_extension() {
    local source_path=${1,,}

    case "$source_path" in
        *.svg) echo "svg" ;;
        *.png) echo "png" ;;
        *.jpg|*.jpeg) echo "jpg" ;;
        *.webp) echo "webp" ;;
        *.gif) echo "gif" ;;
        *) return 1 ;;
    esac
}

sanitize_repo_relative_path() {
    local path=$1

    path="${path//$'\r'/}"
    path="${path%%#*}"
    path="${path%%\?*}"

    while [[ "$path" == ./* ]]; do
        path="${path#./}"
    done

    case "$path" in
        ""|/*|http://*|https://*|data:*|mailto:*|*://*)
            return 1
            ;;
    esac

    printf '%s\n' "$path"
}

logo_candidate_score() {
    local lower_path=${1,,}
    local score=20

    case "$lower_path" in
        assets/*|logo/*|logos/*|static/logo/*|static/logos/*)
            score=0
            ;;
        docs/_static/*|docs/static/*|doc/_static/*|doc/static/*|images/*|img/*)
            score=6
            ;;
        docs/*|doc/*)
            score=8
            ;;
        static/*)
            score=4
            ;;
    esac

    case "$lower_path" in
        *logo*)
            score=$((score - 3))
            ;;
    esac

    case "$lower_path" in
        *.svg)
            score=$((score - 2))
            ;;
        *.png)
            score=$((score - 1))
            ;;
    esac

    printf '%s\n' "$score"
}

prune_stale_cached_logos() {
    local repo_name=$1
    local keep_basename=${2:-}
    local candidate=""

    while IFS= read -r -d '' candidate; do
        if [[ -n "$keep_basename" ]] && [[ "$(basename "$candidate")" == "$keep_basename" ]]; then
            continue
        fi
        rm -f "$candidate"
        LOGO_CACHE_CHANGED=1
    done < <(
        find "$LOGOS_DIR" -maxdepth 1 -type f \
            \( -name "${repo_name}.svg" -o -name "${repo_name}.png" -o -name "${repo_name}.jpg" -o -name "${repo_name}.jpeg" -o -name "${repo_name}.webp" -o -name "${repo_name}.gif" -o -name "${repo_name}-*.*" \) \
            -print0
    )
}

prune_unreferenced_cached_logos() {
    local manifest_file=$1
    local logo_file=""
    local basename=""
    declare -A referenced_logos=()

    while IFS= read -r basename; do
        [[ -n "$basename" ]] || continue
        referenced_logos["$basename"]=1
    done < <(
        rg -o 'logo: "/logos/[^"]+"' "$manifest_file" \
            | sed -E 's/.*\/logos\/([^"]+)".*/\1/'
    )

    while IFS= read -r -d '' logo_file; do
        basename=$(basename "$logo_file")
        if [[ -z "${referenced_logos[$basename]+x}" ]]; then
            rm -f "$logo_file"
            LOGO_CACHE_CHANGED=1
        fi
    done < <(find "$LOGOS_DIR" -maxdepth 1 -type f -print0)
}

cache_logo_artifact() {
    local repo_name=$1
    local source_path=$2
    local temp_path=$3
    local ext=""
    local content_hash=""
    local versioned_name=""
    local final_path=""

    ext=$(normalize_logo_extension "$source_path") || {
        rm -f "$temp_path"
        return 1
    }

    content_hash=$(hash_file "$temp_path") || {
        rm -f "$temp_path"
        return 1
    }

    versioned_name="${repo_name}-${content_hash}.${ext}"
    final_path="$LOGOS_DIR/$versioned_name"

    if [[ ! -f "$final_path" ]]; then
        mv "$temp_path" "$final_path"
        LOGO_CACHE_CHANGED=1
    else
        rm -f "$temp_path"
    fi

    prune_stale_cached_logos "$repo_name" "$versioned_name"
    printf '/logos/%s\n' "$versioned_name"
}

download_github_raw_file() {
    local owner=$1
    local repo_name=$2
    local remote_path=$3
    local dest_path=$4
    local branch=${5:-main}
    local normalized_path=""
    local encoded_path=""
    local url=""

    normalized_path=$(sanitize_repo_relative_path "$remote_path") || return 1
    encoded_path="${normalized_path// /%20}"
    url="https://raw.githubusercontent.com/${owner}/${repo_name}/${branch}/${encoded_path}"

    if curl -fsSL --retry 3 --retry-delay 1 --retry-all-errors --max-time 20 "$url" -o "$dest_path" 2>/dev/null && [[ -s "$dest_path" ]]; then
        return 0
    fi

    rm -f "$dest_path"
    return 1
}

extract_logo_path_from_readme_content() {
    local readme_content=$1
    local best_path=""
    local best_score=999
    local candidate=""
    local sanitized=""
    local score=""

    while IFS= read -r candidate; do
        [[ -n "$candidate" ]] || continue
        sanitized=$(sanitize_repo_relative_path "$candidate" 2>/dev/null || true)
        [[ -n "$sanitized" ]] || continue
        normalize_logo_extension "$sanitized" >/dev/null 2>&1 || continue
        score=$(logo_candidate_score "$sanitized")
        if [[ -z "$best_path" ]] || [[ "$score" -lt "$best_score" ]]; then
            best_path="$sanitized"
            best_score="$score"
        fi
    done < <(
        printf '%s\n' "$readme_content" \
            | grep -oiP 'src=["'"'"'][^"'"'"']+\.(svg|png|jpe?g|webp|gif)(?:\?[^"'"'"']*)?(?:#[^"'"'"']*)?["'"'"']' \
            | sed -E 's/^src=["'"'"'](.*)["'"'"']$/\1/I' || true
        printf '%s\n' "$readme_content" \
            | grep -oP '!\[[^]]*\]\([^)]+\.(svg|png|jpe?g|webp|gif)(?:\?[^)]*)?(?:#[^)]*)?\)' \
            | sed -E 's/^!\[[^]]*\]\((.*)\)$/\1/' || true
        printf '%s\n' "$readme_content" \
            | grep -oiP '^\s*\.\.\s+(?:image|figure)::\s+\K[^[:space:]]+\.(svg|png|jpe?g|webp|gif)(?:\?[^[:space:]]*)?(?:#[^[:space:]]*)?' || true
    )

    printf '%s\n' "$best_path"
}

cache_remote_logo_candidate() {
    local repo_name=$1
    local owner=$2
    local branch=$3
    local remote_path=$4
    local temp_path=""

    temp_path=$(mktemp)
    if download_github_raw_file "$owner" "$repo_name" "$remote_path" "$temp_path" "$branch"; then
        cache_logo_artifact "$repo_name" "$remote_path" "$temp_path"
        return 0
    fi

    rm -f "$temp_path"
    return 1
}

fetch_repo_readme_content() {
    local owner=$1
    local repo_name=$2
    local branch=${3:-main}
    local readme_payload=""

    readme_payload=$(gh api "repos/${owner}/${repo_name}/readme?ref=${branch}" 2>/dev/null || true)
    if [[ -z "$readme_payload" ]]; then
        printf '\n'
        return
    fi

    printf '%s' "$readme_payload" | jq -r '.content // empty | gsub("\n"; "") | @base64d'
}

find_logo_path_in_repo_tree() {
    local owner=$1
    local repo_name=$2
    local branch=${3:-main}
    local preferred_path=${4:-}
    local tree_payload=""

    tree_payload=$(gh api "repos/${owner}/${repo_name}/git/trees/${branch}?recursive=1" 2>/dev/null || true)
    if [[ -z "$tree_payload" ]]; then
        printf '\n'
        return
    fi

    printf '%s' "$tree_payload" | jq -r --arg repo "$repo_name" --arg preferred "$preferred_path" '
        def canonical_basename:
            split("/") | last | ascii_downcase;

        def repo_names($repo):
            ($repo | ascii_downcase) as $r |
            [
                $r + ".svg", $r + ".png", $r + ".jpg", $r + ".jpeg", $r + ".webp", $r + ".gif",
                $r + "_logo.svg", $r + "_logo.png", $r + "_logo.jpg", $r + "_logo.jpeg", $r + "_logo.webp", $r + "_logo.gif",
                $r + "-logo.svg", $r + "-logo.png", $r + "-logo.jpg", $r + "-logo.jpeg", $r + "-logo.webp", $r + "-logo.gif",
                "logo.svg", "logo.png", "logo.jpg", "logo.jpeg", "logo.webp", "logo.gif"
            ];

        def in_common_dir:
            ascii_downcase | test("(^|/)(assets|logo|logos|static/logo|static/logos|static|docs/_static|docs/static|doc/_static|doc/static|images|img)/");

        def has_logo_hint:
            ascii_downcase | test("logo");

        def matches_repo_name($repo):
            canonical_basename as $base |
            repo_names($repo) | index($base) != null;

        def relevant($repo; $preferred):
            ($preferred != "" and ascii_downcase == ($preferred | ascii_downcase)) or
            in_common_dir or
            has_logo_hint or
            matches_repo_name($repo);

        def score($repo; $preferred):
            (ascii_downcase) as $p |
            (if ($preferred != "" and $p == ($preferred | ascii_downcase)) then -100
             elif ($p | test("(^|/)(assets|logo|logos|static/logo|static/logos)/")) then 0
             elif ($p | test("(^|/)(docs/_static|docs/static|doc/_static|doc/static|images|img)/")) then 6
             elif ($p | test("(^|/)static/")) then 4
             else 20 end)
            + (if $p | test("logo") then -3 else 0 end)
            + (if $p | test("\\.svg$") then -2 elif $p | test("\\.png$") then -1 else 0 end);

        (.tree // [])
        | map(select(.type == "blob"))
        | map(.path | gsub("^\\./"; ""))
        | map(select(test("\\.(svg|png|jpe?g|webp|gif)$"; "i")))
        | map(select(relevant($repo; $preferred)))
        | sort_by(score($repo; $preferred), .)
        | .[0] // empty
    '
}

# Fetch and cache the authoritative logo from the repo default branch.
# Returns the versioned Hugo asset path (for example, /logos/repo-abc123def456.svg).
fetch_logo_remote() {
    local repo_name=$1
    local owner=$2
    local branch=${3:-main}
    local readme_content=""
    local logo_path=""
    local resolved_path=""

    readme_content=$(fetch_repo_readme_content "$owner" "$repo_name" "$branch")
    if [[ -n "$readme_content" ]]; then
        logo_path=$(extract_logo_path_from_readme_content "$readme_content")
    fi

    resolved_path=$(find_logo_path_in_repo_tree "$owner" "$repo_name" "$branch" "$logo_path")
    if [[ -n "$resolved_path" ]] && cache_remote_logo_candidate "$repo_name" "$owner" "$branch" "$resolved_path"; then
        return
    fi

    printf '\n'
}

# Resolve the logo from the remote default branch so cache invalidation works
# the same way in local runs and CI.
extract_logo() {
    local repo_name=$1
    local owner=$2
    local branch=${3:-main}
    local logo_path=""

    logo_path=$(fetch_logo_remote "$repo_name" "$owner" "$branch")
    if [[ -n "$logo_path" ]]; then
        printf '%s\n' "$logo_path"
        return
    fi

    prune_stale_cached_logos "$repo_name"
    printf '\n'
}

# Fetch all public repos with topics from both accounts (handles pagination)
fetch_repos() {
    local owner=$1
    local type=$2  # "users" or "orgs"
    local output_file=$3
    local endpoint="${type}/${owner}/repos?per_page=100&type=public"
    local attempt

    for attempt in 1 2 3; do
        if gh api --paginate "$endpoint" | jq -ce '
            .[] | {
                name: .name,
                full_name: .full_name,
                html_url: .html_url,
                description: (.description // ""),
                stars: .stargazers_count,
                language: (.language // ""),
                topics: (.topics // []),
                fork: .fork,
                archived: .archived,
                owner: .owner.login,
                default_branch: .default_branch
            }
        ' > "$output_file"; then
            if [[ -s "$output_file" ]] && jq -se '
                length > 0 and all(.[]; (
                    type == "object" and
                    (.name | type == "string") and
                    (.owner | type == "string") and
                    (.topics | type == "array")
                ))
            ' "$output_file" > /dev/null; then
                return 0
            fi

            echo "Invalid repo payload received from ${endpoint} (attempt ${attempt})" >&2
            sed -n '1,10p' "$output_file" >&2 || true
        fi

        if [[ "$attempt" -lt 3 ]]; then
            sleep "$attempt"
        fi
    done

    echo "Failed to fetch valid repo data from ${endpoint}" >&2
    return 1
}

main() {
    local cat=""
    local cat_name=""
    local count=""
    local logo_path=""
    local owner=""
    local branch=""
    local repo_name=""
    local repos_in_cat=""
    local total=""
    local uncat=""
    local weight=0
    local -a DISCOVERED_CATEGORIES=()
    local -a ORDERED_CATEGORIES=()

    initialize_runtime
    trap cleanup EXIT

    echo "Syncing repositories to Hugo data..."
    echo "Fetching repos from GitHub..."

    {
        fetch_repos "nshkrdotcom" "users" "$USER_REPOS_FILE"
        fetch_repos "North-Shore-AI" "orgs" "$ORG_REPOS_FILE"
        cat "$USER_REPOS_FILE" "$ORG_REPOS_FILE"
    } | jq -s --arg archive "$NSHKR_ARCHIVE_SLUG" --arg uncategorized "$NSHKR_UNCATEGORIZED_SLUG" '
        group_by(.name) | map(sort_by(-.stars) | first) |
        map(select(
            (.topics | index($archive) | not) and
            (.fork == false)
        )) |
        map(. + {
            category: (
                (.topics | map(select(startswith("nshkr-") and . != $archive)) | sort | first) //
                $uncategorized
            )
        }) |
        sort_by(-.stars, .name)
    ' > "$TMP_FILE"

    echo "Generating Hugo data file..."

    mapfile -t DISCOVERED_CATEGORIES < <(jq -r '.[].category' "$TMP_FILE" | sort -u)
    mapfile -t ORDERED_CATEGORIES < <(printf '%s\n' "${DISCOVERED_CATEGORIES[@]}" | nshkr_build_ordered_topics)

    cat > "$DATA_TMP_FILE" << 'HEADER'
# Auto-generated repository data with category-based organization
# Last updated: TIMESTAMP
# Do not edit manually - managed by scripts/sync_repos_to_hugo.sh
# Categories are controlled via GitHub topics (nshkr-*)
# Pinned category metadata lives in config/nshkr_categories.json
# Use scripts/MANAGE_REPO_TOPICS.sh to manage categories

HEADER

    sed -i "s/TIMESTAMP/$(date -u +"%Y-%m-%dT%H:%M:%SZ")/" "$DATA_TMP_FILE"

    echo "categories:" >> "$DATA_TMP_FILE"
    for cat in "${ORDERED_CATEGORIES[@]}"; do
        cat_name=$(nshkr_display_name_for_topic "$cat")
        echo "  ${cat}:" >> "$DATA_TMP_FILE"
        echo "    name: \"${cat_name}\"" >> "$DATA_TMP_FILE"
        echo "    slug: \"${cat}\"" >> "$DATA_TMP_FILE"
        echo "    weight: ${weight}" >> "$DATA_TMP_FILE"
        weight=$((weight + 1))
    done
    echo "  ${NSHKR_UNCATEGORIZED_SLUG}:" >> "$DATA_TMP_FILE"
    echo "    name: \"${NSHKR_UNCATEGORIZED_NAME}\"" >> "$DATA_TMP_FILE"
    echo "    slug: \"${NSHKR_UNCATEGORIZED_SLUG}\"" >> "$DATA_TMP_FILE"
    echo "    weight: 999" >> "$DATA_TMP_FILE"
    echo "" >> "$DATA_TMP_FILE"

    echo "repos:" >> "$DATA_TMP_FILE"

    for cat in "${ORDERED_CATEGORIES[@]}" "$NSHKR_UNCATEGORIZED_SLUG"; do
        repos_in_cat=$(jq -r --arg cat "$cat" '.[] | select(.category == $cat)' "$TMP_FILE")

        if [[ -n "$repos_in_cat" ]]; then
            jq -r --arg cat "$cat" '
                .[] | select(.category == $cat) |
                "\(.name)|\(.owner)|\(.default_branch)"
            ' "$TMP_FILE" | while IFS='|' read -r repo_name owner branch; do
                logo_path=$(extract_logo "$repo_name" "$owner" "$branch")

                jq -r --arg name "$repo_name" --arg logo "$logo_path" '
                    .[] | select(.name == $name) |
                    "  " + .name + ":\n" +
                    "    name: \"" + .name + "\"\n" +
                    "    org: \"" + .owner + "\"\n" +
                    "    stars: " + (.stars | tostring) + "\n" +
                    "    category: \"" + .category + "\"\n" +
                    "    description: \"" + (.description | gsub("\""; "\\\"")) + "\"\n" +
                    "    url: \"" + .html_url + "\"\n" +
                    (if $logo != "" then "    logo: \"" + $logo + "\"\n" else "" end) +
                    (if .language != "" then "    language: \"" + .language + "\"\n" else "" end) +
                    (if .archived then "    archived: true\n" else "" end)
                ' "$TMP_FILE" >> "$DATA_TMP_FILE"
            done
        fi
    done

    prune_unreferenced_cached_logos "$DATA_TMP_FILE"

    if [[ -f "$DATA_FILE" ]] && [[ "$LOGO_CACHE_CHANGED" -eq 0 ]] && diff -q <(sed '/^# Last updated:/d' "$DATA_FILE") <(sed '/^# Last updated:/d' "$DATA_TMP_FILE") >/dev/null; then
        echo "No changes detected. Skipping update."
        return 0
    fi

    mv "$DATA_TMP_FILE" "$DATA_FILE"

    echo ""
    echo "Sync complete!"
    echo ""
    echo "Summary:"
    total=$(jq 'length' "$TMP_FILE")
    echo "  Total repos: $total"
    echo ""
    echo "By category:"
    for cat in "${ORDERED_CATEGORIES[@]}"; do
        count=$(jq --arg cat "$cat" '[.[] | select(.category == $cat)] | length' "$TMP_FILE")
        if [[ "$count" -gt 0 ]]; then
            echo "  $(nshkr_display_name_for_topic "$cat"): $count"
        fi
    done
    uncat=$(jq --arg uncategorized "$NSHKR_UNCATEGORIZED_SLUG" '[.[] | select(.category == $uncategorized)] | length' "$TMP_FILE")
    if [[ "$uncat" -gt 0 ]]; then
        echo "  ${NSHKR_UNCATEGORIZED_NAME}: $uncat"
    fi

    echo ""
    echo "Top repos by stars:"
    jq -r '.[:10] | .[] | "  \(.stars) \(.name)"' "$TMP_FILE"

    echo ""
    echo "Data written to: $DATA_FILE"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
