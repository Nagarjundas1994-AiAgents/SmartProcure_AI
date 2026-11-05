# Developer guides

| Guide | Where |
|---|---|
| Day-1 checklist for both developers | handbook, chapter 00 |
| First pull request | handbook, chapter 01 |
| Git workflow, branch protection, conflicts | handbook, chapter 08 |
| Per-story tutorials (US-01 ... US-14) | handbook, chapters 11-19 |
| Testing: `npm test`, per-folder scripts | handbook, chapter 22 |
| Deployment to BTP | handbook, chapter 23 |

Quick commands

```bash
npm install
npm test                    # everything
npm run test:procurement    # Developer 1 area
npm run test:supplier       # Developer 2 area
npm run mock:portal         # supplier portal mock on :4010
npm run watch               # CAP on :4004
```
