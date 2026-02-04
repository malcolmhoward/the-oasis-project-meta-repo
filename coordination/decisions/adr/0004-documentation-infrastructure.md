# ADR 0004: Documentation Infrastructure and GitHub Pages Integration

**Date**: TBD (pending approval)
**Status**: Proposed
**Deciders**: Kris Kersey, Malcolm Howard

## Context

The O.A.S.I.S. ecosystem needs a unified documentation site that:

1. Aggregates documentation from all component repositories
2. Provides a public-facing site for project information
3. Maintains consistency with S.C.O.P.E.'s coordination role
4. Tracks documentation changes alongside code changes

### Problem

Without a clear documentation architecture:
- Component documentation is scattered across repos
- Public-facing documentation has no clear relationship to S.C.O.P.E.
- Documentation updates are disconnected from code changes
- No single source of truth for ecosystem-wide information

## Decision

**Add GitHub Pages repository as a S.C.O.P.E. submodule and establish it as the documentation aggregation point.**

### GitHub Pages as S.C.O.P.E. Submodule

| Aspect | Value |
|--------|-------|
| **Repository** | The-OASIS-Project.github.io |
| **Submodule Location** | `repos/github-pages` |
| **Build System** | MkDocs with Material theme |
| **Content Source** | S.C.O.P.E. submodules + Pages-specific content |

### Relationship Diagram

```
S.C.O.P.E. (Coordination)
├── repos/mirage (submodule)
│   └── README.md, docs/
├── repos/dawn (submodule)
│   └── README.md, docs/
├── repos/github-pages (submodule)
│   ├── docs/                        ← Aggregated content
│   ├── mkdocs.yml                   ← Build configuration
│   └── site/                        ← Generated output
└── coordination/roadmaps/
    └── Linked from Pages
```

### Why This Is Not a Circular Dependency

The relationships are asymmetric and serve different purposes:

| Relationship | Direction | Purpose |
|--------------|-----------|---------|
| S.C.O.P.E. → Pages | Submodule pointer | Track which commit Pages is at |
| Pages → Components | Build process | Pull content for static site |

S.C.O.P.E. coordinates the **pointer** to Pages; Pages aggregates the **content** from S.C.O.P.E.'s other submodules. These are distinct concerns.

### Content Aggregation Pattern

| Content Type | Source | Pages Location |
|--------------|--------|----------------|
| Component guides | `repos/*/docs/guide.md` | `docs/components/` |
| Component API docs | `repos/*/docs/` | `docs/components/` |
| Coordination protocols | `coordination/protocols/` | `docs/architecture/` |
| ADRs | `coordination/decisions/adr/` | `docs/decisions/` |
| Pages-specific | `repos/github-pages/` | `docs/` (root) |

### Build Process

1. Run `scripts/aggregate_docs.py` to pull content from sibling directories
2. MkDocs generates static site from aggregated content
3. GitHub Actions deploys to GitHub Pages

**Important**: The build process does NOT require S.C.O.P.E. as a dependency. Pages can be built:
- Standalone (using only its own content)
- As part of S.C.O.P.E. (with aggregated content from submodules)

### Content Decomposition Principle

**Source of Truth**: Documentation content should live in the repository closest to the code it describes.

| Content Type | Source of Truth | Why |
|--------------|-----------------|-----|
| Component installation/usage | Component repo `docs/` | Changes with code |
| Component configuration | Component repo `docs/` | Maintained by component maintainers |
| Cross-component protocols | S.C.O.P.E. `coordination/` | Spans multiple components |
| Ecosystem overview | S.C.O.P.E. or Pages | High-level, rarely changes |
| Site-specific (videos, credits) | GitHub Pages | Presentation-only |

**Benefits of decomposition**:
- Documentation reviewed alongside code changes
- Contributors find docs in the repo they're working on
- Clear ownership (component maintainers own their docs)
- Enables documentation-as-code workflow

**Anti-pattern**: Monolithic documentation in a separate docs repo that drifts from actual code.

### Asset Management Strategy

Documentation often references images and other assets. For portability across viewing contexts (GitHub, local, aggregated site), use **absolute URLs to the public site**.

