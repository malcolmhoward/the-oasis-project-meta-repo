# Ecosystem Documentation Standard

This document defines the baseline documentation structure for all repositories in the O.A.S.I.S. ecosystem, including components, coordination infrastructure, and the documentation portal.

## Scope

This standard covers **technical documentation** (`docs/guide.md` and related files). Governance files (`LICENSE`, `CONTRIBUTING.md`, `CLAUDE.md`, `README.md`) are covered separately by S.C.O.P.E. issue #22 (Foundation file standardization).

## Documentation Location

All repository documentation lives in the `docs/` folder at the repository root:

```
<component>/
├── docs/
│   ├── guide.md          # Primary documentation (required)
│   ├── <topic>.md        # Additional topic-specific docs (optional)
│   └── images/           # Local images if needed (optional)
├── README.md             # Project overview with link to docs/
└── ...
```

## Required File: `docs/guide.md`

Every repository MUST have a `docs/guide.md` file that serves as the primary documentation. For component repositories, this file is aggregated to GitHub Pages.

### Required Sections

Not all sections apply to every repository. Sections marked as conditional may be omitted with a brief note explaining why (e.g., "GENESIS has no hardware requirements").

| Section | Purpose | Applicability |
|---------|---------|---------------|
| **Title & Logo** | Repository name, acronym expansion, logo from public assets | All repositories |
| **Overview** | What the repository provides and its role in O.A.S.I.S. | All repositories |
| **Hardware** | Required hardware with links to purchase/specs | Hardware-dependent components (MIRAGE, DAWN, AURA, SPARK, BEACON) |
| **Software Dependencies** | Libraries, frameworks, tools needed | All repositories |
| **Installation** | Step-by-step setup instructions | All repositories |
| **Configuration** | How to configure the component/system | Repositories with configurable behavior |
| **Usage** | How to use the component/system | All repositories |
| **Communication** | MQTT topics and protocol reference | Components that communicate via MQTT (MIRAGE, DAWN, AURA, SPARK) |
| **Troubleshooting** | Common issues and solutions | All repositories |
| **Related Components** | Links to other repositories this one interacts with | All repositories |

#### Applicability by Repository

| Section | MIRAGE | DAWN | AURA | SPARK | BEACON | GENESIS | GitHub Pages | S.C.O.P.E. |
|---------|:------:|:----:|:----:|:-----:|:------:|:-------:|:------------:|:----------:|
| Title & Logo | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes |
| Overview | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes |
| Hardware | Yes | Yes | Yes | Yes | Yes | No | No | No |
| Software Dependencies | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes |
| Installation | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes |
| Configuration | Yes | Yes | Yes | Yes | No | Yes | Yes | Yes |
| Usage | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes |
| Communication | Yes | Yes | Yes | Yes | No | No | No | No |
| Troubleshooting | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes |
| Related Components | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes |

### Section Templates

#### Title & Logo
```markdown
# <COMPONENT> - <Full Name> (<Brief Description>)

<img src="https://www.oasisproject.net/assets/<Component>_Logo_bg.png" alt="<COMPONENT> Logo" width="350" align="right">

<Brief overview paragraph>
```

#### Hardware Section
```markdown
## Hardware

| Component | Description | Link |
|-----------|-------------|------|
| <Name> | <What it does> | [Product Page](<url>) |
```

#### Installation Section
```markdown
## Installation

### Prerequisites

- <Prerequisite 1>
- <Prerequisite 2>

### Steps

1. <Step 1>
2. <Step 2>
```

#### Communication Section

Only applicable to components that communicate via MQTT (MIRAGE, DAWN, AURA, SPARK). BEACON (CAD models), GENESIS (utilities), GitHub Pages (documentation portal), and S.C.O.P.E. (coordination) do not use MQTT and should omit this section.

```markdown
## Communication

This component communicates via MQTT. See the [O.A.S.I.S. Communication Protocols](https://www.oasisproject.net/architecture/mqtt-protocols/) for message formats.

### Topics

| Topic | Direction | Purpose |
|-------|-----------|---------|
| `<topic>` | Publish/Subscribe | <Description> |
```

