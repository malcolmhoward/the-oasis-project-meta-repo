# Onboarding a New Component to O.A.S.I.S.

This guide documents the process for bringing a new component repository into full alignment with the O.A.S.I.S. ecosystem. It was established during the S.T.A.T. alignment and applies to any future component.

---

## Prerequisites

Before starting, the component repo must:
- Exist on GitHub (forked from The-OASIS-Project or newly created)
- Have source code and a LICENSE file
- Have a clear purpose within the O.A.S.I.S. ecosystem

---

## Step 1: Repo Settings

Configure the repo to match other O.A.S.I.S. repositories.

### Features

| Setting | Value | How |
|---------|-------|-----|
| Issues | Enabled | `gh repo edit <owner>/<repo> --enable-issues` |
| Wiki | Disabled | `gh api repos/<owner>/<repo> -X PATCH -f has_wiki=false` |
| Projects | Enabled | Default |
| Discussions | Disabled | Default |

### Branch Protection (main)

```bash
gh api repos/<owner>/<repo>/branches/main/protection -X PUT \
  -F "required_pull_request_reviews[dismiss_stale_reviews]=true" \
  -F "required_pull_request_reviews[required_approving_review_count]=1" \
  -F "enforce_admins=false" \
  -F "required_status_checks=null" \
  -F "restrictions=null"
```

This enforces: 1 approving review, dismiss stale reviews, no force pushes, no branch deletions.

### Verification

```bash
gh api repos/<owner>/<repo> --jq '{has_issues, has_wiki, has_projects, has_discussions}'
gh api repos/<owner>/<repo>/branches/main/protection --jq '{
  required_pull_request_reviews: .required_pull_request_reviews | {dismiss_stale_reviews, required_approving_review_count},
  allow_force_pushes: .allow_force_pushes.enabled,
  allow_deletions: .allow_deletions.enabled
}'
```

---

## Step 2: Update Meta-Issues

Update the following meta-issues in S.C.O.P.E. to include the new component with "Pending" placeholders. This establishes scope before creating component-level issues.

| Meta-Issue | What to Add |
|------------|-------------|
| #22 (Foundation standardization) | Row in component table, update "All N repos" count in acceptance criteria |
| #29 (Documentation aggregation) | Row in component table, update "All N repos" count in acceptance criteria |
| #23 (Docker standardization) | Component issue entry (if applicable — has runtime or hardware) |
| #30 (Mock hardware) | Component entry (if applicable — has hardware interfaces) |

**Not applicable:** Components without runtime (BEACON/CAD) or hardware (GENESIS/utilities) may not need #23 or #30 entries.

---

## Step 3: Create Component Issues (#1-#4)

Create issues in the component repo matching the standard pattern:

| # | Title | Purpose |
|---|-------|---------|
| 1 | Add CLAUDE.md and CONTRIBUTING.md foundation files | Initial governance request |
| 2 | Add Docker development configuration | Docker standardization placeholder |
| 3 | Apply PFT foundation files to [COMPONENT] | Foundation files tracking |
| 4 | [Documentation] Fill docs/guide.md gaps per ecosystem documentation standard | Docs gap-fill |

Each issue should reference the relevant meta-issue in S.C.O.P.E.

---

## Step 4: Add Submodule to Meta-Repo

**This must happen before Step 5.** All component work is done inside `repos/<component>` in the meta-repo.

```bash
cd <meta-repo>
git checkout feat/1-initialize-submodules
git submodule add https://github.com/<owner>/<repo>.git repos/<component>
git commit -m "feat(repos): Add <COMPONENT> submodule"
git push --force-with-lease origin feat/1-initialize-submodules
```

The submodule is added to `feat/1-initialize-submodules` (where all other submodules were initialized) and will be propagated via rebase cascade in Step 7.

---

## Step 5: Foundation Files

Working inside `repos/<component>` in the meta-repo:

```bash
cd repos/<component>
git checkout -b feat/<component>/3-foundation-files
```

### Files to Create/Modify

| File | Action | Notes |
|------|--------|-------|
| `CLAUDE.md` | Create | LLM integration guide — build system, architecture, key files, hardware deps, common tasks. Follow DAWN/MIRAGE pattern. |
| `CONTRIBUTING.md` | Create | Fork-first workflow, conventional commits, hardware testing notes (if applicable). |
| `README.md` | Restructure (if needed) | Reorganize to match ecosystem pattern while preserving existing content. |
| `.gitignore` | Modify | Add `scratch/` and `build/` (if applicable). |
| `docs/guide.md` | Create | Initial stub — expanded in Step 6. |

