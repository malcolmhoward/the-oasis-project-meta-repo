"""
O.A.S.I.S. ecosystem mock — runs simulated components that publish and
subscribe to each other over MQTT, demonstrating the full ecosystem on
a single machine.

Simulated components:
  - A.U.R.A. (helmet sensors) — publishes motion, GPS, environmental data
  - S.T.A.T. (system monitor) — publishes system metrics, battery status
  - S.C.O.P.E. coordination — OCP E4 software peer, monitors all topics
  - Home Assistant mock — smart home entity control
  - LLM mock — OpenAI-compatible keyword → tool call mapping

Each component runs as an OCP peer with E4 (software) embodiment,
publishing status and discovery messages so D.A.W.N. and M.I.R.A.G.E.
can discover them on the network.

Environment variables:
  MQTT_BROKER (default "mqtt-broker")
  MQTT_PORT (default 1883)
  HA_PORT (default 8123)
  LLM_PORT (default 8080)
  PUBLISH_INTERVAL (default 1.0 seconds)
"""

import json
import os
import signal
import sys
import threading
import time

import paho.mqtt.client as mqtt

from simulation.layer0.sensor import MockSensor
from simulation.layer1.mqtt import TopicBuilder, MessageSerializer
from simulation.layer1.ocp import OCPPeer, Embodiment
from simulation.layer2.ha_mock import HomeAssistantMock
from simulation.layer2.llm_mock import LLMMock
from simulation.layer2.llm_http_server import LLMHTTPServer


def create_sensor_publisher(client, interval):
    """Publish simulated A.U.R.A. and S.T.A.T. sensor data at regular intervals."""
    imu = MockSensor("imu", sensor_type="motion")
    gps = MockSensor("gps", sensor_type="gps")
    enviro = MockSensor("enviro", sensor_type="environmental")

    def publish_loop():
        while True:
            # A.U.R.A. topics — same JSON schemas M.I.R.A.G.E. expects
            motion = imu.read()
            client.publish("aura", json.dumps(motion))

            gps_data = gps.read()
            client.publish("aura", json.dumps(gps_data))

            enviro_data = enviro.read()
            client.publish("aura", json.dumps(enviro_data))

            # S.T.A.T. topics — system metrics
            client.publish("stat", json.dumps({
                "device": "SystemMetrics",
                "cpu_percent": 35.2 + (time.time() % 10),
                "memory_percent": 62.1,
                "disk_percent": 45.0,
                "system_temp": 52.3,
                "uptime_seconds": int(time.time()) % 86400,
            }))
            client.publish("stat", json.dumps({
                "device": "BatteryStatus",
                "voltage": 12.4,
                "current": 1.2,
                "power": 14.88,
                "percentage": 85,
                "charging": False,
            }))

            time.sleep(interval)

    t = threading.Thread(target=publish_loop, daemon=True)
    t.start()
    return t


