#!/bin/bash

# This script reads the elixir_projects.json file, and for each project,
# it prints the content of the README file from the corresponding
# directory in ../../

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JSON_FILE="${SCRIPT_DIR}/elixir_projects.json"

# Calculate the parent directory (assuming repos are in ../../ relative to script location)
REPO_BASE_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"

jq -r '.[] | .title' "$JSON_FILE" | while read -r repo_name; do
  repo_path="${REPO_BASE_DIR}/$repo_name"
  if [ -d "$repo_path" ]; then
    readme_file=$(find "$repo_path" -maxdepth 1 -type f -name 'README*' | head -n 1)

    if [ -n "$readme_file" ]; then
      echo "--- README for $repo_name ---"
      cat "$readme_file"
      echo ""
    else
      echo "--- README not found for $repo_name in $repo_path ---"
    fi
  else
    echo "--- Directory not found for $repo_name at $repo_path ---"
  fi
done
