/*
 * Trimmed copy of the S/4HANA "Material Documents" API (API_MATERIAL_DOCUMENT_SRV, OData V2).
 * Goods movement type 101 = goods receipt for a purchase order.
 */
@cds.external: true   // entities below are @cds.persistence.skip: no table is created in HANA; CAP mocks them in memory for development
service API_MATERIAL_DOCUMENT_SRV {
  @cds.persistence.skip
  entity A_MaterialDocumentItem {
    key MaterialDocumentYear : String(4);
    key MaterialDocument     : String(10);
    key MaterialDocumentItem : String(4);
        Material             : String(40);
        Plant                : String(4);
        GoodsMovementType    : String(3);
        QuantityInEntryUnit  : Decimal(13, 3);
        PurchaseOrder        : String(10);
        PurchaseOrderItem    : String(5);
        PostingDate          : Date;
  }
}
