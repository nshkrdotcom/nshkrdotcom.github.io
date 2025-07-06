#!/bin/bash

# Script to manually trigger sidebar update on nshkrdotcom.github.io
# Uses gh CLI (already authenticated) to trigger the workflow

# Usage: ./trigger-sidebar-update.sh [REPO_NAME]
# Example: ./trigger-sidebar-update.sh "json_remedy"
# Or just: ./trigger-sidebar-update.sh (to trigger a general update)

REPO_NAME=${1:-"manual-trigger"}

# Option 1: Trigger via workflow_dispatch (simplest, always works)
echo "Triggering sidebar update workflow..."
gh workflow run update-sidebar.yml \
  --repo nshkrdotcom/nshkrdotcom.github.io \
  --ref main

echo "✓ Workflow triggered successfully!"
echo "View run at: https://github.com/nshkrdotcom/nshkrdotcom.github.io/actions"

# Option 2: If you want to use repository_dispatch instead (requires enabling it)
# Uncomment the lines below and comment out Option 1 above
# NOTE: This requires uncommenting repository_dispatch in update-sidebar.yml
# or enabling cross-repo-trigger.yml

# echo "Triggering sidebar update for: $REPO_NAME"
# gh api \
#   --method POST \
#   repos/nshkrdotcom/nshkrdotcom.github.io/dispatches \
#   --field event_type="external-repo-updated" \
#   --field client_payload[repository]="$REPO_NAME" \
#   --field client_payload[event_type]="manual" \
#   --field client_payload[stars]="$(gh api repos/nshkrdotcom/$REPO_NAME --jq .stargazers_count 2>/dev/null || echo 0)"
# 
# echo "✓ Repository dispatch sent for $REPO_NAME"