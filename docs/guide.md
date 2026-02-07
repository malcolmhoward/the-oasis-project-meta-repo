# S.C.O.P.E. - [Name Pending] (Ecosystem Coordination)

## Overview

S.C.O.P.E. (name and acronym pending stakeholder selection) is the meta-repository that coordinates the O.A.S.I.S. wearable computing ecosystem. It tracks all component repositories as git submodules, provides shared governance tooling, and maintains ecosystem-level documentation, standards, and decision records.

S.C.O.P.E. serves three primary functions:
- **Coordination**: Tracks component repo states via submodule references, ensuring reproducible ecosystem snapshots
- **Standards**: Maintains ecosystem-wide documentation standards, communication protocols, and architecture decision records (ADRs)
- **Tooling**: Provides shared infrastructure including PFT (Project Foundation Template) for governance file generation

## Software Dependencies

| Tool | Purpose |
|------|---------|
| Git (with submodule support) | Repository coordination and version tracking |
| Python 3.7+ | PFT governance template generation |
| GitHub CLI (`gh`) | Issue management and cross-repo coordination |

## Installation

### Prerequisites

- Git 2.13+ (for submodule support)
- GitHub account with access to component repositories

### Setup

```bash
# Clone with all submodules
git clone --recurse-submodules https://github.com/malcolmhoward/the-oasis-project-meta-repo.git
cd the-oasis-project-meta-repo

# Or initialize submodules after cloning
git submodule update --init --recursive
```

### Submodule Structure

```
the-oasis-project-meta-repo/
├── repos/
│   ├── mirage/                    # M.I.R.A.G.E. HUD system
│   ├── dawn/                      # D.A.W.N. AI assistant
│   ├── aura/                      # A.U.R.A. helmet firmware
│   ├── spark/                     # S.P.A.R.K. gauntlet firmware
│   ├── beacon/                    # B.E.A.C.O.N. CAD models
│   ├── genesis/                   # G.E.N.E.S.I.S. Python utilities
│   ├── github-pages/             # Documentation portal
│   └── project-foundation-template/  # PFT governance tooling
├── coordination/
│   ├── standards/                 # Ecosystem-wide standards
│   ├── protocols/                 # Communication protocols (MQTT)
│   ├── hardware-guides/           # Hardware selection guides
│   └── decisions/adr/             # Architecture Decision Records
├── docs/
│   └── guide.md                   # This file
├── templates/                     # Shared templates
└── scratch/                       # Working files (gitignored)
```

## Configuration

### Submodule Management

Each submodule tracks a specific commit of its component repository. To update a submodule to its latest commit:

```bash
cd repos/<component>
git checkout main && git pull
cd ../..
git add repos/<component>
git commit -m "chore: Update <component> submodule reference"
```

To update all submodules:

```bash
git submodule update --remote
```

### Branch Strategy

Feature branches in S.C.O.P.E. follow the convention:
```
feat/<issue#>-<description>          # Meta-repo level work
feat/<component>/<issue#>-<description>  # Component-level work
```

## Usage

### Ecosystem Coordination

S.C.O.P.E. submodule pointers capture coordinated states across the ecosystem. A single S.C.O.P.E. commit can represent a known-good combination of all component versions.

### Governance Generation (PFT)

Generate foundation files for new or existing components:

```bash
cd repos/project-foundation-template
python generate_foundation.py --preset minimal --project-name "ComponentName" --author-name "The O.A.S.I.S. Project"
```

### Issue Tracking

S.C.O.P.E. uses a two-tier issue tracking model:

- **Meta-issues** in the meta-repo track ecosystem-wide initiatives
- **Repo-level issues** in each component repo track implementation work
- Meta-issues reference repo-level issues for cross-repo visibility

When a meta-issue affects S.C.O.P.E. itself (not just its coordination role), S.C.O.P.E. should have its own repo-level issue, just as component repos do. See ADR-0002 §4.5.

### Standards and ADRs

Ecosystem standards live in `coordination/standards/`. Architecture decisions are recorded in `coordination/decisions/adr/`. These apply to all repositories in the ecosystem, including S.C.O.P.E. itself.

## Troubleshooting

| Issue | Possible Cause | Solution |
|-------|---------------|----------|
| Submodule checkout empty | Submodules not initialized | Run `git submodule update --init --recursive` |
| Submodule on detached HEAD | Normal after `submodule update` | `cd repos/<component> && git checkout main` to work on a branch |
| Submodule conflicts during merge | Different submodule commits on branches | Resolve by choosing the correct commit reference |
| PFT generation fails | Python not installed or wrong version | Verify Python 3.7+ is available |
| `gh` commands fail | GitHub CLI not authenticated | Run `gh auth login` |
| Stale submodule references | Component repos have advanced | Run `git submodule update --remote` to sync |

## Related Components

- [M.I.R.A.G.E.](https://www.oasisproject.net/components/mirage/) - HUD system (submodule at `repos/mirage`)
- [D.A.W.N.](https://www.oasisproject.net/components/dawn/) - AI assistant (submodule at `repos/dawn`)
- [A.U.R.A.](https://www.oasisproject.net/components/aura/) - Helmet firmware (submodule at `repos/aura`)
- [S.P.A.R.K.](https://www.oasisproject.net/components/spark/) - Gauntlet firmware (submodule at `repos/spark`)
- [B.E.A.C.O.N.](https://www.oasisproject.net/components/beacon/) - CAD models (submodule at `repos/beacon`)
- [G.E.N.E.S.I.S.](https://www.oasisproject.net/components/genesis/) - Python utilities (submodule at `repos/genesis`)
- [Documentation Portal](https://www.oasisproject.net/) - Public site (submodule at `repos/github-pages`)
- [PFT](https://github.com/malcolmhoward/project-foundation-template) - Governance template generator (submodule at `repos/project-foundation-template`)
