# ADR 0006: Model Availability Strategy for Containerized Components

**Date**: TBD (pending approval)
**Status**: Proposed
**Deciders**: Kris Kersey, Malcolm Howard

## Context

O.A.S.I.S. components that require ML inference (currently: DAWN) depend on large model files
that cannot be bundled in a Docker image:

| Model | Size | Component | Purpose |
|-------|------|-----------|---------|
| Whisper base.en | ~142 MB | DAWN | Speech recognition (ASR) |
| Piper voice (en_GB-alba-medium) | ~50 MB | DAWN | Text-to-speech (TTS) |
| Silero VAD | ~2 MB | DAWN | Voice activity detection |

Piper TTS and Silero VAD models are committed to git and baked into the Docker image. Only
the Whisper ASR model requires external download.

### The Question

When a containerized component requires a model file at runtime, how should that file be
provided? Specifically: should the container block on download at startup, or should it start
immediately and leave model provision to the operator?

### Approaches Evaluated

#### Option A: Bundle Models in Image

Build the Docker image with models pre-downloaded via `RUN wget ...`.

**Pros:**
- Container just works out of the box

**Cons:**
- Image size balloons from ~2GB (DAWN build) to ~2.5GB+ per platform
- CI image pulls become slow even for builds that never run inference
- Model updates require a full image rebuild and push
- Offline development requires pulling a large image first

#### Option B: Require Pre-Mounted Volume

Fail at container startup if models are absent. Operator must populate a volume before running.

**Pros:**
- No download logic in the entrypoint
- Predictable: container either has models or it doesn't

**Cons:**
- Bad developer experience: container fails to start, no clear error message
- CI/CD (build verification) cannot run without a pre-populated volume
- Blocks contributors from doing a quick `docker run` to verify the build

#### Option C: Lazy-Download with Startup-Skip Flag (Selected)

Container starts regardless of model presence. An entrypoint script checks for each model file
before downloading it. A `SKIP_MODEL_DOWNLOAD` flag (default: `true`) suppresses downloads for
CI and offline use. When `false`, missing models are downloaded on first run.

**Pros:**
- `docker run ... dawn` works immediately for build verification (no download)
- CI/CD passes without pre-populated volumes
- Partial model populations work naturally: only missing models are downloaded
- Models persist across container restarts via named Docker volume
- Operator controls download behavior without modifying the image

**Cons:**
- First production run with `SKIP_MODEL_DOWNLOAD=false` may be slow (network download)
- Entrypoint adds complexity vs. a simple `CMD`

## Decision

**Option C: Lazy-download with `SKIP_MODEL_DOWNLOAD` flag.**

## Decision Detail

### Environment Variable Hierarchy

```
SKIP_MODEL_DOWNLOAD=true    # global default: skip all downloads (set in Dockerfile ENV)
SKIP_WHISPER=$SKIP_MODEL_DOWNLOAD  # per-model: inherits global unless explicitly overridden
```

This allows operators to override at the finest granularity needed:

| Use case | Run flags | Result |
|----------|-----------|--------|
| CI / offline dev (default) | _(none)_ | No downloads; container starts immediately |
| Download all missing | `-e SKIP_MODEL_DOWNLOAD=false` | All missing models downloaded |
| Has Whisper, skip re-download | `-e SKIP_MODEL_DOWNLOAD=false SKIP_WHISPER=true` | No download; uses existing file |

### Volume Strategy (DAWN)

DAWN's model paths follow the project's native directory structure:

```
/opt/dawn/whisper.cpp/models/   ← named volume for Whisper ASR model(s)
/opt/dawn/data/                 ← named volume for SQLite DB, conversation history
                                   (configure via DAWN_PATHS_DATA_DIR=/opt/dawn/data)
```

Piper TTS and Silero VAD models are committed to git and live at `/opt/dawn/models/` in the
image. No separate volume is needed for these.

### "Runnability First" Principle

The container ALWAYS starts. Absent models cause DAWN to fail gracefully at the ASR
initialization step with a clear error message — not at container startup. This matches
the expectation that `docker run` should succeed for build verification and inspection even
without a full model set.

### What `SKIP_MODEL_DOWNLOAD` Is Not

`SKIP_MODEL_DOWNLOAD=true` means the entrypoint skips network downloads. It does NOT:

- Mock or stub ASR transcriptions
- Simulate TTS output
- Replace LLM reasoning with canned responses
- Enable end-to-end testing of Dawn's inference pipeline

These are **functional mock testing concerns** that belong to a separate layer of the
O.A.S.I.S. testing architecture. The H.A.Z.E./mock-layer scope — including whether Mock Dawn
(rule-based reasoning without LLM) and hardware simulation are all H.A.Z.E.'s responsibility
— is a design question deferred to a future discussion and separate ADR.

### Naming Rationale: `SKIP_MODEL_DOWNLOAD` over `MOCK_MODELS`

`MOCK_MODELS` was considered but rejected because "mock" implies behavioral substitution
(Dawn responds with canned output instead of real inference). `SKIP_MODEL_DOWNLOAD` is precise:
it only controls the download step at container startup. Operators who read the env var at a
glance immediately understand its scope.

## Consequences

### Positive

1. **Fast CI/CD** — Build verification containers start in seconds, no download required
2. **Offline development** — Works without internet access on first run (default behavior)
3. **Partial model populations** — Only missing models are downloaded; already-present files
   are never overwritten
4. **Operator control** — Per-model granularity without modifying the image
5. **Clear naming** — `SKIP_MODEL_DOWNLOAD` removes ambiguity about what the flag does

### Negative

1. **First production run delay** — With `SKIP_MODEL_DOWNLOAD=false`, first run downloads
   ~142 MB (Whisper base). Acceptable for production; CI uses the default `true`.
2. **Entrypoint complexity** — The entrypoint script adds download logic not present in
   simpler components (MIRAGE, S.T.A.T.). Mitigated by keeping the script minimal.

### Neutral

1. **Convention precedent** — `SKIP_MODEL_DOWNLOAD` becomes the O.A.S.I.S. container
   convention for any future component with model/inference dependencies.
2. **Applies only to DAWN currently** — MIRAGE, S.T.A.T., SPARK, AURA have no model
   dependencies. If a future component adds model dependencies, it should follow this pattern.

## Applicability

This decision applies to any O.A.S.I.S. component that:
- Requires large ML model files (>10 MB) at runtime
- Cannot bundle those models in the Docker image
- May be run in CI or offline environments where downloads are undesirable

Currently: DAWN only.

## Relationship to Other ADRs

- **ADR-0005**: Independent Dockerfiles per platform — companion decision. Each platform
  Dockerfile (dev/jetson/rpi) uses the same `SKIP_MODEL_DOWNLOAD` mechanism but may reference
  different model binaries (CPU vs. CUDA, different ONNX runtime architectures).

## Change History

| Date | Author | Change |
|------|--------|--------|
| 2026-03-01 | Malcolm Howard | Initial draft, during DAWN deployment standardization |
| TBD | Kris Kersey | Review |
| TBD | TBD | Accepted after stakeholder review |

---

*This ADR follows the conventions documented in the [ADR README](README.md).*