| Context | Asset Path | Works? |
|---------|------------|--------|
| GitHub Pages site | `/assets/image.png` | Yes |
| Component repo on GitHub | `/assets/image.png` | No |
| Local development | `/assets/image.png` | No |
| Component repo with absolute URL | `https://www.oasisproject.net/assets/image.png` | Yes |

**Recommendation**: In component repo docs, reference assets using the full public URL:

```markdown
<img src="https://www.oasisproject.net/assets/component-diagram.png" alt="Diagram" />
```

**Trade-offs**:
- Works everywhere (GitHub, local, aggregated)
- No asset duplication across repos
- Requires public site to be available
- Assets must be deployed before docs reference them

**Future consideration**: For offline/local development, consider a build-time asset resolution script that can substitute local paths.

### Migration Pattern: Decomposing Monolithic Docs

When migrating from a monolithic documentation site to the decomposed model:

**Step 1: Identify content ownership**
```
Existing docs/           →  Destination
├── mirage.md            →  repos/mirage/docs/guide.md
├── dawn.md              →  repos/dawn/docs/guide.md
├── comms.md             →  coordination/protocols/mqtt.md
├── overview.md          →  Keep in Pages or S.C.O.P.E.
└── index.md             →  Keep in Pages (site-specific)
```

**Step 2: Create `docs/` folders in component repos**
```bash
mkdir -p repos/mirage/docs
mkdir -p repos/dawn/docs
# etc.
```

**Step 3: Copy content and update asset paths**
```bash
cp github-pages/docs/mirage.md repos/mirage/docs/guide.md
# Update: src="/assets/" → src="https://www.oasisproject.net/assets/"
```

**Step 4: Update GitHub Pages to aggregate**
- Configure aggregation script to pull from component `docs/` folders
- Update mkdocs.yml navigation structure

**Step 5: Verify and iterate**
- Test that docs render correctly in all contexts
- Update navigation structure as needed

### Documentation Versioning Strategy

Documentation improvements follow a linear milestone progression with tagged versions marking key states. This allows comparing different documentation states and reviewing improvements incrementally.

#### Milestone Tags

Use tags on a single branch to mark documentation milestones:

```
feat/github-pages/<issue>-foundation-files
├── current state ← tag: docs-v1-baseline-rollup
├── ... gap-fill commits ...
├── gap-fill complete ← tag: docs-v2-gap-filled
├── ... external standard commits ...
└── external standard complete ← tag: docs-v3-external-standard
```

| Tag | Description |
|-----|-------------|
| `docs-v1-baseline-rollup` | Initial aggregation from component repos |
| `docs-v2-gap-filled` | Documentation gaps filled per current standard |
| `docs-v3-external-standard` | Aligned to external documentation standard |

#### Coordinated State via S.C.O.P.E.

Since documentation spans multiple repos, S.C.O.P.E. submodule pointers capture coordinated states:

```
S.C.O.P.E. commit (tag: docs-v2-gap-filled)
├── repos/mirage @ commit with enhanced docs
├── repos/aura @ commit with enhanced docs
├── repos/github-pages @ commit with re-aggregated content
└── coordination/standards/component-documentation.md
```

This allows checking out a specific documentation version across the entire ecosystem.

#### Multi-Branch Preview Options

GitHub Pages only deploys one branch at a time. For comparing multiple documentation versions:

| Approach | How It Works | Use Case |
|----------|--------------|----------|
| **Local preview** | `mkdocs serve` per branch/tag | Development, quick comparison |
| **Git worktrees** | Multiple checkouts, parallel servers | Side-by-side local comparison |
| **Netlify/Cloudflare** | Automatic branch deploy previews | Stakeholder review, no local setup |
| **Subdirectory deploy** | GitHub Actions deploys to `/v1/`, `/v2/` | Permanent version archive |

**Local preview with git worktrees:**

```bash
# Preview v1 (baseline)
git checkout docs-v1-baseline-rollup
mkdocs serve  # localhost:8000

# In another terminal, preview v2 (gap-filled)
git worktree add ../preview-v2 docs-v2-gap-filled
cd ../preview-v2
mkdocs serve -a localhost:8001  # localhost:8001

# Compare in browser tabs
```

