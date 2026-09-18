# Robotinics AI Runtime — Raspberry Pi

[Português](README.md) · [Español](README.es.md)

This module documents the proposed Raspberry Pi AI runtime based on TCHATGPT.

Services include LLM, Agent, Internet, RAG, Vision, Voice, Telemetry, Robot Gateway, Documentation and Audit.

Only RobotGateway may communicate with Arduino Mega. TAIAgent receives tools, not direct serial access.

Internet results are external context and can never directly authorize physical actions.

See `../../../docs/ai/` for architecture and documentation-agent rules.
