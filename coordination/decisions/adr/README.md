# Architecture Decision Records

This directory contains Architecture Decision Records (ADRs) for the O.A.S.I.S. ecosystem, managed through S.C.O.P.E.

## What is an ADR?

An ADR captures an important architectural decision along with its context and consequences. They serve as:
- Historical record of why decisions were made
- Onboarding documentation for new contributors
- Reference when revisiting past decisions

## ADR Lifecycle

### Status Values

| Status | Meaning |
|--------|---------|
| `Proposed` | Under consideration, pending stakeholder review |
| `Accepted` | Approved and in effect |
| `Deprecated` | No longer recommended but still documented |
| `Superseded` | Replaced by a newer ADR (link to replacement) |

### Naming Convention

ADR files use the format `NNNN-short-title.md`:
- **No DRAFT prefix** - The Status field inside the document indicates approval state
- **Sequential numbering** - 0001, 0002, 0003, etc.
- **Kebab-case title** - Descriptive, lowercase with hyphens

**Example**: `0002-github-infrastructure.md` with `Status: Proposed`

### Workflow

1. **Draft** - Write ADR in scratch directory for initial development
2. **Propose** - Move to `coordination/decisions/adr/` with `Status: Proposed`
3. **Review** - Stakeholders review and provide feedback
4. **Accept** - Update `Status: Accepted` and set decision date
5. **Maintain** - Update Change History as implementation evolves

### When to Move from Draft to Proposed

Move an ADR to the formal location (`coordination/decisions/adr/`) **when it begins guiding implementation**, not after implementation is complete.

| Timing | Rationale |
|--------|-----------|
| **Before/during implementation** | ADR appears in commit history alongside the work it guided; demonstrates decision-driven development |
| **After implementation** | Loses traceability; appears as retroactive documentation rather than guiding document |

**Benefits of early formalization:**
- Git history shows the ADR preceded or accompanied implementation
- Future readers can see decisions drove the work, not vice versa
- `Status: Proposed` still indicates the ADR awaits formal approval
- ADR can evolve during implementation (tracked via Change History)

**The `Status: Proposed` field signals the ADR is not yet approved**, so moving it early does not imply finality. The formal location indicates the ADR is actively guiding decisions, while the status indicates approval state.

## ADR Format

Each ADR follows this structure:

1. **Status**: Proposed, Accepted, Deprecated, Superseded
2. **Date**: When the decision was made (TBD until accepted)
3. **Deciders**: Who has authority to approve
4. **Context**: What situation prompted this decision
5. **Decision**: What we decided to do
6. **Consequences**: What happens as a result (positive, negative, neutral)
7. **Alternatives Considered**: Other options evaluated
8. **Change History**: Track revisions during drafting and after acceptance

## Index

| ADR | Title | Status | Date |
|-----|-------|--------|------|
| [0001](0001-project-governance.md) | Project Governance | Proposed | TBD |
| [0002](0002-github-infrastructure.md) | GitHub Infrastructure Standards | Proposed | TBD |
| [0003](0003-hardware-mocking.md) | Hardware Mocking | Proposed | TBD |
| [0004](0004-documentation-infrastructure.md) | Documentation Infrastructure | Proposed | TBD |
| [0005](0005-dockerfile-independence.md) | Independent Dockerfiles Per Platform | Proposed | TBD |

## Creating New ADRs

1. Start in `scratch/governance-drafts/` for initial development
2. When ready for review, copy to this directory as `NNNN-short-title.md`
3. Set `Status: Proposed` and `Date: TBD`
4. Update this index
5. Submit via PR for stakeholder review
6. Upon approval, update Status to `Accepted` and set the date

## Governance Authority

See [ADR-0001: Project Governance](0001-project-governance.md) for:
- Who has authority to approve ADRs
- Stakeholder roles and responsibilities
- Decision-making process

## Relationship to PFT

S.C.O.P.E. ADRs follow conventions established by the [Project Foundation Template](https://github.com/malcolmhoward/project-foundation-template) ADR system. This ensures consistency across the O.A.S.I.S. ecosystem.

## Modifying ADRs

### When to Modify vs. Create New

| Situation | Action | Rationale |
|-----------|--------|-----------|
| Clarifying language, fixing typos | Modify existing | No decision change |
| Adding implementation details | Modify existing | Enriches context without changing decision |
| Expanding scope of existing decision | Modify existing | Same core decision, broader application |
| Changing a decision significantly | Create new ADR | Preserves historical record; supersede the old |
| Reversing a decision | Create new ADR | Document why the reversal happened |
| Addressing a related but distinct concern | Create new ADR | Keep ADRs focused and atomic |

### Change History

Every ADR should include a Change History section tracking modifications:

```markdown
## Change History

| Date | Author | Change |
|------|--------|--------|
| 2026-01-31 | Name | Initial draft |
| 2026-02-01 | Name | Added section on X based on implementation feedback |
| TBD | Name | Accepted after stakeholder review |
```

**Guidelines**:
- Log all substantive changes (not typo fixes)
- Include author for accountability
- Note what prompted the change when relevant
- Keep entries concise but informative

### Superseding ADRs

When a new ADR supersedes an old one:

1. **New ADR**: Reference the superseded ADR in context
2. **Old ADR**: Update status to `Superseded by [ADR-NNNN](link)`
3. **Both**: Cross-link for discoverability
4. **Index**: Update both entries

This preserves the decision history while clearly indicating current guidance.

## Philosophy

ADRs in this project follow an education-first approach:
- **WHAT**: Clearly state the decision
- **WHY**: Explain the context and reasoning
- **HOW**: Describe implementation and consequences
- **WHEN**: Track evolution and know when decisions change

We believe understanding past decisions is as important as making new ones.