#### Related Components
```markdown
## Related Components

- [M.I.R.A.G.E.](https://www.oasisproject.net/components/mirage/) - <Relationship>
- [D.A.W.N.](https://www.oasisproject.net/components/dawn/) - <Relationship>
```

## Asset References

**Always use absolute URLs** to the public site for images and assets:

```markdown
<!-- Correct: Works everywhere (GitHub, local, aggregated site) -->
<img src="https://www.oasisproject.net/assets/image.png" alt="Description">

<!-- Incorrect: Breaks in component repo context -->
![Description](/assets/image.png)
```

See [ADR-0004: Documentation Infrastructure](../decisions/adr/0004-documentation-infrastructure.md) for rationale.

## Repository-Specific Documentation

Beyond `guide.md`, repositories may have additional documentation:

| Repository Type | Additional Docs |
|-----------------|-----------------|
| Firmware (AURA, SPARK) | `flashing.md`, `calibration.md` |
| Software (MIRAGE, DAWN) | `configuration.md`, `api.md` |
| Hardware (BEACON) | `parts-catalog.md`, `print-settings.md` |
| Utilities (GENESIS) | `scripts.md`, `tools.md` |
| Portal (GitHub Pages) | `aggregation.md`, `deployment.md` |
| Coordination (S.C.O.P.E.) | `submodules.md`, `branching.md` |

## Aggregation Mapping

The `aggregate_docs.py` script in GitHub Pages maps component docs:

| Source | Destination |
|--------|-------------|
| `repos/<component>/docs/guide.md` | `docs/components/<component>.md` |
| `repos/<component>/docs/<topic>.md` | `docs/components/<component>-<topic>.md` |
| `coordination/protocols/*.md` | `docs/architecture/*.md` |

To add new documentation to the aggregation, update the `COMPONENT_DOCS` mapping in `repos/github-pages/scripts/aggregate_docs.py`.

## Quality Checklist

Before committing documentation changes:

- [ ] All required sections present (per applicability matrix above)
- [ ] Conditional sections either filled or explicitly noted as N/A
- [ ] Asset URLs use absolute paths to oasisproject.net
- [ ] Hardware links are valid
- [ ] Code examples are tested
- [ ] No placeholder text remains (no `<Component>`, `<Description>`, `<url>`, etc. from templates)
- [ ] Cross-references to other components are accurate
- [ ] Spelling and grammar checked

## Current State

Status of repository documentation relative to this standard:

| Repository | guide.md | Content Level | Key Gaps |
|------------|:--------:|---------------|----------|
| MIRAGE | Yes | Comprehensive | Missing: Overview, Communication, Troubleshooting, Related Components |
| DAWN | Yes | Comprehensive | Needs review against standard |
| AURA | Yes | Minimal | Missing: Overview, full Installation, Configuration, Usage, Communication, Troubleshooting, Related |
| SPARK | Yes | Needs review | Needs review against standard |
| BEACON | **No** | parts-catalog.md only | Missing guide.md entirely |
| GENESIS | **No docs/** | None | Everything |
| GitHub Pages | **No** | Has README and CLAUDE.md but no guide.md | Missing guide.md; Configuration and Usage content exists in CLAUDE.md but not in standard format |
| S.C.O.P.E. | **No** | Has extensive README.md and CLAUDE.md | Missing guide.md; coordination docs exist but not in standard format |

**Examples of existing documentation:**
- [MIRAGE guide.md](../../repos/mirage/docs/guide.md) - Most complete; good reference for Hardware and Configuration sections
- [DAWN guide.md](../../repos/dawn/docs/guide.md) - Includes additional topic file (local-llm.md)
- [AURA guide.md](../../repos/aura/docs/guide.md) - Good Title/Logo and Hardware sections; needs remaining sections
- [BEACON parts-catalog.md](../../repos/beacon/docs/parts-catalog.md) - Useful content, needs guide.md wrapper
