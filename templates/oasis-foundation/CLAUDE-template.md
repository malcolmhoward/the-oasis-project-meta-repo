# CLAUDE.md - LLM Integration Guide for {COMPONENT_NAME}

## Project Overview

**{COMPONENT_NAME}** is {brief description} within the O.A.S.I.S. (Open-source Assistive System for Integrated Services) ecosystem.

## Key Files

| File/Directory | Purpose |
|----------------|---------|
| `src/` | Main source code |
| `include/` | Header files (if C/C++) |
| `tests/` | Test files |
| `Dockerfile.dev` | Development container |
| `Dockerfile.{platform}` | Platform-specific containers |

## Architecture

{Brief architecture description}

### MQTT Integration

This component communicates with other O.A.S.I.S. components via MQTT:

**Topics Published:**
- `oasis/{component}/status` - Component status updates
- `oasis/{component}/{specific_topic}` - {Description}

**Topics Subscribed:**
- `oasis/{component}/command` - Incoming commands
- `oasis/{other_component}/{topic}` - {Description}

## Development

### Build Commands

```bash
# {Primary build command}
{command}

# Run tests
{test_command}

# Run linter
{lint_command}
```

### Docker Development

```bash
# Build development image
docker build -f Dockerfile.dev -t {component}-dev .

# Run with mock hardware
docker run -it {component}-dev

# Run with volume mount for live development
docker run -it -v $(pwd):/app {component}-dev
```

## Code Style

- **Language**: {Language}
- **Style Guide**: {Style guide reference}
- **Linter**: {Linter name and config}

## Common Tasks

### Adding a New Feature

1. {Step 1}
2. {Step 2}
3. Update MQTT topics if needed
4. Add tests
5. Update documentation

### Debugging

{Debugging tips specific to this component}

## Hardware Abstraction

This component uses a hardware abstraction layer:

- **Mock mode**: `HARDWARE_MODE=mock` - Simulated hardware for development
- **Real mode**: `HARDWARE_MODE=real` - Actual hardware (platform-specific)

## Related Documentation

- [S.C.O.P.E. Coordination](https://github.com/malcolmhoward/the-oasis-project-meta-repo) - Project-wide coordination
- [Feature Matrix](https://github.com/malcolmhoward/the-oasis-project-meta-repo/blob/main/coordination/skill-tree/FEATURE_MATRIX.md) - Platform compatibility
- [Docker Architecture](https://github.com/malcolmhoward/the-oasis-project-meta-repo/blob/main/templates/docker/DOCKER_README.md) - Docker patterns
