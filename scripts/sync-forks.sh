#!/bin/bash
#
# sync-forks.sh
# Syncs O.A.S.I.S. component forks with their upstream repositories
#
# Usage:
#   ./scripts/sync-forks.sh [--check-only] [--repos "mirage dawn"]
#
# Options:
#   --check-only    Only check sync status, don't sync
#   --repos         Space-separated list of repos (default: all)
#
# Prerequisites:
#   - GitHub CLI (gh) installed and authenticated
#   - Fork repos must have upstream set
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ORG="malcolmhoward"
UPSTREAM_ORG="The-OASIS-Project"
DEFAULT_REPOS="mirage dawn spark aura beacon genesis"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Parse arguments
CHECK_ONLY=false
REPOS="$DEFAULT_REPOS"

while [[ $# -gt 0 ]]; do
    case $1 in
        --check-only)
            CHECK_ONLY=true
            shift
            ;;
        --repos)
            REPOS="$2"
            shift 2
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

echo -e "${GREEN}=== O.A.S.I.S. Fork Sync Tool ===${NC}"
echo "Mode: $(if $CHECK_ONLY; then echo 'Check only'; else echo 'Sync'; fi)"
echo "Repos: $REPOS"
echo ""

# Track status
declare -A SYNC_STATUS

check_fork_status() {
    local repo=$1

    echo -e "${YELLOW}Checking $ORG/$repo...${NC}"

    # Get fork info
    FORK_INFO=$(gh api "repos/$ORG/$repo" --jq '{
        fork: .fork,
        parent: .parent.full_name,
        default_branch: .default_branch,
        pushed_at: .pushed_at
    }' 2>/dev/null)

    if [[ $? -ne 0 ]]; then
        echo -e "  ${RED}Failed to get repo info${NC}"
        SYNC_STATUS[$repo]="error"
        return 1
    fi

    IS_FORK=$(echo "$FORK_INFO" | jq -r '.fork')
    PARENT=$(echo "$FORK_INFO" | jq -r '.parent')
    DEFAULT_BRANCH=$(echo "$FORK_INFO" | jq -r '.default_branch')

    if [[ "$IS_FORK" != "true" ]]; then
        echo -e "  ${BLUE}Not a fork (standalone repo)${NC}"
        SYNC_STATUS[$repo]="not_fork"
        return 0
    fi

    echo "  Parent: $PARENT"
    echo "  Default branch: $DEFAULT_BRANCH"

    # Compare commits between fork and upstream
    COMPARE=$(gh api "repos/$ORG/$repo/compare/$DEFAULT_BRANCH...$UPSTREAM_ORG:$DEFAULT_BRANCH" \
        --jq '{ahead: .ahead_by, behind: .behind_by, status: .status}' 2>/dev/null)

    if [[ $? -ne 0 ]]; then
        echo -e "  ${YELLOW}Could not compare with upstream (may not exist or different structure)${NC}"
        SYNC_STATUS[$repo]="unknown"
        return 0
    fi

    AHEAD=$(echo "$COMPARE" | jq -r '.ahead')
    BEHIND=$(echo "$COMPARE" | jq -r '.behind')
    STATUS=$(echo "$COMPARE" | jq -r '.status')

    echo "  Status: $STATUS"
    echo "  Ahead of upstream: $AHEAD commits"
    echo "  Behind upstream: $BEHIND commits"

    if [[ "$BEHIND" -gt 0 ]]; then
        SYNC_STATUS[$repo]="behind"
        echo -e "  ${YELLOW}⚠ Fork is behind upstream${NC}"
    elif [[ "$AHEAD" -gt 0 ]]; then
        SYNC_STATUS[$repo]="ahead"
        echo -e "  ${BLUE}ℹ Fork is ahead of upstream${NC}"
    else
        SYNC_STATUS[$repo]="synced"
        echo -e "  ${GREEN}✓ Fork is in sync${NC}"
    fi

    echo ""
}

sync_fork() {
    local repo=$1

    echo -e "${YELLOW}Syncing $ORG/$repo...${NC}"

    # Use GitHub's sync fork API
    RESULT=$(gh api -X POST "repos/$ORG/$repo/merge-upstream" \
        -f branch="$(gh api repos/$ORG/$repo --jq '.default_branch')" 2>&1)

    if [[ $? -eq 0 ]]; then
        echo -e "  ${GREEN}✓ Synced successfully${NC}"
        echo "  $RESULT" | jq -r '.message // "Merged upstream changes"' 2>/dev/null
    else
        echo -e "  ${RED}Failed to sync: $RESULT${NC}"
    fi

    echo ""
}

check_foundation_files() {
    local repo=$1

    echo -e "${BLUE}  Checking foundation files in $ORG/$repo...${NC}"

    # Check for key files in the repo
    for file in README.md CONTRIBUTING.md CLAUDE.md LICENSE; do
        EXISTS=$(gh api "repos/$ORG/$repo/contents/$file" --jq '.name' 2>/dev/null)
        if [[ -n "$EXISTS" ]]; then
            echo -e "    ${GREEN}✓ $file${NC}"
        else
            echo -e "    ${RED}✗ $file${NC}"
        fi
    done

    echo ""
}

# Main loop
for repo in $REPOS; do
    check_fork_status "$repo"
    check_foundation_files "$repo"

    if [[ "$CHECK_ONLY" == "false" && "${SYNC_STATUS[$repo]}" == "behind" ]]; then
        sync_fork "$repo"
    fi
done

# Summary
echo -e "${GREEN}=== Summary ===${NC}"
echo ""
echo "| Repo | Status | Action Needed |"
echo "|------|--------|---------------|"
for repo in $REPOS; do
    status="${SYNC_STATUS[$repo]:-unknown}"
    case $status in
        synced)
            echo "| $repo | ✓ Synced | None |"
            ;;
        behind)
            if $CHECK_ONLY; then
                echo "| $repo | ⚠ Behind | Run without --check-only to sync |"
            else
                echo "| $repo | ✓ Synced | Was behind, now synced |"
            fi
            ;;
        ahead)
            echo "| $repo | ℹ Ahead | Has local changes to push upstream |"
            ;;
        not_fork)
            echo "| $repo | - | Not a fork |"
            ;;
        *)
            echo "| $repo | ? Unknown | Check manually |"
            ;;
    esac
done
