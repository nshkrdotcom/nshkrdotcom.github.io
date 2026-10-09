#!/bin/bash

# INTERACTIVE REPOSITORY TOPIC MANAGEMENT
# Manages nshkr-* category topics for site organization using the shared
# category config in config/nshkr_categories.json.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CATEGORY_CONFIG="$PROJECT_DIR/config/nshkr_categories.json"

source "$PROJECT_DIR/scripts/lib/nshkr_categories.sh"
nshkr_load_category_config "$CATEGORY_CONFIG"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m'

MENU_CATEGORIES=()

list_account_repos() {
    local owner=$1
    local endpoint

    if [[ "$owner" == "nshkrdotcom" ]]; then
        endpoint="users/${owner}/repos?per_page=100&type=public"
    else
        endpoint="orgs/${owner}/repos?per_page=100&type=public"
    fi

    gh api --paginate "$endpoint" --jq '.[].name' 2>/dev/null | sort
}

fetch_all_category_topics() {
    {
        gh api --paginate "users/nshkrdotcom/repos?per_page=100&type=public"
        gh api --paginate "orgs/North-Shore-AI/repos?per_page=100&type=public"
    } | jq -r --arg archive "$NSHKR_ARCHIVE_SLUG" '
        .[] |
        (.topics // [])[] |
        select(startswith("nshkr-") and . != $archive)
    ' 2>/dev/null | sort -u
}

build_category_menu() {
    local include_archive="${1:-false}"
    local -a discovered_categories=()

    mapfile -t discovered_categories < <(fetch_all_category_topics)
    mapfile -t MENU_CATEGORIES < <(printf '%s\n' "${discovered_categories[@]}" | nshkr_build_ordered_topics)

    if [[ "$include_archive" == "true" ]]; then
        MENU_CATEGORIES+=("$NSHKR_ARCHIVE_SLUG")
    fi
}

print_category_options() {
    local include_archive="${1:-false}"
    local index
    local category

    build_category_menu "$include_archive"

    for index in "${!MENU_CATEGORIES[@]}"; do
        category="${MENU_CATEGORIES[$index]}"
        printf "  %2d. %-24s (%s)\n" $((index + 1)) "$category" "$(nshkr_display_name_for_topic "$category")"
    done
}

get_repo_category() {
    local owner=$1
    local repo=$2
    local topics

    topics=$(gh api "repos/${owner}/${repo}/topics" --jq '.names[]' 2>/dev/null | grep -E '^nshkr-' || true)

    if printf '%s\n' "$topics" | grep -qx "$NSHKR_ARCHIVE_SLUG"; then
        echo "$NSHKR_ARCHIVE_SLUG"
        return
    fi

    printf '%s\n' "$topics" | grep -v "^${NSHKR_ARCHIVE_SLUG}\$" | sort | head -1 || true
}

get_repo_topics() {
    local owner=$1
    local repo=$2

    gh api "repos/${owner}/${repo}/topics" --jq '.names | join(", ")' 2>/dev/null
}

remove_nshkr_topics() {
    local owner=$1
    local repo=$2
    local topics

    topics=$(gh api "repos/${owner}/${repo}/topics" --jq '.names[]' 2>/dev/null | grep -E '^nshkr-' || true)
    for topic in $topics; do
        gh repo edit "${owner}/${repo}" --remove-topic "${topic}" 2>/dev/null || true
    done
}

set_repo_category() {
    local owner=$1
    local repo=$2
    local category=$3

    remove_nshkr_topics "$owner" "$repo"
    gh repo edit "${owner}/${repo}" --add-topic "${category}" 2>/dev/null
}

prompt_custom_category() {
    local raw
    local category

    read -p "Enter custom category (with or without nshkr- prefix): " raw
    category=$(nshkr_normalize_topic_slug "$raw")

    if [[ -z "$category" ]] || ! nshkr_valid_category_slug "$category"; then
        echo -e "${RED}Invalid category. Use letters, numbers, and hyphens only.${NC}"
        return 1
    fi

    if [[ "$category" == "$NSHKR_ARCHIVE_SLUG" ]]; then
        echo -e "${RED}Use exclude mode for ${NSHKR_ARCHIVE_SLUG}.${NC}"
        return 1
    fi

    printf '%s\n' "$category"
}

list_all_repos() {
    local repo
    local cat

    echo -e "\n${BLUE}${BOLD}=== ALL REPOSITORIES ===${NC}\n"

    echo -e "${CYAN}nshkrdotcom repos:${NC}"
    while IFS= read -r repo; do
        cat=$(get_repo_category "nshkrdotcom" "$repo")
        if [[ -z "$cat" ]]; then
            echo -e "  ${YELLOW}[${NSHKR_UNCATEGORIZED_SLUG}]${NC} $repo"
        elif [[ "$cat" == "$NSHKR_ARCHIVE_SLUG" ]]; then
            echo -e "  ${RED}[excluded]${NC} $repo"
        else
            echo -e "  ${GREEN}[$cat]${NC} $repo"
        fi
    done < <(list_account_repos "nshkrdotcom")

    echo -e "\n${CYAN}North-Shore-AI repos:${NC}"
    while IFS= read -r repo; do
        cat=$(get_repo_category "North-Shore-AI" "$repo")
        if [[ -z "$cat" ]]; then
            echo -e "  ${YELLOW}[${NSHKR_UNCATEGORIZED_SLUG}]${NC} $repo"
        elif [[ "$cat" == "$NSHKR_ARCHIVE_SLUG" ]]; then
            echo -e "  ${RED}[excluded]${NC} $repo"
        else
            echo -e "  ${GREEN}[$cat]${NC} $repo"
        fi
    done < <(list_account_repos "North-Shore-AI")
}

list_by_category() {
    local category=$1
    local repo
    local cat

    echo -e "\n${BLUE}${BOLD}=== $category ===${NC}"
    echo -e "${CYAN}($(nshkr_display_name_for_topic "$category"))${NC}\n"

    echo -e "${CYAN}nshkrdotcom:${NC}"
    while IFS= read -r repo; do
        cat=$(get_repo_category "nshkrdotcom" "$repo")
        if [[ "$cat" == "$category" ]]; then
            echo "  $repo"
        fi
    done < <(list_account_repos "nshkrdotcom")

    echo -e "\n${CYAN}North-Shore-AI:${NC}"
    while IFS= read -r repo; do
        cat=$(get_repo_category "North-Shore-AI" "$repo")
        if [[ "$cat" == "$category" ]]; then
            echo "  $repo"
        fi
    done < <(list_account_repos "North-Shore-AI")
}

list_excluded() {
    list_by_category "$NSHKR_ARCHIVE_SLUG"
}

list_uncategorized() {
    local repo
    local cat
    local count=0

    echo -e "\n${YELLOW}${BOLD}=== UNCATEGORIZED REPOS ===${NC}\n"
    echo -e "${CYAN}(These will appear in '${NSHKR_UNCATEGORIZED_NAME}' on the site)${NC}\n"

    echo -e "${CYAN}nshkrdotcom:${NC}"
    while IFS= read -r repo; do
        cat=$(get_repo_category "nshkrdotcom" "$repo")
        if [[ -z "$cat" ]]; then
            echo "  $repo"
            ((count++))
        fi
    done < <(list_account_repos "nshkrdotcom")

    echo -e "\n${CYAN}North-Shore-AI:${NC}"
    while IFS= read -r repo; do
        cat=$(get_repo_category "North-Shore-AI" "$repo")
        if [[ -z "$cat" ]]; then
            echo "  $repo"
            ((count++))
        fi
    done < <(list_account_repos "North-Shore-AI")

    echo -e "\n${YELLOW}Total uncategorized: $count${NC}"
}

toggle_exclude() {
    local owner
    local repo
    local current

    echo -e "\n${BLUE}${BOLD}=== TOGGLE EXCLUDE STATUS ===${NC}\n"

    read -p "Enter owner (nshkrdotcom or North-Shore-AI): " owner
    read -p "Enter repo name: " repo

    current=$(get_repo_category "$owner" "$repo")

    if [[ "$current" == "$NSHKR_ARCHIVE_SLUG" ]]; then
        echo -e "\n${YELLOW}Repo is currently EXCLUDED. Remove archive tag?${NC}"
        read -p "(y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            gh repo edit "${owner}/${repo}" --remove-topic "$NSHKR_ARCHIVE_SLUG" 2>/dev/null
            echo -e "${GREEN}Removed archive tag. Repo will now appear as ${NSHKR_UNCATEGORIZED_NAME}.${NC}"
        fi
    else
        echo -e "\n${YELLOW}Current category: ${current:-$NSHKR_UNCATEGORIZED_SLUG}${NC}"
        echo -e "${YELLOW}Add to archive list? (will remove from site)${NC}"
        read -p "(y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            set_repo_category "$owner" "$repo" "$NSHKR_ARCHIVE_SLUG"
            echo -e "${GREEN}Added to archive list.${NC}"
        fi
    fi
}

set_category() {
    local owner
    local repo
    local current
    local choice
    local cat

    echo -e "\n${BLUE}${BOLD}=== SET REPO CATEGORY ===${NC}\n"

    read -p "Enter owner (nshkrdotcom or North-Shore-AI): " owner
    read -p "Enter repo name: " repo

    current=$(get_repo_category "$owner" "$repo")
    echo -e "\n${CYAN}Current category: ${current:-$NSHKR_UNCATEGORIZED_SLUG}${NC}\n"

    echo "Available categories:"
    print_category_options false
    echo "   c. Enter custom category"
    echo "   0. Remove category (${NSHKR_UNCATEGORIZED_SLUG})"
    echo "  99. Cancel"
    echo ""

    read -p "Select category number: " choice

    if [[ "$choice" == "99" ]]; then
        echo "Cancelled."
        return
    elif [[ "$choice" == "0" ]]; then
        remove_nshkr_topics "$owner" "$repo"
        echo -e "${GREEN}Category removed. Repo is now ${NSHKR_UNCATEGORIZED_SLUG}.${NC}"
    elif [[ "$choice" == "c" || "$choice" == "C" ]]; then
        cat=$(prompt_custom_category) || return
        set_repo_category "$owner" "$repo" "$cat"
        echo -e "${GREEN}Category set to: $cat${NC}"
    elif [[ "$choice" =~ ^[0-9]+$ && "$choice" -ge 1 && "$choice" -le ${#MENU_CATEGORIES[@]} ]]; then
        cat="${MENU_CATEGORIES[$((choice-1))]}"
        set_repo_category "$owner" "$repo" "$cat"
        echo -e "${GREEN}Category set to: $cat${NC}"
    else
        echo -e "${RED}Invalid selection.${NC}"
    fi
}

view_repo() {
    local owner
    local repo
    local cat
    local topics

    echo -e "\n${BLUE}${BOLD}=== VIEW REPO DETAILS ===${NC}\n"

    read -p "Enter owner (nshkrdotcom or North-Shore-AI): " owner
    read -p "Enter repo name: " repo

    echo ""
    cat=$(get_repo_category "$owner" "$repo")
    topics=$(get_repo_topics "$owner" "$repo")

    echo -e "${CYAN}Repository:${NC} ${owner}/${repo}"
    if [[ -n "$cat" ]]; then
        echo -e "${CYAN}Site Category:${NC} ${cat} ($(nshkr_display_name_for_topic "$cat"))"
    else
        echo -e "${CYAN}Site Category:${NC} ${NSHKR_UNCATEGORIZED_SLUG}"
    fi
    echo -e "${CYAN}All Topics:${NC} ${topics:-none}"

    gh api "repos/${owner}/${repo}" --jq '"Description: " + (.description // "none") + "\nStars: " + (.stargazers_count | tostring) + "\nLanguage: " + (.language // "none")' 2>/dev/null
}

batch_set_category() {
    local choice
    local cat
    local entry
    local owner
    local repo

    echo -e "\n${BLUE}${BOLD}=== BATCH SET CATEGORY ===${NC}\n"

    echo "Available categories:"
    print_category_options false
    echo "   c. Enter custom category"
    echo ""

    read -p "Select category number: " choice

    if [[ "$choice" == "c" || "$choice" == "C" ]]; then
        cat=$(prompt_custom_category) || return
    elif [[ "$choice" =~ ^[0-9]+$ && "$choice" -ge 1 && "$choice" -le ${#MENU_CATEGORIES[@]} ]]; then
        cat="${MENU_CATEGORIES[$((choice-1))]}"
    else
        echo -e "${RED}Invalid selection.${NC}"
        return
    fi

    echo -e "\n${CYAN}Setting category: $cat${NC}"
    echo "Enter repos (owner/repo format, one per line, empty line to finish):"

    while true; do
        read -p "> " entry
        [[ -z "$entry" ]] && break

        owner=$(echo "$entry" | cut -d'/' -f1)
        repo=$(echo "$entry" | cut -d'/' -f2)

        if [[ -n "$owner" && -n "$repo" ]]; then
            set_repo_category "$owner" "$repo" "$cat"
            echo -e "  ${GREEN}Set $entry -> $cat${NC}"
        else
            echo -e "  ${RED}Invalid format: $entry${NC}"
        fi
    done
}

main_menu() {
    local choice
    local cat_choice

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
                print_category_options true
                read -p "Category number: " cat_choice
                if [[ "$cat_choice" =~ ^[0-9]+$ && "$cat_choice" -ge 1 && "$cat_choice" -le ${#MENU_CATEGORIES[@]} ]]; then
                    list_by_category "${MENU_CATEGORIES[$((cat_choice-1))]}"
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

main_menu
