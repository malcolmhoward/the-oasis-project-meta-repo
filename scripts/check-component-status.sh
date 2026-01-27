#!/bin/bash
#
# check-component-status.sh
# Checks the status of O.A.S.I.S. component repositories
#
# Usage:
#   ./scripts/check-component-status.sh [--repos "mirage dawn"]
#
# Checks:
#   - Fork status (is it a fork, what's the parent)
#   - Foundation files (README.md, CONTRIBUTING.md, CLAUDE.md, LICENSE)
#   - Default branch
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ORG="malcolmhoward"
DEFAULT_REPOS="mirage dawn spark aura beacon genesis"

# Parse arguments
REPOS="$DEFAULT_REPOS"

while [[ $# -gt 0 ]]; do
    case $1 in
        --repos)
            REPOS="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [--repos \"repo1 repo2\"]"
            echo ""
            echo "Checks status of O.A.S.I.S. component repositories:"
            echo "  - Fork status and parent repository"
            echo "  - Foundation files present"
            echo ""
            echo "Options:"
            echo "  --repos    Space-separated list of repos (default: all)"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

echo "=== O.A.S.I.S. Component Status Check ==="
echo "Repos: $REPOS"
echo ""

# Track results for summary
declare -A HAS_README
declare -A HAS_CONTRIBUTING
declare -A HAS_CLAUDE
declare -A HAS_LICENSE
declare -A IS_FORK
declare -A PARENT_REPO

check_file_exists() {
    local repo=$1
    local file=$2

    # Suppress error output, just check if file exists
    if gh api "repos/$ORG/$repo/contents/$file" --jq '.name' 2>/dev/null | grep -q "$file"; then
        return 0
    else
        return 1
    fi
}

for repo in $REPOS; do
    echo "=== $repo ==="

    # Get fork info using separate gh calls to avoid jq dependency
    FORK_STATUS=$(gh api "repos/$ORG/$repo" --jq '.fork' 2>/dev/null || echo "false")
    PARENT=$(gh api "repos/$ORG/$repo" --jq '.parent.full_name // "none"' 2>/dev/null || echo "none")
    BRANCH=$(gh api "repos/$ORG/$repo" --jq '.default_branch' 2>/dev/null || echo "unknown")

    IS_FORK[$repo]=$FORK_STATUS
    PARENT_REPO[$repo]=$PARENT

    if [[ "$FORK_STATUS" == "true" ]]; then
        echo "  Fork of: $PARENT"
    else
        echo "  Standalone repo (not a fork)"
    fi
    echo "  Default branch: $BRANCH"

    # Check foundation files
    echo "  Files:"

    if check_file_exists "$repo" "README.md"; then
        echo "    ✓ README.md"
        HAS_README[$repo]="yes"
    else
        echo "    ✗ README.md"
        HAS_README[$repo]="no"
    fi

    if check_file_exists "$repo" "CONTRIBUTING.md"; then
        echo "    ✓ CONTRIBUTING.md"
        HAS_CONTRIBUTING[$repo]="yes"
    else
        echo "    ✗ CONTRIBUTING.md"
        HAS_CONTRIBUTING[$repo]="no"
    fi

    if check_file_exists "$repo" "CLAUDE.md"; then
        echo "    ✓ CLAUDE.md"
        HAS_CLAUDE[$repo]="yes"
    else
        echo "    ✗ CLAUDE.md"
        HAS_CLAUDE[$repo]="no"
    fi

    if check_file_exists "$repo" "LICENSE"; then
        echo "    ✓ LICENSE"
        HAS_LICENSE[$repo]="yes"
    else
        echo "    ✗ LICENSE"
        HAS_LICENSE[$repo]="no"
    fi

    echo ""
done

# Summary table
echo "=== Summary ==="
echo ""
echo "| Repo | Fork | README | CONTRIBUTING | CLAUDE | LICENSE |"
echo "|------|------|--------|--------------|--------|---------|"

for repo in $REPOS; do
    fork_icon=$(if [[ "${IS_FORK[$repo]}" == "true" ]]; then echo "✓"; else echo "-"; fi)
    readme_icon=$(if [[ "${HAS_README[$repo]}" == "yes" ]]; then echo "✓"; else echo "✗"; fi)
    contrib_icon=$(if [[ "${HAS_CONTRIBUTING[$repo]}" == "yes" ]]; then echo "✓"; else echo "✗"; fi)
    claude_icon=$(if [[ "${HAS_CLAUDE[$repo]}" == "yes" ]]; then echo "✓"; else echo "✗"; fi)
    license_icon=$(if [[ "${HAS_LICENSE[$repo]}" == "yes" ]]; then echo "✓"; else echo "✗"; fi)

    echo "| $repo | $fork_icon | $readme_icon | $contrib_icon | $claude_icon | $license_icon |"
done

echo ""
echo "Legend: ✓ = present, ✗ = missing, - = N/A"

# Count missing files
MISSING_CONTRIBUTING=0
MISSING_CLAUDE=0

for repo in $REPOS; do
    [[ "${HAS_CONTRIBUTING[$repo]}" == "no" ]] && ((MISSING_CONTRIBUTING++))
    [[ "${HAS_CLAUDE[$repo]}" == "no" ]] && ((MISSING_CLAUDE++))
done

echo ""
echo "=== Action Items ==="
echo "  Repos missing CONTRIBUTING.md: $MISSING_CONTRIBUTING"
echo "  Repos missing CLAUDE.md: $MISSING_CLAUDE"

if [[ $MISSING_CONTRIBUTING -gt 0 || $MISSING_CLAUDE -gt 0 ]]; then
    echo ""
    echo "To create issues for missing files, run:"
    echo "  ./scripts/create-component-issues.sh scripts/issue-templates/foundation-files.sh"
fi