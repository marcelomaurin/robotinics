# Robotinics AI — Rev. 3 Continuation

[Português](README.md) · [Español](README.es.md)

This folder documents the continuation of Robotinics with an AI layer running on Raspberry Pi and using the **TCHATGPT** library.

The Raspberry Pi is responsible for LLM access, RAG, internet integration, vision, voice, planning, telemetry interpretation and documentation assistance.

The LLM never controls motors or servos directly. Physical actions always pass through a deterministic validator and the Arduino Mega device protocol.

See `ARCHITECTURE.md`, `INTERNET_INTEGRATION.md`, `DOCUMENTATION_AGENT.md` and `Software/raspberry/AI/README.md`.
