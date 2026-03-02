# Docker Deployment Standard

This document defines the baseline Docker deployment requirements for all O.A.S.I.S. component
repositories that have a runtime deployment target.

See [ADR-0005](../decisions/adr/0005-dockerfile-independence.md) for the rationale behind
independent, self-contained Dockerfiles per platform.

---

## Platform Coverage Requirement

Every O.A.S.I.S. component with a runtime deployment MUST provide Docker support for the
following platforms, or document in `docs/DOCKER.md` why a platform is not supported:

| Dockerfile | Base Image | Target | Purpose |
|-----------|-----------|--------|---------|
| `Dockerfile.dev` | `ubuntu:22.04` | x86/x64 | Build verification, CI/CD, development |
| `Dockerfile.jetson` | `nvcr.io/nvidia/l4t-base:r35.4.1` | NVIDIA Jetson (ARM64 Tegra) | Production with GPU/hardware acceleration |
| `Dockerfile.rpi` | `arm64v8/debian:bookworm-slim` | Raspberry Pi (ARM64) | Production on RPi hardware |

### Rationale

Jetson and Raspberry Pi are the two primary deployment targets for O.A.S.I.S. hardware. A
component that runs only on one excludes contributors and users on the other. The cost of
an additional Dockerfile is low; the cost of an undocumented exclusion is contributor
confusion and silent platform incompatibility.

Defaulting to "support both until proven otherwise" ensures:
- Contributors can test on whichever hardware they own
- Platform gaps are explicitly acknowledged, not accidentally omitted
- Future hardware support decisions are informed by documented exceptions, not assumptions

---

## Acceptable Exceptions

A component MAY omit a Dockerfile for a platform if one of the following applies. The reason
MUST be documented in `docs/DOCKER.md` under a "Platform Support" or "Limitations" section.

| Exception Category | Description | Examples |
|-------------------|-------------|---------|
| **No runtime** | Component has no executable binary (CAD files, static assets) | BEACON |
| **Native-only utilities** | Scripts/tools that run natively without a container | GENESIS |
| **Firmware flashing** | Component requires direct hardware access for flashing; Docker is not the deployment model | SPARK, AURA |
| **Hardware dependency** | A specific hardware interface required by the component is not available on the excluded platform | *(document which interface and why)* |
| **Library unavailability** | A required library has no build for the target architecture | *(document which library)* |
| **Deferred** | Platform support is planned but not yet implemented | *(document the tracking issue)* |

### Documentation Template for Exceptions

When a platform Dockerfile is omitted, add this to `docs/DOCKER.md`:

```markdown
## Platform Support

| Platform | Dockerfile | Status | Notes |
|----------|-----------|--------|-------|
| x86/x64 (dev) | `Dockerfile.dev` | ✅ Supported | |
| NVIDIA Jetson | `Dockerfile.jetson` | ✅ Supported | |
| Raspberry Pi | `Dockerfile.rpi` | ❌ Not supported | <reason> |
```

---

## Required Files

Components providing Docker support MUST include:

| File | Required | Purpose |
|------|----------|---------|
| `Dockerfile.dev` | Yes (if any Docker support) | x86/x64 build and development |
| `Dockerfile.jetson` | Yes, or documented exception | ARM64 Tegra production |
| `Dockerfile.rpi` | Yes, or documented exception | ARM64 RPi production |
| `.dockerignore` | Yes | Exclude build artifacts and secrets |
| `docs/DOCKER.md` | Yes | Platform guide, run commands, troubleshooting |

---

## Component Status

Current Docker deployment status across O.A.S.I.S. components:

| Component | Dockerfile.dev | Dockerfile.jetson | Dockerfile.rpi | docs/DOCKER.md | Notes |
|-----------|:--------------:|:-----------------:|:--------------:|:--------------:|-------|
| MIRAGE | ✅ | ✅ | ✅ | ✅ | Reference implementation |
| DAWN | ✅ | ✅ | ✅ | ✅ | |
| S.T.A.T. | ✅ | ✅ | ✅ | ✅ | |
| SPARK | — | — | — | — | Firmware flashing model; Docker deferred (see ADR-0005 §Applicability) |
| AURA | — | — | — | — | Firmware flashing model; Docker deferred (see ADR-0005 §Applicability) |
| BEACON | N/A | N/A | N/A | N/A | CAD files only; no runtime |
| GENESIS | N/A | N/A | N/A | N/A | Python utilities; native execution |

*Update this table when a component adds or changes Docker support.*

---

## Dockerfile Conventions

All Dockerfiles MUST follow these conventions (from [ADR-0005](../decisions/adr/0005-dockerfile-independence.md)):

1. **Self-contained** — No shared base images, no external scripts. Each Dockerfile is
   readable top-to-bottom without chasing dependencies.
2. **Single build command** — `docker build -f Dockerfile.<platform> -t <name>:<platform> .`
   must work with no prerequisites.
3. **Version constants at top** — Pin library versions as `ENV` variables at the top of the
   file, making them visible and grep-able across all three Dockerfiles.
4. **Clean layers** — Each `RUN apt-get` block ends with `rm -rf /var/lib/apt/lists/*`.

### For Components with Model Dependencies

Components requiring large ML model files (e.g., DAWN) MUST also follow
[ADR-0006](../decisions/adr/0006-container-model-availability-strategy.md):

- Provide an `entrypoint.sh` that checks for model files before downloading
- Default `SKIP_MODEL_DOWNLOAD=true` so the container starts cleanly without internet
- Declare model storage paths as Docker volumes

---

## Relationship to Other Standards

- [ADR-0005](../decisions/adr/0005-dockerfile-independence.md): Architectural decision for
  independent Dockerfiles — *why* each platform gets its own file
- [ADR-0006](../decisions/adr/0006-container-model-availability-strategy.md): Model
  availability strategy — applies to components with ML inference dependencies
- [ecosystem-documentation.md](ecosystem-documentation.md): Governs `docs/guide.md` content;
  Docker documentation in `docs/DOCKER.md` is complementary
