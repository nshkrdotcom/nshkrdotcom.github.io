#!/bin/bash

# Sync all Elixir repos from GitHub to Hugo data file
# This script fetches ALL public Elixir repos and generates data/repos.yml

set -e

echo "🔄 Syncing all Elixir repositories to Hugo data..."

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
JSON_FILE="$SCRIPT_DIR/elixir_projects.json"
DATA_FILE="$PROJECT_DIR/data/repos.yml"

# Step 1: Fetch latest repo data
echo "📡 Fetching all Elixir repositories from GitHub..."
bash "$SCRIPT_DIR/get_elixir_projects.sh"

# Step 2: Compare star counts against the existing data file so we only rewrite when needed
new_digest=$(jq -r '.[] | "\(.title)=\(.stars)"' "$JSON_FILE" | sort)
existing_digest=""
if [ -f "$DATA_FILE" ]; then
  existing_digest=$(awk '
    /^  [^[:space:]][^:]*:/ {
      repo = $1
      sub(":$", "", repo)
      sub(/^[[:space:]]+/, "", repo)
    }
    /^[[:space:]]{4}stars:/ {
      print repo "=" $2
    }
  ' "$DATA_FILE" | sort)
fi

if [ -f "$DATA_FILE" ] && [ "$existing_digest" = "$new_digest" ]; then
  echo "✨ No star count changes detected. Skipping update."
  exit 0
fi

# Step 3: Backup existing data file (only when we're about to update)
if [ -f "$DATA_FILE" ]; then
  cp "$DATA_FILE" "$DATA_FILE.bak"
  echo "📋 Backup saved to $DATA_FILE.bak"
fi

# Step 4: Convert JSON to YAML format Hugo expects
echo "📝 Converting to Hugo YAML format..."

cat > "$DATA_FILE" << 'HEADER'
# Auto-updated repository data
# Last updated: TIMESTAMP
# Do not edit manually - this file is updated by scripts/sync_repos_to_hugo.sh
# Source: All public Elixir repos from nshkrdotcom and North-Shore-AI

repos:
HEADER

# Replace timestamp
sed -i "s/TIMESTAMP/$(date -u +"%Y-%m-%dT%H:%M:%SZ")/" "$DATA_FILE"

# Convert JSON to YAML entries
jq -r '.[] |
  "  " + .title + ":\n" +
  "    name: " + .title + "\n" +
  "    org: " + .owner_login + "\n" +
  "    stars: " + (.stars | tostring) + "\n" +
  "    description: \"" + .description + "\"\n" +
  (if .fork then "    fork: true\n" else "" end) +
  (if .archived then "    archived: true\n" else "" end) +
  (if .private then "    private: true\n" else "" end) +
  (if .license then "    license: \"" + .license + "\"\n" else "" end) +
  ""
' "$JSON_FILE" >> "$DATA_FILE"

echo "✅ Successfully synced $DATA_FILE with all Elixir repositories"

# Show summary
echo ""
echo "📊 Summary:"
TOTAL=$(jq 'length' "$JSON_FILE")
echo "  Total repos: $TOTAL"
NSHKR=$(jq '[.[] | select(.owner_login == "nshkrdotcom")] | length' "$JSON_FILE")
echo "  nshkrdotcom: $NSHKR"
NORTH=$(jq '[.[] | select(.owner_login == "North-Shore-AI")] | length' "$JSON_FILE")
echo "  North-Shore-AI: $NORTH"

echo ""
echo "⭐ Top 10 repositories by stars:"
jq -r '.[:10] | .[] | "  ★" + (.stars | tostring) + " " + .title' "$JSON_FILE"

echo ""
echo "🎉 Done! Run 'hugo' to rebuild the site with updated star counts."
