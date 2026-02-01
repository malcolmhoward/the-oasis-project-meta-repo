# ADR 0002: GitHub Infrastructure Standards

> **DRAFT STATUS**: This ADR is a draft pending review by project stakeholders.
> Decision on infrastructure standards should be made by Kris Kersey.
>
> **Draft Date**: 2026-01-31
> **Draft Author**: Malcolm Howard

---

**Date**: TBD (pending approval)
**Status**: Proposed
**Deciders**: Kris Kersey, Malcolm Howard

## Context

S.C.O.P.E. (System Coordination, Orchestration, Planning & Execution) serves as the coordination layer for the O.A.S.I.S. ecosystem. As work spans multiple component repositories (MIRAGE, DAWN, SPARK, AURA, BEACON, GENESIS), consistent GitHub infrastructure is needed to:

1. Enable consistent tracking of work across repositories
2. Protect main branches from accidental modifications
3. Establish clear ownership boundaries for issues
4. Maintain visibility into cross-component progress
5. Support future standardization needs

### Problem

Without standardized infrastructure:
- Labels vary between repos, making cross-repo queries difficult
- No branch protection on component repos (risk of accidental main changes)
- Cross-repo work has no natural home for coordination
- Issue ownership becomes ambiguous
- Adding new standardization aspects requires ad-hoc decisions

## Decision

**Establish standardized GitHub infrastructure across all O.A.S.I.S. repositories, with extensible sections for future additions.**

---

## 1. Labels

### 1.1 S.C.O.P.E. Labels

Labels specific to the coordination repository:

| Label | Color | Description |
|-------|-------|-------------|
| `meta-issue` | #bfdadc | Cross-component work owned by S.C.O.P.E. |
| `tracking` | #bfdadc | Reference to component issue for visibility |
| `cross-repo` | #0052cc | Affects multiple repositories |
| `coordination` | #d93f0b | Requires S.C.O.P.E. coordination |
| `setup` | #0e8a16 | Repository setup tasks |
| `templates` | #1d76db | Template files |
| `hardware` | #fbca04 | Hardware-related documentation |
| `getting-started` | #5319e7 | Getting started guides |
| `docker` | #0052cc | Docker and containers |
| `community` | #c2e0c6 | Community contributions |
| `automation` | #006b75 | Automation and CI/CD |
| `meta` | #bfdadc | Meta-issues tracking cross-repo work |

### 1.2 Component Repository Labels

Labels for all component repositories (MIRAGE, DAWN, SPARK, AURA, BEACON, GENESIS):

| Label | Color | Description |
|-------|-------|-------------|
| `standardization` | #1d76db | Repository standardization work |
| `pft` | #0e8a16 | Project Foundation Template related |
| `foundation-files` | #5319e7 | Foundation files (README, CONTRIBUTING, etc.) |
| `tracking` | #bfdadc | Tracks upstream issue in S.C.O.P.E. |
| `ethical-awareness` | #7057ff | Flags ethical considerations relevant to O.A.S.I.S. components |

Plus GitHub's default labels: `bug`, `documentation`, `duplicate`, `enhancement`, `good first issue`, `help wanted`, `invalid`, `question`, `wontfix`.

### 1.3 Label Setup

```bash
# Component repo labels
gh label create "standardization" --description "Repository standardization work" --color "1d76db" -R "owner/repo"
gh label create "pft" --description "Project Foundation Template related" --color "0e8a16" -R "owner/repo"
gh label create "foundation-files" --description "Foundation files" --color "5319e7" -R "owner/repo"
gh label create "tracking" --description "Tracks upstream issue in S.C.O.P.E." --color "bfdadc" -R "owner/repo"
```

---

## 2. Branch Protection

### 2.1 Configuration

All O.A.S.I.S. repositories SHALL have branch protection on `main`:

