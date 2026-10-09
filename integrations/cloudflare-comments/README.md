# Cloudflare Workers Comment System

A free, serverless solution for adding comments to your static site using Cloudflare Workers and GitHub as storage.

## Overview

This integration uses:
- **Cloudflare Workers** (Free tier: 100k requests/day)
- **GitHub API** to store comments as issues in a private repo
- **Pure JavaScript** on the frontend
- **No database required**

## Architecture

```
Static Site Form
    ↓ POST
Cloudflare Worker
    ↓ GitHub API
Private Comments Repo
    ↓ Manual Review
Approved → Build → Display
```

## Setup Instructions

### 1. Create a Private GitHub Repository

```bash
# Create a new private repo for comments
gh repo create nshkr-comments --private
```

### 2. Generate a GitHub Personal Access Token

1. Go to GitHub Settings → Developer settings → Personal access tokens
2. Create a token with `repo` scope
3. Save it securely

### 3. Deploy Cloudflare Worker

1. Sign up for free Cloudflare account
2. Go to Workers & Pages
3. Create new Worker
4. Deploy the worker code (see `worker.js`)

### 4. Configure Secrets

In Cloudflare dashboard:
```bash
wrangler secret put GITHUB_TOKEN
wrangler secret put GITHUB_REPO  # format: owner/repo
```

### 5. Add to Your Site

Include the client script (see `client.js`) on any page where you want comments.

## Features

- **Spam Protection**: Rate limiting + basic content filtering
- **Moderation**: All comments go to GitHub issues for review
- **Privacy**: No cookies, no tracking
- **Free**: Uses free tiers only
- **Simple**: ~100 lines of code total

## Cost

- **Cloudflare Workers**: Free (100k requests/day)
- **GitHub**: Free (private repos included)
- **Total**: $0/month

## Limits

- 100k comment submissions per day
- 10MB worker size
- 50ms CPU time per request
- GitHub API: 5000 requests/hour

For most sites, these limits are more than sufficient.