---
name: Architectural Reasoning
description: How to use the Decision Graph to make architectural choices.
---

# Architectural Reasoning Skill

This skill allows the agent to make deterministic architectural decisions based on the `architecture-decision-graph.mmd`.

## Procedure

1.  **Load the Graph**: Read `.gemini/brains/architecture-decision-graph.mmd`.
2.  **Analyze User Request**: Map the user's requirements to the graph's decision nodes.
    -   *Complexity?* (Low/Medium/High)
    -   *Performance?* (Caching needed?)
    -   *Integrations?* (ACL needed?)
3.  **Traverse & Select**: Follow the paths to determine the target architecture.
4.  **Output Decision**: Before coding, state the "Architectural Decision Record" (ADR) in the chat.

## Example

> **User:** "I need a simple CRUD for managing internal inventory."
> 
> **Agent Reasoning:**
> - Complexity: Low (CRUD) -> Branch B1
> - Performance: Standard -> No Cache
> - Integrations: None
> 
> **Decision:** "Selected Architecture: Simple Layered (Controller -> Service). No Hexagonal overhead required."
