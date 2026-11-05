using { ProcurementService as S } from './procurement-service';

// OWNER: Developer 1. Roles: Employee, Manager, ProcurementOfficer, WarehouseEmployee, Administrator
annotate S.PurchaseRequests with @restrict: [
  { grant: 'READ',   to: 'Employee', where: 'requester.userId = $user' },   // US-02: my requests only
  { grant: 'CREATE', to: 'Employee' },                                       // US-01
  { grant: 'READ',                to: ['Manager', 'ProcurementOfficer', 'Administrator'] },
  { grant: ['approveRequest', 'rejectRequest'], to: 'Manager' },          // handler adds: must be the assigned approver
  { grant: 'createPurchaseOrder', to: 'ProcurementOfficer' }
];

annotate S.PurchaseRequestItems with @restrict: [
  { grant: 'READ',   to: 'Employee', where: 'request.requester.userId = $user' },
  { grant: 'CREATE', to: 'Employee' },
  { grant: 'READ',   to: ['Manager', 'ProcurementOfficer', 'Administrator'] }
];

annotate S.PurchaseApprovals with @restrict: [
  { grant: 'READ', to: 'Employee', where: 'request.requester.userId = $user' },
  { grant: 'READ', to: ['Manager', 'ProcurementOfficer', 'Administrator'] }
];

annotate S.PurchaseOrders with @restrict: [
  { grant: 'READ', to: ['ProcurementOfficer', 'Manager', 'WarehouseEmployee', 'Administrator'] },
  { grant: ['CREATE', 'UPDATE'], to: 'ProcurementOfficer' }
];
annotate S.PurchaseOrderItems with @restrict: [
  { grant: 'READ', to: ['ProcurementOfficer', 'Manager', 'WarehouseEmployee', 'Administrator'] },
  { grant: ['CREATE', 'UPDATE'], to: 'ProcurementOfficer' }
];
annotate S.GoodsReceipts with @restrict: [
  { grant: 'READ',   to: ['WarehouseEmployee', 'ProcurementOfficer', 'Manager', 'Administrator'] },
  { grant: 'CREATE', to: 'WarehouseEmployee' }
];
annotate S.Invoices with @restrict: [{ grant: 'READ', to: ['ProcurementOfficer', 'Manager', 'Administrator'] }];

annotate S.confirmProposal      with @requires: 'Manager';
annotate S.dismissProposal      with @requires: 'Manager';
annotate S.syncFromS4           with @requires: 'ProcurementOfficer';
annotate S.updateDeliveryStatus with @requires: 'ProcurementOfficer';
annotate S.requestStatus        with @requires: ['Employee', 'Manager', 'ProcurementOfficer', 'Administrator'];
annotate S.pendingApprovals     with @requires: ['Manager', 'Administrator'];
annotate S.orderStatus          with @requires: ['ProcurementOfficer', 'Manager', 'WarehouseEmployee', 'Administrator'];
annotate S.delayedOrders        with @requires: ['ProcurementOfficer', 'Manager', 'Administrator'];
annotate S.summary              with @requires: ['ProcurementOfficer', 'Manager', 'Administrator'];
