# Architecture

The architecture, data model, workflow diagrams and security architecture are documented in the
**SmartProcure Enterprise Development Handbook** (`smartprocure-enterprise-development-handbook.html`, chapters 03-05 and 21).

Key facts for developers:

- One CAP application, two business services (`ProcurementService`, `SupplierService`), one read-only MCP facade, one agent.
- Five data sources: HANA Cloud (SQLite locally), S/4HANA (CAP mock locally), supplier portal (REST mock), CSV upload, AI Core (mock LLM locally).
- Authorization lives in CAP (`@requires`, `@restrict`, handlers). MCP, agent and UI are doors to the same rules.
- Decisions: see `../decisions/`.
