using { SupplierService as S } from './supplier-service';

// OWNER: Developer 2
annotate S.Suppliers with @restrict: [
  { grant: 'READ', to: ['ProcurementOfficer', 'Manager', 'Administrator'] },
  { grant: ['CREATE', 'UPDATE', 'activate', 'block'], to: 'ProcurementOfficer' }
];
annotate S.SupplierContacts with @restrict: [
  { grant: 'READ', to: ['ProcurementOfficer', 'Manager', 'Administrator'] },
  { grant: ['CREATE', 'UPDATE', 'DELETE'], to: 'ProcurementOfficer' }
];
annotate S.SupplierCertifications with @restrict: [
  { grant: 'READ', to: ['ProcurementOfficer', 'Manager', 'Administrator'] },
  { grant: ['CREATE', 'UPDATE', 'DELETE'], to: 'ProcurementOfficer' }
];
annotate S.SupplierQuotations with @restrict: [
  { grant: 'READ', to: ['ProcurementOfficer', 'Manager'] },
  { grant: ['CREATE', 'UPDATE'], to: 'ProcurementOfficer' }
];
annotate S.SupplierQuotationItems with @restrict: [
  { grant: 'READ', to: ['ProcurementOfficer', 'Manager'] },
  { grant: ['CREATE', 'UPDATE'], to: 'ProcurementOfficer' }
];
annotate S.SupplierPerformance with @restrict: [{ grant: 'READ', to: ['ProcurementOfficer', 'Manager', 'Administrator'] }];
annotate S.AIRecommendations   with @restrict: [{ grant: 'READ', to: ['ProcurementOfficer', 'Manager', 'Administrator'] }];
annotate S.IntegrationLogs     with @restrict: [{ grant: 'READ', to: ['ProcurementOfficer', 'Administrator'] }];

annotate S.syncFromPortal         with @requires: 'ProcurementOfficer';
annotate S.importQuotationsCsv    with @requires: 'ProcurementOfficer';
annotate S.computePerformance     with @requires: ['ProcurementOfficer', 'Administrator'];
annotate S.saveRecommendation     with @requires: ['ProcurementOfficer', 'Manager'];
annotate S.supplierDetails        with @requires: ['ProcurementOfficer', 'Manager', 'Administrator'];
annotate S.compareQuotations      with @requires: ['ProcurementOfficer', 'Manager'];
annotate S.supplierPerformance    with @requires: ['ProcurementOfficer', 'Manager'];
annotate S.expiringCertifications with @requires: ['ProcurementOfficer', 'Manager'];
annotate S.recommend              with @requires: ['ProcurementOfficer', 'Manager'];
