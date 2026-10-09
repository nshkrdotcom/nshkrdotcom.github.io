#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
DATA_FILE="${DATA_FILE:-$PROJECT_DIR/data/repos.yml}"
LOOKBACK_MINUTES="${LOOKBACK_MINUTES:-15}"

is_relevant_path() {
    local path=$1

    [[ "$path" =~ ^README($|\.) ]] || \
    [[ "$path" =~ ^assets/ ]] || \
    [[ "$path" =~ ^logo/ ]] || \
    [[ "$path" =~ ^logos/ ]] || \
    [[ "$path" =~ ^static/ ]] || \
    [[ "$path" =~ ^docs/.*\.(svg|png|jpe?g|webp|gif)$ ]]
}

compute_cutoff_iso() {
    python3 - "$DATA_FILE" "$LOOKBACK_MINUTES" <<'PY'
from datetime import datetime, timedelta, timezone
from pathlib import Path
import sys

data_file = Path(sys.argv[1])
lookback_minutes = int(sys.argv[2])
now = datetime.now(timezone.utc)
fallback = now - timedelta(minutes=lookback_minutes)
cutoff = fallback

if data_file.exists():
    for line in data_file.read_text().splitlines():
        if line.startswith("# Last updated:"):
            raw = line.split(":", 1)[1].strip()
            try:
                parsed = datetime.fromisoformat(raw.replace("Z", "+00:00"))
            except ValueError:
                break
            cutoff = max(parsed.astimezone(timezone.utc), fallback)
            break

print(cutoff.isoformat(timespec="seconds").replace("+00:00", "Z"))
PY
}

fetch_recent_push_events() {
    local cutoff_iso=$1

    {
        gh api --paginate "users/nshkrdotcom/events/public?per_page=100"
        gh api --paginate "orgs/North-Shore-AI/events?per_page=100"
    } | jq -r --arg cutoff "$cutoff_iso" '
        .[]? |
        select(.type == "PushEvent" and .created_at >= $cutoff) |
        [
            .repo.name,
            (.payload.before // ""),
            (.payload.head // ""),
            (.created_at // ""),
            (.payload.ref // "")
        ] | @tsv
    '
}

main() {
    local cutoff_iso=""
    local full_name=""
    local before=""
    local head=""
    local created_at=""
    local ref=""
    local key=""
    local default_branch=""
    local compare_payload=""
    local summary=""
    local should_sync=false
    local reasons_json='[]'
    declare -A seen=()
    declare -A default_branches=()
    declare -a reasons=()

    cutoff_iso=$(compute_cutoff_iso)

    while IFS=$'\t' read -r full_name before head created_at ref; do
        [[ -n "$full_name" ]] || continue

        key="${full_name}|${before}|${head}"
        if [[ -n "${seen[$key]+x}" ]]; then
            continue
        fi
        seen["$key"]=1

        default_branch="${default_branches[$full_name]:-}"
        if [[ -z "$default_branch" ]]; then
            default_branch=$(gh api "repos/${full_name}" --jq '.default_branch' 2>/dev/null || true)
            default_branches["$full_name"]="$default_branch"
        fi

        if [[ -n "$default_branch" ]] && [[ "$ref" != "refs/heads/${default_branch}" ]]; then
            continue
        fi

        if [[ -z "$before" ]] || [[ -z "$head" ]] || [[ "$before" =~ ^0+$ ]]; then
            should_sync=true
            reasons+=("${full_name} changed on ${ref:-unknown-ref}; compare baseline unavailable")
            continue
        fi

        compare_payload=$(gh api "repos/${full_name}/compare/${before}...${head}" 2>/dev/null || true)
        if [[ -z "$compare_payload" ]]; then
            should_sync=true
            reasons+=("${full_name} changed on ${ref:-unknown-ref}; compare payload unavailable")
            continue
        fi

        while IFS= read -r changed_file; do
            [[ -n "$changed_file" ]] || continue
            if is_relevant_path "$changed_file"; then
                should_sync=true
                reasons+=("${full_name} changed ${changed_file}")
                break
            fi
        done < <(printf '%s' "$compare_payload" | jq -r '.files[]?.filename')
    done < <(fetch_recent_push_events "$cutoff_iso")

    if [[ "${#reasons[@]}" -gt 0 ]]; then
        reasons_json=$(printf '%s\n' "${reasons[@]}" | jq -R . | jq -s .)
        summary="Relevant source README/logo changes detected since ${cutoff_iso}"
    else
        summary="No relevant source README/logo changes detected since ${cutoff_iso}"
    fi

    jq -n \
        --argjson should_sync "$should_sync" \
        --arg cutoff "$cutoff_iso" \
        --arg summary "$summary" \
        --argjson reasons "$reasons_json" \
        '{
            should_sync: $should_sync,
            cutoff: $cutoff,
            summary: $summary,
            reasons: $reasons
        }'
}

main "$@"
