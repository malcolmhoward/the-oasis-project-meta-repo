# ADR 0003: Hardware Mocking Architecture

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

| Name | Expansion | Notes |
|------|-----------|-------|
| **H.A.Z.E.** | Hardware Abstraction Zone for Emulation | Thematically aligned, virtual imagery |
| **M.I.S.T.** | Mock Infrastructure for System Testing | Complements haze imagery |
| **S.H.A.D.O.W.** | Simulated Hardware Abstraction for Development & Offline Work | Descriptive but long |
| **E.C.H.O.** | Emulated Components for Hardware Operations | Short and functional |
| **M.I.R.R.O.R.** | Mock Infrastructure for Reliable Replication of Resources | Mirrors M.I.R.A.G.E. naming |
| **P.H.A.N.T.O.M.** | Platform for Hardware Abstraction, Non-physical Testing & Operations Mocking | Very descriptive |
| **V.E.I.L.** | Virtual Emulation Interface Layer | Short, evokes abstraction |

## Change History

| Date | Author | Change |
|------|--------|--------|
| 2026-01-30 | Malcolm Howard | Initial draft |
| 2026-02-03 | Malcolm Howard | Moved to formal location, status changed to Proposed; added Cross-Language Strategy section with HAL approach |
| TBD | Kris Kersey | Review and name selection |
| TBD | TBD | ADR approved, status changed to Accepted |

---

*This ADR follows the conventions documented in the [ADR README](README.md).*
