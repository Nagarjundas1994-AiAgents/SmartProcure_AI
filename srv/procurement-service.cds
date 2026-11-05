using { smartprocure as db } from '../db/schema';

/**
 * OWNER: Developer 1 (procurement). Contract: docs/api-contracts/procurement-service.md
 * Changing a signature in this file needs a pull request that Developer 2 reviews.
 */
@path: 'procurement'
@requires: 'authenticated-user'
service ProcurementService {

  // ---- master data the screens need (read-only) ----
  @readonly entity Materials   as projection on db.Materials;
  @readonly entity Employees   as projection on db.Employees { ID, employeeNo, userId, name, department, manager, approvalLimit };
  @readonly entity Departments as projection on db.Departments;

  // ---- US-01 / US-02 / US-03: one entity, three audiences. Row-level rules are in procurement-auth.cds:
  //      employees see and create only their own requests; managers, officers and admins see all.
  entity PurchaseRequests as projection on db.PurchaseRequests actions {
    action approveRequest(comment : String) returns PurchaseRequests;
    action rejectRequest(comment : String)  returns PurchaseRequests;
    /** US-04: officer turns an approved request + chosen quotation into a purchase order. */
    // action createPurchaseOrder(quotation : UUID) returns PurchaseOrders;
  };
  entity PurchaseRequestItems as projection on db.PurchaseRequestItems;
  @readonly entity PurchaseApprovals as projection on db.PurchaseApprovals;
}
