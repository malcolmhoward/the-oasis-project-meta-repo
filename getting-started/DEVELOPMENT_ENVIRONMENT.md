# Development Environment Guide

You do not need a Jetson, a GPU, specialized hardware, or even Linux to
contribute to or use O.A.S.I.S.

There are five distinct ways to access the O.A.S.I.S. stack, each with a
different hardware floor. The [simulation framework][sim-repo] removes the
hardware and software service dependencies for most of them — and the
[Docker distribution path](#path-3--pre-built-docker-image-any-os) brings the
full stack to Windows and macOS without any build step on the recipient's
machine.

---

## Access Paths

### Path 1 — Browser access to a remote DAWN instance

**Hardware floor**: Any device with a browser. No install, no build, no OS
requirement.

DAWN's WebUI runs on port 3000 and serves a full-featured browser interface
for voice and text interaction, conversation history, and settings. Any device
on the same network — phone, tablet, Chromebook, Windows laptop — can
participate as a client.

In a classroom or workshop setting, a single capable machine runs DAWN (or a
Docker container with DAWN) and students access it via browser. No software
installation is required on student devices.

TTS audio playback is handled by the browser via WebSocket audio streaming —
the host container does not need audio output devices.

---

### Path 2 — Simulation framework development (Python only)

**Hardware floor**: 4 GB RAM, Python 3.8+, any OS with a terminal.

The simulation framework is a pure-Python package. No C++ compiler, no system
library chain, no build toolchain required. Install it with `pip` and import
it like any other library.

```bash
pip install -e ".[all]"   # All three layers
```

This path is sufficient to exercise the full O.A.S.I.S. software pipeline:
sensor data flows, OCP protocol interactions, and DAWN's full intent-processing
pipeline via the Platform layer mocks (Home Assistant, LLM, memory/RAG). All
of this runs in-process — no external services, no network required.

See [Simulation Framework Development](#simulation-framework-development) for
the full per-component capability breakdown.

---

### Path 3 — Pre-built Docker image (any OS)

**Hardware floor**: 4 GB RAM, Docker Desktop (Windows/macOS) or Docker Engine
(Linux). No build toolchain. No C++ compiler. No Linux required on the host.

A Docker image built once on a capable machine contains the DAWN binary and
all runtime dependencies. It runs identically on Linux, Windows (Docker
Desktop), and macOS (Docker Desktop). The container is a Linux environment
regardless of host OS — Docker Desktop on Windows and macOS provides a
lightweight Linux VM that hosts the container transparently.

The `docker-compose` file handles all OS-specific concerns: port mapping,
volume mounts, environment variable injection. Recipients do not need to
understand Linux, Docker internals, or DAWN's dependency chain.

In simulation mode, no hardware passthrough is required. The simulation
framework's mock classes handle all hardware and software service dependencies
in-process. TTS audio streams to the browser via WebSocket — the container
does not need host audio devices. This means the same image runs without
modification on Linux, Windows, and macOS.

#### Receiving a pre-built image

```bash
# From a compressed archive (offline / bandwidth-constrained environments)
docker load < dawn-simulation.tar.gz
docker compose up

# Or pull from the container registry
docker pull ghcr.io/the-oasis-project/dawn-simulation:latest
docker compose up
```

Then open `http://localhost:3000` in any browser on the host machine.

#### Producing a distributable image (build machine)

```bash
# Build the image on any capable Linux machine or CI runner
docker build -f Dockerfile.dev -t oasis-dawn-simulation .

# Export as a compressed archive for offline distribution
docker save oasis-dawn-simulation | gzip > dawn-simulation.tar.gz

# Or push to the container registry for pull-based distribution
docker push ghcr.io/the-oasis-project/dawn-simulation:latest
```

> **GPU passthrough note**: Docker GPU passthrough for local LLM inference or
> GPU-accelerated ASR requires `nvidia-container-toolkit` and is Linux-only.
> This does not affect simulation mode — no GPU is needed when the Platform
> layer mock handles LLM responses and MockMicrophone handles audio input.

> **Cross-architecture note**: Building an ARM64 image (for Jetson or RPi)
> on an x86-64 host requires `docker buildx` with QEMU emulation, which the
> existing `Dockerfile.jetson` and `Dockerfile.rpi` already anticipate. A
> simulation-only x86-64 image does not require cross-compilation.

---

### Path 4 — Build and run DAWN locally

**Hardware floor**: 8 GB RAM, modern x86-64 or ARM64 CPU, Linux
(Debian/Ubuntu-based recommended).

This path involves building the DAWN C/C++ binary from source using CMake.
The dependency chain — ONNX Runtime, espeak-ng, whisper.cpp, libwebsockets,
and others — requires a full build toolchain and takes approximately 20–40
minutes on a capable machine.

See the [DAWN README](../repos/dawn/README.md) for full build instructions.

**When to use this path**: Only when modifying DAWN's C/C++ source code
directly. For simulation development, integration testing, or anything that
doesn't require changing compiled DAWN code, Path 2 or Path 3 is faster and
requires less setup.

Running DAWN without a configured LLM endpoint is not explicitly documented,
but DAWN supports cloud LLM providers (OpenAI, Claude, Gemini) via API keys as
well as local Ollama. Pointing DAWN's LLM config at the Platform layer mock
service running on localhost is a viable no-cloud, no-GPU configuration that
has not yet been empirically verified — see [Unverified Items](#unverified-items).

---

### Path 5 — Full target hardware

**Hardware floor**: NVIDIA Jetson Orin Nano (8 GB+) or Xavier NX.

Production deployment. Local LLM inference via Ollama and real-time ASR run at
conversational latency on Jetson GPU. All physical hardware interfaces are
available.

The simulation framework remains useful at this level for CI/CD pipelines and
edge case testing even when real hardware is attached.

---

## Access Path Summary

| Path | Host OS | Build required | GPU required | LLM requirement | Typical use |
|------|---------|:--------------:|:------------:|-----------------|-------------|
| Browser client | **Any** (browser) | No | No | None on client | Classroom, evaluation |
| Simulation framework | **Any** (Python) | No | No | None — mock | Feature dev, testing |
| Docker image | **Any** (Docker Desktop/Engine) | No (recipient) | No | Cloud API, mock, or none | Distribution, Windows/macOS dev, classroom |
| Build locally | Linux / macOS | Yes | No | Cloud API, mock, or none | DAWN C/C++ development |
| Full target | Linux (JetPack) | Yes | Jetson GPU | Local Ollama or cloud | Production deployment |

---

## What the Simulation Framework Replaces

The simulation framework addresses two compounding categories of dependency
that would otherwise block contributors at Paths 1–3:

### Hardware dependencies

| Hardware | Component(s) | Simulation layer |
|----------|-------------|:---------------:|
| GPIO pins (Raspberry Pi, Jetson) | MIRAGE, DAWN, SPARK, AURA | Layer 0 |
| I2C bus (sensors, displays) | All | Layer 0 |
| SPI bus (ADCs, peripherals) | SPARK, AURA | Layer 0 |
| Camera / stereo vision | MIRAGE, DAWN | Layer 0 |
| IMU / GPS / environmental sensors | DAWN, AURA | Layer 0 |
| Microphone / speaker | DAWN | Layer 0 |

### Software service dependencies

These services imply hardware that many contributors don't own:

| Service | Component(s) | Hardware implied | Simulation layer |
|---------|-------------|-----------------|:---------------:|
| MQTT broker | MIRAGE, DAWN, SPARK, AURA | Any networked machine | Layer 1 |
| OCP peer participation | DAWN, any OCP peer | Any running OASIS component | Layer 1 |
| Home Assistant | DAWN | Dedicated server or VM | Layer 2 |
| Local LLM (Ollama) | DAWN | Jetson-class CPU or GPU | Layer 2 |
| Remote LLM (API keys) | DAWN | Network + credentials | Layer 2 |
| Real-time ASR (Whisper) | DAWN | GPU for real-time throughput | Layer 2 |
| Memory / RAG (vector store) | DAWN | Running embedding service | Layer 2 |

The Platform layer (Layer 2) mock services run in-process using Flask and
SQLite. They do not load model weights. The full three-layer simulation stack
running simultaneously uses approximately 150–300 MB of memory.

---

## Simulation Framework Development

Applicable to Paths 2 and 3.

### Per-component capability in simulation

| Component | Exercisable via simulation | Requires real hardware |
|-----------|--------------------------|----------------------|
| **MIRAGE** | HUD rendering, sensor overlay, display state transitions | Live camera feed processing (stereo vision, object tracking) |
| **DAWN** | Full intent pipeline: sensor → OCP → HA action → LLM → memory | Real-time ASR/TTS latency; local LLM performance |
| **SPARK** | SPI/I2C peripheral logic, firmware input handling | Physical device communication |
| **AURA** | Sensor mocking, helmet controller logic | Physical sensor integration |
| **S.T.A.T.** | I2C mocking (INA238, INA3221, Daly BMS) | Real power monitoring |
| **All** | Unit tests, integration tests, CI/CD | Hardware-in-the-loop testing |

> **MIRAGE camera note**: `MockCamera` returns frame metadata dicts — sufficient
> for testing overlay rendering, display state logic, and HUD layout. Vision
> pipeline processing (object detection, stereo depth) requires real pixel data
> and is not achievable via simulation regardless of host hardware.

### Minimum hardware for Path 2

| Requirement | Minimum | Recommended |
|-------------|---------|-------------|
| RAM | 4 GB | 8 GB (comfortable alongside browser and other tools) |
| CPU | Any modern x86-64, ARM64, or Apple Silicon | 4+ cores |
| GPU | Not required | Not required |
| OS | Linux, macOS, Windows (WSL2), Chrome OS (Crostini) | Linux or macOS |
| Python | 3.8+ | 3.11+ |
| Storage | ~1 GB (Layer 0 only) | ~2 GB (all layers + dev deps) |
| Network | Not required for Layer 0 | Loopback only for Layer 1/2 in-process mocks |

### Setup (Path 2)

```bash
git clone --recursive https://github.com/malcolmhoward/the-oasis-project-meta-repo.git
cd repos/simulation

pip install -e .          # Layer 0 only — no extra deps
pip install -e ".[all]"   # All layers
pip install -e ".[dev]"   # With pytest
pytest
```

### Verify

```python
import simulation as sim

imu = sim.MockSensor("imu", sensor_type="motion")
print(imu.read())
# {"device": "Motion", "heading": 45.2, "pitch": -2.1, "roll": 3.5, ...}
```

---

## Classroom and Group Use

### Configuration A — Single server, browser clients

One capable machine (or cloud VM) runs DAWN or a Docker container. Students
access it at `http://<server-ip>:3000`. No software required on student devices.

Works on any device with a browser. Suitable for demonstrations, interactive
lessons, and scenarios where one instance serves a whole class.

### Configuration B — Docker image distribution

Instructor builds or downloads a Docker image once and distributes it as a
compressed archive. Students load and run it on their own machines.

```bash
# Students receive the archive and run:
docker load < dawn-simulation.tar.gz
docker compose up
# Open http://localhost:3000
```

- **Works on**: Windows, macOS, Linux — anything with Docker Desktop or Engine
- **Does not require**: Linux, build toolchain, Python, API keys
- **Offline-capable**: Yes, once the image is loaded
- **Estimated image size**: ~500 MB–1 GB compressed

### Configuration C — Python simulation only

For lessons focused on sensor data, protocol logic, or firmware concepts
without running the full DAWN stack. Installs in minutes on any machine with
Python.

Works on Chromebook via Crostini, WSL2 on Windows, or any Linux/macOS machine.

### Notes for managed environments

- **Chromebook labs**: Linux (Crostini) must be enabled — this is controlled
  by IT policy in managed deployments and is the most common blocker. Confirm
  before the session. Docker Desktop is not available on Chrome OS; use
  Configuration A or C instead.
- **Docker on school machines**: Docker Desktop may require admin rights to
  install. If pre-installed, Configuration B is the lowest-friction path.
- **Network-restricted environments**: Layer 0 and Layer 2 in-process mocks
  require no outbound network access. Configuration A requires LAN connectivity
  between server and clients but no internet.
- **Storage-constrained devices**: Layer 0 alone (~1 GB) is sufficient for
  sensor, firmware, and HUD logic lessons.

---

## Unverified Items

The following behaviors have not been empirically tested and should be verified
before being documented as supported:

- **DAWN startup with no LLM configured**: Whether the DAWN daemon starts
  cleanly with no reachable LLM endpoint, or requires a valid endpoint to
  initialize. If it requires one, pointing it at the Platform layer mock on
  localhost is the expected no-cloud path.
- **Shared library compatibility for native binary distribution**: Whether a
  DAWN binary built on one Linux machine runs on another without `GLIBC`
  version conflicts. Docker (Path 3) avoids this problem entirely by bundling
  the runtime.
- **Docker image size estimate**: The ~500 MB–1 GB compressed estimate above
  is based on typical C++ application images with ONNX Runtime and Whisper
  models. Actual size depends on which models and layers are included.

---

## Related

- [Simulation Framework Repository][sim-repo] — installation, API reference,
  layer status
- [ADR-0003: Simulation Environment Architecture](../coordination/decisions/adr/0003-simulation-environment-architecture.md)
  — architectural decisions and accessibility motivation (Amendment 3)
- [DAWN README](../repos/dawn/README.md) — full build instructions, platform
  tiers, hardware requirements for production deployment
- Getting started by platform: [Raspberry Pi](raspberry-pi/),
  [Orin Nano](orin-nano/), [Jetson NX](jetson-nx/)

[sim-repo]: https://github.com/malcolmhoward/the-oasis-project-simulation-repo
