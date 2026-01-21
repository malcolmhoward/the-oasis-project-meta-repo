# S.C.O.P.E.

**System Coordination, Orchestration, Planning & Execution**

> Coordinates cross-repo automation, documentation, and planning across the [O.A.S.I.S. project](https://github.com/The-OASIS-Project).

## Overview

S.C.O.P.E. is the meta-repository for the O.A.S.I.S. project ecosystem. It provides centralized coordination for:

- Cross-repository automation and workflows
- Unified documentation and standards
- Planning and project management
- Integration between O.A.S.I.S. components

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
  github-pages/        # Public documentation site
  project-foundation-template/  # PFT governance tooling (v3.7.0)
```

## Getting Started

```bash
# Clone with submodules
git clone --recursive https://github.com/malcolmhoward/the-oasis-project-meta-repo.git

# Or initialize submodules after cloning
git submodule update --init --recursive
```

## Contributing

Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file.

---

*Part of the [O.A.S.I.S. project](https://github.com/The-OASIS-Project)*
