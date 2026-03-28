# S.C.O.P.E. Scripts

Automation scripts for coordinating O.A.S.I.S. component repositories.

## Available Scripts

### for-each-component.sh

**General-purpose script for running commands across all O.A.S.I.S. component repos.**

```bash
# Basic usage - run any command with placeholders
./scripts/for-each-component.sh "gh repo view {full} --json isFork"

# Run on specific repos only
./scripts/for-each-component.sh --repos "mirage dawn" "gh issue list --repo {full}"

# Dry run to preview commands
./scripts/for-each-component.sh --dry-run "gh issue edit 1 --repo {full} --add-label bug"

# Add a label to all repos
./scripts/for-each-component.sh "gh label create 'priority' --repo {full} --color 'ff0000'"

# Create issue in all repos
./scripts/for-each-component.sh "gh issue create --repo {full} --title 'Update docs' --body 'Details here'"
```

**Placeholders:**
| Placeholder | Example | Description |
|-------------|---------|-------------|
| `{repo}` | `mirage` | Repository name |
| `{owner}` | `malcolmhoward` | GitHub owner |
| `{full}` | `malcolmhoward/mirage` | Full repo path |

### check-component-status.sh

Checks the status of all O.A.S.I.S. component repositories (fork status, foundation files).

```bash
./scripts/check-component-status.sh
./scripts/check-component-status.sh --repos "mirage dawn"
```

### sync-forks.sh

Syncs O.A.S.I.S. component forks with their upstream repositories (The-OASIS-Project).

```bash
# Check sync status only
./scripts/sync-forks.sh --check-only

# Sync all forks that are behind
./scripts/sync-forks.sh

# Check specific repos only
./scripts/sync-forks.sh --check-only --repos "mirage dawn"
```

**Output includes:**
- Commits ahead/behind upstream
- Foundation file status (README.md, CONTRIBUTING.md, CLAUDE.md, LICENSE)
- Sync status summary

### create-component-issues.sh

Creates issues across multiple O.A.S.I.S. component repositories from a template.

```bash
# Dry run to see what would be created
./scripts/create-component-issues.sh scripts/issue-templates/foundation-files.sh --dry-run

# Create issues in all component repos
./scripts/create-component-issues.sh scripts/issue-templates/foundation-files.sh
```

**Template format** (see `issue-templates/` for examples):
```bash
TITLE="Issue title here"
LABELS="documentation,enhancement"
META_ISSUE="22"  # S.C.O.P.E. meta-issue to reference
REPOS="mirage dawn spark aura beacon genesis"

read -r -d '' BODY << 'EOF'
## Summary
Issue body in markdown...
EOF
```

## Issue Templates

Issue templates are stored in `scripts/issue-templates/`:

| Template | Purpose |
|----------|---------|
| `foundation-files.sh` | Add CLAUDE.md and CONTRIBUTING.md |
| `docker-config.sh` | Add Docker configurations |

## Prerequisites

- [GitHub CLI](https://cli.github.com/) (`gh`) installed and authenticated
- Bash shell (Git Bash on Windows, native on macOS/Linux)

## Workflow

Typical workflow for coordinating cross-repo changes:

1. **Sync forks** - Ensure forks are up to date with upstream
   ```bash
   ./scripts/sync-forks.sh --check-only
   ./scripts/sync-forks.sh  # if behind
   ```

2. **Create component issues** - Track work in each repo
   ```bash
   ./scripts/create-component-issues.sh scripts/issue-templates/foundation-files.sh
   ```

3. **Update meta-issue** - Link component issues to S.C.O.P.E. meta-issue
   ```bash
   # Script outputs the issue links to add to the meta-issue
   ```

4. **Do the work** - Implement changes in each component repo

5. **Create PRs to upstream** - Contribute changes back to The-OASIS-Project

---

*Part of [S.C.O.P.E.](../README.md) - System Coordination, Orchestration, Planning & Execution*