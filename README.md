# S.C.O.P.E.

**System Coordination, Orchestration, Planning & Execution**

Meta-repository for coordinating the [O.A.S.I.S. Project](https://github.com/The-OASIS-Project) ecosystem.

## What is S.C.O.P.E.?

S.C.O.P.E. serves as the central coordination point for the Open-source Assistive System for Integrated Services (O.A.S.I.S.) project. It will provide:

- **Unified documentation** across all O.A.S.I.S. components
- **Getting started guides** for different hardware platforms — including
  simulation-only development on Windows, macOS, Linux, and Chromebooks
  via Python or pre-built Docker images; no Jetson or GPU required
- **Hardware guides** showing hardware progression paths
- **Cross-project coordination** for roadmaps and dependencies
- **Docker orchestration** for multi-component development
- **Foundation templates** for repository standardization

## Documentation Architecture

O.A.S.I.S. documentation follows a three-tier architecture:

```
┌─────────────────────────────────────────────────────────────────┐
│            The-OASIS-Project.github.io (Public Portal)          │
│  • Landing page & project overview                              │
│  • User-facing getting started guides                           │
│  • Feature demos & showcase                                     │
│  • Compiles content from S.C.O.P.E. via MkDocs                 │
└─────────────────────────┬───────────────────────────────────────┘
                          │ compiles from
┌─────────────────────────▼───────────────────────────────────────┐
│                S.C.O.P.E. (Coordination Hub)                    │
│  • Hardware guides (hardware-guides/)                           │
│  • Platform setup guides (getting-started/)                     │
│  • Cross-repo roadmaps & dependencies                           │
│  • Standardization templates for component repos                │
└─────────────────────────┬───────────────────────────────────────┘
                          │ coordinates
┌─────────────────────────▼───────────────────────────────────────┐
│              Component Repos (Authoritative Source)             │
│  MIRAGE │ DAWN │ SPARK │ AURA │ BEACON │ GENESIS │ S.T.A.T.   │
│  Each repo owns: README, CLAUDE.md, Dockerfiles, code docs     │
└─────────────────────────────────────────────────────────────────┘
```

| Tier | Repository | Audience | Content |
|------|------------|----------|---------|
| Portal | [The-OASIS-Project.github.io](https://github.com/The-OASIS-Project/The-OASIS-Project.github.io) | End users | Polished guides, demos |
| Coordination | S.C.O.P.E. (this repo) | Developers | Hardware paths, templates |
| Components | MIRAGE, DAWN, etc. | Contributors | Code, component docs |

## Repository Structure

This meta-repository contains submodules for each O.A.S.I.S. component:

```
repos/
  mirage/              # HUD rendering system (C/CMake, Jetson)
  dawn/                # AI assistant integration (C/C++)
  spark/               # Hand controller firmware (C)
  aura/                # Helmet controller firmware (C)
  beacon/              # CAD models and hardware documentation
  genesis/             # Python utilities and tools
  stat/                # System telemetry and power monitoring (C)
  github-pages/        # Public documentation site
  project-foundation-template/  # PFT governance tooling (v3.7.0)
```

## What is O.A.S.I.S.?

O.A.S.I.S. (Open-source Assistive System for Integrated Services) is an open-source project building an Iron Man-style AI assistant and heads-up display (HUD) system.

### Component Repositories

| Repository | Description | Language |
|------------|-------------|----------|
| [MIRAGE](https://github.com/The-OASIS-Project/mirage) | HUD display system | C |
| [DAWN](https://github.com/The-OASIS-Project/dawn) | AI voice assistant | C++ / Python |
| [SPARK](https://github.com/The-OASIS-Project/spark) | Hand/gauntlet firmware | C |
| [AURA](https://github.com/The-OASIS-Project/aura) | Helmet sensor firmware | C |
| [BEACON](https://github.com/The-OASIS-Project/beacon) | CAD models and designs | N/A |
| [GENESIS](https://github.com/The-OASIS-Project/genesis) | Python utilities | Python |
| [S.T.A.T.](https://github.com/The-OASIS-Project/stat) | System telemetry and power monitoring | C |
| [E.C.H.O.](https://github.com/malcolmhoward/the-oasis-project-simulation-repo) | Simulation framework (Device/Network/Platform mocks) | Python |
| [Game Engine Plugin](https://github.com/malcolmhoward/the-oasis-project-game-engine-plugin-repo) | OCP plugin for game engines (Godot 4.6) | GDScript |

All component repositories are available as submodules under `repos/`.

## Current Status

This repository is under active development. Currently implemented:

- [x] Component repository submodules
- [x] Claude LLM integration guide (`CLAUDE.md`)
- [x] Directory structure for coordination

Coming soon:

- [ ] Foundation templates for repo standardization
- [x] Development environment guide (access paths, Docker distribution, classroom setup)
- [ ] Hardware guides (platform comparison, costs)
- [ ] Getting started guides per platform
- [ ] Docker orchestration

## Repository Structure

```
scope/
├── README.md                    # This file
├── CLAUDE.md                    # LLM integration guide
├── LICENSE                      # GPL v3
├── coordination/
│   ├── roadmaps/               # Per-repo roadmaps (planned)
│   ├── dependencies/           # Cross-repo dependencies (planned)
│   └── decisions/adr/          # Architecture decisions (planned)
├── getting-started/
│   ├── DEVELOPMENT_ENVIRONMENT.md  # Access paths, hardware profiles, Docker distribution, classroom setup
│   ├── raspberry-pi/           # Pi setup guide (planned)
│   ├── orin-nano/              # Orin setup guide (planned)
│   └── jetson-nx/              # Jetson setup guide (planned)
├── journey/                    # Community build stories (planned)
├── repos/                      # Component submodules
│   ├── aura/
│   ├── beacon/
│   ├── dawn/
│   ├── game-engine-plugin/
│   ├── genesis/
│   ├── github-pages/
│   ├── mirage/
│   ├── project-foundation-template/
│   ├── spark/
│   └── stat/
└── scripts/                    # Automation scripts (planned)
```

## Feature Matrix

| Feature | Raspberry Pi | Orin Nano | Jetson NX |
|---------|:------------:|:---------:|:---------:|
| Basic HUD | Yes | Yes | Yes |
| Camera input | Yes | Yes | Yes |
| Stereo vision | Limited | Yes | Yes |
| Voice recognition | Limited | Yes | Yes |
| Local LLM | No | Limited | Yes |
| Full DAWN AI | No | Limited | Yes |
| Sensor suite | Yes | Yes | Yes |

## Getting Started

```bash
# Clone with submodules
git clone --recursive https://github.com/malcolmhoward/the-oasis-project-meta-repo.git

# Or initialize submodules after cloning
git submodule update --init --recursive
```

## Contributing

Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Standardization

All O.A.S.I.S. repositories should include:
- `README.md` - Project overview
- `CONTRIBUTING.md` - Contribution guidelines
- `CLAUDE.md` - LLM integration guidance
- `GETTING_STARTED.md` - Quick start for that component

Component names follow the O.A.S.I.S. thematic naming convention.
See [ADR-0007: Component Naming Convention](coordination/decisions/adr/0007-component-naming-convention.md)
before proposing a name for a new component.

## Related Projects

- [The-OASIS-Project.github.io](https://github.com/The-OASIS-Project/The-OASIS-Project.github.io) - Public documentation portal (MkDocs site)
- [Project Foundation Template](https://github.com/malcolmhoward/project-foundation-template) - Governance templates used to standardize O.A.S.I.S. repos

## License

This project is licensed under the GNU General Public License v3.0 - see [LICENSE](LICENSE) file.

## Acknowledgments

- [The O.A.S.I.S. Project](https://github.com/The-OASIS-Project) and Kris Kersey for creating this vision
- All contributors to the O.A.S.I.S. ecosystem
- The open-source hardware and maker communities

---

*Part of the [O.A.S.I.S. project](https://github.com/The-OASIS-Project)*