```json
{
  "required_status_checks": null,
  "enforce_admins": false,
  "required_pull_request_reviews": {
    "dismiss_stale_reviews": true,
    "required_approving_review_count": 1
  },
  "restrictions": null,
  "allow_force_pushes": false,
  "allow_deletions": false
}
```

### 2.2 Rationale

| Setting | Value | Reason |
|---------|-------|--------|
| `required_pull_request_reviews` | 1 review, dismiss stale | Catches mistakes, ensures fresh review |
| `enforce_admins` | false | Allows emergency fixes by admins |
| `allow_force_pushes` | false | Protects commit history |
| `allow_deletions` | false | Prevents accidental branch deletion |

### 2.3 Setup

```bash
gh api repos/owner/repo/branches/main/protection -X PUT --input - <<'EOF'
{
  "required_status_checks": null,
  "enforce_admins": false,
  "required_pull_request_reviews": {
    "dismiss_stale_reviews": true,
    "required_approving_review_count": 1
  },
  "restrictions": null,
  "allow_force_pushes": false,
  "allow_deletions": false
}
EOF
```

---

## 3. Milestones

### 3.1 Standard Milestones

Each component repository SHALL have a "PFT Standardization" milestone for initial governance work:

```markdown
Title: PFT Standardization
Description: Apply Project Foundation Template governance files and standardization.

Tracks S.C.O.P.E. META issue: [link to META issue]
```

### 3.2 Future Milestones

Additional milestones should follow the pattern:
- Clear title describing the work phase
- Description linking to coordination issues

---

## 4. Issue Tracking System

### 4.1 Two-Tier Architecture

O.A.S.I.S. uses a two-tier issue tracking system with clear ownership boundaries:

```
┌─────────────────────────────────────────────────────────────┐
│                    S.C.O.P.E. (Tier 1)                      │
│  Meta-Issues: Cross-component work (2+ repos)               │
│  Label: meta-issue                                          │
│  Ownership: S.C.O.P.E.                                      │
└─────────────────────────┬───────────────────────────────────┘
                          │ links to
┌─────────────────────────▼───────────────────────────────────┐
│              Component Repos (Tier 2)                       │
│  Implementation Issues: Single-component work               │
│  Label: tracking (when linked from S.C.O.P.E.)             │
│  Ownership: Component repo                                  │
└─────────────────────────────────────────────────────────────┘
```

### 4.2 Tier 1: Meta-Issues

**Definition**: Issues tracking work that spans 2 or more component repositories.

| Aspect | Value |
|--------|-------|
| **Scope** | 2+ component repositories |
| **Ownership** | S.C.O.P.E. owns and manages |
| **Location** | Created in S.C.O.P.E. repository |
| **Label** | `meta-issue` |

**Characteristics**:
- Created and managed in S.C.O.P.E.
- Includes "Components Affected" section listing all repos
- May link to component-level implementation issues
- Closed when all component work is complete

**Examples**:
- Foundation file standardization (all components)
- Documentation aggregation pipeline (all components → S.C.O.P.E. → GitHub Pages)
- Cross-component integration testing

**Template**:
```markdown
## Summary
[Brief description of cross-component work]

## Why This Matters
[Impact on O.A.S.I.S. ecosystem]

## Components Affected
- [ ] MIRAGE - [specific work]
- [ ] DAWN - [specific work]
- [ ] [other components...]

## Component Issues
- MIRAGE: [link to implementation issue]
- DAWN: [link to implementation issue]

## Acceptance Criteria
- [ ] [criteria spanning all components]

## Coordination Notes
[Any cross-component dependencies or sequencing]
```

### 4.3 Tier 2: Tracking References

**Definition**: Links to significant single-component issues that S.C.O.P.E. wants visibility into for coordination purposes.

| Aspect | Value |
|--------|-------|
| **Scope** | Single component repository |
| **Ownership** | Component repo owns; S.C.O.P.E. references |
| **Location** | Issue lives in component repo; reference in S.C.O.P.E. |
| **Label** | `tracking` (in S.C.O.P.E.) |

