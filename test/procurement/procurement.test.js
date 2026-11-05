import cds from '@sap/cds'
import { describe, it } from 'node:test'
import assert from 'node:assert/strict'

process.env.CDS_REQUIRES_LLM_KIND ??= 'llm-mock'                     // tests never call a real LLM
process.env.S4_PAGE_SIZE = '2'                                       // forces paging against the S/4HANA mock
const { GET, POST } = cds.test(import.meta.dirname + '/../..', '--with-mocks')

const as = n => ({ auth: { username: n, password: n } })
const [alice, bob, carol, dave, erin, frank, admin] = ['alice', 'bob', 'carol', 'dave', 'erin', 'frank', 'admin'].map(as)
const P = '/odata/v4/procurement'
const PR1 = 'b1000000-0000-4000-8000-000000000001'   // alice, 250 000, approver bob
const PR3 = 'b1000000-0000-4000-8000-000000000003'   // erin, 720 000, approver frank (limit 600 000)
const PR4 = 'b1000000-0000-4000-8000-000000000004'   // ORDERED already
const MAT_STEEL = 'a1000000-0000-4000-8000-000000000001'
const rejects = (p, re) => assert.rejects(p, e => re.test(`${e.code} ${e.message} ${JSON.stringify(e.response?.data ?? '')}`))

// Sprint 0: proves the shared model and seed data load. Each story appends its describe() blocks below.
describe('Sprint 0 foundation', () => {
  it('loads the shared model and the seed data', async () => {
    const { PurchaseRequests } = cds.entities('smartprocure')
    assert.equal((await SELECT.from(PurchaseRequests)).length, 5)
  })
})
