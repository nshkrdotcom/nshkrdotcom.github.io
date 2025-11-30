#!/bin/bash

# INTERACTIVE REPOSITORY TOPIC MANAGEMENT
# Manages nshkr-* category topics for site organization
#
# Categories:
#   nshkr-crucible      - Crucible Framework
#   nshkr-ai-agents     - AI Agent Orchestration
#   nshkr-ai-sdk        - AI SDKs & API Clients
#   nshkr-ai-infra      - AI Infrastructure
#   nshkr-schema        - Schema & Validation
#   nshkr-devtools      - Developer Tools
#   nshkr-otp           - OTP & Distributed
#   nshkr-testing       - Testing & QA
#   nshkr-observability - Observability
#   nshkr-cloud         - Cloud & Edge
#   nshkr-browser       - Browser Integration
#   nshkr-data          - Data & Databases
#   nshkr-security      - Security
#   nshkr-research      - Research
#   nshkr-utility       - Utilities
#   nshkr-archive       - Excluded from site

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m'

# All valid categories
CATEGORIES=(
    "nshkr-crucible"
    "nshkr-ai-agents"
    "nshkr-ai-sdk"
    "nshkr-ai-infra"
    "nshkr-schema"
    "nshkr-devtools"
    "nshkr-otp"
    "nshkr-testing"
    "nshkr-observability"
    "nshkr-cloud"
    "nshkr-browser"
    "nshkr-data"
    "nshkr-security"
    "nshkr-research"
    "nshkr-utility"
)

CATEGORY_NAMES=(
    "Crucible Framework"
    "AI Agent Orchestration"
    "AI SDKs & API Clients"
    "AI Infrastructure"
    "Schema & Validation"
    "Developer Tools"
    "OTP & Distributed"
    "Testing & QA"
    "Observability"
    "Cloud & Edge"
    "Browser Integration"
    "Data & Databases"
    "Security"
    "Research"
    "Utilities"
)

# Get current nshkr topic for a repo
get_repo_category() {
    local owner=$1
    local repo=$2
    gh api "repos/${owner}/${repo}/topics" --jq '.names[]' 2>/dev/null | grep -E '^nshkr-' | head -1
}

# Get all topics for a repo
get_repo_topics() {
    local owner=$1
    local repo=$2
    gh api "repos/${owner}/${repo}/topics" --jq '.names | join(", ")' 2>/dev/null
}

# Remove all nshkr-* topics from repo
remove_nshkr_topics() {
    local owner=$1
    local repo=$2

    local topics=$(gh api "repos/${owner}/${repo}/topics" --jq '.names[]' 2>/dev/null | grep -E '^nshkr-' || true)
    for topic in $topics; do
        gh repo edit "${owner}/${repo}" --remove-topic "${topic}" 2>/dev/null || true
    done
}

# Add a single nshkr topic (removes others first for exclusivity)
set_repo_category() {
    local owner=$1
    local repo=$2
    local category=$3

    # Remove existing nshkr topics
    remove_nshkr_topics "$owner" "$repo"

    # Add new topic
    gh repo edit "${owner}/${repo}" --add-topic "${category}" 2>/dev/null
}

# List all repos with their categories
list_all_repos() {
    echo -e "\n${BLUE}${BOLD}=== ALL REPOSITORIES ===${NC}\n"

    echo -e "${CYAN}nshkrdotcom repos:${NC}"
    for repo in $(gh api "users/nshkrdotcom/repos?per_page=100&type=public" --jq '.[].name' 2>/dev/null | sort); do
        local cat=$(get_repo_category "nshkrdotcom" "$repo")
        if [[ -z "$cat" ]]; then
            echo -e "  ${YELLOW}[uncategorized]${NC} $repo"
        elif [[ "$cat" == "nshkr-archive" ]]; then
            echo -e "  ${RED}[excluded]${NC} $repo"
        else
            echo -e "  ${GREEN}[$cat]${NC} $repo"
        fi
    done

    echo -e "\n${CYAN}North-Shore-AI repos:${NC}"
    for repo in $(gh api "orgs/North-Shore-AI/repos?per_page=100&type=public" --jq '.[].name' 2>/dev/null | sort); do
        local cat=$(get_repo_category "North-Shore-AI" "$repo")
        if [[ -z "$cat" ]]; then
            echo -e "  ${YELLOW}[uncategorized]${NC} $repo"
        elif [[ "$cat" == "nshkr-archive" ]]; then
            echo -e "  ${RED}[excluded]${NC} $repo"
        else
            echo -e "  ${GREEN}[$cat]${NC} $repo"
        fi
    done
}

