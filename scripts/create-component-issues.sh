#!/bin/bash
#
# create-component-issues.sh
# Creates issues across O.A.S.I.S. component repositories
#
# Usage:
#   ./scripts/create-component-issues.sh <issue-template-file> [--dry-run]
#
# The template file should contain:
#   TITLE="Issue title here"
#   LABELS="label1,label2"
#   META_ISSUE="22"  # S.C.O.P.E. meta-issue number to reference
#   REPOS="mirage dawn spark aura beacon genesis"  # or subset
#   BODY heredoc
#
# Example template file (templates/issues/foundation-files.md):
#   TITLE="Add CLAUDE.md and CONTRIBUTING.md foundation files"
#   LABELS="documentation,enhancement"
#   META_ISSUE="22"
#   REPOS="mirage dawn spark aura beacon genesis"
#   read -r -d '' BODY << 'EOF'
#   ## Summary
#   ...
#   EOF

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
ORG="malcolmhoward"
META_REPO="the-oasis-project-meta-repo"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Parse arguments
DRY_RUN=false
TEMPLATE_FILE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        *)
            TEMPLATE_FILE="$1"
            shift
            ;;
    esac
done

if [[ -z "$TEMPLATE_FILE" ]]; then
    echo -e "${RED}Error: No template file specified${NC}"
    echo "Usage: $0 <template-file> [--dry-run]"
    exit 1
fi

if [[ ! -f "$TEMPLATE_FILE" ]]; then
    echo -e "${RED}Error: Template file not found: $TEMPLATE_FILE${NC}"
    exit 1
fi

# Source the template file
source "$TEMPLATE_FILE"

# Validate required variables
if [[ -z "$TITLE" ]]; then
    echo -e "${RED}Error: TITLE not defined in template${NC}"
    exit 1
fi

if [[ -z "$REPOS" ]]; then
    REPOS="mirage dawn spark aura beacon genesis"
fi

echo -e "${GREEN}=== O.A.S.I.S. Component Issue Creator ===${NC}"
echo "Template: $TEMPLATE_FILE"
echo "Title: $TITLE"
echo "Labels: ${LABELS:-none}"
echo "Repos: $REPOS"
echo "Meta-issue: ${META_ISSUE:-none}"
echo "Dry run: $DRY_RUN"
echo ""

# Track created issues for meta-issue update
declare -A CREATED_ISSUES

for repo in $REPOS; do
    echo -e "${YELLOW}Processing $ORG/$repo...${NC}"

    # Build the issue body with meta-issue reference
    FULL_BODY="$BODY"
    if [[ -n "$META_ISSUE" ]]; then
        FULL_BODY="$BODY

---
## Related
- Meta-issue: $ORG/$META_REPO#$META_ISSUE"
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        echo "  [DRY RUN] Would create issue:"
        echo "    Title: $TITLE"
        echo "    Labels: $LABELS"
        echo ""
    else
        # Create the issue
        ISSUE_URL=$(gh issue create \
            --repo "$ORG/$repo" \
            --title "$TITLE" \
            --body "$FULL_BODY" \
            ${LABELS:+--label "$LABELS"} 2>&1)

        if [[ $? -eq 0 ]]; then
            # Extract issue number from URL
            ISSUE_NUM=$(echo "$ISSUE_URL" | grep -oE '[0-9]+$')
            CREATED_ISSUES[$repo]=$ISSUE_NUM
            echo -e "  ${GREEN}Created: $ISSUE_URL${NC}"
        else
            echo -e "  ${RED}Failed to create issue: $ISSUE_URL${NC}"
        fi
    fi
done

echo ""
echo -e "${GREEN}=== Summary ===${NC}"

if [[ "$DRY_RUN" == "true" ]]; then
    echo "Dry run complete. No issues created."
else
    echo "Created issues:"
    for repo in "${!CREATED_ISSUES[@]}"; do
        echo "  - $ORG/$repo#${CREATED_ISSUES[$repo]}"
    done

    if [[ -n "$META_ISSUE" ]]; then
        echo ""
        echo -e "${YELLOW}Update meta-issue #$META_ISSUE with:${NC}"
        for repo in "${!CREATED_ISSUES[@]}"; do
            echo "  - [ ] $ORG/$repo#${CREATED_ISSUES[$repo]}"
        done
    fi
fi