### Commit, Push, PR

```bash
git add CLAUDE.md CONTRIBUTING.md docs/guide.md .gitignore
git commit -m "docs: Add foundation files"
git push -u origin feat/<component>/3-foundation-files
gh pr create --base main --head feat/<component>/3-foundation-files \
  --title "Add foundation files (CLAUDE.md, CONTRIBUTING.md, docs stub)"
```

PR should reference meta-issue #22 and close issues #1 and #3.

---

## Step 6: Documentation Gap-Fill

Working inside `repos/<component>` in the meta-repo:

```bash
git checkout -b feat/<component>/4-docs-gap-fill
```

Expand `docs/guide.md` per the ecosystem documentation standard. Typical sections:

| Section | Content |
|---------|---------|
| Overview | Component role, what it does, where it runs |
| Hardware (if applicable) | Supported devices, interfaces, configuration |
| Communication | MQTT topics, JSON payloads, subscribing/publishing components |
| Troubleshooting | Common issues with diagnostic commands and solutions |
| Related Components | How this component interacts with others |

Write for the least experienced reader — the cost of over-explaining is seconds of skimming; the cost of under-explaining is lost contributors.

### Commit, Push, PR

```bash
git add docs/guide.md
git commit -m "docs: Expand guide.md with comprehensive documentation"
git push -u origin feat/<component>/4-docs-gap-fill
gh pr create --base feat/<component>/3-foundation-files \
  --head feat/<component>/4-docs-gap-fill \
  --title "Expand docs/guide.md per ecosystem documentation standard"
```

PR should reference meta-issue #29 and resolve issue #4.

---

## Step 7: Rebase Cascade

Propagate the submodule addition through the full meta-repo PR chain:

```
feat/1-initialize-submodules  (updated in Step 4)
  ↓ rebase
feat/2-claude-llm-integration
  ↓ rebase
feat/4-directory-structure
  ↓ rebase
feat/6-foundation-templates
  ↓ rebase
feat/scope/32-foundation-files
  ↓ rebase
feat/22-foundation-standardization
  ↓ rebase
feat/29-documentation-aggregation
  ↓ rebase
feat/scope/23-docker-standardization
```

For each branch: `git checkout <branch> && git rebase <parent> && git push --force-with-lease`

Use `--force-with-lease` (not `--force`) to prevent overwriting unexpected upstream changes.

---

## Step 8: Update Meta-Repo CLAUDE.md

On the chain tip, add the component to the O.A.S.I.S. Component Repositories table and update the cross-repo relationships diagram.

---

## Step 9: GitHub Pages

After the component's docs reach `main` (PRs merged):

1. Add mapping to `repos/github-pages/scripts/aggregate_docs.py`
2. Add entry to `repos/github-pages/mkdocs.yml` nav
3. Re-run aggregation: `python scripts/aggregate_docs.py`

This is deferred until steady state — CI-driven aggregation is not yet active.

---

## Step 10: Finalize

1. **Update meta-issues** #22 and #29 — replace "Pending" with actual issue/PR numbers
2. **Update memory** — increment repo count, add component to the repo list
3. **Commit and push** meta-repo changes on the chain tip

---

## PR Chain Pattern (per component)

Each component follows this branch chain:

```
main ← foundation-files (#3) ← docs-gap-fill (#4) ← deployment (#2, future) ← mock-hardware (future)
```

---

## Checklist

Use this checklist to track progress:

- [ ] Repo settings aligned (issues, wiki, branch protection)
- [ ] Meta-issues updated with Pending placeholders (#22, #29, #23, #30)
- [ ] Component issues #1-#4 created
- [ ] Submodule added to `feat/1-initialize-submodules`
- [ ] Foundation files committed and PR created
- [ ] docs/guide.md expanded and PR created
- [ ] Rebase cascade completed (all meta-repo chain branches)
- [ ] Meta-repo CLAUDE.md updated with component
- [ ] Meta-issues updated with final issue/PR numbers
- [ ] Memory updated
- [ ] Meta-repo changes committed and pushed
