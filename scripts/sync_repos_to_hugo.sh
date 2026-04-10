#!/bin/bash

# Sync all repos from GitHub to Hugo data file with category-based organization
# Uses nshkr-* topic tags for categorization
# Repos with nshkr-archive are hidden from site
# Uncategorized repos appear in "Other Projects"

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CATEGORY_CONFIG="$PROJECT_DIR/config/nshkr_categories.json"
DATA_FILE="$PROJECT_DIR/data/repos.yml"
LOGOS_DIR="$PROJECT_DIR/static/logos"
TMP_FILE="$(mktemp)"
USER_REPOS_FILE="$(mktemp)"
ORG_REPOS_FILE="$(mktemp)"
DATA_TMP_FILE="$(mktemp)"

source "$PROJECT_DIR/scripts/lib/nshkr_categories.sh"
nshkr_load_category_config "$CATEGORY_CONFIG"

echo "Syncing repositories to Hugo data..."

# Local repo paths
LOCAL_NSHKR="$HOME/p/g/n"
LOCAL_NORTHSHORE="$HOME/p/g/North-Shore-AI"

mkdir -p "$LOGOS_DIR"

cleanup() {
    rm -f "$TMP_FILE"
    rm -f "$USER_REPOS_FILE"
    rm -f "$ORG_REPOS_FILE"
    rm -f "$DATA_TMP_FILE"
}
trap cleanup EXIT

# Fetch logo from GitHub raw URL
# Returns 0 on success, 1 on failure
fetch_logo_from_github() {
    local owner=$1
    local repo_name=$2
    local remote_path=$3
    local dest_path=$4
    local branch=${5:-main}

    local url="https://raw.githubusercontent.com/${owner}/${repo_name}/${branch}/${remote_path}"

    # Use curl with silent mode, fail on HTTP errors, follow redirects
    if curl -sfL --max-time 10 "$url" -o "$dest_path" 2>/dev/null; then
        # Verify we got actual content (not a 404 page)
        if [[ -s "$dest_path" ]] && ! grep -q "404" "$dest_path" 2>/dev/null; then
            return 0
        fi
        rm -f "$dest_path"
    fi
    return 1
}

# Try to fetch logo from GitHub by parsing remote README or trying standard paths
fetch_logo_remote() {
    local repo_name=$1
    local owner=$2
    local branch=${3:-main}

    local readme_url="https://raw.githubusercontent.com/${owner}/${repo_name}/${branch}/README.md"
    local readme_content=""
    local logo_file=""
    local logo_dir=""

    # Try to fetch and parse README
    readme_content=$(curl -sfL --max-time 10 "$readme_url" 2>/dev/null || echo "")

    if [[ -n "$readme_content" ]]; then
        # Check for <img src="assets/..."
        logo_file=$(echo "$readme_content" | grep -oP '(?<=src=["'"'"']assets/)[^"'"'"']+' | head -1)
        if [[ -n "$logo_file" ]]; then
            logo_dir="assets"
        fi

        # Check for <img src="logo/..."
        if [[ -z "$logo_file" ]]; then
            logo_file=$(echo "$readme_content" | grep -oP '(?<=src=["'"'"']logo/)[^"'"'"']+' | head -1)
            if [[ -n "$logo_file" ]]; then
                logo_dir="logo"
            fi
        fi

        # Check for ![...](assets/...)
        if [[ -z "$logo_file" ]]; then
            logo_file=$(echo "$readme_content" | grep -oP '(?<=\]\(assets/)[^)]+' | head -1)
            if [[ -n "$logo_file" ]]; then
                logo_dir="assets"
            fi
        fi

        # Check for ![...](logo/...)
        if [[ -z "$logo_file" ]]; then
            logo_file=$(echo "$readme_content" | grep -oP '(?<=\]\(logo/)[^)]+' | head -1)
            if [[ -n "$logo_file" ]]; then
                logo_dir="logo"
            fi
        fi
    fi

    # If found in README, try to fetch it
    if [[ -n "$logo_file" ]] && [[ -n "$logo_dir" ]]; then
        local ext="${logo_file##*.}"
        local dest_path="$LOGOS_DIR/${repo_name}.${ext}"
        if fetch_logo_from_github "$owner" "$repo_name" "${logo_dir}/${logo_file}" "$dest_path" "$branch"; then
            echo "/logos/${repo_name}.${ext}"
            return
        fi
    fi

    # Fallback: try standard paths
    for dir in assets logo; do
        for ext in svg png; do
            for pattern in "${repo_name}.${ext}" "${repo_name}_logo.${ext}" "${repo_name}-logo.${ext}" "logo.${ext}"; do
                local dest_path="$LOGOS_DIR/${repo_name}.${ext}"
                if fetch_logo_from_github "$owner" "$repo_name" "${dir}/${pattern}" "$dest_path" "$branch"; then
                    echo "/logos/${repo_name}.${ext}"
                    return
                fi
            done
        done
    done

    echo ""
}

