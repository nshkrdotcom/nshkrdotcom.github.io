---
title: "Site Rebuild Complete: Live GitHub Projects & Modern Design"
date: 2025-07-06
draft: false
tags: ["announcement", "website", "github", "automation"]
summary: "Just rebuilt NSHkr.com with a dynamic sidebar that pulls live data from GitHub, automated updates via Actions, and a clean Hawaii-inspired design."
---

## Fresh Site Launch 

Finally got around to rebuilding the site from scratch. The old static pages were getting stale, so I built something that actually reflects what we're working on in real-time.

## What's Different

### **Dynamic GitHub Sidebar**

The biggest change is the left sidebar now pulls directly from GitHub:

- Shows our top 20 repos sorted by stars
- Live star counts displayed next to each project  
- Updates automatically every 6 hours via GitHub Actions
- Custom descriptions for each project (no more generic "GitHub repository")

Built a simple bash script (`update_sidebar.sh`) that fetches data using `gh` CLI and generates the Hugo partial. Clean, simple, works.

### **Modular Architecture** 

Broke everything into reusable components:
- Sidebar is now its own partial (`layouts/partials/sidebar.html`)
- Can be included anywhere with `{{ partial "sidebar.html" . }}`
- Styles are self-contained within the partial
- Easy to maintain and update

### **GitHub Actions Integration**

Set up automated updates without needing server-side cron:
```yaml
on:
  schedule:
    - cron: '0 */6 * * *'  # Every 6 hours
  workflow_dispatch:       # Manual trigger
```

The workflow:
1. Runs `get_top_repos.sh` to fetch latest repo data
2. Executes `update_sidebar.sh` to regenerate the sidebar
3. Commits changes if anything updated
4. Site rebuilds automatically

### **Visual Updates**

Kept the Hawaii-inspired design but made it cleaner:
- Deep ocean gradient background (#0a0f1c → #0fbcf9)
- Floating particle effects for subtle motion
- Golden accents (#ffa801) for important elements
- Smooth hover animations on project cards

### **Real Projects Front and Center**

No more placeholder content. The sidebar shows actual repositories:
- [json_remedy](https://github.com/nshkrdotcom/json_remedy) - 13 stars
- [GUARDRAIL](https://github.com/nshkrdotcom/GUARDRAIL) - 10 stars  
- [axon](https://github.com/nshkrdotcom/axon) - 10 stars
- Plus 17 more active projects

Each links directly to GitHub with star counts visible at a glance.

## Technical Details

### **The Update Script**

Simple but effective:
```bash
#!/bin/bash
repos_json=$(./get_top_repos.sh)
# Generate sidebar HTML with repo data
# Include star counts and descriptions
# Write to layouts/partials/sidebar.html
```

### **Manual Trigger**

Added a local script for manual updates:
```bash
gh workflow run update-sidebar.yml \
  --repo nshkrdotcom/nshkrdotcom.github.io
```

No need for PATs since `gh` is already authenticated locally.

### **Future-Proofed**

Left hooks in place for:
- Cross-repository triggers (disabled by default)
- Push-based updates 
- Star event webhooks

All commented out but ready if needed.

## What's Working

- Sidebar updates automatically show new repos and star changes
- Zero maintenance required after initial setup
- GitHub Actions handles everything
- Site stays fresh without manual intervention

## Next Steps

Working on:
- Better mobile layout for the project list
- Adding language badges to each repo
- Maybe pull in latest commit info
- Considering adding download/fork counts

The new setup makes it trivial to add more dynamic content. Everything's modular, automated, and pulling from a single source of truth: GitHub.

Check out the [live site](/) to see it in action. The code's all there if you want to build something similar.

---

*Building what we need, when we need it, from the North Shore.*