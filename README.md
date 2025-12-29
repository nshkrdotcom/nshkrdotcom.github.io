# NSHkr.com

Hugo-based portfolio site showcasing 89+ open-source repositories from [nshkrdotcom](https://github.com/nshkrdotcom) and [North-Shore-AI](https://github.com/North-Shore-AI).

**Live site:** https://nshkr.com

## How It Works

```
GitHub Repos (nshkrdotcom + North-Shore-AI)
    │
    │  GitHub Actions (every 12 hours)
    ▼
┌─────────────────────────────────────┐
│  scripts/sync_repos_to_hugo.sh      │
│  - Fetches repos via GitHub API     │
│  - Filters by nshkr-* topics        │
│  - Generates data/repos.yml         │
└─────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────┐
│  Hugo Build                         │
│  - Reads data/repos.yml             │
│  - Renders layouts/index.html       │
│  - Outputs to public/               │
└─────────────────────────────────────┘
    │
    ▼
GitHub Pages → https://nshkr.com
```

### Categorization System

Repos are categorized using GitHub topics with the `nshkr-` prefix:
- `nshkr-crucible` → Crucible Framework
- `nshkr-distributed` → Distributed Systems
- `nshkr-ml` → Machine Learning
- etc.

Repos with `nshkr-archive` topic are hidden from the site.

Use `scripts/MANAGE_REPO_TOPICS.sh` to manage topics on your repos.

### Category Display Order

Categories are displayed in order by weight (defined in `sync_repos_to_hugo.sh`). Within each category, repos are sorted by star count descending.

### Logo Extraction

The sync script also extracts logos from local repo clones:
- Parses each repo's `README.md` for images in `assets/` or `logo/` directories
- Falls back to standard filenames like `{repo}.svg`, `{repo}_logo.svg`
- Copies found logos to `static/logos/{repo}.svg`

**Note:** Requires repos cloned locally at `~/p/g/n/` (nshkrdotcom) and `~/p/g/North-Shore-AI/`. Logos won't be extracted in CI unless those paths exist.

## Local Development

### Prerequisites

- [Hugo](https://gohugo.io/installation/) (extended version)
- [GitHub CLI](https://cli.github.com/) (`gh`) - for syncing repos
- [jq](https://stedolan.github.io/jq/) - JSON processor

```bash
# Ubuntu/Debian
sudo apt install hugo gh jq
gh auth login

# macOS
brew install hugo gh jq
gh auth login
```

### Clone

Set up SSH config for multiple GitHub accounts (if needed):

```
# ~/.ssh/config
Host github-nshkrdotcom
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_rsa_nshkrdotcom
    IdentitiesOnly yes
```

Clone with submodules:

```bash
git clone --recurse-submodules -j8 git@github-nshkrdotcom:nshkrdotcom/nshkrdotcom.github.io.git
cd nshkrdotcom.github.io
```

### Run Locally

```bash
# Sync latest repo data (optional)
./scripts/sync_repos_to_hugo.sh

# Start dev server
hugo server

# Build for production
hugo --minify
```

## CI/CD Pipeline

`.github/workflows/sync-and-deploy.yml` runs automatically:

| Trigger | Action |
|---------|--------|
| Every 12 hours | Sync repos from GitHub, rebuild, deploy |
| Push to main | Rebuild and deploy |
| Manual dispatch | Sync + rebuild + deploy |

### Jobs

1. **Sync** - Runs `sync_repos_to_hugo.sh`, commits if data changed
2. **Build** - Hugo builds with `--minify`
3. **Deploy** - Pushes to GitHub Pages

## Key Files

| File | Purpose |
|------|---------|
| `data/repos.yml` | Auto-generated repo data (don't edit manually) |
| `layouts/index.html` | Homepage template |
| `scripts/sync_repos_to_hugo.sh` | Fetches repos from GitHub API |
| `scripts/MANAGE_REPO_TOPICS.sh` | Interactive tool to manage repo topics |
| `config.toml` | Hugo configuration |

## Adding/Updating Repos

1. Create or update your repo on GitHub
2. Add appropriate `nshkr-*` topic to categorize it
3. Wait for the next sync (12 hours) or manually trigger the workflow
4. Or run locally: `./scripts/sync_repos_to_hugo.sh && git commit && git push`

## Theme

Uses the [mainroad](https://github.com/Vimux/Mainroad) theme as a submodule with custom homepage template override.

## License

MIT
