-- ============================================================
-- IAM Practice Database - Seed Data
-- ============================================================
USE IAMPractice;
GO

-- Departments
INSERT INTO Departments (DepartmentName, CostCenter) VALUES
('Information Technology',      'CC-IT-001'),
('Identity & Access Management','CC-IT-002'),
('Risk & Compliance',           'CC-RC-001'),
('Retail Banking',              'CC-RB-001'),
('Corporate Finance',           'CC-CF-001'),
('Human Resources',             'CC-HR-001'),
('Trading & Markets',           'CC-TM-001'),
('Information Security',        'CC-IS-001');

-- Employees
INSERT INTO Employees (Username, FirstName, LastName, Email, DepartmentID, JobTitle, EmploymentType, Status, StartDate) VALUES
('m.kowalski',    'Marek',     'Kowalski',    'marek.kowalski@ing.com',    1, 'IT Manager',              'Permanent',  'Active',     '2018-03-12'),
('a.nowak',       'Anna',      'Nowak',       'anna.nowak@ing.com',        2, 'IAM Engineer',            'Permanent',  'Active',     '2020-06-01'),
('p.wisniewski',  'Piotr',     'Wiśniewski',  'piotr.wisniewski@ing.com',  2, 'IAM Analyst',             'Permanent',  'Active',     '2021-09-15'),
('k.wojcik',      'Katarzyna', 'Wójcik',      'katarzyna.wojcik@ing.com',  3, 'Compliance Officer',      'Permanent',  'Active',     '2019-01-20'),
('j.kaminski',    'Jan',       'Kamiński',    'jan.kaminski@ing.com',      4, 'Retail Banking Analyst',  'Permanent',  'Active',     '2022-04-11'),
('e.lewandowska', 'Ewa',       'Lewandowska', 'ewa.lewandowska@ing.com',   5, 'Finance Manager',         'Permanent',  'Active',     '2017-07-03'),
('t.zielinski',   'Tomasz',    'Zieliński',   'tomasz.zielinski@ing.com',  7, 'Trader',                  'Permanent',  'Active',     '2020-11-22'),
('m.szymanski',   'Michał',    'Szymański',   'michal.szymanski@ing.com',  8, 'Security Analyst',        'Permanent',  'Active',     '2021-02-08'),
('b.contractor',  'Barbara',   'Nowacka',     'barbara.nowacka@ext.com',   1, 'IT Consultant',           'Contractor', 'Active',     '2024-01-10'),
('r.intern',      'Rafał',     'Intern',      'rafal.intern@ing.com',      2, 'IAM Intern',              'Intern',     'Active',     '2025-02-01'),
('l.former',      'Lidia',     'Kowalczyk',   'lidia.kowalczyk@ing.com',   4, 'Retail Banking Analyst',  'Permanent',  'Terminated', '2020-05-01'),
('d.mover',       'Dominika',  'Wróbel',      'dominika.wrobel@ing.com',   6, 'HR Specialist',           'Permanent',  'Active',     '2019-03-17');

-- Set termination date for terminated employee
UPDATE Employees SET EndDate = '2023-08-31' WHERE Username = 'l.former';

-- Set department managers
UPDATE Departments SET ManagerID = 1 WHERE DepartmentID = 1;
UPDATE Departments SET ManagerID = 2 WHERE DepartmentID = 2;
UPDATE Departments SET ManagerID = 4 WHERE DepartmentID = 3;
UPDATE Departments SET ManagerID = 6 WHERE DepartmentID = 5;
UPDATE Departments SET ManagerID = 8 WHERE DepartmentID = 8;

-- Applications
INSERT INTO Applications (AppName, AppType, Owner, RiskLevel, IsPrivileged) VALUES
('Active Directory',      'Directory',    'IT Team',          'Critical', 1),
('SAP HR',                'HR',           'HR Team',          'High',     0),
('Core Banking System',   'Core Banking', 'Banking Ops',      'Critical', 1),
('Trading Platform',      'Trading',      'Markets Team',     'Critical', 1),
('CRM Salesforce',        'CRM',          'Retail Banking',   'Medium',   0),
('Azure Cloud',           'Cloud',        'IT Team',          'High',     1),
('SIEM (Splunk)',          'Security',     'InfoSec Team',     'High',     1),
('SAP Finance',           'ERP',          'Finance Team',     'High',     0);

