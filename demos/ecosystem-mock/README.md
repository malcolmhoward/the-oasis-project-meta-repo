# O.A.S.I.S. Ecosystem Simulation Demo

Run the entire O.A.S.I.S. ecosystem on a single machine — no specialized hardware, GPU, or API keys required. All components are simulated by the [E.C.H.O.](https://github.com/malcolmhoward/the-oasis-project-simulation-repo) simulation framework.

## What This Demonstrates

Multiple O.A.S.I.S. components coexisting on a shared MQTT network, each running as an OCP (OASIS Communications Protocol) E4 software peer:

```
┌──────────────────────────────────────────────────────────────────────┐
│                        Docker Compose                                │
│                                                                      │
│  ┌──────────────┐  ┌──────────────────────────────────────────────┐  │
│  │ mqtt-broker   │  │ mock-ecosystem                              │  │
│  │ (Mosquitto)   │  │                                              │  │
│  │ :1883         │  │  OCP peers:                                  │  │
│  │               │  │    echo-aura-simulation  (sensors)           │  │
│  │               │  │    echo-stat-simulation  (system metrics)    │  │
│  │               │  │    echo-scope-simulation (coordination)      │  │
│  │               │  │                                              │  │
│  │               │  │  Sensor publisher:                           │  │
│  │               │  │    aura topic (motion/GPS/enviro) at ~1Hz    │  │
│  │               │  │    stat topic (CPU/memory/battery) at ~1Hz   │  │
│  │               │  │                                              │  │
│  │               │  │  Service mocks:                              │  │
│  │               │  │    HA REST API :8123                         │  │
│  │               │  │    LLM API :8080                             │  │
│  └───────┬───────┘  └────────────────────┬───────────────────────┘  │
│          │            MQTT + HTTP         │                          │
│          └───────────────────────────────┘                          │
│                                                                      │
│  ┌─ Optional (uncomment in docker-compose.demo.yaml) ──────────┐    │
│  │  dawn    — D.A.W.N. WebUI :3000 (connects to mock services) │    │
│  │  mirage  — M.I.R.A.G.E. HUD (displays simulated sensors)    │    │
│  └──────────────────────────────────────────────────────────────┘    │
└──────────────────────────────────────────────────────────────────────┘
```

## Requirements

- Docker and Docker Compose
- ~500 MB disk (Python-based mock services)
- No GPU, no API keys, no external services

## Quick Start

```bash
# From the meta-repo root
docker compose -f demos/ecosystem-mock/docker-compose.demo.yaml up --build
```

## What You'll See

Once running, the mock ecosystem publishes data on the MQTT network at ~1Hz:

### MQTT Topics (subscribe to observe)

```bash
# In a separate terminal — subscribe to all topics
docker exec -it <mqtt-broker-container> mosquitto_sub -t '#' -v
```

| Topic | Publisher | Data |
|-------|-----------|------|
| `aura` | echo-aura-simulation | Motion (heading/pitch/roll), GPS (lat/lon/satellites), Environmental (temp/humidity/CO2) |
| `stat` | echo-stat-simulation | SystemMetrics (CPU/memory/temp), BatteryStatus (voltage/current/percentage) |
| `aura/status` | echo-aura-simulation | OCP online status (retained, heartbeat every 30s) |
| `stat/status` | echo-stat-simulation | OCP online status (retained, heartbeat every 30s) |
| `scope/status` | echo-scope-simulation | OCP online status (retained, heartbeat every 30s) |
| `echo/discovery/simulates` | All peers | Discovery messages identifying simulated components |

### Service Endpoints

| Service | URL | Description |
|---------|-----|-------------|
| Home Assistant API | http://localhost:8123/api/states | Entity states (kitchen lights, bedroom lights, thermostat) |
| LLM API | http://localhost:8080/v1/models | Model listing |
| LLM Chat | http://localhost:8080/v1/chat/completions | OpenAI-compatible chat (keyword → tool call) |

## Adding D.A.W.N. to the Ecosystem

Uncomment the `dawn` service in `docker-compose.demo.yaml`, or run the D.A.W.N. demo separately and point it at this network's MQTT broker:

```bash
# Option 1: Uncomment in docker-compose.demo.yaml and rebuild
docker compose -f demos/ecosystem-mock/docker-compose.demo.yaml up --build

# Option 2: Run D.A.W.N. demo on the same Docker network
docker compose -f demos/ecosystem-mock/docker-compose.demo.yaml up -d
docker compose -f repos/dawn/demos/full-mock/docker-compose.demo.yaml \
  --env-file /dev/null up --build
```

Then open **http://localhost:3000** for D.A.W.N.'s WebUI. Type "turn on the kitchen lights" to see the full pipeline:
user input → LLM mock → tool call → HA mock → entity state change.

## Adding M.I.R.A.G.E. to the Ecosystem

M.I.R.A.G.E. can connect to the same MQTT broker to display simulated sensor data on its HUD:

```bash
# Build M.I.R.A.G.E. and point it at the ecosystem broker
cd repos/mirage && mkdir -p build && cd build && cmake .. && make -j$(nproc)
./mirage --broker <host-ip> -b  # black background mode for UI testing
```

M.I.R.A.G.E. subscribes to `aura` and `stat` topics and displays heading, pitch, roll, GPS coordinates, environmental data, and system metrics — all from simulated data.

## OCP Component Discovery

Each simulated peer publishes to `echo/discovery/simulates` (retained) so other components can distinguish simulated peers from physical hardware:

```json
{
  "peer_id": "echo-aura-simulation",
  "component": "aura",
  "embodiment": "software",
  "capabilities": ["motion", "gps", "environmental"],
  "timestamp": 1711148400
}
```

This aligns with ADR-0003 Amendment 4 (runtime injection and graceful degradation) — real components can coexist with simulated peers on the same network, and the Provider pattern (future) can swap between them transparently.

## Related

- [E.C.H.O. Simulation Framework](https://github.com/malcolmhoward/the-oasis-project-simulation-repo) — Mock implementations for all three layers
- [D.A.W.N. Full Mock Demo](https://github.com/malcolmhoward/dawn/tree/feat/dawn/5-simulation-demo/demos/full-mock) — D.A.W.N. with all services mocked
- [M.I.R.A.G.E. HUD Mock Demo](https://github.com/malcolmhoward/mirage/tree/feat/mirage/5-simulation-demo/demos/hud-mock) — HUD display with simulated sensors
- [ADR-0003](../../coordination/decisions/adr/0003-simulation-environment-architecture.md) — Simulation environment architecture (Amendments 1-4)
- [ADR-0007](../../coordination/decisions/adr/0007-component-naming-convention.md) — Component naming convention
