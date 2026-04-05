# ADR 0007: Component Naming Convention

**Date**: TBD (pending approval)
**Status**: Proposed
**Deciders**: Kris Kersey, Malcolm Howard

## Context

The O.A.S.I.S. ecosystem has organically developed a consistent naming pattern
across its components. As the ecosystem grows and new components are proposed
(both by the core team and by future contributors), the implicit pattern should
be made explicit so that:

- New component names are evaluated against the established register before
  being proposed to stakeholders
- AI agents (Claude Code and others) working in the ecosystem can apply the
  convention without requiring human correction
- Contributors understand the *why* behind existing names, not just the *what*

### Stated Naming Philosophy

The O.A.S.I.S. Project overview ([oasisproject.net/overview/](https://oasisproject.net/overview/)) describes the naming approach directly:

> "all of these components were named to thematically sound like part of the O.A.S.I.S. Project"
> "in many cases, the name was brainstormed attempting to find a fun acronym to back it up"
> "conceived in the spirit of Tony Stark and are not to be taken too literally"

The key criteria are therefore: **thematic cohesion with O.A.S.I.S.**, a **fun and memorable word or phrase**, and an **acronym expansion** that describes the component's function — in that priority order. Names come first; acronym expansions are reverse-engineered to fit.

### Existing Components

| Component | Expansion |
|-----------|-----------|
| O.A.S.I.S. | Open Armor Systems Integrated Suite |
| M.I.R.A.G.E. | Modular Integrated Rendering And Graphics Engine |
| D.A.W.N. | Dynamic Awareness and Wakefulness Node |
| A.U.R.A. | Adaptive Unified Response Architecture |
| S.P.A.R.K. | Sensor Processing and Reaction Kit |
| B.E.A.C.O.N. | Build Environment and Component Organization Node |
| G.E.N.E.S.I.S. | General Embedded Node for Ecosystem Support and Integration Scripts |
| S.C.O.P.E. | System Coordination, Orchestration, Planning & Execution |
| S.T.A.T. | System Telemetry and Analysis Toolkit |

### Components Pending Naming

These components use temporary descriptive names pending the project lead's selection of official O.A.S.I.S. acronyms:

| Temporary Name | Repo | Purpose | Candidate Names |
|----------------|------|---------|-----------------|
| Simulation Framework | the-oasis-project-simulation-repo | Hardware, protocol, and service simulation | E.C.H.O. is the leading candidate per [ADR-0003](0003-simulation-environment-architecture.md) |
| Game Engine Plugin | the-oasis-project-game-engine-plugin-repo | OCP client plugin for game engines (Godot 4.5) | No candidates proposed yet — see [meta-issue #43](https://github.com/malcolmhoward/the-oasis-project-meta-repo/issues/43) |

An observer may notice that many of these names evoke natural or atmospheric phenomena, but the project lead has not described this as a deliberate constraint — it is a characteristic of the existing set, not a stated requirement for new names.

### Why This Matters for New Components

Without explicit documentation, new component names risk:

1. **Breaking the register** — generic technical slugs (`oasis-sim`,
   `oasis-testbed`) read as infrastructure rather than ecosystem components
2. **Thematic inconsistency** — names in a different register (mechanical,
   clinical, abstract) reduce the coherence of the ecosystem identity
3. **Premature naming** — names proposed before evaluating thematic fit are
   harder to change once used in documentation, issues, and conversations

### Trigger for This ADR

Naming analysis performed during the simulation environment architecture work
(see ADR-0003) identified the need to make the implicit convention explicit.
The analysis also identified candidate names for the simulation environment
repo, evaluated against this pattern.

## Decision

**All new O.A.S.I.S. component names must be evaluated against the thematic
naming pattern before being proposed to stakeholders.**

### The Criteria

Based on the stated philosophy at [oasisproject.net/overview/](https://oasisproject.net/overview/), a good component name:

1. **Sounds like part of O.A.S.I.S.** — thematic cohesion with the existing ecosystem comes first
2. **Is fun and memorable** — the word or phrase should be immediately evocative; Kris describes the naming as playful and "not to be taken too literally"
3. **Has an acronym expansion that describes the component's function** — this is the secondary criterion; expansions are reverse-engineered to fit the chosen name, not the other way around

When evaluating a candidate, ask: does it *feel* like it belongs alongside MIRAGE, DAWN, AURA, and S.P.A.R.K.? That judgment takes precedence over whether the acronym is perfectly accurate.

### A Mental Framework for Brainstorming

Kris has not prescribed a specific thematic register beyond "sounds like O.A.S.I.S." and "spirit of Tony Stark." However, looking across the existing names, a pattern emerges that can help when brainstorming candidates: most names evoke **natural phenomena that exist at the boundary of perception** — things you can sense or feel but cannot physically hold (a mirage, an aura, a dawn, a spark). This is not a stated rule, but it is a useful filter: if a candidate name evokes something from this register, it is likely to feel native to the ecosystem.

### Naming Authority

**Kris Kersey selects all official component names.** This ADR establishes the
convention for evaluation and proposal — it does not transfer naming authority.
The process is:

1. Identify candidate names that fit the thematic register
2. Evaluate each against the existing ecosystem (avoid phonetic/visual
   collision with existing names)
3. Present candidates to Kris with rationale
4. Kris selects the official name
5. ADR for the new component (if warranted) documents the decision

### Working Names

Components under development may use a working name before Kris has selected
the official name. Working names should:

- Be clearly labeled as provisional in all documentation
- Follow the thematic convention where possible, so the working name is a
  candidate rather than a placeholder
- Not be used in repo names, PyPI packages, or other hard-to-rename artifacts
  until the official name is selected

### What This Convention Does Not Cover

- **Repo naming** — repos use kebab-case slugs derived from the component name
  (e.g., `the-oasis-project-mirage-repo`). The repo slug is not required to
  spell out the acronym.
- **Internal module/package naming** — Python packages, C namespaces, and
  similar internal identifiers follow their language's conventions and are not
  bound by this ADR.
- **Feature names and subsystems** — names for features within a component
  (e.g., DAWN's subsystems) are at the discretion of the component maintainer,
  though the thematic register is encouraged.

## Alternatives Considered

### Option A: No explicit convention (status quo)
Let naming evolve organically as it has until now.

**Rejected because**: The pattern is coherent enough that breaking it would be
noticeable and jarring. Making it explicit costs little and prevents drift,
especially as external contributors join the ecosystem.

### Option B: Strict acronym-first naming
Require that the acronym expansion accurately describes the component before
evaluating thematic fit.

**Rejected because**: Acronym engineering often produces strained expansions
that read as post-hoc justifications. The existing names show that thematic
resonance and functional accuracy can coexist — neither should be treated as
a hard gate.

### Option C: Expand governance to include naming committee
Require a formal review process for all proposed names.

**Rejected because**: The project is small enough that Kris's direct
involvement in name selection is appropriate. A committee adds process overhead
without adding value at current scale.

## Consequences

### Positive

1. **Ecosystem coherence** — new components will feel native to the O.A.S.I.S.
   aesthetic rather than bolted on
2. **AI agent guidance** — Claude Code and other agents can apply the convention
   without requiring human correction or re-explanation each session
3. **Contributor onboarding** — contributors understand the naming philosophy
   before proposing names, reducing review friction
4. **Decision traceability** — the rationale for the pattern is documented,
   so future contributors don't have to reverse-engineer it from the existing
   names

### Negative

1. **Creative constraint** — the thematic register is deliberately narrow;
   a technically excellent name that doesn't fit may need to be adapted or
   rejected
2. **Acronym strain** — fitting a meaningful word into an acronym that also
   accurately describes a component is genuinely hard; the convention may
   occasionally force a compromise

### Neutral

1. **Kris retains authority** — this ADR documents a pattern Kris has
   established; it does not change how naming decisions are made

## Candidate Name Reference

The following table captures candidates evaluated for the simulation environment
repo (ADR-0003). It is preserved here as a reference for the thematic pattern
in practice, and because E.C.H.O. is a new candidate not yet in ADR-0003.

| Candidate | Thematic fit | Scope fit | Notes |
|-----------|:---:|:---:|-------|
| **E.C.H.O.** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | An echo reproduces behavior faithfully without being the original — precise metaphor for simulation. Short, memorable, no hardware specificity. Recommended addition to ADR-0003 candidate table. |
| **P.H.A.N.T.O.M.** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | Non-physical presence — maps directly to simulated OCP peers. Most semantically precise candidate. |
| **M.I.S.T.** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | "System" scope covers Device/Network/Platform layers. Complements H.A.Z.E. thematically. |
| **M.I.R.R.O.R.** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | Reflects reality faithfully; strong simulation metaphor. |
| **H.A.Z.E.** | ⭐⭐⭐⭐ | ⭐⭐⭐ | Current working name. "Hardware" in expansion undersells scope now that Network and Platform layers are included; expansion can be revised if selected. |
| **V.E.I.L.** | ⭐⭐⭐ | ⭐⭐⭐⭐ | Fits register but a veil *obscures* rather than *replicates* — slightly wrong metaphor. |
| **S.H.A.D.O.W.** | ⭐⭐⭐ | ⭐⭐⭐ | A shadow requires the real object — opposite of what simulation does. |

See ADR-0003 for the full simulation environment naming decision and Kris's
selection authority.

## Change History

| Date | Author | Change |
|------|--------|--------|
| 2026-03-08 | Malcolm Howard | Initial draft — naming convention extracted from simulation environment architecture analysis |
