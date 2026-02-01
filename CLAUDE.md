# CLAUDE.md - S.C.O.P.E. LLM Integration Guide

## Project Overview

**S.C.O.P.E.** (System Coordination, Orchestration, Planning & Execution) is the meta-repository coordinating the O.A.S.I.S. ecosystem - an open-source Iron Man-style AI assistant and HUD project.

## Repository Purpose

This is a **coordination repository**, not a code repository. It will:
- Track roadmaps across multiple component repos
- Provide unified documentation and getting-started guides
- Contain templates for repository standardization
- House Docker configurations for development environments

## Current State

Currently implemented:
- Component repository submodules under `repos/`
- This LLM integration guide (`CLAUDE.md`)
- Directory structure for coordination

Existing directories (content coming soon):
- `coordination/roadmaps/` - Per-repo development roadmaps
- `coordination/dependencies/` - Cross-repo dependency documentation
- `coordination/decisions/adr/` - Architecture Decision Records
- `getting-started/` - Platform-specific setup guides (raspberry-pi, orin-nano, jetson-nx)
- `journey/` - Community build stories
- `scripts/` - Automation scripts

Planned directories:
- `coordination/hardware-guides/` - Hardware progression paths
- `templates/docker/` - Docker configuration templates
- `templates/oasis-foundation/` - Repository standardization templates

## O.A.S.I.S. Component Repositories

Available as submodules under `repos/`:

| Repo | Purpose | Primary Language | Hardware |
|------|---------|------------------|----------|
| MIRAGE | HUD display | C | Display, cameras |
| DAWN | AI assistant | C++/Python | Audio, compute |
| SPARK | Hand firmware | C | SPI/I2C sensors |
| AURA | Helmet firmware | C | Sensors, LEDs |
| BEACON | CAD models | N/A | 3D printing |
| GENESIS | Python utilities | Python | N/A |

## Cross-Repo Relationships

```
GENESIS (utilities)
    |
    v
DAWN (AI) <--MQTT--> MIRAGE (HUD)
    |                    |
    v                    v
  SPARK <---MQTT---> AURA (firmware)
                        |
                        v
                   BEACON (CAD)
```

Communication between components uses **MQTT** messaging.

## Hardware Platforms

| Platform | Key Specs | Best For |
|----------|-----------|----------|
| Raspberry Pi 4/5 | ARM64, 4-8GB RAM | Entry-level, learning |
| Orin Nano | 6 TOPS AI, 8GB RAM | Development, testing |
| Jetson NX | 21 TOPS AI, 16GB RAM | Full deployment |

## Working with This Repository

### Do
- Keep documentation synchronized across repos
- Update dependency graphs when relationships change
- Test Docker configurations on target platforms
- Maintain consistent file structures

### Don't
- Put component-specific code here (goes in component repos)
- Duplicate documentation that exists in component repos
- Make breaking changes to templates without coordination

## Branch Naming Convention

**Critical**: Branch names must include the GitHub issue number being addressed.

### Format
```
feat/<issue#>-<short-description>
```

### Before Creating a Branch

1. **Identify the issue** you're working on (check GitHub Issues)
2. **Use that issue's number** in the branch name
3. **Verify** the issue number matches the work being done

### Examples
```bash
# Check available issues first
gh issue list --repo malcolmhoward/the-oasis-project-meta-repo

# Create branch with correct issue number
git checkout -b feat/<issue#>-description
```

### Common Mistake
- ❌ Using arbitrary numbers or the wrong issue number
- ✅ Always check `gh issue list` or GitHub Issues before creating a branch

## Documentation Architecture

S.C.O.P.E. is the **middle tier** in O.A.S.I.S. documentation:

| Tier | Repository | Purpose |
|------|------------|---------|
| Portal | The-OASIS-Project.github.io | Public-facing MkDocs site |
| Coordination | S.C.O.P.E. (this repo) | Developer guides, templates |
| Components | MIRAGE, DAWN, etc. | Code and component docs |

The .github.io site compiles user-facing content from S.C.O.P.E. via MkDocs.

## Related Resources

- [The-OASIS-Project.github.io](https://github.com/The-OASIS-Project/The-OASIS-Project.github.io) - Public documentation portal
- [Project Foundation Template](https://github.com/malcolmhoward/project-foundation-template) - Governance templates
- [The O.A.S.I.S. Project](https://github.com/The-OASIS-Project) - Main organization
