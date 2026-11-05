using { smartprocure as db } from '../db/schema';

/**
 * OWNER: Developer 2 (suppliers, integration, AI). Contract: docs/api-contracts/supplier-service.md
 */
@path: 'supplier'
@requires: 'authenticated-user'
service SupplierService {

  // ---- US-07 / US-08: supplier master, contacts and certifications ----
  entity Suppliers as projection on db.Suppliers actions {
    action activate() returns Suppliers;   // needs one valid certification
    action block(reason : String) returns Suppliers;
  };
  entity SupplierContacts       as projection on db.SupplierContacts;
  entity SupplierCertifications as projection on db.SupplierCertifications;
  @readonly entity Materials    as projection on db.Materials;

  // ---- US-09: quotations ----
  entity SupplierQuotations     as projection on db.SupplierQuotations;
  entity SupplierQuotationItems as projection on db.SupplierQuotationItems;

  // ---- US-10 / US-12 / US-14: analytics and AI output (written by actions only) ----
  @readonly entity SupplierPerformance as projection on db.SupplierPerformance;
  @readonly entity AIRecommendations   as projection on db.AIRecommendations;
  @readonly entity IntegrationLogs     as projection on db.IntegrationLogs;

  // ---- US-11: integrations ----
  action syncFromPortal() returns SyncResult;
  action importQuotationsCsv(fileName : String, content : LargeString) returns ImportResult;
  action computePerformance(period : String(7)) returns Integer;
  /** Stores the deterministic recommendation so managers can audit it later. */
  action saveRecommendation(requestNo : String) returns Recommendation;

  type SyncResult   { suppliers : Integer; certifications : Integer; quotations : Integer; deliveries : Integer; }
  type ImportResult { rows : Integer; imported : Integer; duplicates : Integer; errors : Integer; messages : array of String; }

  type SupplierDetails { supplierNo : String; name : String; state : String; riskLevel : String; country : String;
                         certifications : array of { certType : String; expiresOn : Date; valid : Boolean };
                         latestScore : Decimal(5,2); openOrders : Integer; }
  type Offer      { supplierNo : String; supplier : String; unitPrice : Decimal(15,2); deliveryDays : Integer;
                    quality : Decimal(5,2); riskLevel : String; certificationOk : Boolean; score : Decimal(5,2);
                    rank : Integer; unusualPrice : Boolean; }
  type Comparison { materialNo : String; offers : array of Offer; medianPrice : Decimal(15,2); }
  type Performance { supplierNo : String; supplier : String; period : String; onTimeRate : Decimal(5,2);
                     qualityScore : Decimal(5,2); avgDeliveryDays : Decimal(5,1); overallScore : Decimal(5,2); }
  type ExpiringCert { supplierNo : String; supplier : String; certType : String; expiresOn : Date; daysLeft : Integer; }
  type Recommendation { requestNo : String; materialNo : String; best : Offer; reason : String; alternatives : array of Offer; }

  function supplierDetails(supplierNo : String) returns SupplierDetails;
  function compareQuotations(materialNo : String) returns Comparison;
  function supplierPerformance(supplierNo : String) returns many Performance;
  function expiringCertifications(days : Integer) returns many ExpiringCert;
  function recommend(requestNo : String) returns Recommendation;
}