-- Roles
INSERT INTO Roles (RoleName, Description, ApplicationID, IsPrivileged) VALUES
('AD_User',               'Standard Active Directory user account',               1, 0),
('AD_Admin',              'Active Directory administrator - full domain control',  1, 1),
('AD_ServiceDesk',        'Service desk - password resets and account unlocks',    1, 0),
('SAP_HR_Viewer',         'Read-only access to HR data',                          2, 0),
('SAP_HR_Admin',          'Full HR system administration',                        2, 1),
('CBS_ReadOnly',          'Read-only access to core banking',                     3, 0),
('CBS_Teller',            'Teller operations - deposits and withdrawals',         3, 0),
('CBS_Admin',             'Core banking system administrator',                    3, 1),
('Trading_Viewer',        'View-only trading positions and reports',              4, 0),
('Trading_Execute',       'Execute trades up to defined limits',                  4, 1),
('Trading_Admin',         'Full trading platform administration',                 4, 1),
('CRM_Agent',             'CRM standard customer service agent',                  5, 0),
('CRM_Manager',           'CRM manager - access to all customer data',            5, 0),
('Azure_Reader',          'Azure subscription read access',                       6, 0),
('Azure_Contributor',     'Azure resource management',                            6, 1),
('SIEM_Viewer',           'View security events and dashboards',                  7, 0),
('SIEM_Admin',            'Full SIEM administration and rule management',         7, 1),
('SAP_Finance_Viewer',    'Read-only financial reports',                          8, 0),
('SAP_Finance_Poster',    'Post journal entries and financial transactions',      8, 0),
('SAP_Finance_Admin',     'Full SAP Finance administration',                      8, 1);

-- Permissions
INSERT INTO Permissions (PermissionName, Description, ApplicationID, PermissionType) VALUES
('AD.Users.Read',         'Read user accounts',                   1, 'Read'),
('AD.Users.Write',        'Create and modify user accounts',      1, 'Write'),
('AD.Groups.Admin',       'Manage all AD groups',                 1, 'Admin'),
('AD.ResetPassword',      'Reset user passwords',                 1, 'Execute'),
('HR.Employee.Read',      'Read employee records',                2, 'Read'),
('HR.Employee.Write',     'Create and modify employee records',   2, 'Write'),
('HR.Payroll.Read',       'View payroll data',                    2, 'Read'),
('CBS.Accounts.Read',     'View customer account balances',       3, 'Read'),
('CBS.Transactions.Read', 'View transaction history',             3, 'Read'),
('CBS.Transactions.Post', 'Post financial transactions',          3, 'Write'),
('CBS.Admin.Full',        'Full core banking administration',     3, 'Admin'),
('Trade.Positions.Read',  'View open positions',                  4, 'Read'),
('Trade.Orders.Execute',  'Place and cancel trade orders',        4, 'Execute'),
('Trade.Admin.Full',      'Full trading system admin',            4, 'Admin'),
('Finance.GL.Read',       'Read general ledger',                  8, 'Read'),
('Finance.GL.Post',       'Post to general ledger',               8, 'Write'),
('Finance.Admin.Full',    'Full SAP Finance admin',               8, 'Admin');

