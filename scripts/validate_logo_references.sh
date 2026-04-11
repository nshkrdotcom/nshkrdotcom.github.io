#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

source "$PROJECT_DIR/scripts/sync_repos_to_hugo.sh"

validate_referenced_logo_assets "${DATA_FILE:-$PROJECT_DIR/data/repos.yml}"
echo "logo references validated"
