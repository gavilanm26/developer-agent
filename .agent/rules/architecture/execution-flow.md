---
trigger: always_on
---

# Execution Flow Standard

Mandatory flow pattern (transport-agnostic):

Inbound Adapter (HTTP Controller / Messaging Consumer / gRPC Controller)
↓
Inbound Transport DTO (if transport requires it)
↓
Application DTO
↓
UseCase / Orchestrator
↓
Domain Port
↓
Outbound Adapter
↓
Infrastructure Resource

Examples:

HTTP flow:

Controller
↓
HTTP DTO
↓
Application DTO
↓
UseCase / Orchestrator
↓
Domain Port
↓
Outbound Adapter
↓
Infrastructure Resource

Messaging flow (example):

Consumer
↓
Message Payload DTO
↓
Application DTO
↓
UseCase / Orchestrator
↓
Domain Port
↓
Outbound Adapter
↓
Infrastructure Resource

Rules:

- Inbound adapters contain no business logic.
- UseCases orchestrate logic.
- Domain ports define outbound boundaries.
- Adapters implement external communication.
- Layer direction must always point inward.
