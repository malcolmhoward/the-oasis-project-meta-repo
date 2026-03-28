# ADR 0003: Simulation Environment Architecture

> **Renamed** from "Hardware Mocking Architecture" on 2026-03-08 to reflect
> expanded scope. See Amendment 1.

**Date**: TBD (pending approval)
**Status**: Proposed
**Deciders**: Kris Kersey, Malcolm Howard

## Context

O.A.S.I.S. components (MIRAGE, DAWN, SPARK, AURA) interact with specialized hardware:
- GPIO pins (Raspberry Pi, Jetson)
- I2C bus (sensors, displays)
- SPI bus (ADCs, peripherals)
- Cameras (stereo vision, tracking)
- IMU sensors (orientation, motion)
- GPS modules (positioning)

Contributors without this hardware face barriers to development and testing. Hardware
mocking enables:
- Development without physical hardware
- CI/CD testing in cloud environments (GitHub Actions)
- Faster iteration cycles
- Lower contribution barriers

### Existing Implementation

A working, OS-independent hardware mocking solution already exists that covers
GPIO, I2C, Camera, IMU, and GPS interfaces. This implementation serves as the
basis for the proposed standalone repository.

### Research Findings

Evaluation of existing open-source libraries:

| Library | Coverage | OS-Independent | Active | Recommendation |
|---------|----------|:--------------:|:------:|----------------|
| gpiozero MockFactory | GPIO, SPI | Yes | Yes | Use for SPI gaps |
| fake-rpi | GPIO, I2C | Yes | No (Archived) | Not recommended |
| PyVirtualDisplay | Display | Linux* | Yes | Use for display |
| Custom mock_hardware | GPIO, I2C, Camera, IMU, GPS | Yes | Yes | Primary solution |

*PyVirtualDisplay requires X server on non-Linux systems

**Key finding**: No single existing library covers all O.A.S.I.S. needs. The existing
implementation exceeds available libraries for this use case.

## Decision

**Create a new standalone repository extracted from the existing implementation, integrated via git submodule.**

### Approach Selected: Option C + D Hybrid

| Aspect | Decision |
|--------|----------|
| **Primary solution** | New standalone project (Option C) |
| **Gaps** | Complement with existing libraries (Option D) |
| **Integration** | Git submodule (not PyPI, short-term) |
| **Naming** | Temporary name; Kris selects official acronym |

### Alternatives Considered

#### Option A: In-Repo Component Mocking
Each component implements its own mock classes.

**Rejected because**:
- Code duplication across repos
- Adds "tangential" code to Kris's repos
- Maintenance burden per component

#### Option B: External Dependency (Existing Library)
Use existing open-source library as dependency.

**Partially adopted**: Use gpiozero MockSPIDevice and PyVirtualDisplay for gaps.

**Not primary because**:
- No single library covers all O.A.S.I.S. needs
- Would require multiple libraries with inconsistent APIs

#### Option C: New Standalone Project (Selected)
Create new O.A.S.I.S.-aligned project for hardware mocking.

**Selected because**:
- Working implementation already exists
- Clean separation from component repos
- Reusable beyond O.A.S.I.S.
- Can follow PFT governance

#### Option D: Hybrid Approach (Complementary)
Use existing libraries for specific hardware types.

**Adopted for gaps**:
- SPI: gpiozero MockSPIDevice
- Display: PyVirtualDisplay

#### Option E: Add to GENESIS (Existing Utility Repo)
Place mock hardware within the existing GENESIS Python utilities repository.

**Considered because**:
- GENESIS is the ecosystem's cross-component utility repo
- Python mock implementations would sit alongside other Python utilities

**Rejected because**:
- **Consumption pattern mismatch**: GENESIS utilities are standalone scripts that are *run* independently (vision trigger, RTSP server, camera HUD). Mock hardware is a *library* that other repos import as a build dependency via submodule. These are fundamentally different relationships.
- **Cross-language scope**: The HAL approach (see Cross-Language Strategy below) requires C header files and C mock implementations alongside the Python mocks. GENESIS is a Python-only repository with no C toolchain.
- **Submodule granularity**: Components needing mock hardware would pull in all of GENESIS as a submodule, bringing unrelated camera scripts, GPIO triggers, and RTSP server code into their dependency tree.
- **Independent maintenance scope**: Mock hardware has its own versioning, testing, and contribution concerns distinct from GENESIS utilities.

## Implementation

### Repository Setup

