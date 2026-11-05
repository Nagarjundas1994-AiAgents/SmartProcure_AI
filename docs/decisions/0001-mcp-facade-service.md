# ADR 0001 - MCP tools live in a separate read-only facade service

**Status:** accepted · **Owner:** Developer 2 · **Reviewer:** Architect

## Context
`@cap-js/mcp` can expose entities (a generic `query` tool) or functions as tools. AI clients must not get a path to the data
model that bypasses the rules of the business services.

## Decision
`SmartProcureMcpService` has **no entities**. Every tool is a function that forwards to exactly one function of
`ProcurementService` or `SupplierService` in the same request context. `cds.mcp.per_action_tool = true` gives each function its own
tool name and input schema. `cds.mcp.autowire = false`.

## Consequences
- OData and MCP can never disagree about who may see what.
- Tools are read-only; consequential actions are not exposed.
- A changed result type in a business function changes the tool schema - contract PR needed.