# List repos by category
list_by_category() {
    local category=$1
    echo -e "\n${BLUE}${BOLD}=== $category ===${NC}\n"

    echo -e "${CYAN}nshkrdotcom:${NC}"
    gh api "users/nshkrdotcom/repos?per_page=100&type=public" --jq '.[].name' 2>/dev/null | while read repo; do
        local cat=$(get_repo_category "nshkrdotcom" "$repo")
        if [[ "$cat" == "$category" ]]; then
            echo "  $repo"
        fi
    done

    echo -e "\n${CYAN}North-Shore-AI:${NC}"
    gh api "orgs/North-Shore-AI/repos?per_page=100&type=public" --jq '.[].name' 2>/dev/null | while read repo; do
        local cat=$(get_repo_category "North-Shore-AI" "$repo")
        if [[ "$cat" == "$category" ]]; then
            echo "  $repo"
        fi
    done
}

# List excluded repos
list_excluded() {
    list_by_category "nshkr-archive"
}

# List uncategorized repos
list_uncategorized() {
    echo -e "\n${YELLOW}${BOLD}=== UNCATEGORIZED REPOS ===${NC}\n"
    echo -e "${CYAN}(These will appear in 'Other Projects' on the site)${NC}\n"

    local count=0

    echo -e "${CYAN}nshkrdotcom:${NC}"
    for repo in $(gh api "users/nshkrdotcom/repos?per_page=100&type=public" --jq '.[].name' 2>/dev/null | sort); do
        local cat=$(get_repo_category "nshkrdotcom" "$repo")
        if [[ -z "$cat" ]]; then
            echo "  $repo"
            ((count++))
        fi
    done

    echo -e "\n${CYAN}North-Shore-AI:${NC}"
    for repo in $(gh api "orgs/North-Shore-AI/repos?per_page=100&type=public" --jq '.[].name' 2>/dev/null | sort); do
        local cat=$(get_repo_category "North-Shore-AI" "$repo")
        if [[ -z "$cat" ]]; then
            echo "  $repo"
            ((count++))
        fi
    done

    echo -e "\n${YELLOW}Total uncategorized: $count${NC}"
}

# Toggle exclude status
toggle_exclude() {
    echo -e "\n${BLUE}${BOLD}=== TOGGLE EXCLUDE STATUS ===${NC}\n"

    read -p "Enter owner (nshkrdotcom or North-Shore-AI): " owner
    read -p "Enter repo name: " repo

    local current=$(get_repo_category "$owner" "$repo")

    if [[ "$current" == "nshkr-archive" ]]; then
        echo -e "\n${YELLOW}Repo is currently EXCLUDED. Remove exclude tag?${NC}"
        read -p "(y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            gh repo edit "${owner}/${repo}" --remove-topic "nshkr-archive" 2>/dev/null
            echo -e "${GREEN}Removed exclude tag. Repo will now appear as uncategorized.${NC}"
        fi
    else
        echo -e "\n${YELLOW}Current category: ${current:-uncategorized}${NC}"
        echo -e "${YELLOW}Add to exclude list? (will remove from site)${NC}"
        read -p "(y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            set_repo_category "$owner" "$repo" "nshkr-archive"
            echo -e "${GREEN}Added to exclude list.${NC}"
        fi
    fi
}

