# smartprocure-enterprise

AI-powered enterprise procurement and supplier management on SAP CAP (Node.js, CDS 10), SAP HANA Cloud, Fiori Elements,
S/4HANA integration (mock), a supplier-portal REST integration (mock), CSV import, a native MCP server (`@cap-js/mcp`) and a CAP agent (`@cap-js/agents`).

## Run locally (no BTP account needed)

```bash
npm install
npm run mock:portal        # terminal 1: supplier portal mock on :4010
npm run watch              # terminal 2: http://localhost:4004  (SQLite in memory, S/4 mocked by CAP)
npm test                   # 74 tests, no internet, no LLM
```

Users (password = user name): `alice` Employee · `bob`, `frank` Employee+Manager · `carol` ProcurementOfficer · `dave` WarehouseEmployee · `admin` Administrator.

| What | URL |
|---|---|
| Launchpad | http://localhost:4004/common/index.html |
| Procurement API | http://localhost:4004/odata/v4/procurement |
| Supplier API | http://localhost:4004/odata/v4/supplier |
| MCP endpoint | http://localhost:4004/mcp/smartprocure-mcp |
| Agent (A2A) | http://localhost:4004/a2a/procurement-assistant/.well-known/agent-card.json |

## Layout

```
app/        procurement-ui (Developer 1) · supplier-ui (Developer 2) · common (shared shell)
db/         schema.cds (shared) · data/*.csv
srv/        procurement-service.* (D1) · supplier-service.* (D2) · integrations/ · mcp/ · agents/ · external/ · lib/
mocks/      supplier-portal-mock.js
test/       procurement · supplier · integrations · agents
docs/       api-contracts · architecture · developer-guides · decisions
```

Ownership and the branching rules are in `docs/api-contracts/shared-contract.md` and the handbook.
