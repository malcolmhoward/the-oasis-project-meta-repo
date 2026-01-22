# {COMPONENT_NAME}

{Brief one-line description of the component}

Part of the [O.A.S.I.S. Project](https://github.com/The-OASIS-Project) - Open-source Assistive System for Integrated Services.

## Overview

{2-3 paragraph description of what this component does, its role in the O.A.S.I.S. ecosystem, and key features}

## Features

- {Feature 1}
- {Feature 2}
- {Feature 3}

## Hardware Requirements

| Platform | Support Level | Notes |
|----------|---------------|-------|
| Raspberry Pi 4/5 | {Full/Limited/None} | {Notes} |
| Jetson Orin Nano | {Full/Limited/None} | {Notes} |
| Jetson Xavier NX | {Full/Limited/None} | {Notes} |

See [S.C.O.P.E. Feature Matrix](https://github.com/malcolmhoward/the-oasis-project-meta-repo/blob/main/coordination/skill-tree/FEATURE_MATRIX.md) for detailed compatibility.

## Quick Start

### Prerequisites

- {Prerequisite 1}
- {Prerequisite 2}

### Installation

```bash
# Clone the repository
git clone https://github.com/The-OASIS-Project/{component_name}.git
cd {component_name}

# {Installation steps}
```

### Docker Development

```bash
# Build development image
docker build -f Dockerfile.dev -t {component_name}-dev .

# Run in development mode
docker run -it {component_name}-dev
```

See [GETTING_STARTED.md](GETTING_STARTED.md) for detailed setup instructions.

## Architecture

{Brief description of component architecture}

```
{ASCII diagram or component structure}
```

## MQTT Topics

This component uses the following MQTT topics:

| Topic | Direction | Description |
|-------|-----------|-------------|
| `oasis/{component}/status` | Publish | Status updates |
| `oasis/{component}/command` | Subscribe | Incoming commands |

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## Documentation

- [S.C.O.P.E.](https://github.com/malcolmhoward/the-oasis-project-meta-repo) - Project coordination and hardware guides
- [O.A.S.I.S. Docs](https://the-oasis-project.github.io/) - Public documentation portal

## Related Components

- [MIRAGE](https://github.com/The-OASIS-Project/mirage) - HUD Display
- [DAWN](https://github.com/The-OASIS-Project/dawn) - AI Assistant
- [SPARK](https://github.com/The-OASIS-Project/spark) - Hand/Gauntlet
- [AURA](https://github.com/The-OASIS-Project/aura) - Helmet Sensors
- [BEACON](https://github.com/The-OASIS-Project/beacon) - CAD Models
- [GENESIS](https://github.com/The-OASIS-Project/genesis) - Python Utilities

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [The O.A.S.I.S. Project](https://github.com/The-OASIS-Project) and Kris Kersey
- All contributors to the O.A.S.I.S. ecosystem
