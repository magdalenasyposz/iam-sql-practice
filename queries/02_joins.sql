-- ============================================================
-- Module 2: JOINs
-- Topics: INNER JOIN, LEFT JOIN, RIGHT JOIN, FULL OUTER JOIN, self-join
-- ============================================================
USE IAMPractice;
GO

-- 1. INNER JOIN: Show each employee with their department name
SELECT e.Username, e.FirstName, e.LastName, d.DepartmentName, e.JobTitle
FROM Employees e
INNER JOIN Departments d ON e.DepartmentID = d.DepartmentID
ORDER BY d.DepartmentName, e.LastName;

-- 2. LEFT JOIN: All employees and their roles (including employees with NO roles)
SELECT e.Username, e.FirstName, e.LastName,
       r.RoleName,
       a.AppName
FROM Employees e
LEFT JOIN UserRoles ur ON e.EmployeeID = ur.EmployeeID AND ur.IsActive = 1
LEFT JOIN Roles r      ON ur.RoleID = r.RoleID
LEFT JOIN Applications a ON r.ApplicationID = a.ApplicationID
ORDER BY e.Username, a.AppName;

-- 3. Find employees with NO role assignments at all (potential orphaned accounts)
SELECT e.Username, e.FirstName, e.LastName, e.Status, e.EmploymentType
FROM Employees e
LEFT JOIN UserRoles ur ON e.EmployeeID = ur.EmployeeID AND ur.IsActive = 1
WHERE ur.UserRoleID IS NULL;

-- 4. SELF JOIN: List employees alongside their department manager
SELECT e.FirstName + ' ' + e.LastName AS Employee,
       e.JobTitle,
       d.DepartmentName,
       mgr.FirstName + ' ' + mgr.LastName AS Manager,
       mgr.JobTitle AS ManagerTitle
FROM Employees e
JOIN Departments d  ON e.DepartmentID = d.DepartmentID
LEFT JOIN Employees mgr ON d.ManagerID = mgr.EmployeeID
ORDER BY d.DepartmentName;

-- 5. Multi-table JOIN: Full access map — who has what permission where
SELECT e.Username,
       e.FirstName + ' ' + e.LastName AS FullName,
       d.DepartmentName,
       a.AppName,
       r.RoleName,
       p.PermissionName,
       p.PermissionType
FROM Employees e
JOIN Departments d   ON e.DepartmentID = d.DepartmentID
JOIN UserRoles ur    ON e.EmployeeID = ur.EmployeeID AND ur.IsActive = 1
JOIN Roles r         ON ur.RoleID = r.RoleID
JOIN Applications a  ON r.ApplicationID = a.ApplicationID
JOIN RolePermissions rp ON r.RoleID = rp.RoleID
JOIN Permissions p   ON rp.PermissionID = p.PermissionID
ORDER BY e.Username, a.AppName, p.PermissionType;

-- 6. FULL OUTER JOIN: Match roles to SoD conflicts (show roles with and without conflicts)
SELECT r.RoleName,
       sod.ConflictReason,
       sod.Severity
FROM Roles r
FULL OUTER JOIN SoDConflicts sod
    ON r.RoleID = sod.RoleID_A OR r.RoleID = sod.RoleID_B
ORDER BY sod.Severity DESC, r.RoleName;

-- 7. Three-way self-join: Show SoD conflict pairs with both role names
SELECT ra.RoleName    AS Role_A,
       rb.RoleName    AS Role_B,
       sod.ConflictReason,
       sod.Severity
FROM SoDConflicts sod
JOIN Roles ra ON sod.RoleID_A = ra.RoleID
JOIN Roles rb ON sod.RoleID_B = rb.RoleID
ORDER BY sod.Severity DESC;