# Extract logo from local repo and copy to static/logos/{repo}.{ext}
# Falls back to fetching from GitHub if local repo not available
# Returns the logo path (e.g., /logos/repo.svg) or empty string
extract_logo() {
    local repo_name=$1
    local owner=$2
    local branch=${3:-main}
    local repo_dir=""

    # Check if logo already exists (avoid re-fetching)
    for ext in svg png; do
        if [[ -f "$LOGOS_DIR/${repo_name}.${ext}" ]]; then
            echo "/logos/${repo_name}.${ext}"
            return
        fi
    done

    # Find local repo path
    if [[ "$owner" == "nshkrdotcom" ]] && [[ -d "$LOCAL_NSHKR/$repo_name" ]]; then
        repo_dir="$LOCAL_NSHKR/$repo_name"
    elif [[ "$owner" == "North-Shore-AI" ]] && [[ -d "$LOCAL_NORTHSHORE/$repo_name" ]]; then
        repo_dir="$LOCAL_NORTHSHORE/$repo_name"
    fi

    # If no local repo, try fetching from GitHub
    if [[ -z "$repo_dir" ]]; then
        fetch_logo_remote "$repo_name" "$owner" "$branch"
        return
    fi

    local readme="$repo_dir/README.md"
    local logo_file=""
    local logo_dir=""

    # Parse README for logo in assets/ or logo/ directories
    if [[ -f "$readme" ]]; then
        # Check for <img src="assets/..." first
        logo_file=$(grep -oP '(?<=src=["'"'"']assets/)[^"'"'"']+' "$readme" | head -1)
        if [[ -n "$logo_file" ]]; then
            logo_dir="assets"
        fi

        # Check for <img src="logo/..."
        if [[ -z "$logo_file" ]]; then
            logo_file=$(grep -oP '(?<=src=["'"'"']logo/)[^"'"'"']+' "$readme" | head -1)
            if [[ -n "$logo_file" ]]; then
                logo_dir="logo"
            fi
        fi

        # Check for ![...](assets/...)
        if [[ -z "$logo_file" ]]; then
            logo_file=$(grep -oP '(?<=\]\(assets/)[^)]+' "$readme" | head -1)
            if [[ -n "$logo_file" ]]; then
                logo_dir="assets"
            fi
        fi

        # Check for ![...](logo/...)
        if [[ -z "$logo_file" ]]; then
            logo_file=$(grep -oP '(?<=\]\(logo/)[^)]+' "$readme" | head -1)
            if [[ -n "$logo_file" ]]; then
                logo_dir="logo"
            fi
        fi
    fi

    # Fallback: check for standard logo filenames if not found in README
    if [[ -z "$logo_file" ]]; then
        for dir in assets logo; do
            for ext in svg png; do
                for pattern in "${repo_name}.${ext}" "${repo_name}_logo.${ext}" "${repo_name}-logo.${ext}"; do
                    if [[ -f "$repo_dir/$dir/$pattern" ]]; then
                        logo_file="$pattern"
                        logo_dir="$dir"
                        break 3
                    fi
                done
            done
        done
    fi

    if [[ -z "$logo_file" ]] || [[ -z "$logo_dir" ]]; then
        # Local repo exists but no logo found - try remote as last resort
        fetch_logo_remote "$repo_name" "$owner" "$branch"
        return
    fi

    local src_path="$repo_dir/$logo_dir/$logo_file"
    if [[ ! -f "$src_path" ]]; then
        echo ""
        return
    fi

    # Get extension and copy with normalized name
    local ext="${logo_file##*.}"
    local dest_path="$LOGOS_DIR/${repo_name}.${ext}"
    cp "$src_path" "$dest_path"

    echo "/logos/${repo_name}.${ext}"
}

