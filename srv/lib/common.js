import cds from '@sap/cds'

export const today = () => new Date().toISOString().slice(0, 10)
export const daysBetween = (a, b) => Math.round((Date.parse(b) - Date.parse(a)) / 864e5)
export const round2 = n => Math.round(Number(n) * 100) / 100

/** Append-only audit trail. Runs in the caller's transaction, so it commits or rolls back with the business change. */
export async function audit(req, action, entity, entityKey, detail = '', channel = 'ODATA') {
  const { AuditLogs } = cds.entities('smartprocure')
  await INSERT.into(AuditLogs).entries({
    actor: req.user?.id, channel, action, entity, entityKey: String(entityKey ?? ''), detail: String(detail).slice(0, 1000)
  })
}

/** Next number in a series, e.g. nextNumber('PR-2026-', 4, existingNumbers) -> PR-2026-0006 */
export function nextNumber(prefix, width, existing) {
  const used = existing.filter(n => n?.startsWith(prefix)).map(n => Number(n.slice(prefix.length)) || 0)
  return prefix + String(Math.max(0, ...used) + 1).padStart(width, '0')
}

export const integrationLog = (system, operation, status, records, errors, detail, actor) => {
  const { IntegrationLogs } = cds.entities('smartprocure')
  return INSERT.into(IntegrationLogs).entries({ system, operation, status, records, errors, detail: JSON.stringify(detail ?? []), actor })
}
