-- ============================================================
-- IAM Practice Database - Schema
-- Project: ING Hubs IAM SQL Practice
-- ============================================================

CREATE DATABASE IF NOT EXISTS IAMPractice;
USE IAMPractice;

-- Departments / Business Units
CREATE TABLE Departments (
    DepartmentID    INT             PRIMARY KEY IDENTITY(1,1),
    DepartmentName  NVARCHAR(100)   NOT NULL,
    CostCenter      NVARCHAR(20)    NOT NULL,
    ManagerID       INT             NULL,  -- FK set after Employees created
    CreatedAt       DATETIME2       DEFAULT GETDATE()
);

-- Employees (Identities)
CREATE TABLE Employees (
    EmployeeID      INT             PRIMARY KEY IDENTITY(1,1),
    Username        NVARCHAR(50)    NOT NULL UNIQUE,
    FirstName       NVARCHAR(100)   NOT NULL,
    LastName        NVARCHAR(100)   NOT NULL,
    Email           NVARCHAR(150)   NOT NULL UNIQUE,
    DepartmentID    INT             NOT NULL REFERENCES Departments(DepartmentID),
    JobTitle        NVARCHAR(100)   NOT NULL,
    EmploymentType  NVARCHAR(20)    NOT NULL CHECK (EmploymentType IN ('Permanent', 'Contractor', 'Intern')),
    Status          NVARCHAR(20)    NOT NULL DEFAULT 'Active' CHECK (Status IN ('Active', 'Inactive', 'Terminated')),
    StartDate       DATE            NOT NULL,
    EndDate         DATE            NULL,  -- NULL means still employed
    CreatedAt       DATETIME2       DEFAULT GETDATE(),
    UpdatedAt       DATETIME2       DEFAULT GETDATE()
);

-- Add manager FK now that Employees exists
ALTER TABLE Departments
    ADD CONSTRAINT FK_Departments_Manager
    FOREIGN KEY (ManagerID) REFERENCES Employees(EmployeeID);

-- Applications / Systems (e.g. Active Directory, SAP, Core Banking)
CREATE TABLE Applications (
    ApplicationID   INT             PRIMARY KEY IDENTITY(1,1),
    AppName         NVARCHAR(100)   NOT NULL UNIQUE,
    AppType         NVARCHAR(50)    NOT NULL CHECK (AppType IN ('Core Banking', 'ERP', 'CRM', 'Directory', 'Trading', 'HR', 'Security', 'Cloud')),
    Owner           NVARCHAR(100)   NOT NULL,
    RiskLevel       NVARCHAR(10)    NOT NULL CHECK (RiskLevel IN ('Low', 'Medium', 'High', 'Critical')),
    IsPrivileged    BIT             NOT NULL DEFAULT 0,
    CreatedAt       DATETIME2       DEFAULT GETDATE()
);

-- Roles (RBAC — Role-Based Access Control)
CREATE TABLE Roles (
    RoleID          INT             PRIMARY KEY IDENTITY(1,1),
    RoleName        NVARCHAR(100)   NOT NULL UNIQUE,
    Description     NVARCHAR(500)   NULL,
    ApplicationID   INT             NOT NULL REFERENCES Applications(ApplicationID),
    IsPrivileged    BIT             NOT NULL DEFAULT 0,
    CreatedAt       DATETIME2       DEFAULT GETDATE()
);

-- Permissions (granular entitlements within an application)
CREATE TABLE Permissions (
    PermissionID    INT             PRIMARY KEY IDENTITY(1,1),
    PermissionName  NVARCHAR(100)   NOT NULL,
    Description     NVARCHAR(500)   NULL,
    ApplicationID   INT             NOT NULL REFERENCES Applications(ApplicationID),
    PermissionType  NVARCHAR(20)    NOT NULL CHECK (PermissionType IN ('Read', 'Write', 'Execute', 'Admin', 'Delete')),
    UNIQUE (PermissionName, ApplicationID)
);

-- Role <-> Permission mapping (many-to-many)
CREATE TABLE RolePermissions (
    RoleID          INT             NOT NULL REFERENCES Roles(RoleID),
    PermissionID    INT             NOT NULL REFERENCES Permissions(PermissionID),
    GrantedAt       DATETIME2       DEFAULT GETDATE(),
    GrantedBy       NVARCHAR(50)    NOT NULL,
    PRIMARY KEY (RoleID, PermissionID)
);

-- Employee <-> Role assignments (many-to-many)
CREATE TABLE UserRoles (
    UserRoleID      INT             PRIMARY KEY IDENTITY(1,1),
    EmployeeID      INT             NOT NULL REFERENCES Employees(EmployeeID),
    RoleID          INT             NOT NULL REFERENCES Roles(RoleID),
    AssignedAt      DATETIME2       DEFAULT GETDATE(),
    AssignedBy      NVARCHAR(50)    NOT NULL,
    ExpiresAt       DATETIME2       NULL,  -- NULL = no expiry
    IsActive        BIT             NOT NULL DEFAULT 1,
    UNIQUE (EmployeeID, RoleID)
);

-- Access Requests (joiner/mover/leaver workflow)
CREATE TABLE AccessRequests (
    RequestID       INT             PRIMARY KEY IDENTITY(1,1),
    EmployeeID      INT             NOT NULL REFERENCES Employees(EmployeeID),
    RoleID          INT             NOT NULL REFERENCES Roles(RoleID),
    RequestType     NVARCHAR(20)    NOT NULL CHECK (RequestType IN ('Grant', 'Revoke', 'Review')),
    RequestedBy     NVARCHAR(50)    NOT NULL,
    ApprovedBy      NVARCHAR(50)    NULL,
    Status          NVARCHAR(20)    NOT NULL DEFAULT 'Pending' CHECK (Status IN ('Pending', 'Approved', 'Rejected', 'Cancelled')),
    BusinessJustification NVARCHAR(1000) NOT NULL,
    RequestedAt     DATETIME2       DEFAULT GETDATE(),
    ResolvedAt      DATETIME2       NULL
);

-- Audit Log (immutable record of all access events)
CREATE TABLE AuditLog (
    AuditID         BIGINT          PRIMARY KEY IDENTITY(1,1),
    EventType       NVARCHAR(50)    NOT NULL,  -- e.g. Login, RoleAssigned, RoleRevoked, PermissionDenied
    EmployeeID      INT             NULL REFERENCES Employees(EmployeeID),
    ApplicationID   INT             NULL REFERENCES Applications(ApplicationID),
    TargetResource  NVARCHAR(200)   NULL,
    Outcome         NVARCHAR(20)    NOT NULL CHECK (Outcome IN ('Success', 'Failure', 'Warning')),
    IPAddress       NVARCHAR(45)    NULL,
    Details         NVARCHAR(1000)  NULL,
    EventTimestamp  DATETIME2       NOT NULL DEFAULT GETDATE()
);

-- Segregation of Duties rules (SoD — conflicts that should never co-exist)
CREATE TABLE SoDConflicts (
    ConflictID      INT             PRIMARY KEY IDENTITY(1,1),
    RoleID_A        INT             NOT NULL REFERENCES Roles(RoleID),
    RoleID_B        INT             NOT NULL REFERENCES Roles(RoleID),
    ConflictReason  NVARCHAR(500)   NOT NULL,
    Severity        NVARCHAR(10)    NOT NULL CHECK (Severity IN ('Low', 'Medium', 'High', 'Critical')),
    CreatedAt       DATETIME2       DEFAULT GETDATE()
);
