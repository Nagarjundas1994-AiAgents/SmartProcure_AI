# ADR 0002 - The agent proposes, a person decides

**Status:** accepted · **Owner:** Developer 2 + Developer 1 · **Reviewer:** Architect

## Context
A confirmation dialog is a user-interface convenience; a model or a malicious prompt can skip it.

## Decision
The agent's only write tool, `proposeDecision`, stores an `AIRecommendations` row (`ACTION_PROPOSAL`, `PENDING`).
`ProcurementService.confirmProposal` executes it with the **human's** identity through the same `decideRequest` function
as a manual approval (assigned approver, limit, separation of duties, state).

## Consequences
- The agent cannot approve, reject or order anything.
- Audit shows channel `AGENT` for the proposal and `ODATA` + the person for the decision.
- The approval inbox must show open proposals.
