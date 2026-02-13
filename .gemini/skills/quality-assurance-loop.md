---
name: Quality Assurance Loop
description: How to execute the Build-Test-Cover-Run-Document loop.
---

# Quality Assurance Loop Skill

This skill mandates a rigorous "Fix-It-Yourself" cycle. You must never deliver code that hasn't passed this loop.

## Procedure

1.  **Build Phase**:
    -   Command: `npm run build`
    -   *If Fail*: Analyze error -> Fix Code -> Retry.
    -   *If Success*: Proceed to Test.

2.  **Unit Test Phase**:
    -   Command: `npm run test`
    -   *If Fail*: logical error in code or bad test -> Fix -> Retry.
    -   *If Success*: Proceed to Coverage.

3.  **Coverage Phase**:
    -   Command: `npm run test:cov`
    -   Target: **95% Branch Coverage**.
    -   *If < 95%*: Identify uncovered lines -> Add tests -> Retry.

4.  **Runtime Phase**:
    -   Command: `npm run start:dev` (Check for startup crashes).
    -   *If Crash*: Fix dependency injection/config -> Retry.
    -   *If Healthy*: Proceed to Documentation.

5.  **Documentation Phase (Postman)**:
    -   **Context**: Identify the current Repository Name (e.g., via `basename $(pwd)`).
    -   **Workspace Discovery**:
        -   Call `mcp_postman_getWorkspaces`.
        -   Find a workspace name that matches the Repository Name (case-insensitive).
        -   *Fallback*: If not found, use the first available Personal Workspace.
    -   **Collection Setup**:
        -   Call `mcp_postman_getCollections` in the target workspace.
        -   Look for a collection named **"Local"**.
        -   *If Missing*: Create it via `mcp_postman_createCollection` (Name: "Local").
    -   **Request Creation**:
        -   Add a request to the "Local" collection.
        -   **Name**: `<Service Name> - Health Check` (or specific endpoint).
        -   **URL**: `http://localhost:<PORT>/<PREFIX>/health` (or similar).
    -   **Deliverable**: Provide the `curl` command in the chat for immediate verification.

## Mental Loop
DO NOT ask the user to fix compilation errors. You fix them.
DO NOT deliver code with failing tests. You fix them.
DO NOT ignore coverage. You improve it.
DO NOT forget the Postman Collection. You create it.
