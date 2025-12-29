#!/bin/bash

# Sync all repos from GitHub to Hugo data file with category-based organization
# Uses nshkr-* topic tags for categorization
# Repos with nshkr-archive are hidden from site
# Uncategorized repos appear in "Other Projects"

set -e

echo "Syncing repositories to Hugo data..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
DATA_FILE="$PROJECT_DIR/data/repos.yml"
LOGOS_DIR="$PROJECT_DIR/static/logos"
TMP_FILE="$(mktemp)"

# Local repo paths
LOCAL_NSHKR="$HOME/p/g/n"
LOCAL_NORTHSHORE="$HOME/p/g/North-Shore-AI"

mkdir -p "$LOGOS_DIR"

cleanup() {
    rm -f "$TMP_FILE"
}
trap cleanup EXIT

# Extract logo from local repo and copy to static/logos/{repo}.{ext}
# Returns the logo path (e.g., /logos/repo.svg) or empty string
extract_logo() {
    local repo_name=$1
    local owner=$2
    local repo_dir=""

    # Find local repo path
    if [[ "$owner" == "nshkrdotcom" ]] && [[ -d "$LOCAL_NSHKR/$repo_name" ]]; then
        repo_dir="$LOCAL_NSHKR/$repo_name"
    elif [[ "$owner" == "North-Shore-AI" ]] && [[ -d "$LOCAL_NORTHSHORE/$repo_name" ]]; then
        repo_dir="$LOCAL_NORTHSHORE/$repo_name"
    else
        echo ""
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
        echo ""
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

# Category definitions (order matters for display)
declare -A CATEGORY_NAMES=(
    ["nshkr-crucible"]="Crucible Framework"
    ["nshkr-ingot"]="Ingot Data Labeling"
    ["nshkr-ai-agents"]="AI Agent Orchestration"
    ["nshkr-ai-sdk"]="AI SDKs & API Clients"
    ["nshkr-ai-infra"]="AI Infrastructure"
    ["nshkr-schema"]="Schema & Validation"
    ["nshkr-devtools"]="Developer Tools"
    ["nshkr-otp"]="OTP & Distributed"
    ["nshkr-testing"]="Testing & QA"
    ["nshkr-observability"]="Observability"
    ["nshkr-cloud"]="Cloud & Edge"
    ["nshkr-browser"]="Browser Integration"
    ["nshkr-data"]="Data & Databases"
    ["nshkr-security"]="Security"
    ["nshkr-research"]="Research"
    ["nshkr-utility"]="Utilities"
)

# Display order
CATEGORY_ORDER=(
    "nshkr-crucible"
    "nshkr-ingot"
    "nshkr-ai-agents"
    "nshkr-ai-sdk"
    "nshkr-ai-infra"
    "nshkr-schema"
    "nshkr-devtools"
    "nshkr-otp"
    "nshkr-testing"
    "nshkr-observability"
    "nshkr-cloud"
    "nshkr-browser"
    "nshkr-data"
    "nshkr-security"
    "nshkr-research"
    "nshkr-utility"
)

echo "Fetching repos from GitHub..."

# Fetch all public repos with topics from both accounts (handles pagination)
fetch_repos() {
    local owner=$1
    local type=$2  # "users" or "orgs"

    gh api --paginate "${type}/${owner}/repos?per_page=100&type=public" --jq '.[] | {
        name: .name,
        full_name: .full_name,
        html_url: .html_url,
        description: (.description // ""),
        stars: .stargazers_count,
        language: (.language // ""),
        topics: .topics,
        fork: .fork,
        archived: .archived,
        owner: .owner.login
    }' 2>/dev/null
}

# Combine repos from both sources
{
    fetch_repos "nshkrdotcom" "users"
    fetch_repos "North-Shore-AI" "orgs"
} | jq -s '
    # Deduplicate by name (prefer higher star count)
    group_by(.name) | map(sort_by(-.stars) | first) |

    # Filter out archived repos and forks
    map(select(
        (.topics | index("nshkr-archive") | not) and
        (.fork == false)
    )) |

    # Add category field based on nshkr-* topic
    map(. + {
        category: (
            .topics | map(select(startswith("nshkr-"))) | first // "uncategorized"
        )
    }) |

    # Sort by stars within each category
    sort_by(-.stars)
' > "$TMP_FILE"

# Check if anything changed
if [ -f "$DATA_FILE" ]; then
    new_digest=$(jq -r '.[] | "\(.name)=\(.stars)=\(.category)"' "$TMP_FILE" | sort)
    existing_digest=$(grep -E "^\s{4}stars:|^\s{4}category:|^\s{2}[a-zA-Z]" "$DATA_FILE" 2>/dev/null | \
        awk '
            /^  [a-zA-Z]/ { repo = $1; gsub(/:$/, "", repo) }
            /stars:/ { stars = $2 }
            /category:/ { cat = $2; print repo "=" stars "=" cat }
        ' | sort)

    if [ "$existing_digest" = "$new_digest" ]; then
        echo "No changes detected. Skipping update."
        exit 0
    fi
fi

echo "Generating Hugo data file..."

# Generate YAML header
cat > "$DATA_FILE" << 'HEADER'
# Auto-generated repository data with category-based organization
# Last updated: TIMESTAMP
# Do not edit manually - managed by scripts/sync_repos_to_hugo.sh
# Categories are controlled via GitHub topics (nshkr-*)
# Use scripts/MANAGE_REPO_TOPICS.sh to manage categories

HEADER

sed -i "s/TIMESTAMP/$(date -u +"%Y-%m-%dT%H:%M:%SZ")/" "$DATA_FILE"

# Generate categories section with weights for ordering
echo "categories:" >> "$DATA_FILE"
weight=0
for cat in "${CATEGORY_ORDER[@]}"; do
    cat_name="${CATEGORY_NAMES[$cat]}"
    echo "  ${cat}:" >> "$DATA_FILE"
    echo "    name: \"${cat_name}\"" >> "$DATA_FILE"
    echo "    slug: \"${cat}\"" >> "$DATA_FILE"
    echo "    weight: ${weight}" >> "$DATA_FILE"
    weight=$((weight + 1))
done
echo "  uncategorized:" >> "$DATA_FILE"
echo "    name: \"Other Projects\"" >> "$DATA_FILE"
echo "    slug: \"uncategorized\"" >> "$DATA_FILE"
echo "    weight: 999" >> "$DATA_FILE"
echo "" >> "$DATA_FILE"

# Generate repos section grouped by category
echo "repos:" >> "$DATA_FILE"

# Process each category
for cat in "${CATEGORY_ORDER[@]}" "uncategorized"; do
    repos_in_cat=$(jq -r --arg cat "$cat" '.[] | select(.category == $cat)' "$TMP_FILE")

    if [ -n "$repos_in_cat" ]; then
        # Process each repo to extract logo and generate YAML
        jq -r --arg cat "$cat" '
            .[] | select(.category == $cat) |
            "\(.name)|\(.owner)"
        ' "$TMP_FILE" | while IFS='|' read -r repo_name owner; do
            # Extract logo (copies file and returns path)
            logo_path=$(extract_logo "$repo_name" "$owner")

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
            ' "$TMP_FILE" >> "$DATA_FILE"
        done
    fi
done

# Summary
echo ""
echo "Sync complete!"
echo ""
echo "Summary:"
total=$(jq 'length' "$TMP_FILE")
echo "  Total repos: $total"
echo ""
echo "By category:"
for cat in "${CATEGORY_ORDER[@]}"; do
    count=$(jq --arg cat "$cat" '[.[] | select(.category == $cat)] | length' "$TMP_FILE")
    if [ "$count" -gt 0 ]; then
        echo "  ${CATEGORY_NAMES[$cat]}: $count"
    fi
done
uncat=$(jq '[.[] | select(.category == "uncategorized")] | length' "$TMP_FILE")
if [ "$uncat" -gt 0 ]; then
    echo "  Other Projects: $uncat"
fi

echo ""
echo "Top repos by stars:"
jq -r '.[:10] | .[] | "  \(.stars) \(.name)"' "$TMP_FILE"

echo ""
echo "Data written to: $DATA_FILE"
