# ADR 0001: S.C.O.P.E. Project Governance

> **DRAFT STATUS**: This ADR is a draft pending review by project stakeholders.
> Decision on formal governance adoption should be made by Kris Kersey before or after
> this project is added to the O.A.S.I.S. Project GitHub organization.
>
> **Draft Date**: 2026-01-30
> **Draft Author**: Malcolm Howard

---

**Date**: TBD (pending approval)
**Status**: Proposed
**Deciders**: Kris Kersey, Malcolm Howard

## Context

S.C.O.P.E. (System Coordination, Orchestration, Planning & Execution) is the meta-repository coordinating the O.A.S.I.S. ecosystem. As a coordination repository managing multiple component repos (MIRAGE, DAWN, SPARK, AURA, BEACON, GENESIS), it needs clear governance to:

1. Ensure consistent practices across the ecosystem
2. Document contribution workflows
3. Establish templates for component repositories
4. Maintain ethical alignment with Principle Zero

The project was initialized using [Project Foundation Template (PFT)](https://github.com/malcolmhoward/project-foundation-template) v3.7.0.

## Decision

**S.C.O.P.E. adopts PFT's minimal preset as its initial governance foundation, with planned expansion to strict preset as the project matures.**

### Initial Governance (Minimal Preset)

The following files were generated on 2026-01-25:

| File | Purpose | Status |
|------|---------|--------|
| README.md | Project overview, component documentation | Customized |
| CONTRIBUTING.md | Fork-first workflow, contribution guidelines | Generated |
| LICENSE | GNU GPL v3.0 | Generated |
| .gitignore | Standard ignore patterns | Generated |
| FOUNDATION_NOTICE.md | Ethical use notice | Generated |
| GENERATION_LOG.md | File provenance tracking | Generated |

### Additional Governance (Project-Specific)

| File | Purpose | Status |
|------|---------|--------|
| CLAUDE.md | LLM integration guide for O.A.S.I.S. context | Created manually |
| coordination/decisions/adr/ | Architecture Decision Records | This ADR |

### Planned Governance Expansion

As S.C.O.P.E. matures, the following governance files will be adopted:

| Phase | Files | Trigger |
|-------|-------|---------|
| **Phase 1** (Current) | Minimal preset + CLAUDE.md | Project initialization |
| **Phase 2** | CODE_OF_CONDUCT.md, SECURITY.md | First external contributor |
| **Phase 3** | Issue templates, PR template | Active community contribution |
| **Phase 4** | CHANGELOG.md, enhanced security | First versioned release |
| **Phase 5** | Full ADR system, CI workflows | Component integration testing |

## Governance Principles

S.C.O.P.E. aligns with PFT's governance principles:

| Principle | Implementation Status | Notes |
|-----------|----------------------|-------|
| `readme` | ✅ Implemented | Customized for three-tier documentation |
| `contributing` | ✅ Implemented | Fork-first workflow |
| `license` | ✅ Implemented | GPL v3.0 |
| `code-of-conduct` | 📋 Planned | Phase 2 |
| `security` | 📋 Planned | Phase 2 |
| `issue-templates` | 📋 Planned | Phase 3 |
| `pr-template` | 📋 Planned | Phase 3 |
| `changelog` | 📋 Planned | Phase 4 |
| `adr` | 🔄 In Progress | This document |

### Principle Zero Alignment

As a project using PFT, S.C.O.P.E. inherits the "Do No Harm, Allow No Harm" principle:

- **Direct Harm Prevention**: Documentation emphasizes safety in hardware projects
- **Enabling Harm Prevention**: Templates include ethical use notices
- **Passive Harm Prevention**: Governance prevents negligent practices

## Component Repository Governance

S.C.O.P.E. provides governance templates for component repositories:

| Template | Location | Purpose |
|----------|----------|---------|
| CLAUDE-template.md | templates/oasis-foundation/ | LLM integration for components |
| README-template.md | templates/oasis-foundation/ | Component README structure |
| CONTRIBUTING-template.md | templates/oasis-foundation/ | Component contribution guide |

Components should adopt these templates to maintain ecosystem consistency.

### Foundation File Generation Responsibility

**Decision**: Each component generates its own foundation files using PFT.

| Responsibility | Owner | Notes |
|----------------|-------|-------|
| Foundation file generation | Component repo | Each repo runs PFT independently |
| Preset selection | Component maintainer | Based on component maturity |
| File customization | Component maintainer | Add project-specific context |
| Update timing | Component maintainer | Independent of other components |

**Rationale**:
- **Component autonomy**: Each repo owns its governance files, enabling independent updates
- **Operational independence**: Components can update files without blocking on S.C.O.P.E.
- **PFT philosophy**: Templates are educational tools for each project to customize
- **Git history**: Each component has clear provenance via GENERATION_LOG.md

**S.C.O.P.E.'s coordination role**:
- Provides PFT as a submodule (shared tooling)
- Recommends presets per component type
- Aggregates documentation across components
- Tracks component status via submodule references

**"Linking upward" for observability**:
- Submodule references: S.C.O.P.E. tracks which commit each component is at
- Tracking references: Component issues link upward to S.C.O.P.E. tracking issues
- Documentation aggregation: Changes visible in S.C.O.P.E. roadmaps
- Component CLAUDE.md/README: Links to S.C.O.P.E. for ecosystem context

### Authorship Attribution Policy

**Decision**: Use "The O.A.S.I.S. Project" for generated structure, individual names for customization.

| Phase | Attribution | Where Tracked |
|-------|-------------|---------------|
| Generated structure | "The O.A.S.I.S. Project" | PFT --author-name, GENERATION_LOG.md |
| Project-specific customization | Individual contributor | Git history, file header (optional) |
| Provenance | Both | GENERATION_LOG.md |

**Rationale**:
- Reflects collective ownership of template structure
- Credits individuals for project-specific work
- Clear provenance chain via GENERATION_LOG.md
- Consistent across all components

**Example file header** (optional, for customized files):
```markdown
# CLAUDE.md - LLM Integration Guide

Generated with PFT v3.7.0 by The O.A.S.I.S. Project
Customized by: [Contributor Name]
See GENERATION_LOG.md for file provenance.
```

**For existing content being merged**: Preserve original author credits in comments or dedicated attribution section.

## ADR Governance

### Authority

| Role | Authority | Scope |
|------|-----------|-------|
| Project Lead (Kris Kersey) | Final approval | All ADRs affecting O.A.S.I.S. direction |
| Core Maintainers | Propose and review | Any ADR within their component expertise |
| Contributors | Propose | ADRs related to their contributions |

### Process

1. **Proposal**: Author creates ADR with `Status: Proposed`
2. **Review**: Stakeholders review and provide feedback via PR
3. **Revision**: Author incorporates feedback, updates Change History
4. **Approval**: Decider(s) approve; Status updated to `Accepted`
5. **Implementation**: ADR decisions are enacted

### Conventions

See [ADR README](coordination/decisions/adr/README.md) for:
- ADR format and naming conventions
- When to modify vs. create new ADRs
- Change History guidelines
- Index of all ADRs

## Consequences

### Positive

1. **Clear governance foundation** - Project starts with established best practices
2. **Phased adoption** - Governance grows with project needs
3. **Ecosystem consistency** - Templates ensure uniform practices across components
4. **Ethical alignment** - Principle Zero embedded from inception
5. **Provenance tracking** - GENERATION_LOG documents governance evolution

### Negative

1. **Initial overhead** - Governance files require customization
2. **Maintenance burden** - Must update governance as project grows
3. **Template dependency** - Relies on PFT for governance patterns

### Neutral

1. **PFT version tracking** - Must monitor PFT updates for governance improvements
2. **Component autonomy** - Components may customize templates for their needs

## Alternatives Considered

### Alternative 1: No Formal Governance

Start without governance files, add them organically.

**Rejected because**:
- Coordination repos especially need clear contribution guidelines
- Retrofitting governance is harder than starting with it
- Sets poor example for component repositories

### Alternative 2: Full Enterprise Governance Immediately

Adopt PFT's enterprise preset (30 principles) from the start.

**Rejected because**:
- Overkill for current project stage
- Would create unused documentation
- Better to grow governance with actual needs

### Alternative 3: Custom Governance (No PFT)

Create governance files from scratch.

**Rejected because**:
- Reinvents established patterns
- Loses educational structure of PFT
- No provenance tracking
- More maintenance burden

## Implementation

1. ✅ Generate initial governance with PFT v3.7.0 minimal preset
2. ✅ Customize README.md for S.C.O.P.E. context
3. ✅ Create CLAUDE.md for LLM integration
4. 📋 Approve this ADR to document governance decisions
5. 📋 Create component templates in templates/oasis-foundation/
6. 📋 Expand governance per phased plan

## Change History

| Date | Author | Change |
|------|--------|--------|
| 2026-01-25 | Malcolm Howard | Initial generation with PFT v3.7.0 minimal preset |
| 2026-01-30 | Malcolm Howard | Drafted governance ADR |
| 2026-01-31 | Malcolm Howard | Added foundation file generation and authorship policies |
| TBD | TBD | ADR approved, status changed to Accepted |
| TBD | TBD | Phase 2 adoption (CODE_OF_CONDUCT, SECURITY) |
| TBD | TBD | Phase 3 adoption (Issue/PR templates) |

## References

- [Project Foundation Template](https://github.com/malcolmhoward/project-foundation-template) - Governance source
- [PFT ADR-0011](https://github.com/malcolmhoward/project-foundation-template/blob/main/docs/adr/0011-pft-self-governance.md) - PFT's self-governance pattern
- [GENERATION_LOG.md](../../GENERATION_LOG.md) - File provenance tracking
- [FOUNDATION_NOTICE.md](../../FOUNDATION_NOTICE.md) - Ethical use notice

---

*This ADR follows the pattern established by PFT's self-governance (ADR-0011).*
