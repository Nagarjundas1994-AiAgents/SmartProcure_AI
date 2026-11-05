// ---------- US-01: create a purchase request ----------
import cds from '@sap/cds'


const { SELECT, INSERT, UPDATE, DELETE } = cds.ql;
export default class ProcurementService extends cds.ApplicationService {
    async init() {
        const db = cds.entities('smartprocure')
        const { PurchaseRequests, GoodsReceipts } = this.entities


        this.before('CREATE', PurchaseRequests, async req => {

            const r = req.data
            const me = await SELECT.one.from(db.Employees).where({ userId: req.user.id })
            if (!me) return req.reject(400, `No employee record for user ${req.user.id}`)
            if (!r.items?.length) return req.reject(400, 'A purchase request needs at least one item')

            let total = 0
            for (const [i, it] of r.items.entries()) {
                const m = it.material_ID && await SELECT.one.from(db.Materials, it.material_ID)
                if (it.material_ID && !m) return req.reject(400, `Item ${i + 1}: unknown material`)
                if (!(Number(it.quantity) > 0)) return req.reject(400, `Item ${i + 1}: quantity must be greater than 0`)
                if (!m && !it.description) return req.reject(400, `Item ${i + 1}: enter a material or a description`)
                it.itemNo = (i + 1) * 10
                it.description ??= m.description
                it.unit ??= m?.baseUnit ?? 'EA'
                it.estimatedPrice ??= m?.standardPrice ?? 0
                it.netAmount = round2(it.quantity * it.estimatedPrice)
                total += it.netAmount
            }

            // duplicate detection: the same person submitting the same title twice
            const open = await SELECT.from(db.PurchaseRequests).columns('requestNo', 'title').where({ requester_ID: me.ID, status: 'SUBMITTED' })
            const dup = open.find(o => o.title.trim().toLowerCase() === (r.title ?? '').trim().toLowerCase())
            if (dup) return req.reject(409, `Duplicate request: ${dup.requestNo} already has the title "${dup.title}"`)

            const all = await SELECT.from(db.PurchaseRequests).columns('requestNo')
            r.requestNo = nextNumber(`PR-${new Date().getFullYear()}-`, 4, all.map(x => x.requestNo))
            Object.assign(r, {
                requester_ID: me.ID, department_ID: me.department_ID, approver_ID: me.manager_ID,
                status: 'SUBMITTED', currency_code: 'INR', totalAmount: round2(total)
            })
        })
        this.after('CREATE', PurchaseRequests, (_, req) => audit(req, 'CREATE', 'PurchaseRequest', req.data.requestNo, `total ${req.data.totalAmount}`))
        return super.init()
    }
}

