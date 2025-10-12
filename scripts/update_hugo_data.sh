#!/bin/bash

# Update Hugo data file with latest GitHub star counts
# This script fetches star counts via GitHub CLI and updates data/repos.yml

set -e

echo "🔄 Fetching latest star counts from GitHub..."

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
DATA_FILE="$PROJECT_DIR/data/repos.yml"

# Backup the current data file
cp "$DATA_FILE" "$DATA_FILE.bak"

# Fetch all repos and create lookup tables
echo "📡 Fetching nshkrdotcom repositories..."
nshkr_data=$(gh api users/nshkrdotcom/repos --method GET --field per_page="100" --jq 'map({key: .name, value: .stargazers_count}) | from_entries')

echo "📡 Fetching North-Shore-AI repositories..."
north_shore_data=$(gh api users/North-Shore-AI/repos --method GET --field per_page="100" --jq 'map({key: .name, value: .stargazers_count}) | from_entries')

# Update the YAML file using awk
echo "📝 Updating star counts in $DATA_FILE..."

awk -v nshkr="$nshkr_data" -v north="$north_shore_data" '
BEGIN {
    # Parse JSON data into associative arrays (simplified approach)
    current_org = ""
    current_name = ""
}

# Match org line and remember it
/^[[:space:]]+org:/ {
    current_org = $2
    print
    next
}

# Match name line and remember it  
/^[[:space:]]+name:/ {
    current_name = $2
    print
    next
}

# Match stars line and update it
/^[[:space:]]+stars:/ {
    if (current_org != "" && current_name != "") {
        # Build the jq command to extract star count
        if (current_org == "nshkrdotcom") {
            cmd = "echo '\''" nshkr "'\'' | jq -r '\''.\"" current_name "\" // 0'\''"
        } else if (current_org == "North-Shore-AI") {
            cmd = "echo '\''" north "'\'' | jq -r '\''.\"" current_name "\" // 0'\''"
        }
        
        if (cmd != "") {
            cmd | getline stars
            close(cmd)
            print "    stars: " stars
            current_org = ""
            current_name = ""
            next
        }
    }
    print
    next
}

# Print all other lines as-is
{
    print
}
' "$DATA_FILE" > "$DATA_FILE.tmp"

# Replace original with updated file
mv "$DATA_FILE.tmp" "$DATA_FILE"

# Update the timestamp in the header
sed -i "2s/.*/# Last updated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")/" "$DATA_FILE"

echo "✅ Successfully updated $DATA_FILE with latest star counts"
echo "📋 Backup saved to $DATA_FILE.bak"

# Show summary
echo ""
echo "⭐ Top repositories by stars:"
grep -E "^[[:space:]]+stars: [1-9]" "$DATA_FILE" | sort -t: -k2 -rn | head -10
