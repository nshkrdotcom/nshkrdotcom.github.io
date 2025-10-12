# NSHkr.com - North Shore Hackerspace

## Project Overview
This is a Hugo static site for North Shore Hackerspace, Hawaii's premier technology innovation hub. The site showcases projects including ASKA security architecture and ChronoLedger blockchain, along with ElixirML metrics and GitHub projects.

## Recent Changes (October 12, 2025)
- Installed Hugo static site generator via Nix package system
- Cloned Hugo themes (mainroad and hugo-theme-shell) from Git repositories
- Added theme configuration to config.toml
- Created Hugo Server workflow running on port 5000 with 0.0.0.0 binding
- Configured deployment with autoscale target for static site hosting
- Verified site loads correctly with all features working
- **Homepage Redesign**: Complete overhaul of layouts/index.html with modern AI/ML infrastructure showcase
  - Created 6 custom SVG assets (neural-network, distributed-beam, code-lib, research-lab, ensemble-reliability, nshkr-logo)
  - Organized 50+ projects into 9 thematic sections (Crucible Framework, AI Infrastructure, Developer Tools, etc.)
  - Removed false production claims; replaced with accurate technical achievements
  - Added Hawaiian-inspired technical logo combining circuit patterns with traditional geometric designs
  - Integrated links to North-Shore-AI org and Hackaday hackerspace

## Project Architecture

### Technology Stack
- **Hugo**: v0.147.3+extended - Static site generator
- **Theme**: Mainroad (with custom layouts)
- **Content**: 140 pages, 368 static files
- **Languages**: HTML, CSS, JavaScript
- **Build System**: Hugo with minification enabled

### Directory Structure
```
.
├── archetypes/          # Content templates
├── content/            # Markdown content files
├── layouts/            # Custom Hugo layouts and templates
│   ├── _default/       # Default templates
│   ├── partials/       # Partial templates
│   └── shortcodes/     # Custom shortcodes
├── static/             # Static assets (images, PDFs, JSON APIs)
│   ├── api/           # JSON data files
│   ├── assets/        # Custom SVG logos and icons
│   ├── js/            # JavaScript files
│   └── [various PDFs and images]
├── themes/             # Hugo themes
│   ├── mainroad/      # Main theme in use
│   └── hugo-theme-shell/
├── config.toml         # Hugo configuration
└── public/            # Generated site (gitignored)
```

### Configuration
- **Base URL**: https://NSHkr.com/
- **Development Server**: 0.0.0.0:5000
- **Build Output**: public/ directory
- **Features**: Mermaid diagrams, RSS feeds, SEO optimization, minification with preserved HTML comments

### Workflow
- **Hugo Server**: Runs Hugo development server with live reload
  - Command: `hugo server --bind 0.0.0.0 --port 5000 --baseURL / --appendPort=false`
  - Port: 5000 (webview output)
  - Features: Fast render mode, automatic rebuilds on file changes

### Deployment Configuration
- **Target**: Autoscale
- **Build**: `hugo --minify` - Generates optimized static files to public/ directory
- **Run**: `npx serve public -l 5000` - Serves pre-built static files using production-ready server
- **Details**: 
  - Hugo builds the site into the public/ directory during deployment
  - The `serve` package provides a lightweight, production-ready static file server
  - Autoscale automatically scales based on traffic demands

## User Preferences
- None specified yet

## Development Notes
- The site uses custom layouts in addition to the mainroad theme
- Mermaid diagrams are enabled for interactive visualizations
- HTML comments are preserved for AI agent metadata
- Git submodules are used for theme management
- SEO features include sitemap, robots.txt, and metadata configuration
