import cds from '@sap/cds'
import { today, daysBetween, round2, audit } from './lib/common.js'
// US-09 adds: import { scoreOffers, explain } from './lib/scoring.js'
// US-11 adds: import { syncFromPortal } from './integrations/supplier-portal.js'
// US-11 adds: import { importQuotationsCsv } from './integrations/csv-import.js'

const EMAIL = /^[^@\s]+@[^@\s]+\.[^@\s]+$/

/** OWNER: Developer 2. Suppliers, certifications, quotations, performance, integrations and the deterministic recommendation. */
export default class SupplierService extends cds.ApplicationService {
  async init() {
    const db = cds.entities('smartprocure')
    const { Suppliers, SupplierCertifications, SupplierQuotations } = this.entities

    // Sprint 0 skeleton. Each story pastes its handlers HERE, in story order, under its
    // "// ---------- US-NN" marker (chapters 15-17). This file is loaded once srv/supplier-service.cds exists (US-07).

    return super.init()
  }
}
