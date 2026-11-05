/*
 * Trimmed copy of the S/4HANA "Purchase Order (A2X)" API (API_PURCHASEORDER_PROCESS_SRV, OData V2).
 * Real model: download the EDMX from api.sap.com and run   cds import <file>.edmx --as cds
 * We keep only the fields SmartProcure reads. Field names are the SAP names.
 */
@cds.external: true   // entities below are @cds.persistence.skip: no table is created in HANA; CAP mocks them in memory for development
service API_PURCHASEORDER_PROCESS_SRV {
  @cds.persistence.skip
  entity A_PurchaseOrder {
    key PurchaseOrder         : String(10);
        CompanyCode           : String(4);
        PurchaseOrderType     : String(4);
        Supplier              : String(10);
        DocumentCurrency      : String(5);
        PurchaseOrderDate     : Date;
        PurchasingOrganization: String(4);
  }
  @cds.persistence.skip
  entity A_PurchaseOrderItem {
    key PurchaseOrder             : String(10);
    key PurchaseOrderItem         : String(5);
        Material                  : String(40);
        PurchaseOrderItemText     : String(40);
        OrderQuantity             : Decimal(13, 3);
        PurchaseOrderQuantityUnit : String(3);
        NetPriceAmount            : Decimal(11, 2);
        DocumentCurrency          : String(5);
  }
}
