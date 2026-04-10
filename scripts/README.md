# Repository Sync Scripts

Automated scripts to fetch and sync all Elixir repositories from GitHub to Hugo data files.

## Overview

This directory contains scripts that automatically:
1. Fetch all public source repositories from `nshkrdotcom` and `North-Shore-AI`
2. Extract categories, metadata, and logo assets
3. Convert the result into Hugo-compatible YAML
4. Keep the deployed site in sync with GitHub changes

## Main Scripts

### `sync_repos_to_hugo.sh` ⭐ **USE THIS ONE**

**Primary automation script** - Fetches all repos and updates Hugo data file.

```bash
./scripts/sync_repos_to_hugo.sh
```

**What it does:**
- Fetches live repo metadata from GitHub with topics and default branches
- Resolves logos from remote `README.md` and `README.rst` references plus repo-tree fallbacks
- Writes `data/repos.yml` and content-addressed assets in `static/logos/`
- Prunes stale cached logos when source assets change or disappear
- Shows a summary by category and top repos by stars

**Quality gates:**
- `./tests/test_sync_repos_to_hugo.sh` validates cache stability, cache busting, stale-logo pruning, and `README.rst`/`docs/_static` parsing

**When to run:**
- Before deploying site updates
- After creating new repositories
- Weekly/monthly to keep star counts fresh

### `get_elixir_projects.sh`

Fetches all Elixir repositories from GitHub using GitHub CLI.

```bash
./scripts/get_elixir_projects.sh [--include-private]
```

**Output:** `scripts/elixir_projects.json` (comprehensive metadata)

**What it fetches:**
- All public Elixir repos from `nshkrdotcom` user
- All public Elixir repos from `North-Shore-AI` org
- Sorts by star count (descending)
- Includes: stars, description, license, topics, dates, etc.

### `list_elixir_projects.sh`

Pretty CLI display of fetched projects.

```bash
./scripts/list_elixir_projects.sh [--source-only] [--public-only] [--all]
```

**Examples:**
```bash
# Show all projects
./scripts/list_elixir_projects.sh

# Show only source repos (no forks)
./scripts/list_elixir_projects.sh --source-only

# Show only public repos
./scripts/list_elixir_projects.sh --public-only
```

### `update_hugo_data.sh` (Legacy)

Old script that updated YAML manually. **Replaced by `sync_repos_to_hugo.sh`** which auto-generates from GitHub.

## Data Flow

```
GitHub API
    ↓
sync_repos_to_hugo.sh → data/repos.yml + static/logos/{repo}-{sha12}.{ext}
    ↓
Hugo build → public/index.html
```

## Hugo Template Integration

The `layouts/index.html` template uses Hugo's data files:

```html
<div class="project-stars">⭐ {{ (index .Site.Data.repos.repos "json_remedy").stars }}</div>
```

Hugo reads from `data/repos.yml`:
```yaml
repos:
  json_remedy:
    name: json_remedy
    org: nshkrdotcom
    stars: 20
    description: "A practical, multi-layered JSON repair library..."
```

## Requirements

- **GitHub CLI** (`gh`) - Must be installed and authenticated
- **jq** - JSON processor for parsing GitHub API responses
- **Hugo** - Static site generator

Install on Ubuntu/Debian:
```bash
sudo apt install gh jq
gh auth login
```

## Workflow

### Regular Updates

```bash
# 1. Sync latest repo data from GitHub
cd /path/to/nshkrdotcom.github.io
./tests/test_sync_repos_to_hugo.sh
./scripts/sync_repos_to_hugo.sh

# 2. Rebuild Hugo site
hugo --minify

# 3. Preview locally (optional)
hugo server

# 4. Deploy (if happy with changes)
git add -A data/repos.yml static/logos
git commit -m "Sync repository data"
git push
```

### Automation with GitHub Actions

Automation lives in `.github/workflows/sync-and-deploy.yml` and supports:
- scheduled sync every 12 hours
- immediate sync via `repository_dispatch` from source repos
- manual `workflow_dispatch`
- push-triggered rebuilds for direct site changes

The workflow validates `scripts/sync_repos_to_hugo.sh` and runs `./tests/test_sync_repos_to_hugo.sh` before sync and build jobs.

## Troubleshooting

### "gh: command not found"
Install GitHub CLI:
```bash
# Ubuntu/Debian
sudo apt install gh

# macOS
brew install gh

# Then authenticate
gh auth login
```

### "jq: command not found"
Install jq:
```bash
# Ubuntu/Debian
sudo apt install jq

# macOS
brew install jq
```

### "Repository not found" or empty results
Ensure you're authenticated with GitHub CLI:
```bash
gh auth status
gh auth login  # if not authenticated
```

### Hugo build fails with "unmarshal of format"
Remove any `.bak` backup files from `data/` directory:
```bash
rm data/*.bak
```

## Statistics

As of last sync:
- **Total Repos:** 51 Elixir repositories
- **nshkrdotcom:** 38 repos
- **North-Shore-AI:** 13 repos
- **Top Repo:** json_remedy (★20)

## Files

- `get_elixir_projects.sh` - Fetch repos from GitHub API
- `sync_repos_to_hugo.sh` - Main sync script (JSON → YAML)
- `list_elixir_projects.sh` - Pretty CLI display
- `elixir_projects.json` - Cached GitHub data (auto-generated)
- `update_hugo_data.sh` - Legacy manual update script
- `../data/repos.yml` - Hugo data file (auto-generated)

## License

MIT - Same as parent repository