| Item | Value |
|------|-------|
| **Temporary name** | TBD |
| **Source** | Extract from existing implementation |
| **Governance** | PFT minimal preset |
| **Official name** | TBD (Kris selects, like S.C.O.P.E.) |

### Mock Classes

| Class | Hardware | Status |
|-------|----------|--------|
| `MockGPIO` | GPIO pins | Exists |
| `MockI2C` | I2C bus | Exists |
| `MockCamera` | Camera capture | Exists |
| `MockIMU` | 9-DOF IMU | Exists |
| `MockGPS` | GPS module | Exists |
| `MockSPI` | SPI bus | To add |
| `MockDisplay` | Display | To add (or PyVirtualDisplay) |

### Integration Pattern

**Git submodule** (not PyPI):
```bash
# In component repo
git submodule add <mock-hardware-repo-url> mock_hardware
git submodule update --init

# Install for development
cd mock_hardware && pip install -e .
```

**Why submodule over PyPI**:
- Project is unofficial/temporary until stakeholder approval
- Avoids premature PyPI publication
- Easy to update, pin versions, or remove
- Consistent with fork-first workflow

### Cross-Language Strategy

O.A.S.I.S. components are implemented in multiple languages:

| Component | Language | Runtime Environment |
|-----------|----------|---------------------|
| MIRAGE | C | Raspberry Pi, Jetson |
| DAWN | C/C++ + Python | Raspberry Pi, Jetson |
| SPARK | C | Arduino/ESP32 |
| AURA | C | Arduino/Teensy |
| GENESIS | Python | General purpose |

To support mocking across languages, we adopt a **Hardware Abstraction Layer (HAL)** approach where interface contracts are defined and both real and mock implementations conform to the same interface.

#### HAL Interface Pattern

Define consistent interfaces that abstract hardware access:

```
Interface Contract (conceptual):
├── gpio_init(pin, mode) -> status
├── gpio_read(pin) -> value
├── gpio_write(pin, value) -> status
├── i2c_read(addr, reg, len) -> data
├── i2c_write(addr, reg, data) -> status
└── ...
```

#### Language-Specific Implementations

**C (MIRAGE, DAWN, SPARK, AURA):**

```c
// hal_gpio.h - Interface definition
typedef struct {
    int (*init)(int pin, int mode);
    int (*read)(int pin);
    int (*write)(int pin, int value);
} gpio_hal_t;

// Real implementation (linked on target hardware)
extern gpio_hal_t gpio_hal_real;

// Mock implementation (linked for testing)
extern gpio_hal_t gpio_hal_mock;

// Selected at compile time or runtime
#ifdef MOCK_MODE
    #define gpio_hal gpio_hal_mock
#else
    #define gpio_hal gpio_hal_real
#endif
```

**Python (DAWN, GENESIS):**

```python
# hal_gpio.py - Interface definition
from abc import ABC, abstractmethod

class GPIOInterface(ABC):
    @abstractmethod
    def init(self, pin: int, mode: int) -> int: ...

    @abstractmethod
    def read(self, pin: int) -> int: ...

    @abstractmethod
    def write(self, pin: int, value: int) -> int: ...

# Real implementation
class RealGPIO(GPIOInterface):
    def init(self, pin, mode):
        # Actual hardware access
        ...

# Mock implementation
class MockGPIO(GPIOInterface):
    def __init__(self):
        self._pin_states = {}

    def read(self, pin):
        return self._pin_states.get(pin, 0)

# Selected via environment or dependency injection
import os
if os.environ.get('MOCK_MODE'):
    gpio = MockGPIO()
else:
    gpio = RealGPIO()
```

#### Integration Testing Across Languages

For integration tests involving multiple components (e.g., MIRAGE ↔ AURA ↔ DAWN), a Python test harness can:

1. Launch C components compiled with mock HAL
2. Inject simulated sensor data via mock interfaces
3. Capture and verify component outputs
4. Simulate MQTT message flows between components

This enables end-to-end testing without physical hardware while respecting each component's native language.

#### Phased Implementation

| Phase | Scope | Deliverable |
|-------|-------|-------------|
| 1 | Python mocks | Mock classes for Python components and test harnesses |
| 2 | C HAL headers | Interface definitions for C components |
| 3 | C mock implementations | Mock implementations linkable in C components |
| 4 | Integration harness | Python test harness for cross-component testing |

#### Language Extensibility

