# Deployment Guide

## Prerequisites

1. Cloudflare account (free)
2. GitHub account with a private repository for comments
3. GitHub Personal Access Token with `repo` scope

## Step 1: Deploy the Worker

### Option A: Using Wrangler CLI

1. Install Wrangler:
```bash
npm install -g wrangler
```

2. Login to Cloudflare:
```bash
wrangler login
```

3. Create `wrangler.toml`:
```toml
name = "comment-handler"
main = "worker.js"
compatibility_date = "2024-01-01"

[[kv_namespaces]]
binding = "COMMENTS_KV"
id = "YOUR_KV_NAMESPACE_ID"
```

4. Create KV namespace:
```bash
wrangler kv:namespace create "COMMENTS_KV"
```

5. Deploy:
```bash
wrangler publish
```

6. Set secrets:
```bash
wrangler secret put GITHUB_TOKEN
wrangler secret put GITHUB_REPO
```

### Option B: Using Cloudflare Dashboard

1. Go to [dash.cloudflare.com](https://dash.cloudflare.com)
2. Navigate to Workers & Pages
3. Create Application → Create Worker
4. Copy the contents of `worker.js`
5. Click "Save and Deploy"
6. Go to Settings → Variables
7. Add environment variables:
   - `GITHUB_TOKEN`: Your GitHub PAT
   - `GITHUB_REPO`: Format `owner/repo-name`
8. Go to Settings → Bindings
9. Add KV Namespace binding:
   - Variable name: `COMMENTS_KV`
   - Create new namespace called "comments-ratelimit"

## Step 2: Add to Your Site

1. Copy `client.js` to your static assets folder

2. On any page where you want comments, add:

```html
<!-- Where comments will appear -->
<div id="comments-container" 
     data-comments="true"
     data-endpoint="https://YOUR-WORKER.workers.dev">
</div>

<!-- Include the script -->
<script src="/path/to/client.js"></script>
```

Or manually initialize:

```html
<script>
document.addEventListener('DOMContentLoaded', () => {
  new CommentSystem({
    endpoint: 'https://YOUR-WORKER.workers.dev',
    containerId: 'my-comments'
  });
});
</script>
```

## Step 3: Moderation Workflow

1. Comments appear as issues in your private GitHub repo
2. Each issue has labels: `comment` and `pending-moderation`
3. To approve a comment:
   - Remove `pending-moderation` label
   - Add `approved` label
4. To reject: Simply close the issue

## Step 4: Display Approved Comments (Optional)

Create a GitHub Action to build approved comments into your site:

```yaml
name: Build Comments
on:
  issues:
    types: [labeled, unlabeled, closed]

jobs:
  build-comments:
    if: github.event.label.name == 'approved'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Fetch approved comments
        run: |
          gh api repos/${{ github.repository }}/issues \
            --jq '.[] | select(.labels[].name == "approved") | 
            {author: .title, body: .body, created: .created_at}' \
            > data/comments.json
            
      - name: Commit comments
        run: |
          git config user.name "GitHub Actions"
          git config user.email "actions@github.com"
          git add data/comments.json
          git commit -m "Update approved comments" || exit 0
          git push
```

## Security Notes

1. **Rate Limiting**: 5 submissions per hour per IP
2. **CORS**: Configured for your domain only
3. **Validation**: Basic input validation and spam detection
4. **Privacy**: No tracking, no cookies, minimal data collection

## Troubleshooting

### "Too many submissions" error
- Rate limit exceeded. Wait 1 hour.

### "Internal server error"
- Check Worker logs in Cloudflare dashboard
- Verify GitHub token has `repo` scope
- Ensure private repo exists

### Comments not appearing
- Check GitHub issues in your private repo
- Verify labels are correct
- Check Worker metrics for errors