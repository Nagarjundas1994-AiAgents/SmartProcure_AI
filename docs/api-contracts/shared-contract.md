# SmartProcure shared API contract (v1.0)

Both developers sign this file before writing code. Changing anything below needs a pull request that **both** approve.

## 1. Ownership

| Artifact | Owner | The other developer may |
|---|---|---|
| `db/schema.cds` (all 19 entities) | shared | propose changes by PR only |
| `ProcurementService` (`srv/procurement-*`) | Developer 1 | call its published actions and functions |
| `SupplierService` (`srv/supplier-*`) | Developer 2 | call its published functions |
| `SmartProcureMcpService`, `ProcurementAssistant` | Developer 2 | review |
| `AuditLogs`, `IntegrationLogs` writers | each service writes its own rows | read |

## 2. Published cross-service calls (the only allowed coupling)

| Caller | Callee | Contract |
|---|---|---|
| Supplier portal sync (D2) | `ProcurementService.updateDeliveryStatus(poNumber, deliveryStatus, promisedDate)` | returns `"<po>: <status>"`, 404 if unknown PO |
| MCP tools (D2) | `ProcurementService.requestStatus / pendingApprovals / orderStatus / delayedOrders / summary` | functions listed in `procurement-service.cds` |
| Order creation (D1) | reads `SupplierQuotations` + `SupplierQuotationItems` + `Suppliers.state` through the shared schema | read-only |
| Agent proposals (D2 writes, D1 executes) | `AIRecommendations` row with `kind = ACTION_PROPOSAL`, `status = PENDING`; `ProcurementService.confirmProposal / dismissProposal` | payload JSON `{ decision, comment }` |

## 3. Rules

1. Entity and field names never change without a contract PR.
2. New fields are optional or have defaults, so the other developer's tests keep passing.
3. Status values are the enums in `db/schema.cds` (`RequestStatus`, `OrderStatus`, `SupplierState`, `RiskLevel`).
4. Error codes: 400 validation, 401 anonymous, 403 role / separation of duties, 404 not found or not yours, 409 wrong state / duplicate, 502 external system failed.
5. Every state change writes an `AuditLogs` row in the same transaction.
6. The AI agent and MCP tools never write business state; they call read functions or store a proposal.
