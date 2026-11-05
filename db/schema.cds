namespace smartprocure;

using { cuid, managed, Currency, Country } from '@sap/cds/common';

// ---------- Reusable types (shared contract: change only via a PR both developers review) ----------
type Amount        : Decimal(15, 2);
type Email         : String(255);
type RequestStatus : String(12) enum { SUBMITTED; APPROVED; REJECTED; ORDERED; CANCELLED; };
type OrderStatus   : String(12) enum { CREATED; CONFIRMED; DELIVERED; CLOSED; };
type SupplierState : String(10) enum { PENDING; ACTIVE; BLOCKED; };
type RiskLevel     : String(6)  enum { LOW; MEDIUM; HIGH; };

// ---------- 1-2 Organisation ----------
entity Departments : cuid, managed {
  code       : String(10) @mandatory;
  name       : String(60) @mandatory;
  costCenter : String(10);
  head       : Association to Employees;
}

entity Employees : cuid, managed {
  employeeNo    : String(10) @mandatory;
  userId        : String(60) @mandatory;      // login name, matches $user.id
  name          : String(100) @mandatory;
  email         : Email;
  department    : Association to Departments;
  manager       : Association to Employees;   // the approver for this employee's requests
  approvalLimit : Amount default 0;
}

// ---------- 3-5 Supplier master (Developer 2) ----------
entity Suppliers : cuid, managed {
  supplierNo     : String(10);               // generated (S-1006) unless supplied
  name           : String(120) @mandatory;
  country        : Country;
  email          : Email;
  state          : SupplierState default 'PENDING';
  riskLevel      : RiskLevel default 'MEDIUM';
  s4PartnerId    : String(10);                // S/4HANA business partner
  portalId       : String(20);                // supplier portal id
  contacts       : Composition of many SupplierContacts on contacts.supplier = $self;
  certifications : Composition of many SupplierCertifications on certifications.supplier = $self;
}

entity SupplierContacts : cuid {
  supplier : Association to Suppliers;
  name     : String(100) @mandatory;
  role     : String(40);
  email    : Email;
  phone    : String(30);
}

entity SupplierCertifications : cuid {
  supplier  : Association to Suppliers;
  certType  : String(40) @mandatory;          // e.g. ISO 9001
  issuedOn  : Date;
  expiresOn : Date @mandatory;
  document  : String(255);                    // link to the stored file
}

// ---------- 6 Materials ----------
entity Materials : cuid, managed {
  materialNo    : String(18) @mandatory;
  description   : String(120) @mandatory;
  category      : String(30);
  baseUnit      : String(3) default 'EA';
  standardPrice : Amount;
  currency      : Currency;
  s4MaterialId  : String(18);
}

// ---------- 7-9 Purchase requests (Developer 1) ----------
entity PurchaseRequests : cuid, managed {
  requestNo     : String(14);                 // PR-2026-0001, generated
  title         : String(120) @mandatory;
  justification : String(500);
  requester     : Association to Employees;
  department    : Association to Departments;
  approver      : Association to Employees;
  status        : RequestStatus default 'SUBMITTED';
  neededBy      : Date;
  currency      : Currency;
  totalAmount   : Amount default 0;
  items         : Composition of many PurchaseRequestItems on items.request = $self;
  approvals     : Composition of many PurchaseApprovals on approvals.request = $self;
}

entity PurchaseRequestItems : cuid {
  request        : Association to PurchaseRequests;
  itemNo         : Integer;
  material       : Association to Materials;
  description    : String(120);
  quantity       : Decimal(13, 3) @assert.range: [0.001, 999999];
  unit           : String(3) default 'EA';
  estimatedPrice : Amount;
  netAmount      : Amount;
}

entity PurchaseApprovals : cuid {
  request   : Association to PurchaseRequests;
  approver  : Association to Employees;
  decision  : String(10) enum { APPROVED; REJECTED; };
  comment   : String(500);
  decidedAt : Timestamp;
}