-- Role <-> Permission mappings
INSERT INTO RolePermissions (RoleID, PermissionID, GrantedBy) VALUES
(1, 1, 'iam.system'),  -- AD_User -> AD.Users.Read
(2, 1, 'iam.system'),  -- AD_Admin -> AD.Users.Read
(2, 2, 'iam.system'),  -- AD_Admin -> AD.Users.Write
(2, 3, 'iam.system'),  -- AD_Admin -> AD.Groups.Admin
(2, 4, 'iam.system'),  -- AD_Admin -> AD.ResetPassword
(3, 1, 'iam.system'),  -- AD_ServiceDesk -> AD.Users.Read
(3, 4, 'iam.system'),  -- AD_ServiceDesk -> AD.ResetPassword
(4, 5, 'iam.system'),  -- SAP_HR_Viewer -> HR.Employee.Read
(5, 5, 'iam.system'),  -- SAP_HR_Admin -> HR.Employee.Read
(5, 6, 'iam.system'),  -- SAP_HR_Admin -> HR.Employee.Write
(5, 7, 'iam.system'),  -- SAP_HR_Admin -> HR.Payroll.Read
(6, 8, 'iam.system'),  -- CBS_ReadOnly -> CBS.Accounts.Read
(6, 9, 'iam.system'),  -- CBS_ReadOnly -> CBS.Transactions.Read
(7, 8, 'iam.system'),  -- CBS_Teller -> CBS.Accounts.Read
(7, 9, 'iam.system'),  -- CBS_Teller -> CBS.Transactions.Read
(7, 10, 'iam.system'), -- CBS_Teller -> CBS.Transactions.Post
(8, 11, 'iam.system'), -- CBS_Admin -> CBS.Admin.Full
(9, 12, 'iam.system'), -- Trading_Viewer -> Trade.Positions.Read
(10, 12, 'iam.system'),-- Trading_Execute -> Trade.Positions.Read
(10, 13, 'iam.system'),-- Trading_Execute -> Trade.Orders.Execute
(11, 14, 'iam.system'),-- Trading_Admin -> Trade.Admin.Full
(18, 15, 'iam.system'),-- SAP_Finance_Viewer -> Finance.GL.Read
(19, 15, 'iam.system'),-- SAP_Finance_Poster -> Finance.GL.Read
(19, 16, 'iam.system'),-- SAP_Finance_Poster -> Finance.GL.Post
(20, 17, 'iam.system');-- SAP_Finance_Admin -> Finance.Admin.Full

-- User Role Assignments
INSERT INTO UserRoles (EmployeeID, RoleID, AssignedBy) VALUES
-- Marek Kowalski (IT Manager)
(1,  1,  'iam.system'),   -- AD_User
(1,  2,  'iam.system'),   -- AD_Admin
(1,  14, 'iam.system'),   -- Azure_Reader
(1,  15, 'iam.system'),   -- Azure_Contributor
-- Anna Nowak (IAM Engineer)
(2,  1,  'iam.system'),   -- AD_User
(2,  3,  'iam.system'),   -- AD_ServiceDesk
(2,  16, 'iam.system'),   -- SIEM_Viewer
-- Piotr Wiśniewski (IAM Analyst)
(3,  1,  'iam.system'),   -- AD_User
(3,  3,  'iam.system'),   -- AD_ServiceDesk
-- Katarzyna Wójcik (Compliance)
(4,  1,  'iam.system'),   -- AD_User
(4,  6,  'iam.system'),   -- CBS_ReadOnly
(4,  16, 'iam.system'),   -- SIEM_Viewer
(4,  18, 'iam.system'),   -- SAP_Finance_Viewer
-- Jan Kamiński (Retail Banking)
(5,  1,  'iam.system'),   -- AD_User
(5,  7,  'iam.system'),   -- CBS_Teller
(5,  12, 'iam.system'),   -- CRM_Agent
-- Ewa Lewandowska (Finance Manager)
(6,  1,  'iam.system'),   -- AD_User
(6,  18, 'iam.system'),   -- SAP_Finance_Viewer
(6,  19, 'iam.system'),   -- SAP_Finance_Poster
-- Tomasz Zieliński (Trader)
(7,  1,  'iam.system'),   -- AD_User
(7,  9,  'iam.system'),   -- Trading_Viewer
(7,  10, 'iam.system'),   -- Trading_Execute
-- Michał Szymański (Security Analyst)
(8,  1,  'iam.system'),   -- AD_User
(8,  16, 'iam.system'),   -- SIEM_Viewer
(8,  17, 'iam.system'),   -- SIEM_Admin
-- Barbara (Contractor) - intentionally over-provisioned
(9,  1,  'iam.system'),   -- AD_User
(9,  2,  'm.kowalski'),   -- AD_Admin (excessive for contractor!)
(9,  8,  'm.kowalski'),   -- CBS_Admin (excessive!)
-- Rafał (Intern) - correctly limited
(10, 1,  'iam.system'),   -- AD_User only
-- Lidia (Terminated) - orphaned access, should have been revoked
(11, 1,  'iam.system'),   -- AD_User (NOT revoked on termination - finding!)
(11, 7,  'iam.system'),   -- CBS_Teller (NOT revoked - finding!)
-- Dominika (HR)
(12, 1,  'iam.system'),   -- AD_User
(12, 4,  'iam.system'),   -- SAP_HR_Viewer
(12, 19, 'a.nowak');      -- SAP_Finance_Poster (SoD violation: HR + Finance posting!)