The C HAL approach is inherently extensible to additional languages because C headers serve as a universal interop layer. Any language with C Foreign Function Interface (FFI) support can consume the HAL headers directly:

| Language | Interop Mechanism | Relevance to O.A.S.I.S. |
|----------|-------------------|--------------------------|
| C/C++ | Native | Current components (MIRAGE, DAWN, AURA, SPARK) |
| Python | ctypes, cffi | Current components (DAWN, GENESIS) |
| MicroPython/CircuitPython | Native API | AURA and SPARK hardware (ESP32-S3) already supports CircuitPython; lowers contribution barrier |
| Rust | bindgen (C FFI) | Potential future components prioritizing memory safety |

No additional HAL architecture work is required to support these languages. The only per-language effort would be writing idiomatic wrapper libraries if raw FFI is not ergonomic enough for a given use case.

### OS Independence

**Requirement**: Must work on Linux, macOS, and Windows without physical hardware.

**Implementation patterns**:
1. Environment variable control: `MOCK_MODE=1`
2. Conditional imports with try-except fallback
3. Pure Python (no platform-specific C extensions)
4. No hardcoded `/dev/` paths

### S.C.O.P.E. Integration

New coordination files:
- `coordination/roadmaps/MOCK-HARDWARE.md`
- `coordination/dependencies/MOCK-HARDWARE.md`
- `getting-started/development/MOCK_SETUP.md`

Updates to existing files:
- `README.md` - Add to component list
- `CLAUDE.md` - Add mock-hardware context
- Dependency graph - Add mock-hardware node

## Consequences

### Positive

1. **Clean separation** - Mocking code stays out of Kris's component repos
2. **Lower contribution barrier** - Developers can work without hardware
3. **CI/CD enabled** - Cloud testing in GitHub Actions
4. **Reusable** - Useful beyond O.A.S.I.S. ecosystem
5. **Working solution** - Based on proven implementation
6. **OS-independent** - Works on developer's platform of choice

### Testing Capabilities Enabled

Mock hardware would enable testing patterns not currently possible:

| Testing Type | Current State | With Mock Hardware |
|--------------|---------------|-------------------|
| Unit tests | Manual, hardware-dependent | Automated, CI-enabled |
| Integration tests | Requires physical O.A.S.I.S. setup | Simulated component interactions |
| Regression tests | Manual verification | Automated on every PR |
| Edge case testing | Limited by hardware states | Simulate any sensor state |
| Cross-platform dev | Jetson-only | Linux/macOS/Windows |

**Integration testing example**: Test MIRAGE ↔ AURA ↔ DAWN communication without physical devices by mocking sensor data flows and MQTT messages.

### Negative

1. **New project to maintain** - Additional repository in ecosystem
2. **Submodule complexity** - Contributors must understand git submodules
3. **Temporary naming** - Requires rename when official name selected

### Neutral

1. **Stakeholder dependency** - Official integration requires Kris's approval
2. **Name selection pending** - Temporary name until acronym chosen

## Candidate Names (For Stakeholder Selection)

> **Note**: The following acronyms and expansions are **illustrative examples only**.
> They do not represent proposed names. The official name will be selected by Kris Kersey.
>
> **Scope note (2026-03-08)**: Candidates whose expansions reference "Hardware" specifically
> now undersell the full scope (Device + Network + Platform layers). Expansions can be
> revised if a name is selected. See ADR-0007 for thematic evaluation against the expanded scope.