def main():
    broker = os.environ.get("MQTT_BROKER", "mqtt-broker")
    port = int(os.environ.get("MQTT_PORT", "1883"))
    ha_port = int(os.environ.get("HA_PORT", "8123"))
    llm_port = int(os.environ.get("LLM_PORT", "8080"))
    interval = float(os.environ.get("PUBLISH_INTERVAL", "1.0"))

    # --- MQTT client ---
    client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2)
    client.connect(broker, port, 60)
    client.loop_start()

    # --- OCP peers (E4 software embodiment) ---
    aura_peer = OCPPeer(
        client=client,
        peer_id="echo-aura-simulation",
        component="aura",
        embodiment=Embodiment.E4,
        capabilities=["motion", "gps", "environmental"],
        version="0.1.0-simulation",
    )

    stat_peer = OCPPeer(
        client=client,
        peer_id="echo-stat-simulation",
        component="stat",
        embodiment=Embodiment.E4,
        capabilities=["system_metrics", "battery"],
        version="0.1.0-simulation",
    )

    scope_peer = OCPPeer(
        client=client,
        peer_id="echo-scope-simulation",
        component="scope",
        embodiment=Embodiment.E4,
        capabilities=["coordination", "monitoring"],
        version="0.1.0-simulation",
    )

    # --- Start OCP peers ---
    for peer in [aura_peer, stat_peer, scope_peer]:
        peer.start()
        print(f"  OCP peer online: {peer.peer_id} ({peer.component})")

    # --- Start sensor publisher ---
    create_sensor_publisher(client, interval)
    print(f"  Sensor publisher: aura + stat topics at {interval}s intervals")

    # --- Home Assistant Mock ---
    ha = HomeAssistantMock(host="0.0.0.0", port=ha_port)
    ha.start()
    print(f"  Home Assistant mock: http://0.0.0.0:{ha_port}")

    # --- LLM Mock ---
    llm = LLMMock(default_response="I'm not sure how to help with that.")
    llm.add_tool_rule("turn on the kitchen lights",
        tool="homeassistant", args={"action": "turn_on", "entity_id": "light.kitchen_lights"})
    llm.add_tool_rule("turn off the kitchen lights",
        tool="homeassistant", args={"action": "turn_off", "entity_id": "light.kitchen_lights"})
    llm.add_tool_rule("turn on the bedroom lights",
        tool="homeassistant", args={"action": "turn_on", "entity_id": "light.bedroom_lights"})
    llm.add_tool_rule("turn off the bedroom lights",
        tool="homeassistant", args={"action": "turn_off", "entity_id": "light.bedroom_lights"})
    llm.add_tool_rule("set thermostat",
        tool="homeassistant", args={"action": "set_temperature", "entity_id": "climate.living_room_thermostat", "temperature": 22})
    llm.add_rule("hello", "Hey! I'm the O.A.S.I.S. ecosystem running in full simulation mode.")
    llm.add_rule("status", "All simulated peers online: A.U.R.A. (sensors), S.T.A.T. (system), S.C.O.P.E. (coordination). HA mock active. MQTT broker connected.")

    llm_server = LLMHTTPServer(llm, host="0.0.0.0", port=llm_port)
    llm_server.start()
    print(f"  LLM mock: http://0.0.0.0:{llm_port}")

    # --- Mock DAWN responder (listens on MQTT, responds via LLM mock) ---
    def on_dawn_message(mqtt_client, userdata, msg):
        try:
            payload = json.loads(msg.payload.decode())
        except (json.JSONDecodeError, UnicodeDecodeError):
            return

        # Extract user text from different message formats
        text = payload.get("value", payload.get("text", ""))
        if not text or payload.get("device") == "echo-dawn-simulation":
            return  # Ignore empty messages and our own responses

        print(f"  [DAWN mock] Received: {text}")

        # Check for tool call first
        tool_result = llm.tool_call(text)
        if tool_result is not None:
            # Execute tool call against HA mock
            tool_name = tool_result.get("tool", "")
            tool_args = tool_result.get("args", {})
            response_text = f"Executing {tool_name}: {tool_args.get('action', '')} on {tool_args.get('entity_id', '')}"

            if tool_name == "homeassistant":
                action = tool_args.get("action", "")
                entity_id = tool_args.get("entity_id", "")
                if action and entity_id:
                    ha.call_service(action.replace("turn_", ""), action, {"entity_id": entity_id})
                    state = ha.get_state(entity_id)
                    if state:
                        response_text = f"Done. {state['attributes'].get('friendly_name', entity_id)} is now {state['state']}."

            print(f"  [DAWN mock] Tool call: {tool_result}")
        else:
            # Regular text response
            response_text = llm.complete(text)

        # Publish response back to dawn topic
        mqtt_client.publish("dawn", json.dumps({
            "device": "echo-dawn-simulation",
            "action": "speak",
            "value": response_text,
            "timestamp": int(time.time()),
        }))
        print(f"  [DAWN mock] Response: {response_text}")

    def on_any_message(mqtt_client, userdata, msg):
        if msg.topic == "dawn":
            on_dawn_message(mqtt_client, userdata, msg)

    client.on_message = on_any_message
    client.subscribe("dawn")
    print(f"  DAWN mock responder: listening on 'dawn' topic")

    # Register DAWN as an OCP peer
    dawn_peer = OCPPeer(
        client=client,
        peer_id="echo-dawn-simulation",
        component="dawn",
        embodiment=Embodiment.E4,
        capabilities=["conversation", "tool_execution", "reasoning"],
        version="0.1.0-simulation",
    )
    dawn_peer.start()
    print(f"  OCP peer online: {dawn_peer.peer_id} (dawn)")

    print(f"\nO.A.S.I.S. ecosystem simulation ready.")
    print(f"  MQTT broker: {broker}:{port}")
    print(f"  OCP peers: echo-aura-simulation, echo-stat-simulation, echo-scope-simulation")
    print(f"  Sensor data: aura (motion/GPS/enviro) + stat (metrics/battery)")
    print(f"  Smart home: kitchen lights, bedroom lights, thermostat")
    print(f"\nConnect D.A.W.N. or M.I.R.A.G.E. to this network to see the full ecosystem.")

    # --- Wait for shutdown ---
    def shutdown(signum, frame):
        print("\nShutting down ecosystem simulation...")
        for peer in [aura_peer, stat_peer, scope_peer, dawn_peer]:
            peer.stop()
        llm_server.stop()
        ha.stop()
        client.loop_stop()
        client.disconnect()
        sys.exit(0)

    signal.signal(signal.SIGTERM, shutdown)
    signal.signal(signal.SIGINT, shutdown)

    while True:
        time.sleep(1)


if __name__ == "__main__":
    main()
