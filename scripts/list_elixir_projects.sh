#!/bin/bash

# List Elixir projects in a friendly CLI format
# Usage: list_elixir_projects.sh [--source-only] [--public-only] [--all]
# Filters: source repos only (not forks), public repos only, or all repos

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JSON_FILE="${SCRIPT_DIR}/elixir_projects.json"

if [ ! -f "$JSON_FILE" ]; then
  echo "Error: $JSON_FILE not found"
  echo "Run get_elixir_projects.sh first to generate the project list"
  exit 1
fi

# Parse flags
SOURCE_ONLY=false
PUBLIC_ONLY=false
SHOW_ALL=false

for arg in "$@"; do
  case $arg in
    --source-only)
      SOURCE_ONLY=true
      ;;
    --public-only)
      PUBLIC_ONLY=true
      ;;
    --all)
      SHOW_ALL=true
      ;;
    *)
      echo "Unknown option: $arg"
      echo "Usage: $0 [--source-only] [--public-only] [--all]"
      exit 1
      ;;
  esac
done

# Build jq filter
JQ_FILTER=".[]"
if [ "$SOURCE_ONLY" = true ]; then
  JQ_FILTER="$JQ_FILTER | select(.fork == false)"
fi
if [ "$PUBLIC_ONLY" = true ]; then
  JQ_FILTER="$JQ_FILTER | select(.private == false)"
fi

# Build title based on filters
TITLE="ELIXIR PROJECTS"
if [ "$SOURCE_ONLY" = true ] || [ "$PUBLIC_ONLY" = true ]; then
  FILTERS=""
  [ "$SOURCE_ONLY" = true ] && FILTERS="${FILTERS}Source "
  [ "$PUBLIC_ONLY" = true ] && FILTERS="${FILTERS}Public "
  TITLE="ELIXIR PROJECTS (${FILTERS}Only)"
fi

echo "════════════════════════════════════════════════════════════════════════════════"
echo "                         $TITLE"
echo "════════════════════════════════════════════════════════════════════════════════"

# One-line format: ★12 repo_name [MIT] [F] [A] - Short description (truncated to 60 chars)
jq -r "$JQ_FILTER |
  (\"\u001b[1;36m★\" + (.stars | tostring | if length == 1 then \" \" + . else . end) + \"\u001b[0m\") +
  \" \u001b[1;33m\" + (.title | if length > 20 then .[0:20] + \"…\" else . + (\" \" * (21 - length)) end) + \"\u001b[0m\" +
  \" \u001b[2m[\" + (if .license then (.license | split(\" \") | .[0]) else \"None\" end) + \"]\u001b[0m\" +
  (if .fork then \" \u001b[33m[Fork]\u001b[0m\" else \"\" end) +
  (if .archived then \" \u001b[31m[Archived]\u001b[0m\" else \"\" end) +
  (if .private then \" \u001b[35m[Private]\u001b[0m\" else \"\" end) +
  \" - \" +
  (\"\u001b[2m\" + (if (.description | length) > 70 then (.description[0:70] + \"…\") else .description end) + \"\u001b[0m\")" "$JSON_FILE"

echo "════════════════════════════════════════════════════════════════════════════════"
TOTAL=$(jq "[$JQ_FILTER] | length" "$JSON_FILE")
echo "Total: $TOTAL projects"
echo "════════════════════════════════════════════════════════════════════════════════"