**Characteristics**:
- Issue is owned by the component repository
- S.C.O.P.E. creates a lightweight tracking reference (not a duplicate issue)
- Used for roadmap visibility and coordination planning
- Reference closed when component issue is resolved

**Examples**:
- Major MIRAGE feature affecting system roadmap
- DAWN API change requiring documentation updates
- GENESIS breaking change affecting dependents

**S.C.O.P.E. Tracking Reference Template**:
```markdown
## Tracking Reference

**Component**: [MIRAGE/DAWN/etc.]
**Source Issue**: [link to component issue]
**Roadmap Impact**: [why S.C.O.P.E. is tracking this]

## Summary
[Brief description from source issue]

## S.C.O.P.E. Actions
- [ ] Update roadmap when complete
- [ ] Coordinate with [other components] if needed
```

**Component Tracking Issue Template**:
```markdown
## Summary
[Description of work]

## Tracks
- **S.C.O.P.E. META issue**: [link to META issue]

## Tasks
- [ ] [task list]

## References
- [relevant links]
```

### 4.4 Coordination Files

Update these S.C.O.P.E. files to reflect meta-issue status:

| File | Purpose |
|------|---------|
| `coordination/roadmaps/*.md` | Per-component roadmaps with meta-issue links |
| `coordination/dependencies/` | Dependency tracking including meta-issues |
| Project board | Kanban view of meta-issues and tracking refs |

---

## 5. Branch Naming Convention

### 5.1 Format

All O.A.S.I.S. repositories SHALL use hierarchical branch names:

```
<type>/<component>/<issue>-<description>
```

| Segment | Description | Example |
|---------|-------------|---------|
| `type` | Branch type (feat, fix, docs, chore) | `feat` |
| `component` | Lowercase component name | `mirage`, `dawn` |
| `issue` | Issue number in that component repo | `3` |
| `description` | Kebab-case description | `foundation-files` |

### 5.2 Examples

```
feat/mirage/3-foundation-files
feat/dawn/1-foundation-files
fix/spark/12-mqtt-reconnect
docs/aura/5-sensor-calibration
chore/genesis/8-dependency-update
```

### 5.3 Rationale

| Benefit | Explanation |
|---------|-------------|
| **Hierarchical grouping** | Git GUIs display as nested folders, grouping by component |
| **S.C.O.P.E. visibility** | When viewing submodule status, branch names are self-documenting |
| **Issue traceability** | Branch name links directly to component issue |
| **Collision avoidance** | Full component name prevents ambiguity (vs single-letter prefix) |

### 5.4 S.C.O.P.E. Branches

For S.C.O.P.E. itself (the meta-repo), omit the component segment:

```
feat/<issue>-<description>
```

Example: `feat/22-foundation-standardization`

### 5.5 Alternatives Considered

| Convention | Example | Verdict | Reason |
|------------|---------|---------|--------|
| Single-letter prefix | `feat/M-3-foundation-files` | Rejected | Collision risk (DAWN/DOCKER, SPARK/S.C.O.P.E.); not self-documenting |
| Issue number only | `feat/3-foundation-files` | Rejected | Less clear when viewing submodule status from S.C.O.P.E. |
| Full name with hyphen | `feat/mirage-3-foundation-files` | Considered | Works, but loses hierarchical grouping in Git GUIs |
| Full name with slash | `feat/mirage/3-foundation-files` | **Adopted** | Hierarchical grouping; self-documenting; no collision risk |

The double-slash format provides the best balance of clarity and organization, especially when viewing branch status across multiple submodules from S.C.O.P.E.

### 5.6 Issue Number Verification

**Critical**: Always verify the issue number before creating a branch.

```bash
# Check available issues first
gh issue list --repo <owner>/<repo>

# Then create the branch with the verified number
git checkout -b feat/<component>/<issue#>-description
```

**Common Mistake**: Using arbitrary numbers or copying from another repo's issues. Each repository has its own issue numbering—issue #3 in MIRAGE is different from issue #3 in DAWN.

