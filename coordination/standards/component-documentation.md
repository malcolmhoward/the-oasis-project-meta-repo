# Component Documentation Standard

This document defines the baseline documentation structure for O.A.S.I.S. component repositories to ensure consistency and quality across the ecosystem.

## Documentation Location

All component documentation lives in the `docs/` folder at the repository root:

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

Every component MUST have a `docs/guide.md` file that serves as the primary documentation. This file is aggregated to GitHub Pages.

### Required Sections

| Section | Purpose |
|---------|---------|
| **Title & Logo** | Component name, acronym expansion, logo from public assets |
| **Overview** | What the component does and its role in O.A.S.I.S. |
| **Hardware** | Required hardware with links to purchase/specs |
| **Software Dependencies** | Libraries, frameworks, tools needed |
| **Installation** | Step-by-step setup instructions |
| **Configuration** | How to configure the component |
| **Usage** | How to use the component |
| **Communication** | Protocol reference (link to mqtt-protocols.md) |
| **Troubleshooting** | Common issues and solutions |
| **Related Components** | Links to components this one interacts with |

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

## Component-Specific Documentation

Beyond `guide.md`, components may have additional documentation:

| Component Type | Additional Docs |
|----------------|-----------------|
| Firmware (AURA, SPARK) | `flashing.md`, `calibration.md` |
| Software (MIRAGE, DAWN) | `configuration.md`, `api.md` |
| Hardware (BEACON) | `parts-catalog.md`, `print-settings.md` |
| Utilities (GENESIS) | `scripts.md`, `tools.md` |

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

- [ ] All required sections present
- [ ] Asset URLs use absolute paths to oasisproject.net
- [ ] Hardware links are valid
- [ ] Code examples are tested
- [ ] No placeholder text remains
- [ ] Cross-references to other components are accurate
- [ ] Spelling and grammar checked

## Examples

**Comprehensive documentation:**
- [MIRAGE guide.md](../../repos/mirage/docs/guide.md) - Full-featured example
- [DAWN guide.md](../../repos/dawn/docs/guide.md) - Includes local LLM setup

**Minimal documentation (needs enhancement):**
- [AURA guide.md](../../repos/aura/docs/guide.md)
- [SPARK guide.md](../../repos/spark/docs/guide.md)
