#!/bin/bash
#
# for-each-component.sh
# Runs a command or script across all O.A.S.I.S. component repositories
#
# Usage:
#   ./scripts/for-each-component.sh <command>
#   ./scripts/for-each-component.sh --repos "mirage dawn" <command>
#   ./scripts/for-each-component.sh --dry-run <command>
#
# The command can use these placeholders:
#   {repo}  - Repository name (e.g., "mirage")
#   {owner} - Repository owner (default: "malcolmhoward")
#   {full}  - Full repo path (e.g., "malcolmhoward/mirage")
#
# Examples:
#   # Check all repos
#   ./scripts/for-each-component.sh "gh repo view {full} --json name,isFork"
#
#   # Create an issue in all repos
#   ./scripts/for-each-component.sh "gh issue create --repo {full} --title 'Test' --body 'Body'"
#
#   # Add a label to issue #1 in all repos
#   ./scripts/for-each-component.sh "gh issue edit 1 --repo {full} --add-label 'enhancement'"
#
#   # Run only on specific repos
#   ./scripts/for-each-component.sh --repos "mirage dawn" "gh repo view {full}"
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OWNER="malcolmhoward"
DEFAULT_REPOS="mirage dawn spark aura beacon genesis"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Parse arguments
REPOS="$DEFAULT_REPOS"
DRY_RUN=false
COMMAND=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --repos)
            REPOS="$2"
            shift 2
            ;;
        --owner)
            OWNER="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [options] <command>"
            echo ""
            echo "Runs a command across all O.A.S.I.S. component repositories."
            echo ""
            echo "Options:"
            echo "  --repos \"repo1 repo2\"  Specific repos (default: all 6)"
            echo "  --owner <name>          GitHub owner (default: malcolmhoward)"
            echo "  --dry-run               Show commands without executing"
            echo ""
            echo "Placeholders in command:"
            echo "  {repo}   Repository name (e.g., mirage)"
            echo "  {owner}  Repository owner"
            echo "  {full}   Full path (e.g., malcolmhoward/mirage)"
            echo ""
            echo "Examples:"
            echo "  $0 \"gh repo view {full} --json isFork\""
            echo "  $0 --repos \"mirage dawn\" \"gh issue list --repo {full}\""
            echo "  $0 \"gh issue edit 1 --repo {full} --add-label bug\""
            exit 0
            ;;
        *)
            COMMAND="$1"
            shift
            ;;
    esac
done

if [[ -z "$COMMAND" ]]; then
    echo -e "${RED}Error: No command specified${NC}"
    echo "Usage: $0 [options] <command>"
    echo "Run '$0 --help' for more information."
    exit 1
fi

echo -e "${GREEN}=== Running across O.A.S.I.S. components ===${NC}"
echo "Owner: $OWNER"
echo "Repos: $REPOS"
echo "Command: $COMMAND"
echo "Dry run: $DRY_RUN"
echo ""

# Track results
SUCCESS_COUNT=0
FAIL_COUNT=0
declare -A RESULTS

for repo in $REPOS; do
    full="$OWNER/$repo"

    # Replace placeholders
    cmd="${COMMAND//\{repo\}/$repo}"
    cmd="${cmd//\{owner\}/$OWNER}"
    cmd="${cmd//\{full\}/$full}"

    echo -e "${YELLOW}--- $repo ---${NC}"

    if [[ "$DRY_RUN" == "true" ]]; then
        echo -e "${BLUE}[DRY RUN] Would execute:${NC}"
        echo "  $cmd"
        RESULTS[$repo]="dry-run"
    else
        echo -e "${BLUE}Executing:${NC} $cmd"
        if eval "$cmd"; then
            RESULTS[$repo]="success"
            ((SUCCESS_COUNT++))
        else
            RESULTS[$repo]="failed"
            ((FAIL_COUNT++))
            echo -e "${RED}Command failed for $repo${NC}"
        fi
    fi

    echo ""
done

# Summary
echo -e "${GREEN}=== Summary ===${NC}"
if [[ "$DRY_RUN" == "true" ]]; then
    echo "Dry run complete. No commands executed."
else
    echo "Success: $SUCCESS_COUNT"
    echo "Failed: $FAIL_COUNT"
    echo ""
    echo "| Repo | Result |"
    echo "|------|--------|"
    for repo in $REPOS; do
        result="${RESULTS[$repo]}"
        if [[ "$result" == "success" ]]; then
            echo "| $repo | ✓ |"
        else
            echo "| $repo | ✗ |"
        fi
    done
fi
