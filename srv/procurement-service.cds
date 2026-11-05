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
    action createPurchaseOrder(quotation : UUID) returns PurchaseOrders;
  };
  entity PurchaseRequestItems as projection on db.PurchaseRequestItems;
  @readonly entity PurchaseApprovals as projection on db.PurchaseApprovals;

  // ---- US-04 / US-05 ----
  entity PurchaseOrders as projection on db.PurchaseOrders;
  entity PurchaseOrderItems as projection on db.PurchaseOrderItems;
  entity GoodsReceipts as projection on db.GoodsReceipts;
  @readonly entity Invoices as projection on db.Invoices;

  // ---- human-in-the-loop: a person confirms what the AI agent only proposed (US-13 / US-14) ----
  action confirmProposal(proposalId : UUID) returns PurchaseRequests;
  action dismissProposal(proposalId : UUID) returns String;

  // ---- US-06: S/4HANA synchronisation ----
  action syncFromS4() returns SyncResult;

  // ---- contract used by Developer 2 (supplier portal delivery status) ----
  action updateDeliveryStatus(poNumber : String(10), deliveryStatus : String(20), promisedDate : Date) returns String;

  // ---- read-model functions: the ONLY place these rules live. MCP tools and the UI both call them ----
  type SyncResult     { read : Integer; created : Integer; updated : Integer; receipts : Integer; }
  type RequestStatus  { requestNo : String; title : String; status : String; totalAmount : Decimal(15,2); currency : String;
                        requester : String; approver : String; lastDecision : String; lastComment : String; }
  type PendingRequest { requestNo : String; title : String; requester : String; totalAmount : Decimal(15,2); neededBy : Date; ageDays : Integer; }
  type OrderStatus    { poNumber : String; supplier : String; status : String; deliveryStatus : String; promisedDate : Date;
                        totalAmount : Decimal(15,2); receivedPercent : Integer; delayed : Boolean; delayDays : Integer; }
  type Summary        { requestsSubmitted : Integer; requestsApproved : Integer; requestsRejected : Integer; requestsOrdered : Integer;
                        pendingValue : Decimal(15,2); openOrders : Integer; delayedOrders : Integer; receiptsLast30Days : Integer; }

  function requestStatus(requestNo : String) returns RequestStatus;
  function pendingApprovals() returns many PendingRequest;
  function orderStatus(poNumber : String)   returns OrderStatus;
  function delayedOrders()                  returns many OrderStatus;
  function summary()                        returns Summary;
}