-- SoD Conflict definitions
INSERT INTO SoDConflicts (RoleID_A, RoleID_B, ConflictReason, Severity) VALUES
(19, 5,  'Finance GL posting + HR Admin: risk of fraudulent payroll manipulation',   'Critical'),
(10, 19, 'Trade execution + Finance GL posting: market manipulation risk',            'Critical'),
(7,  19, 'CBS Teller + Finance GL posting: dual control bypass risk',                 'High'),
(8,  11, 'CBS Admin + Trading Admin: excessive privileged access concentration',      'High'),
(2,  8,  'AD Admin + CBS Admin: could grant self elevated banking access',            'Critical');

-- Access Requests (sample workflow history)
INSERT INTO AccessRequests (EmployeeID, RoleID, RequestType, RequestedBy, ApprovedBy, Status, BusinessJustification, RequestedAt, ResolvedAt) VALUES
(7,  10, 'Grant',  't.zielinski',  'e.lewandowska', 'Approved',  'Trader requires execution rights for EUR/USD desk',         '2020-11-22', '2020-11-23'),
(9,  2,  'Grant',  'm.kowalski',   'm.kowalski',    'Approved',  'Contractor needs AD admin for migration project',           '2024-01-10', '2024-01-10'),  -- self-approved: finding!
(12, 19, 'Grant',  'd.mover',      'a.nowak',       'Approved',  'Temporary access needed for year-end finance reconciliation','2025-01-05', '2025-01-06'),
(5,  8,  'Grant',  'j.kaminski',   NULL,            'Pending',   'Need CBS Admin to fix customer data issue',                 '2026-05-01', NULL),
(11, 7,  'Revoke', 'iam.system',   NULL,            'Pending',   'Automated: employee terminated, access pending revocation', '2026-05-08', NULL);  -- overdue!

-- Audit Log (sample events)
INSERT INTO AuditLog (EventType, EmployeeID, ApplicationID, TargetResource, Outcome, IPAddress, Details) VALUES
('Login',           5,  3, 'Core Banking System', 'Success', '10.10.1.45',  'Standard business hours login'),
('Login',           11, 3, 'Core Banking System', 'Success', '185.23.44.12', 'Login from external IP - terminated employee!'),
('PermissionDenied',10, 3, 'CBS Admin Panel',     'Failure', '10.10.2.11',  'Intern attempted to access admin panel'),
('RoleAssigned',    9,  1, 'AD_Admin role',        'Success', '10.10.1.1',   'AD Admin granted to contractor by m.kowalski'),
('Login',           7,  4, 'Trading Platform',     'Success', '10.10.3.22',  'Pre-market session login'),
('Login',           7,  4, 'Trading Platform',     'Success', '10.10.3.22',  'Trade executed: EUR/USD 2M'),
('Login',           9,  3, 'Core Banking System', 'Success', '10.10.1.88',  'Contractor accessing CBS outside project scope'),
('PermissionDenied',3,  3, 'CBS Admin Panel',     'Failure', '10.10.2.15',  'IAM Analyst attempted CBS admin access'),
('RoleRevoked',     NULL,1, 'Scheduled review',   'Warning', NULL,           'Quarterly access review initiated'),
('Login',           6,  8, 'SAP Finance',          'Success', '10.10.4.01',  'Month-end journal entry posting');
