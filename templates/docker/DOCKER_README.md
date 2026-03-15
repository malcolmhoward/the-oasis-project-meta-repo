# O.A.S.I.S. Docker Architecture

This document explains the Docker architecture for the O.A.S.I.S. ecosystem.

## Architecture Overview

```
Component Repos (own their Dockerfiles)     S.C.O.P.E. (orchestration)
┌─────────────────────────────────────┐     ┌─────────────────────────┐
│ mirage/                             │     │ templates/docker/       │
│   ├── Dockerfile.dev                │     │   ├── docker-compose.yml│
│   ├── Dockerfile.rpi                │◄────│   └── DOCKER_README.md  │
│   └── Dockerfile.jetson             │     │                         │
├─────────────────────────────────────┤     │ (Orchestrates component │
│ dawn/                               │     │  repos for integrated   │
│   ├── Dockerfile.dev                │◄────│  development)           │
│   └── Dockerfile.jetson             │     │                         │
├─────────────────────────────────────┤     └─────────────────────────┘
│ aura/                               │
│   └── Dockerfile.dev                │
├─────────────────────────────────────┤
│ spark/                              │
│   └── Dockerfile.dev                │
└─────────────────────────────────────┘
```

## Key Principles

1. **Component repos own their Dockerfiles** - Each O.A.S.I.S. component (MIRAGE, DAWN, AURA, SPARK) maintains its own Docker configurations.

2. **S.C.O.P.E. provides orchestration** - This meta-repo contains only `docker-compose.yml` for coordinating multiple components during development.

3. **Mock hardware for development** - Development Dockerfiles include mock hardware classes so you can develop without physical devices.

4. **Platform-specific production images** - Component repos provide platform-specific Dockerfiles (`.rpi`, `.jetson`) for deployment.

## Dockerfile Patterns for Component Repos

Each component repo should follow this pattern:

### Dockerfile.dev (Development)

```dockerfile
# Example pattern for component Dockerfile.dev
FROM python:3.11-slim  # or appropriate base

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install -r requirements.txt

# Copy source with mock hardware
COPY . .
COPY mock_hardware/ /app/mock_hardware/

# Development entry point
ENV HARDWARE_MODE=mock
CMD ["python", "-m", "component_name"]
```

### Dockerfile.rpi (Raspberry Pi)

```dockerfile
# Example pattern for Raspberry Pi deployment
FROM balenalib/raspberrypi4-python:3.11

WORKDIR /app

# Install Pi-specific dependencies
RUN apt-get update && apt-get install -y \
    python3-picamera2 \
    python3-lgpio \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

ENV HARDWARE_MODE=real
CMD ["python", "-m", "component_name"]
```

### Dockerfile.jetson (NVIDIA Jetson)

```dockerfile
# Example pattern for Jetson deployment
FROM nvcr.io/nvidia/l4t-pytorch:r35.2.1-pth2.0-py3

WORKDIR /app

# Jetson-specific setup
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

ENV HARDWARE_MODE=real
CMD ["python", "-m", "component_name"]
```

## Using docker-compose.yml

The `docker-compose.yml` in this directory orchestrates multiple components:

### Prerequisites

Clone component repos as siblings to this repo:

```bash
cd ~/src  # or your workspace
git clone https://github.com/The-OASIS-Project/mirage.git
git clone https://github.com/The-OASIS-Project/dawn.git
git clone https://github.com/The-OASIS-Project/aura.git
git clone https://github.com/The-OASIS-Project/spark.git
git clone https://github.com/malcolmhoward/the-oasis-project-meta-repo.git
```

### Start Development Environment

```bash
cd the-oasis-project-meta-repo/templates/docker

# Start all services
docker-compose up

# Start specific services
docker-compose up mqtt mirage dawn

# Run in background
docker-compose up -d

# View logs
docker-compose logs -f mirage

# Stop all services
docker-compose down
```

### Custom Repo Locations

If repos are not in the expected sibling locations:

```bash
export OASIS_REPOS_PATH=/path/to/repos
docker-compose up
```

## MQTT Topics

All O.A.S.I.S. components communicate via MQTT. Standard topics:

| Topic Pattern | Publisher | Purpose |
|---------------|-----------|---------|
| `oasis/mirage/status` | MIRAGE | HUD status updates |
| `oasis/mirage/overlay` | Any | Send overlay content to HUD |
| `oasis/dawn/command` | Any | Voice commands to DAWN |
| `oasis/dawn/response` | DAWN | AI responses |
| `oasis/aura/sensors` | AURA | Sensor data stream |
| `oasis/spark/gesture` | SPARK | Gesture recognition events |

## Development Tips

### Watching MQTT Traffic

```bash
# In a separate terminal
docker-compose up mqtt-monitor
```

### Rebuilding After Changes

```bash
docker-compose build mirage  # Rebuild specific service
docker-compose up --build    # Rebuild all and start
```

### Accessing Container Shell

```bash
docker-compose exec mirage /bin/bash
```

## Related Documentation

- [HARDWARE_PATHS.md](../../coordination/hardware-guides/HARDWARE_PATHS.md) - Hardware platform recommendations
- [FEATURE_MATRIX.md](../../coordination/hardware-guides/FEATURE_MATRIX.md) - Feature support by platform
