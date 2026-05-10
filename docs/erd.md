# IAMPractice — Entity Relationship Diagram

## Visual Map

```
┌─────────────────┐
│   Departments   │
│─────────────────│
│ DepartmentID PK │◄────────────────────────────┐
│ DepartmentName  │                             │
│ CostCenter      │                             │
│ ManagerID FK────┼──┐                          │
│ CreatedAt       │  │                          │
└─────────────────┘  │                          │
                     │                          │
                     ▼                          │
┌─────────────────┐       ┌──────────────────┐  │
│    Employees    │       │  AccessRequests  │  │
│─────────────────│       │──────────────────│  │
│ EmployeeID   PK │◄──┐   │ RequestID     PK │  │
│ Username        │  │   │ EmployeeID    FK─┼──┘ (via Employees)
│ FirstName       │  │   │ RoleID        FK─┼──┐
│ LastName        │  │   │ RequestType      │  │
│ Email           │  │   │ RequestedBy      │  │
│ DepartmentID FK─┼──┘   │ ApprovedBy       │  │
│ JobTitle        │      │ Status           │  │
│ EmploymentType  │      │ BusinessJustif.. │  │
│ Status          │      │ RequestedAt      │  │
│ StartDate       │      │ ResolvedAt       │  │
│ EndDate         │      └──────────────────┘  │
└────────┬────────┘                            │
         │ EmployeeID                          │
         ▼                                     │
┌─────────────────┐       ┌──────────────────┐ │
│    UserRoles    │       │    AuditLog      │ │
│─────────────────│       │──────────────────│ │
│ UserRoleID   PK │       │ AuditID       PK │ │
│ EmployeeID   FK │       │ EventType        │ │
│ RoleID       FK─┼──┐    │ EmployeeID    FK │ │
│ AssignedAt      │  │    │ ApplicationID FK │ │
│ AssignedBy      │  │    │ TargetResource   │ │
│ ExpiresAt       │  │    │ Outcome          │ │
│ IsActive        │  │    │ IPAddress        │ │
└─────────────────┘  │    │ EventTimestamp   │ │
                     │    └──────────────────┘ │
                     │                         │
                     ▼                         │
┌─────────────────┐       ┌──────────────────┐ │
│      Roles      │       │  SoDConflicts    │ │
│─────────────────│       │──────────────────│ │
│ RoleID       PK │◄──────┼─RoleID_A      FK │ │
│ RoleName        │◄──────┼─RoleID_B      FK │ │
│ Description     │  │    │ ConflictReason   │ │
│ ApplicationID FK┼──┤    │ Severity         │ │
│ IsPrivileged    │  │    └──────────────────┘ │
│ CreatedAt       │  │                         │
└────────┬────────┘  │    ◄─────────────────── ┘
         │ RoleID    │         (RoleID)
         ▼           │
┌─────────────────┐  │
│ RolePermissions │  │
│─────────────────│  │
│ RoleID       FK │◄─┘
│ PermissionID FK─┼──┐
│ GrantedAt       │  │
│ GrantedBy       │  │
└─────────────────┘  │
                     ▼
┌─────────────────┐       ┌──────────────────┐
│   Permissions   │       │  Applications    │
│─────────────────│       │──────────────────│
│ PermissionID PK │       │ ApplicationID PK │◄── Roles.ApplicationID
│ PermissionName  │       │ AppName          │◄── Permissions.ApplicationID
│ Description     │       │ AppType          │◄── AuditLog.ApplicationID
│ ApplicationID FK┼──────►│ Owner            │
│ PermissionType  │       │ RiskLevel        │
└─────────────────┘       │ IsPrivileged     │
                          └──────────────────┘
```

## Foreign Key Summary (cheat sheet)

| Table | Column | Points To |
|---|---|---|
| Departments | ManagerID | Employees.EmployeeID |
| Employees | DepartmentID | Departments.DepartmentID |
| Roles | ApplicationID | Applications.ApplicationID |
| Permissions | ApplicationID | Applications.ApplicationID |
| RolePermissions | RoleID | Roles.RoleID |
| RolePermissions | PermissionID | Permissions.PermissionID |
| UserRoles | EmployeeID | Employees.EmployeeID |
| UserRoles | RoleID | Roles.RoleID |
| AccessRequests | EmployeeID | Employees.EmployeeID |
| AccessRequests | RoleID | Roles.RoleID |
| AuditLog | EmployeeID | Employees.EmployeeID |
| AuditLog | ApplicationID | Applications.ApplicationID |
| SoDConflicts | RoleID_A | Roles.RoleID |
| SoDConflicts | RoleID_B | Roles.RoleID |

## The Main Chain (covers 90% of queries)

```
Employees
    └── UserRoles       (shared: EmployeeID)
            └── Roles   (shared: RoleID)
                    └── Applications  (shared: ApplicationID)
```