**External preview services:**

For stakeholder review without local setup, connect the GitHub Pages repo to Netlify or Cloudflare Pages. These services provide automatic branch previews:

```
main              → your-site.netlify.app
docs-v2-gap-filled → docs-v2-gap-filled--your-site.netlify.app
```

#### Future Consideration: External Documentation Standards

The `docs-v3-external-standard` milestone anticipates aligning to a recognized documentation framework. Candidates include:

| Framework | Focus | Consideration |
|-----------|-------|---------------|
| [Diátaxis](https://diataxis.fr/) | Tutorial/How-to/Reference/Explanation structure | Strong conceptual model |
| [Google Developer Documentation Style Guide](https://developers.google.com/style) | Style and formatting | Industry standard |
| [Write the Docs](https://www.writethedocs.org/guide/) | Community best practices | Practical guidance |

Selection of an external standard is deferred until baseline documentation is complete.

## Implementation

### Phase 1: Add Submodule

```bash
cd <S.C.O.P.E. repo root>
git submodule add <github-pages-repo-url> repos/github-pages
git commit -m "chore: Add GitHub Pages as coordinated submodule"
```

### Phase 2: Configure Build System

1. Use MkDocs with Material theme (existing configuration)
2. Create navigation structure for component docs
3. Add build configuration (mkdocs.yml)
4. Test local build

### Phase 3: Set Up Aggregation

1. Create `scripts/aggregate_docs.py` for content aggregation
2. Create `scripts/test_aggregate_docs.py` for test coverage
3. Configure GitHub Actions workflow
4. Deploy to GitHub Pages

### Phase 4: Documentation Standards

1. Create `coordination/standards/component-documentation.md`
2. Define expected file structure for components
3. Establish review process for doc changes

## Consequences

### Positive

1. **Unified documentation** - Single site for all O.A.S.I.S. information
2. **Change tracking** - Doc changes tracked alongside code via submodules
3. **Consistent coordination** - Pages treated like any other component
4. **Clear ownership** - Pages repo owns build process; components own content

### Negative

1. **Build complexity** - Aggregation adds build steps
2. **Sync overhead** - Must update submodule when Pages changes
3. **Learning curve** - Contributors need to understand aggregation model

### Neutral

1. **Tool choice** - MkDocs vs Jekyll is implementation detail
2. **Automation level** - Can start manual, automate later

## Alternatives Considered

### Alternative 1: Pages Separate from S.C.O.P.E.

Keep GitHub Pages as an independent repository with no S.C.O.P.E. relationship.

**Rejected because**:
- Loses documentation-as-code tracking
- Disconnects docs from code changes
- Inconsistent with S.C.O.P.E.'s coordination role

### Alternative 2: Documentation in S.C.O.P.E. Directly

Put all documentation in S.C.O.P.E. without a Pages submodule.

**Rejected because**:
- GitHub Pages requires specific repo structure
- Conflates coordination (S.C.O.P.E.) with publishing (Pages)
- Harder to manage Pages-specific configuration

### Alternative 3: No Aggregation

Each component publishes its own docs independently.

**Rejected because**:
- No unified navigation or search
- Inconsistent look and feel
- Users must know where each component's docs are

## Related

- ADR-0001: Project Governance (S.C.O.P.E.'s coordination role)
- ADR-0002: GitHub Infrastructure (issue tracking system)
- `coordination/standards/component-documentation.md` - Documentation standard

## Change History

| Date | Author | Change |
|------|--------|--------|
| 2026-01-31 | Malcolm Howard | Initial draft |
| 2026-02-01 | Malcolm Howard | Added content decomposition, asset management, and migration pattern sections |
| 2026-02-03 | Malcolm Howard | Added documentation versioning strategy section; moved to formal location, status changed to Proposed |
| TBD | Kris Kersey | Review and approval |
| TBD | TBD | ADR approved, status changed to Accepted |

---

*This ADR follows the conventions documented in the [ADR README](README.md).*
