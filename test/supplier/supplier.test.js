import cds from '@sap/cds'
import { describe, it } from 'node:test'
import assert from 'node:assert/strict'

process.env.CDS_REQUIRES_LLM_KIND ??= 'llm-mock'
const { GET, POST } = cds.test(import.meta.dirname + '/../..', '--with-mocks')
const as = n => ({ auth: { username: n, password: n } })
const [alice, bob, carol, dave, admin] = ['alice', 'bob', 'carol', 'dave', 'admin'].map(as)
const S = '/odata/v4/supplier'
const rejects = (p, re) => assert.rejects(p, e => re.test(`${e.code} ${e.message} ${JSON.stringify(e.response?.data ?? '')}`))
const MAT_STEEL = 'a1000000-0000-4000-8000-000000000001'

// Sprint 0: proves the shared model and seed data load. Each story appends its describe() blocks below.
describe('Sprint 0 foundation', () => {
  it('loads the shared model and the seed data', async () => {
    const { Suppliers } = cds.entities('smartprocure')
    assert.equal((await SELECT.from(Suppliers)).length, 5)
  })
})