echo "Fetching repos from GitHub..."

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

# Combine repos from both sources
{
    fetch_repos "nshkrdotcom" "users" "$USER_REPOS_FILE"
    fetch_repos "North-Shore-AI" "orgs" "$ORG_REPOS_FILE"
    cat "$USER_REPOS_FILE" "$ORG_REPOS_FILE"
} | jq -s --arg archive "$NSHKR_ARCHIVE_SLUG" --arg uncategorized "$NSHKR_UNCATEGORIZED_SLUG" '
    # Deduplicate by name (prefer higher star count)
    group_by(.name) | map(sort_by(-.stars) | first) |

    # Filter out archived repos and forks
    map(select(
        (.topics | index($archive) | not) and
        (.fork == false)
    )) |

    # Add category field based on nshkr-* topic
    map(. + {
        category: (
            (.topics | map(select(startswith("nshkr-") and . != $archive)) | sort | first) //
            $uncategorized
        )
    }) |

    # Sort by stars within each category
    sort_by(-.stars, .name)
' > "$TMP_FILE"

echo "Generating Hugo data file..."

mapfile -t DISCOVERED_CATEGORIES < <(jq -r '.[].category' "$TMP_FILE" | sort -u)
mapfile -t ORDERED_CATEGORIES < <(printf '%s\n' "${DISCOVERED_CATEGORIES[@]}" | nshkr_build_ordered_topics)

# Generate YAML header
cat > "$DATA_TMP_FILE" << 'HEADER'
# Auto-generated repository data with category-based organization
# Last updated: TIMESTAMP
# Do not edit manually - managed by scripts/sync_repos_to_hugo.sh
# Categories are controlled via GitHub topics (nshkr-*)
# Pinned category metadata lives in config/nshkr_categories.json
# Use scripts/MANAGE_REPO_TOPICS.sh to manage categories

HEADER

sed -i "s/TIMESTAMP/$(date -u +"%Y-%m-%dT%H:%M:%SZ")/" "$DATA_TMP_FILE"

# Generate categories section with weights for ordering
echo "categories:" >> "$DATA_TMP_FILE"
weight=0
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

# Generate repos section grouped by category
echo "repos:" >> "$DATA_TMP_FILE"

# Process each category
for cat in "${ORDERED_CATEGORIES[@]}" "$NSHKR_UNCATEGORIZED_SLUG"; do
    repos_in_cat=$(jq -r --arg cat "$cat" '.[] | select(.category == $cat)' "$TMP_FILE")

    if [ -n "$repos_in_cat" ]; then
        # Process each repo to extract logo and generate YAML
        jq -r --arg cat "$cat" '
            .[] | select(.category == $cat) |
            "\(.name)|\(.owner)|\(.default_branch)"
        ' "$TMP_FILE" | while IFS='|' read -r repo_name owner branch; do
            # Extract logo (copies file and returns path)
            logo_path=$(extract_logo "$repo_name" "$owner" "$branch")

            # Get repo data from JSON
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

if [[ -f "$DATA_FILE" ]] && diff -q <(sed '/^# Last updated:/d' "$DATA_FILE") <(sed '/^# Last updated:/d' "$DATA_TMP_FILE") >/dev/null; then
    echo "No changes detected. Skipping update."
    exit 0
fi

mv "$DATA_TMP_FILE" "$DATA_FILE"

# Summary
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
    if [ "$count" -gt 0 ]; then
        echo "  $(nshkr_display_name_for_topic "$cat"): $count"
    fi
done
uncat=$(jq --arg uncategorized "$NSHKR_UNCATEGORIZED_SLUG" '[.[] | select(.category == $uncategorized)] | length' "$TMP_FILE")
if [ "$uncat" -gt 0 ]; then
    echo "  ${NSHKR_UNCATEGORIZED_NAME}: $uncat"
fi

echo ""
echo "Top repos by stars:"
jq -r '.[:10] | .[] | "  \(.stars) \(.name)"' "$TMP_FILE"

echo ""
echo "Data written to: $DATA_FILE"
