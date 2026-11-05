using { ProcurementService as S } from './procurement-service';
// OWNER: Developer 1. Roles: Employee, Manager, ProcurementOfficer, WarehouseEmployee, Administrator
annotate S.PurchaseRequests with @restrict: [
  { grant: 'READ',   to: 'Employee', where: 'requester.userId = $user' },   // US-02: my requests only
  { grant: 'CREATE', to: 'Employee' },                                       // US-01
  { grant: 'READ',                to: ['Manager', 'ProcurementOfficer', 'Administrator'] },
  { grant: ['approveRequest', 'rejectRequest'], to: 'Manager' },          // handler adds: must be the assigned approver
  { grant: 'createPurchaseOrder', to: 'ProcurementOfficer' }
];