# Set category for repo
set_category() {
    echo -e "\n${BLUE}${BOLD}=== SET REPO CATEGORY ===${NC}\n"

    read -p "Enter owner (nshkrdotcom or North-Shore-AI): " owner
    read -p "Enter repo name: " repo

    local current=$(get_repo_category "$owner" "$repo")
    echo -e "\n${CYAN}Current category: ${current:-uncategorized}${NC}\n"

    echo "Available categories:"
    for i in "${!CATEGORIES[@]}"; do
        printf "  %2d. %-20s %s\n" $((i+1)) "${CATEGORIES[$i]}" "(${CATEGORY_NAMES[$i]})"
    done
    echo "   0. Remove category (uncategorized)"
    echo "  99. Cancel"

    echo ""
    read -p "Select category number: " choice

    if [[ "$choice" == "99" ]]; then
        echo "Cancelled."
        return
    elif [[ "$choice" == "0" ]]; then
        remove_nshkr_topics "$owner" "$repo"
        echo -e "${GREEN}Category removed. Repo is now uncategorized.${NC}"
    elif [[ "$choice" -ge 1 && "$choice" -le ${#CATEGORIES[@]} ]]; then
        local cat="${CATEGORIES[$((choice-1))]}"
        set_repo_category "$owner" "$repo" "$cat"
        echo -e "${GREEN}Category set to: $cat${NC}"
    else
        echo -e "${RED}Invalid selection.${NC}"
    fi
}

# View repo details
view_repo() {
    echo -e "\n${BLUE}${BOLD}=== VIEW REPO DETAILS ===${NC}\n"

    read -p "Enter owner (nshkrdotcom or North-Shore-AI): " owner
    read -p "Enter repo name: " repo

    echo ""
    local cat=$(get_repo_category "$owner" "$repo")
    local topics=$(get_repo_topics "$owner" "$repo")

    echo -e "${CYAN}Repository:${NC} ${owner}/${repo}"
    echo -e "${CYAN}Site Category:${NC} ${cat:-uncategorized}"
    echo -e "${CYAN}All Topics:${NC} ${topics:-none}"

    # Get more details
    gh api "repos/${owner}/${repo}" --jq '"Description: " + (.description // "none") + "\nStars: " + (.stargazers_count | tostring) + "\nLanguage: " + (.language // "none")' 2>/dev/null
}

# Batch set category
batch_set_category() {
    echo -e "\n${BLUE}${BOLD}=== BATCH SET CATEGORY ===${NC}\n"

    echo "Available categories:"
    for i in "${!CATEGORIES[@]}"; do
        printf "  %2d. %-20s %s\n" $((i+1)) "${CATEGORIES[$i]}" "(${CATEGORY_NAMES[$i]})"
    done
    echo ""
    read -p "Select category number: " choice

    if [[ "$choice" -lt 1 || "$choice" -gt ${#CATEGORIES[@]} ]]; then
        echo -e "${RED}Invalid selection.${NC}"
        return
    fi

    local cat="${CATEGORIES[$((choice-1))]}"
    echo -e "\n${CYAN}Setting category: $cat${NC}"
    echo "Enter repos (owner/repo format, one per line, empty line to finish):"

    while true; do
        read -p "> " entry
        [[ -z "$entry" ]] && break

        local owner=$(echo "$entry" | cut -d'/' -f1)
        local repo=$(echo "$entry" | cut -d'/' -f2)

        if [[ -n "$owner" && -n "$repo" ]]; then
            set_repo_category "$owner" "$repo" "$cat"
            echo -e "  ${GREEN}Set $entry -> $cat${NC}"
        else
            echo -e "  ${RED}Invalid format: $entry${NC}"
        fi
    done
}

# Main menu
main_menu() {
    while true; do
        echo -e "\n${MAGENTA}${BOLD}╔═══════════════════════════════════════════╗${NC}"
        echo -e "${MAGENTA}${BOLD}║     REPOSITORY TOPIC MANAGEMENT           ║${NC}"
        echo -e "${MAGENTA}${BOLD}╚═══════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${BOLD}EXCLUDE MANAGEMENT:${NC}"
        echo "  1. Toggle exclude status for a repo"
        echo "  2. List excluded repos"
        echo ""
        echo -e "${BOLD}CATEGORY MANAGEMENT:${NC}"
        echo "  3. Set/change category for a repo"
        echo "  4. Batch set category for multiple repos"
        echo "  5. View repo details"
        echo ""
        echo -e "${BOLD}LISTINGS:${NC}"
        echo "  6. List all repos with categories"
        echo "  7. List repos by category"
        echo "  8. List uncategorized repos"
        echo ""
        echo "  0. Exit"
        echo ""
        read -p "Select option: " choice

        case $choice in
            1) toggle_exclude ;;
            2) list_excluded ;;
            3) set_category ;;
            4) batch_set_category ;;
            5) view_repo ;;
            6) list_all_repos ;;
            7)
                echo ""
                echo "Select category to list:"
                for i in "${!CATEGORIES[@]}"; do
                    printf "  %2d. %s\n" $((i+1)) "${CATEGORIES[$i]}"
                done
                read -p "Category number: " cat_choice
                if [[ "$cat_choice" -ge 1 && "$cat_choice" -le ${#CATEGORIES[@]} ]]; then
                    list_by_category "${CATEGORIES[$((cat_choice-1))]}"
                fi
                ;;
            8) list_uncategorized ;;
            0)
                echo -e "\n${GREEN}Goodbye!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option${NC}"
                ;;
        esac

        echo ""
        read -p "Press Enter to continue..."
    done
}

# Run
main_menu
