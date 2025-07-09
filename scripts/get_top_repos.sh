#!/bin/bash

# Get top 10 repos by stars for nshkrdotcom using GitHub CLI
# Output format: JSON with link and title

# Get repos for user nshkrdotcom sorted by stars
gh api users/nshkrdotcom/repos \
  --method GET \
  --field per_page="100" \
  --field sort="updated" \
  --jq 'sort_by(.stargazers_count) | reverse | .[0:20] | map({
    "link": .html_url,
    "title": .name,
    "stars": .stargazers_count
  })'
