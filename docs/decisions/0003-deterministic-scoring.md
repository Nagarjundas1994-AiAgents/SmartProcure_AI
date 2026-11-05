# ADR 0003 - Supplier ranking is deterministic code, the LLM only explains

**Status:** accepted · **Owner:** Developer 2

Weights price 40 %, delivery 25 %, quality 25 %, risk 10 % in `srv/lib/scoring.js` (pure function, unit-tested).
A language model that calculates a ranking is neither reproducible nor auditable. The agent receives the ranked table
from `compareSupplierQuotations` and explains it.

Unusual price: more than 30 % from the median with at least 3 offers. Missing certificate halves the risk score.
