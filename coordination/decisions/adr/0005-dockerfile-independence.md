# ADR 0005: Independent Dockerfiles Per Platform

**Date**: TBD (pending approval)
**Status**: Proposed
**Deciders**: Kris Kersey, Malcolm Howard

## Context

O.A.S.I.S. component repos (MIRAGE, DAWN, SPARK, AURA) require Docker configurations for multiple target platforms:

| Platform | Base Image | Use Case |
|----------|-----------|----------|
| Development (x86/x64) | `ubuntu:22.04` | Build verification, CI/CD, development |
| NVIDIA Jetson | `nvcr.io/nvidia/l4t-base:r35.4.1` | Production with GPU acceleration |
| Raspberry Pi (ARM64) | `arm64v8/debian:bookworm-slim` | Production on RPi hardware |

Each platform shares significant dependency overlap (SDL2, Mosquitto, json-c, GStreamer, etc.) but requires different base images, platform-specific packages, and build flags.

### The Question

Should platform Dockerfiles inherit from a common base image, or should each be self-contained?

### Approaches Evaluated

#### Option A: Common Base Image

Create a shared base Dockerfile that installs common dependencies, then extend it per platform.

```
Dockerfile.base (common deps)
├── Dockerfile.dev   (FROM mirage-base)
├── Dockerfile.jetson (FROM mirage-base)
└── Dockerfile.rpi   (FROM mirage-base)
```

**Pros:**
- DRY: dependency lists maintained in one place
- SDL2 version updates require one change

**Cons:**
- Cannot share a base when `FROM` images differ fundamentally (`ubuntu:22.04` vs `nvcr.io/nvidia/l4t-base` vs `arm64v8/debian`)
- Requires either: (a) publishing a base image to a registry, (b) multi-stage builds with `ARG`-switched base images, or (c) a build script that builds base first
- `ARG`-based base switching is fragile: apt package names and availability differ across distros
- Adds build-time complexity for contributors who just want to run `docker build`

#### Option B: Shared Install Script

Extract common apt-get package lists into a shell script that each Dockerfile `COPY`s and executes.

```
scripts/docker-deps.sh (shared package list)
├── Dockerfile.dev   (COPY + RUN docker-deps.sh)
├── Dockerfile.jetson (COPY + RUN docker-deps.sh)
└── Dockerfile.rpi   (COPY + RUN docker-deps.sh)
```

**Pros:**
- Package lists maintained in one place
- Each Dockerfile keeps its own `FROM`
- No registry or multi-stage complexity

**Cons:**
- "Same" packages resolve differently across base images (Ubuntu 22.04 vs Debian Bookworm vs L4T)
- Script must handle distro differences, adding conditional logic
- Breaks Docker layer caching (any script change invalidates all downstream layers)
- Adds indirection: debugging a build failure requires reading both the Dockerfile and the script

#### Option C: Independent Dockerfiles (Selected)

Each platform Dockerfile is fully self-contained with its own dependency declarations.

```
Dockerfile.dev      (complete, self-contained)
Dockerfile.jetson   (complete, self-contained)
Dockerfile.rpi      (complete, self-contained)
```

**Pros:**
- Each file is readable top-to-bottom without chasing dependencies
- No build prerequisites (no base image to build first)
- `docker build -f Dockerfile.dev .` just works
- Platform-specific optimizations are visible in context
- Docker layer caching works optimally per platform

**Cons:**
- Apparent duplication of apt-get package lists
- SDL2 version updates require changes in three files

## Decision

**Option C: Independent Dockerfiles.** Each platform Dockerfile is fully self-contained.

### Rationale

1. **Fundamentally different base images**: The three platforms use base images from different registries, architectures, and distros. A shared base would require `ARG`-switching the `FROM` line, but downstream `apt-get` commands are not guaranteed to resolve identically across these bases. The "common" code is only superficially common.

2. **Readability over DRY**: When debugging a Jetson build failure at 2am on hardware, you want to read one file top-to-bottom, not chase into shared scripts or multi-stage base images. For 3 files, readability outweighs deduplication.

3. **Manageable maintenance burden**: Updating an SDL2 version across 3 Dockerfiles is a trivial find-and-replace. The maintenance cost of abstraction (base image builds, conditional scripts, layer cache invalidation) exceeds the cost of the duplication it eliminates.

4. **Contributor experience**: `docker build -f Dockerfile.dev .` works with zero prerequisites. No base image to build first, no scripts to understand, no multi-stage chain to reason about.

### Applicability

This decision applies to all O.A.S.I.S. component repos that provide platform-specific Dockerfiles. MIRAGE establishes the reference pattern; DAWN, SPARK, and AURA should follow the same approach.

## Consequences

### Positive

1. **Simple onboarding** — Contributors can build any platform container with a single command
2. **Independent evolution** — Platform-specific optimizations don't require coordinating with shared code
3. **Clear debugging** — Build failures are traceable within a single file
4. **No infrastructure** — No Docker registry for base images, no build orchestration

### Negative

1. **SDL2 version drift risk** — If one Dockerfile is updated and others are not, versions may diverge. Mitigated by: version constants defined as `ENV` at the top of each file, making them visible and grep-able.
2. **Repeated apt-get lists** — Similar (not identical) package lists appear in multiple files. Mitigated by: these lists are stable and rarely change after initial setup.

### Neutral

1. **Pattern precedent** — This decision sets the pattern for other component repos. If a future component has significantly more platforms (5+), the calculus may shift toward a shared approach. Re-evaluate if the number of platform Dockerfiles exceeds 4 per component.

## Change History

| Date | Author | Change |
|------|--------|--------|
| 2026-02-08 | Malcolm Howard | Initial draft, during MIRAGE deployment standardization |
| TBD | Kris Kersey | Review |
| TBD | TBD | Accepted after stakeholder review |

---

*This ADR follows the conventions documented in the [ADR README](README.md).*