| Name | Expansion | Notes |
|------|-----------|-------|
| **E.C.H.O.** | Emulated Component and Hardware Operations (or Kris's choice) | Strongest new candidate for expanded scope. An echo faithfully reproduces behavior without being the original — precise metaphor for all three layers. Short, memorable, no hardware specificity. |
| **P.H.A.N.T.O.M.** | Platform for Hardware Abstraction, Non-physical Testing & Operations Mocking | Most semantically precise — a phantom is definitionally non-physical presence. Expansion is a stretch; acronym is long. |
| **H.A.Z.E.** | Hardware Abstraction Zone for Emulation | Current working name; familiarity is an asset. "Hardware" in expansion undersells scope; expansion can be revised if selected. |
| **M.I.S.T.** | Mock Infrastructure for System Testing | "System Testing" naturally covers all three layers. Complements H.A.Z.E. thematically. |
| **M.I.R.R.O.R.** | Mock Infrastructure for Reliable Replication of Resources | Reflects reality faithfully; strong simulation metaphor. Phonetically echoes M.I.R.A.G.E. |
| **V.E.I.L.** | Virtual Emulation Interface Layer | Fits the thematic register, but a veil *obscures* rather than *replicates* — slightly wrong metaphor. |
| **S.H.A.D.O.W.** | Simulated Hardware Abstraction for Development & Offline Work | A shadow requires the real object to be present — opposite of what simulation does. |

## Amendments

### Amendment 1 — Scope Expansion: Simulation Framework (2026-03-08)

The scope of this project has expanded from hardware-primitive mocking to a full
**simulation framework** covering three layers. The standalone repository and git
submodule integration established in the original decision remain correct. The
layered architecture adds Network and Platform layers above the Device layer
without changing the repository structure or integration approach.

#### Layered Architecture

```
Simulation Framework Architecture
├── Device layer: Hardware Primitives (STABLE — no external dependencies)
│   ├── Sensor value generators (IMU, GPS, environmental, battery, system metrics)
│   ├── GPIO / I2C / SPI state simulators
│   ├── MockCamera (metadata dict output)
│   └── MockMicrophone / MockSpeaker (synthetic audio frames, null sink)
│
├── Network layer: Protocol Simulation (STABLE — depends only on OCP spec)
│   ├── DAP2 satellite WebSocket client (register, text-path command injection)
│   ├── OCP peer registration and keepalive (E3/E4 embodiment)
│   └── MQTT topic helpers and message serializers
│
└── Platform layer: Software Behavior Simulation (VERSIONED — may evolve)
    ├── Home Assistant REST API mock (Flask, in-process, no real HA required)
    ├── LLM mock service (keyword → tool call synthesis, streaming simulation)
    └── Memory/RAG stub (SQLite + embedding stub, keyword retrieval)
```

Breaking the Platform layer does not break the Device or Network layers. The Device
layer remains stable regardless of LLM or external API changes.

#### Per-Component Layer Requirements

| Component | Device | Network | Platform | Notes |
|-----------|:------:|:-------:|:--------:|-------|
| MIRAGE | ✅ | — | — | HUD sensors over MQTT |
| DAWN | ✅ | ✅ | ✅ | Full pipeline: sensors + OCP + HA/LLM/memory |
| SPARK | ✅ | — | — | SPI/I2C peripheral mocking |
| AURA | ✅ | — | — | Sensor mocking |
| S.T.A.T. | ✅ | — | — | I2C mocking (INA238, INA3221, Daly BMS) |

#### Demo Ownership Model

Runnable demos are not part of the simulation framework repository itself. Ownership:

| Scope | Lives in | What it demonstrates |
|-------|----------|----------------------|
| Component demo | Component repo `demos/` | That component running with simulation substituting its dependencies |
| Cross-component demo | S.C.O.P.E. `demos/` | Multiple components working together against a simulated environment — fully mocked by default, with real hardware or services substituted where available |

The simulation framework repository ships `examples/` showing how to use each
layer's API; runnable Docker Compose demos live in the repos that own the
component(s) being demonstrated.

---

### Amendment 2 — Selective Injection Design Constraint (2026-03-08)

**Design constraint**: All simulation layer mock classes must be **interface-compatible**
with their real hardware and software counterparts. A component must be able to
substitute a mock for a real driver without changing component code — only the
injected object changes.

This elevates the HAL Interface Pattern in the Cross-Language Strategy section from
a design suggestion to a **hard requirement** for all Device layer classes, and
applies equivalently to Network and Platform layer mocks.

#### Requirement

For every interface mocked by the simulation framework:

1. The mock class implements exactly the same public API as the real driver or service
2. Component code programs against the interface, not the implementation
3. At runtime, either the real implementation or the mock is injected depending on
   hardware availability and user intent

`MockGPIO` already satisfies this (RPi.GPIO-compatible class-method API). This
pattern must be applied consistently across all layers.

#### Demo Launch Behaviour

Demos must support three modes to accommodate mixed real/simulated environments:

| Mode | Behaviour | How invoked |
|------|-----------|-------------|
| Auto-detect | Probe for real hardware/services first; fall back to mock for anything unavailable | Default (no flags) |
| Full mock | Skip probing; use simulation for everything | `--all-mock` |
| Selective mock | Use real hardware/services except where explicitly overridden | `--mock-camera`, `--mock-imu`, etc. |

Auto-detect is the recommended default: the same demo command works on a
developer's laptop (everything mocked) and on a Jetson with a real camera attached
(camera real, sensors mocked) without requiring the user to declare what hardware
is present.

#### Rationale

If mocks are not interface-compatible, selective injection is not possible — code
using a `MockCamera` would require different paths from code using a real camera
driver. Interface compatibility is what makes auto-detect and selective override
work transparently, and is what allows a demo to gracefully use real hardware where
available without reconfiguration.

---

### Amendment 3 — Accessibility as Primary Motivation (2026-03-11)

The original Context section frames the simulation environment primarily as a
**testing infrastructure** concern. This framing is incomplete.

The simulation environment's primary value is **contributor and user
accessibility**. End-to-end testing is a significant secondary benefit that
falls out of the same infrastructure, not the reverse.

#### The Dependency Spectrum

O.A.S.I.S. contributors face two compounding categories of barrier:

**Hardware dependencies** — physical devices required to run component code:
GPIO, I2C, SPI, cameras, IMU, GPS, microphone, speaker. These require
Jetson-class or Raspberry Pi hardware and associated peripherals.

**Software service dependencies** — infrastructure required to exercise
component logic, independent of hardware ownership:

| Service | Component | Barrier |
|---------|-----------|---------|
| LLM inference (local Ollama) | DAWN | Requires Jetson-class CPU or GPU; not viable on standard laptops at conversational latency |
| LLM inference (remote API) | DAWN | Requires API keys and outbound network access |
| Home Assistant | DAWN | Requires a dedicated running instance with configured integrations |
| Real-time ASR (Whisper / faster-whisper) | DAWN | GPU recommended for real-time throughput |
| Memory / RAG (vector store) | DAWN | Requires a running embedding service |
| MQTT broker | MIRAGE, DAWN, SPARK, AURA | Lower barrier, but still a runtime service dependency |

A capable developer with a modern laptop, no GPU, and no Jetson — which
describes the majority of potential contributors, classroom participants, and
early evaluators — cannot exercise DAWN's core intent-processing pipeline
without the Platform layer simulation. They are blocked not by lack of skill
or motivation but by a software dependency chain that implies specialized
hardware.

#### Minimum Viable Contributor Hardware

The simulation environment is specifically designed so that **a 4 GB device
with Docker Desktop or Python is a sufficient development environment** for the
majority of O.A.S.I.S. component logic. This includes:

- **Any OS via Docker Desktop** — Windows and macOS users can run a pre-built
  Docker image containing the full DAWN binary and runtime. The container is
  a self-contained Linux environment; `docker-compose` handles all OS-specific
  differences. No Linux, no build toolchain, no API keys required.
- **Linux / Chrome OS (Crostini) / macOS via Python** — the simulation
  framework is a pure-Python package installable with `pip`. Works on
  Chromebooks with Linux enabled, low-end laptops, and shared school or
  library computers.
- **Raspberry Pi 3B+ or earlier** — sufficient for logic development and
  simulation framework use; not for performance testing.

All three simulation layers run as lightweight Python processes. The Layer 2
mock services (Home Assistant, LLM, memory) use in-process Flask and SQLite —
they do not load model weights and have no meaningful compute floor. The full
three-layer stack active simultaneously uses approximately 150–300 MB of
memory.

This profile is sufficient to exercise:
- MIRAGE: HUD rendering, sensor overlay, display state transitions
  (excluding live camera feed processing)
- DAWN: Full intent-processing pipeline via Device + Network + Platform layers
- SPARK, AURA: Firmware logic, SPI/I2C peripheral handling
- S.T.A.T.: I2C mocking
- All components: Unit tests, integration tests, CI/CD

#### The Docker Distribution Path

A pre-built Docker image extends accessibility further than the Python
simulation path alone. Because simulation mode requires no hardware
passthrough (no GPU, no audio devices, no `/dev/` paths), a Docker image
built once on a capable Linux machine or CI runner runs without modification
on Linux, Windows (Docker Desktop), and macOS (Docker Desktop).

For offline or bandwidth-constrained environments such as classrooms:

```bash
# Distribute as a compressed archive
docker save oasis-dawn-simulation | gzip > dawn-simulation.tar.gz

# Recipient loads and runs on any OS with Docker
docker load < dawn-simulation.tar.gz
docker compose up
```

This is the same pattern as distributing a compiled application with its
runtime bundled — the recipient requires no build toolchain, no Linux, and
no knowledge of the dependency chain.

#### Educational Context

The 4 GB / no-GPU / any-OS profile is the profile of hardware commonly
available in school settings — Chromebook labs, shared Windows desktops,
and student laptops. Making this a first-class supported profile is a
deliberate design choice. Documentation, demos, and getting-started guides
should reflect this.

#### Implications for Context Section

The Context section's "Hardware mocking enables" bullet list should be read
with this framing:

- **Development without physical hardware** — primary value: reaches
  contributors and learners who cannot acquire Jetson-class hardware
- **CI/CD testing in cloud environments** — secondary value: same
  infrastructure enables automated testing at no additional cost
- **Faster iteration cycles** — secondary value: falls out of not needing
  physical hardware present
- **Lower contribution barriers** — restatement of primary value; should be
  first, not last

For the full development environment guide including access paths, Docker
distribution instructions, classroom configurations, and component coverage
by profile, see
[`getting-started/DEVELOPMENT_ENVIRONMENT.md`](../../getting-started/DEVELOPMENT_ENVIRONMENT.md)
in S.C.O.P.E.

### Amendment 4 — Runtime Injection Modes and Graceful Degradation (2026-03-22)

Amendment 2 defines three injection modes at **startup** (auto-detect, full-mock,
selective-mock). This amendment extends the injection model to cover the full
component **lifecycle**, including hardware and service changes that occur after
launch.

#### The Three Injection Phases

| Phase | When | What Happens | Example |
|-------|------|-------------|---------|
| **Default injection** | Container/process start | All mocks active; no configuration needed | Docker container launches on a laptop — everything simulated |
| **Explicit injection** | Container/process start | User declares which deps are real vs. mocked | `--mock-camera --real-mqtt` — real broker, simulated sensors |
| **Runtime injection** | After launch | Hardware or services appear/disappear; framework swaps implementations transparently | USB camera plugged in → MockCamera replaced by real driver; camera unplugged → falls back to MockCamera |

Default and explicit injection are covered by Amendment 2's auto-detect, full-mock,
and selective-mock modes. Runtime injection is new.

#### Runtime Drop-In / Drop-Out

Components in the O.A.S.I.S. ecosystem are loosely coupled — OCP peers register
and deregister dynamically, and hardware can be connected or disconnected at any
time. The simulation framework should reflect this by supporting **runtime
injection changes** without restarting the component.

Scenarios:

| Event | Behaviour |
|-------|-----------|
| USB camera plugged in after launch | Provider detects new hardware; swaps MockCamera for real camera driver; component continues without restart |
| Camera disconnected during operation | Provider detects removal; swaps back to MockCamera; component continues with simulated frames |
| Real MQTT broker becomes reachable | Provider swaps mock MQTT client for real paho-mqtt connection; existing subscriptions are re-established |
| OCP physical peer (E3) goes offline | Simulated E4 peer can fill the gap, advertising via `echo/discovery/simulates`; consuming components see continuity |
| Home Assistant instance starts | Provider swaps HomeAssistantMock for real HA REST client; tool calls now hit real devices |

#### Provider Pattern

To support all three injection phases, each HAL interface should be accessed
through a **Provider** that manages which implementation is currently active:

```
┌─────────────────────────────────────────────────────┐
│                    Component Code                     │
│           (programs against HAL interface)            │
└──────────────────────┬──────────────────────────────┘
                       │ calls
┌──────────────────────▼──────────────────────────────┐
│                     Provider                         │
│  - Holds reference to active implementation          │
│  - Monitors for hardware/service availability        │
│  - Swaps implementation on detection events          │
│  - Emits status change notifications                 │
└──────────┬───────────────────────┬──────────────────┘
           │                       │
  ┌────────▼────────┐    ┌────────▼────────┐
  │   MockCamera    │    │  Real Camera    │
  │ (CameraInterface)│    │ (CameraInterface)│
  └─────────────────┘    └─────────────────┘
```

The Provider is **not** part of the HAL interfaces themselves — it sits above
them. HAL interfaces remain pure contracts with no awareness of injection. The
Provider is an **orchestration concern** that lives in the consuming component
or in a shared utility module.

Implementation is deferred to the demo phase. The minimum viable Provider:

1. Wraps a HAL interface reference
2. Supports `swap(new_implementation)` to change the active backend
3. Optionally monitors for hardware events (OS-level device detection)
4. Emits a callback or event when the active implementation changes

#### Connection to OCP Component Discovery

OCP's discovery mechanism (`<component>/discovery/<capability>` topics) and
the simulation framework's `echo/discovery/simulates` topic together enable
a system where:

- Real and simulated peers coexist on the same MQTT network
- Consumers can query which peers are simulated vs. physical
- The Provider can use discovery information to decide when to swap
  implementations (e.g., a real AURA peer publishes its status → the Provider
  swaps MockSensor for real AURA telemetry)

This aligns with the O.A.S.I.S. architecture's design principle that components
should not hard-fail when a peer disappears. The simulation framework provides
the fallback layer that makes graceful degradation possible.

#### Phasing

| Phase | Deliverable | Status |
|-------|-------------|--------|
| 1 | HAL interfaces (pure contracts) | Complete |
| 2 | Mock implementations (all three layers) | Complete |
| 3 | Startup injection modes (Amendment 2) | Design complete; demo implementation pending |
| 4 | Provider pattern (runtime swap) | Complete (`simulation/hal/provider.py`); 16 tests |
| 5 | OS-level device detection (hot-plug) | Future; requires platform-specific code (udev on Linux, WMI on Windows) |

---

### Amendment 5 — OCP Embodiment Spectrum (2026-03-22, revised 2026-03-28)

The simulation framework uses "embodiment" to classify peers on the O.A.S.I.S.
network by their **relationship to physical reality** — not by platform
capability. A passive temperature sensor and a full-compute Jetson are both
*physical* peers (E1) because they have real bodies; they differ in capability,
not in embodiment. This distinction keeps the spectrum intuitive as O.A.S.I.S.
expands into game engines, simulations, and software-only services.

> **Status**: E1 and E4 are implemented in the simulation framework (as
> `Embodiment.E3` and `Embodiment.E4` — enum values will be updated to
> match the revised spectrum). E2, E3, and E5 are proposed pending Kris
> Kersey's review.

#### Embodiment Types

| Type | Embodiment | Description | Examples |
|------|-----------|-------------|----------|
| **E1** | Physical | Dedicated hardware with a physical body | M.I.R.A.G.E. on Jetson, A.U.R.A. (ESP32), S.P.A.R.K. (Arduino), S.T.A.T. on RPi, standalone sensors |
| **E2** | Remote-Physical | Real hardware operated by a remote operator | Wirelessly driven robot suit; dual keepalive (operator + hardware) |
| **E3** | Digital/Virtual | Virtual body in a game engine, simulation, or visualization | Godot avatar, E.C.H.O. simulated peer, VR character |
| **E4** | Software-Only | No body — pure service or infrastructure peer | D.A.W.N. running as headless server, LLM routing, session management |
| **E5** | Hybrid | Spans multiple embodiment types via Provider | Real camera + simulated sensors; physical body + virtual twin |

##### E1 Platform Subtypes

Physical peers (E1) span a wide range of hardware capability. Platform
subtypes allow finer-grained classification when needed, but all E1 peers
share the same embodiment — a real, physical presence:

| Subtype | Capability | Examples |
|---------|-----------|----------|
| E1a | Passive sensor — publishes data, accepts no commands | Standalone temperature logger, fixed environmental monitor |
| E1b | Embedded controller — microcontroller with fixed command set | A.U.R.A. (ESP32 sensor array), S.P.A.R.K. (Arduino actuators) |
| E1c | Full compute — SBC (Single-Board Computer) with full OS | M.I.R.A.G.E. on Jetson, S.T.A.T. on Raspberry Pi |

Platform subtypes are optional metadata. A peer that reports `"embodiment": "E1"`
without a subtype is valid — the subtype adds detail, not a requirement.

#### OCP Behaviour by Type

- **E1**: Full OCP participation — status with LWT (Last Will and Testament),
  discovery, command/response, heartbeat (30-second interval, 90-second timeout).
  E1a subtypes may publish data only (no command subscription). Peers that omit
  the `embodiment` field are assumed E1 for backward compatibility.
- **E2**: Same as E1, plus a secondary keepalive for the remote operator session.
  Discovery message includes `"operator"` field identifying the controlling entity.
- **E3**: Same as E1, but `embodiment` field is `"digital"`. Virtual peers
  additionally publish to `echo/discovery/simulates` so physical peers can
  distinguish them. Game engine avatars report their host engine and scene.
- **E4**: Same as E1, but `embodiment` field is `"software"`. No physical or
  virtual body representation. Publishes to `echo/discovery/simulates`.
- **E5**: Same as E1, but discovery message lists which capabilities are
  real vs. simulated. The Provider pattern manages runtime transitions
  between backing implementations.

#### Status Message Schema Extension

The existing OCP status message gains an optional `embodiment` block:

```json
{
  "device": "mirage",
  "msg_type": "status",
  "status": "online",
  "timestamp": 1711148400,
  "version": "2.1.0",
  "capabilities": ["armor_display", "detect", "map"],
  "embodiment": {
    "type": "E1",
    "subtype": "E1c",
    "label": "physical",
    "real_capabilities": ["armor_display", "detect", "map"],
    "simulated_capabilities": []
  }
}
```

Peers that omit the `embodiment` block are assumed E1 (physical) for backward
compatibility with existing O.A.S.I.S. components. The block is most useful
for E3 (digital/virtual), E4 (software-only), and E5 (hybrid) peers.

#### Discovery for Non-Physical Peers

E3 and E4 peers publish to `echo/discovery/simulates` (retained):

```json
{
  "peer_id": "echo-aura-simulation",
  "component": "aura",
  "embodiment": "digital",
  "capabilities": ["motion", "gps", "environmental"],
  "timestamp": 1711148400
}
```

This enables consuming components (e.g., M.I.R.A.G.E. HUD status display,
D.A.W.N. WebUI), the Provider pattern, and test harnesses to distinguish
physical, virtual, and software-only peers on the same network.

#### Implementation Status

| Type | Status |
|------|--------|
| E1 (physical) | Implemented — current `Embodiment.E3` maps to E1 (enum rename pending) |
| E4 (software) | Implemented — current `Embodiment.E4` maps to E4 |
| E2 (remote-physical) | Proposed — pending review |
| E3 (digital/virtual) | Proposed — pending review; needed for Godot OCP plugin |
| E5 (hybrid) | Proposed — pending review; depends on Provider pattern (implemented) |
| E1 platform subtypes | Proposed — optional metadata for finer-grained classification |
| `embodiment` block | Proposed schema — not yet in `OCPPeer` status messages |
| `echo/discovery/simulates` | Implemented — published by `OCPPeer` and ecosystem demo |

---

## Change History

| Date | Author | Change |
|------|--------|--------|
| 2026-01-30 | Malcolm Howard | Initial draft |
| 2026-02-03 | Malcolm Howard | Moved to formal location, status changed to Proposed; added Cross-Language Strategy section with HAL approach |
| 2026-02-06 | Malcolm Howard | Added Option E (GENESIS) evaluation; added HAL language extensibility note |
| 2026-03-08 | Malcolm Howard | Amendment 1: Scope expanded to full simulation framework; added layered architecture (Device/Network/Platform), per-component layer needs, and demo ownership model |
| 2026-03-08 | Malcolm Howard | Amendment 2: Selective injection design constraint; mock classes must be interface-compatible with real drivers; demo auto-detect and selective override modes |
| 2026-03-08 | Malcolm Howard | Renamed file from `0003-hardware-mocking.md` to `0003-simulation-environment-architecture.md`; title updated to match expanded scope |
| 2026-03-11 | Malcolm Howard | Amendment 3: Accessibility reframing — contributor accessibility identified as primary motivation; software dependency spectrum documented; minimum viable hardware profile (4 GB, no GPU, any OS via Docker) established; Docker distribution path documented; classroom context added |
| 2026-03-22 | Malcolm Howard | Amendment 4: Runtime injection modes and graceful degradation — three injection phases (default, explicit, runtime); Provider pattern for hot-swap (implemented in `simulation/hal/provider.py`); connection to OCP component discovery; graceful degradation when hardware/services appear or disappear |
| 2026-03-22 | Malcolm Howard | Amendment 5: OCP Embodiment Spectrum — initial E1-E5 type definitions |
| 2026-03-28 | Malcolm Howard | Amendment 5 revised: reframed spectrum around relationship to physical reality (not platform capability); E1=Physical (with E1a/b/c subtypes), E2=Remote-Physical (new), E3=Digital/Virtual (new — Godot avatars, simulated peers), E4=Software-Only, E5=Hybrid; backward compatible (omitting embodiment field = E1) |
| TBD | Kris Kersey | Review and name selection |
| TBD | TBD | ADR approved, status changed to Accepted |

---

*This ADR follows the conventions documented in the [ADR README](README.md).*