**Lesson Learned**: During initial standardization, several branches were created with incorrect issue numbers (e.g., using #1 when the tracking issue was #3). This required branch renaming across multiple repos. The verification step prevents this overhead.

---

## 6. Applied Infrastructure

### 5.1 Current Status

| Repository | Labels | Branch Protection | Milestone | Tracking Issue |
|------------|--------|-------------------|-----------|----------------|
| malcolmhoward/the-oasis-project-meta-repo | ✅ | ✅ | N/A | N/A |
| malcolmhoward/mirage | ✅ | ✅ | ✅ | #3 |
| malcolmhoward/dawn | ✅ | ✅ | ✅ | #3 |
| malcolmhoward/spark | ✅ | ✅ | ✅ | #3 |
| malcolmhoward/aura | ✅ | ✅ | ✅ | #3 |
| malcolmhoward/beacon | ✅ | ✅ | ✅ | #2 |
| malcolmhoward/genesis | ✅ | ✅ | ✅ | #2 |

---

## 7. Future Sections (Reserved)

This ADR is designed to be extended. Future sections may include:

- **7.1 Pull Request Templates** - Standardized PR descriptions
- **7.2 Issue Templates** - Bug reports, feature requests, etc.
- **7.3 GitHub Actions** - CI/CD workflow standards
- **7.4 GitHub Projects** - Project board conventions
- **7.5 Repository Settings** - Visibility, features, etc.

---

## Consequences

### Positive

1. **Consistent infrastructure** - All repos follow same patterns
2. **Protected main branches** - Prevents accidental direct pushes
3. **Clear ownership** - No ambiguity about who manages which issues
4. **Cross-repo visibility** - Tracking issues link to S.C.O.P.E. META issues
5. **Queryable progress** - Can search across repos by label
6. **Extensible** - Easy to add new standards as sections

### Negative

1. **Setup overhead** - Initial configuration required per repo
2. **PR requirement** - Slows down trivial fixes (but adds review)
3. **Maintenance overhead** - Tracking refs must be kept in sync
4. **Label discipline** - Requires consistent labeling across repos

### Neutral

1. **Automation potential** - Could be further automated with GitHub Actions
2. **Learning curve** - New contributors need onboarding on conventions
3. **Organization migration** - When repos move to The-OASIS-Project org, org-level settings can enforce these standards

## Alternatives Considered

### Alternative 1: No Standardization

Let each component repo configure its own infrastructure.

**Rejected because**:
- Inconsistent tracking across repos
- No cross-repo queries possible
- S.C.O.P.E. loses visibility

### Alternative 2: All Issues in S.C.O.P.E.

Mirror all component issues in S.C.O.P.E. for central tracking.

**Rejected because**:
- Duplicates work and creates sync burden
- Unclear ownership (which is the "real" issue?)
- Doesn't scale with ecosystem growth

### Alternative 3: GitHub Projects Only

Use GitHub Projects across repos without issue/label conventions.

**Partially adopted**: Projects complement but don't replace these conventions.

**Not sufficient because**:
- Projects don't establish ownership
- Still need conventions for cross-repo issues

### Alternative 4: Separate ADRs per Topic

Create separate ADRs for labels, branch protection, issues, etc.

**Rejected because**:
- Fragments related decisions
- Harder to maintain consistency
- This unified ADR provides single reference

## Related

- ADR-0001: Project Governance
- ADR-0004: Documentation Infrastructure
- Issue #22: [META] Foundation file standardization across O.A.S.I.S.

## Change History

| Date | Author | Change |
|------|--------|--------|
| 2026-01-31 | Malcolm Howard | Initial draft: labels, branch protection, milestones, issue tracking, branch naming (including 5.6 verification guidance); applied to all component repos |
| TBD | Kris Kersey | Review and approval |
| TBD | TBD | ADR approved, status changed to Accepted |

---

*This ADR follows the pattern established by PFT's ADR template.*
