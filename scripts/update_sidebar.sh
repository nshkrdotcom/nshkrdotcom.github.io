#!/bin/bash

# Script to update the sidebar with GitHub repos from get_top_repos.sh
# This script fetches the top repos and generates the sidebar partial

# Define descriptions for known repositories
declare -A descriptions
descriptions["json_remedy"]="Industrial-strength JSON repair library"
descriptions["GUARDRAIL"]="Security framework for Elixir applications"
descriptions["axon"]="Neural network library for Elixir"
descriptions["ds_ex"]="Data structures for Elixir"
descriptions["ex_dbg"]="Enhanced debugging for Elixir"
descriptions["foundation"]="Core utilities and patterns"
descriptions["elixir_scope"]="Code analysis and scoping tools"
descriptions["gemini_ex"]="Gemini API client for Elixir"
descriptions["sinter"]="Static analysis framework"
descriptions["exdantic"]="Pydantic-inspired validation for Elixir"
descriptions["pqc-hqc"]="Post-quantum cryptography experiments"
descriptions["claude_code_sdk_elixir"]="Claude Code SDK for Elixir"
descriptions["pipeline_ex"]="Pipeline processing framework"
descriptions["digits_py"]="Digit manipulation utilities"
descriptions["cf_ex"]="CloudFlare API client for Elixir"
descriptions["AutoElixir"]="Code generation and automation"
descriptions["diagram_experiments"]="Diagram generation experiments"
descriptions["ChronoLedger"]="Temporal blockchain system"
descriptions["vscode-extensions"]="VS Code extension collection"
descriptions["ElixirScope"]="Elixir code intelligence"

# Get top repos
echo "Fetching top repositories..."
# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repos_json=$("$SCRIPT_DIR/get_top_repos.sh")

# Start building the sidebar HTML
cat > layouts/partials/sidebar.html << 'EOF'
<style>
/* Sidebar styles */
.sidebar {
    background: rgba(15, 20, 35, 0.6);
    backdrop-filter: blur(10px);
    border-right: 1px solid rgba(255, 255, 255, 0.1);
    padding: 30px;
    overflow-y: auto;
    overflow-x: hidden;
    scrollbar-width: thin;
    scrollbar-color: rgba(255, 255, 255, 0.2) transparent;
    position: relative;
    height: calc(100vh - 180px); /* Account for header and footer */
    z-index: 10; /* Above main content */
}

.sidebar::-webkit-scrollbar {
    width: 6px;
}

.sidebar::-webkit-scrollbar-track {
    background: transparent;
}

.sidebar::-webkit-scrollbar-thumb {
    background: rgba(255, 255, 255, 0.2);
    border-radius: 3px;
}

.project-list {
    list-style: none;
}

.project-item {
    margin-bottom: 20px;
    padding: 15px;
    background: rgba(255, 255, 255, 0.05);
    border-radius: 8px;
    cursor: pointer;
    transition: all 0.3s;
    border: 1px solid transparent;
    position: relative;
}

.project-item:hover {
    background: rgba(255, 255, 255, 0.1);
    border-color: #0fbcf9;
    transform: translateX(5px);
}

.project-item.active {
    background: rgba(15, 188, 249, 0.1);
    border-color: #0fbcf9;
}

.project-title {
    font-size: 18px;
    font-weight: 600;
    margin-bottom: 5px;
    color: #fff;
    display: flex;
    align-items: center;
    justify-content: space-between;
}

.project-desc {
    font-size: 14px;
    color: rgba(255, 255, 255, 0.7);
}

.star-count {
    font-size: 14px;
    color: #ffa801;
    display: flex;
    align-items: center;
    gap: 4px;
}

.star-icon {
    width: 16px;
    height: 16px;
}
</style>

<aside class="sidebar">
    <h3 style="color: #ffa801; margin-bottom: 20px;">GitHub Projects</h3>
    <ul class="project-list">
EOF

# Process each repository
echo "$repos_json" | jq -r '.[] | @base64' | while read -r repo_base64; do
    # Decode the repo data
    repo=$(echo "$repo_base64" | base64 -d)
    
    # Extract fields
    link=$(echo "$repo" | jq -r '.link')
    title=$(echo "$repo" | jq -r '.title')
    stars=$(echo "$repo" | jq -r '.stars')
    
    # Get description or use default
    desc="${descriptions[$title]:-"GitHub repository"}"
    
    # Special handling for specific repos to mark as active
    active_class=""
    if [[ "$title" == "GUARDRAIL" ]] || [[ "$title" == "ChronoLedger" ]]; then
        active_class=" active"
    fi
    
    # Write the HTML for this repo
    cat >> layouts/partials/sidebar.html << EOF
        <li class="project-item${active_class}">
            <a href="${link}" style="text-decoration: none; color: inherit; display: block;" target="_blank">
                <div class="project-title">
                    <span>${title}</span>
                    <span class="star-count">
                        <svg class="star-icon" fill="#ffa801" viewBox="0 0 16 16">
                            <path d="M8 0.25a.75.75 0 01.673.418l1.882 3.815 4.21.612a.75.75 0 01.416 1.279l-3.046 2.97.719 4.192a.75.75 0 01-1.088.791L8 12.347l-3.766 1.98a.75.75 0 01-1.088-.79l.72-4.194L.818 6.374a.75.75 0 01.416-1.28l4.21-.611L7.327.668A.75.75 0 018 .25z"/>
                        </svg>
                        ${stars}
                    </span>
                </div>
                <div class="project-desc">${desc}</div>
            </a>
        </li>
EOF
done

# Close the HTML
cat >> layouts/partials/sidebar.html << 'EOF'
    </ul>
</aside>
EOF

echo "Sidebar updated successfully!"
echo "Generated $(echo "$repos_json" | jq '. | length') repository entries"