// ---------- 10-11 Quotations (Developer 2) ----------
entity SupplierQuotations : cuid, managed {
  quotationNo  : String(20);                  // generated (QT-1007) unless supplied
  request      : Association to PurchaseRequests;   // optional link to a request
  supplier     : Association to Suppliers @mandatory;
  validUntil   : Date;
  currency     : Currency;
  deliveryDays : Integer;
  source       : String(8) enum { MANUAL; PORTAL; CSV; } default 'MANUAL';
  totalAmount  : Amount default 0;
  items        : Composition of many SupplierQuotationItems on items.quotation = $self;
}

entity SupplierQuotationItems : cuid {
  quotation : Association to SupplierQuotations;
  material  : Association to Materials @mandatory;
  quantity  : Decimal(13, 3);
  unitPrice : Amount @assert.range: [0.01, 99999999];
  netAmount : Amount;
}

// ---------- 12-15 Orders, receipts, invoices (Developer 1) ----------
entity PurchaseOrders : cuid, managed {
  poNumber       : String(10);
  s4PoNumber     : String(10);                // set when synchronised with S/4HANA
  request        : Association to PurchaseRequests;
  supplier       : Association to Suppliers @mandatory;
  status         : OrderStatus default 'CREATED';
  orderDate      : Date;
  promisedDate   : Date;
  deliveryStatus : String(20);                // from the supplier portal
  currency       : Currency;
  totalAmount    : Amount default 0;
  items          : Composition of many PurchaseOrderItems on items.order = $self;
  receipts       : Association to many GoodsReceipts on receipts.order = $self;
}

entity PurchaseOrderItems : cuid {
  order      : Association to PurchaseOrders;
  itemNo     : Integer;
  material   : Association to Materials;
  quantity   : Decimal(13, 3);
  unitPrice  : Amount;
  netAmount  : Amount;
  receivedQty: Decimal(13, 3) default 0;
}

entity GoodsReceipts : cuid, managed {
  grNumber   : String(30);
  order      : Association to PurchaseOrders @mandatory;
  item       : Association to PurchaseOrderItems @mandatory;
  quantity   : Decimal(13, 3) @assert.range: [0.001, 999999];
  receivedOn : Date;
  receivedBy : String(60);
  note       : String(200);
  source     : String(6) enum { LOCAL; S4; } default 'LOCAL';
}

entity Invoices : cuid, managed {
  invoiceNo : String(20) @mandatory;
  order     : Association to PurchaseOrders;
  supplier  : Association to Suppliers;
  amount    : Amount;
  currency  : Currency;
  status    : String(8) enum { OPEN; PAID; BLOCKED; } default 'OPEN';
  dueDate   : Date;
}

// ---------- 16-19 Analytics, AI and logs ----------
entity SupplierPerformance : cuid, managed {
  supplier        : Association to Suppliers @mandatory;
  period          : String(7) @mandatory;     // 2026-09
  onTimeRate      : Decimal(5, 2);            // % of deliveries on time
  qualityScore    : Decimal(5, 2);            // 0..100
  avgDeliveryDays : Decimal(5, 1);
  overallScore    : Decimal(5, 2);
}

entity AIRecommendations : cuid, managed {
  kind      : String(20) enum { SUPPLIER; RISK; PRICE; ACTION_PROPOSAL; };
  subject   : String(60);                     // request no, material no, ...
  supplier  : Association to Suppliers;
  request   : Association to PurchaseRequests;
  score     : Decimal(5, 2);
  text      : String(2000);
  payload   : LargeString;                    // JSON of the proposed action
  status    : String(10) enum { NEW; PENDING; CONFIRMED; DISMISSED; } default 'NEW';
  model     : String(60);
}

// append-only: no UPDATE / DELETE is exposed anywhere
entity AuditLogs : cuid {
  at       : Timestamp @cds.on.insert: $now;
  actor    : String(60);
  channel  : String(10);                      // ODATA | MCP | AGENT | JOB
  action   : String(40);
  entity   : String(40);
  entityKey: String(60);
  detail   : String(1000);
}

entity IntegrationLogs : cuid {
  at       : Timestamp @cds.on.insert: $now;
  system   : String(12) enum { S4HANA; PORTAL; CSV; AICORE; };
  operation: String(40);
  status   : String(8) enum { SUCCESS; PARTIAL; FAILED; };
  records  : Integer;
  errors   : Integer;
  detail   : LargeString;                     // JSON list of row errors
  actor    : String(60);
}
