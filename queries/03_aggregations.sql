-- ============================================================
-- Module 3: Aggregations
-- Topics: COUNT, SUM, AVG, GROUP BY, HAVING, DISTINCT
-- ============================================================
USE IAMPractice;
GO

-- 1. Count employees per department
SELECT d.DepartmentName,
       COUNT(e.EmployeeID) AS TotalEmployees,
       SUM(CASE WHEN e.Status = 'Active' THEN 1 ELSE 0 END)     AS ActiveCount,
       SUM(CASE WHEN e.Status = 'Terminated' THEN 1 ELSE 0 END) AS TerminatedCount
FROM Departments d
LEFT JOIN Employees e ON d.DepartmentID = e.DepartmentID
GROUP BY d.DepartmentName
ORDER BY TotalEmployees DESC;

-- 2. Count active role assignments per employee (who has the most access?)
SELECT e.Username,
       e.FirstName + ' ' + e.LastName AS FullName,
       e.EmploymentType,
       COUNT(ur.RoleID) AS TotalRoles
FROM Employees e
LEFT JOIN UserRoles ur ON e.EmployeeID = ur.EmployeeID AND ur.IsActive = 1
GROUP BY e.EmployeeID, e.Username, e.FirstName, e.LastName, e.EmploymentType
ORDER BY TotalRoles DESC;

-- 3. Applications by number of privileged role assignments
SELECT a.AppName, a.RiskLevel,
       COUNT(DISTINCT r.RoleID)   AS TotalRoles,
       SUM(CAST(r.IsPrivileged AS INT)) AS PrivilegedRoles,
       COUNT(DISTINCT ur.EmployeeID) AS UsersWithAccess
FROM Applications a
JOIN Roles r    ON a.ApplicationID = r.ApplicationID
LEFT JOIN UserRoles ur ON r.RoleID = ur.RoleID AND ur.IsActive = 1
GROUP BY a.ApplicationID, a.AppName, a.RiskLevel
ORDER BY PrivilegedRoles DESC, a.RiskLevel DESC;

-- 4. Departments with more than 1 privileged role assigned to their employees
SELECT d.DepartmentName,
       COUNT(DISTINCT ur.EmployeeID) AS EmployeesWithPrivAccess,
       COUNT(ur.UserRoleID)          AS TotalPrivilegedAssignments
FROM Departments d
JOIN Employees e  ON d.DepartmentID = e.DepartmentID
JOIN UserRoles ur ON e.EmployeeID = ur.EmployeeID AND ur.IsActive = 1
JOIN Roles r      ON ur.RoleID = r.RoleID
WHERE r.IsPrivileged = 1
GROUP BY d.DepartmentName
HAVING COUNT(DISTINCT ur.EmployeeID) > 1
ORDER BY TotalPrivilegedAssignments DESC;

-- 5. Audit log summary: event counts by type and outcome
SELECT EventType,
       Outcome,
       COUNT(*) AS EventCount,
       MIN(EventTimestamp) AS FirstSeen,
       MAX(EventTimestamp) AS LastSeen
FROM AuditLog
GROUP BY EventType, Outcome
ORDER BY EventCount DESC;

-- 6. Access request resolution time (avg days to resolve, by request type)
SELECT RequestType,
       Status,
       COUNT(*)                                               AS TotalRequests,
       AVG(DATEDIFF(DAY, RequestedAt, ResolvedAt))           AS AvgDaysToResolve,
       MAX(DATEDIFF(DAY, RequestedAt, ResolvedAt))           AS MaxDaysToResolve
FROM AccessRequests
WHERE ResolvedAt IS NOT NULL
GROUP BY RequestType, Status
ORDER BY AvgDaysToResolve DESC;

-- 7. Permissions granted per role (how powerful is each role?)
SELECT r.RoleName, a.AppName, a.RiskLevel,
       COUNT(rp.PermissionID)                                 AS PermissionCount,
       STRING_AGG(p.PermissionType, ', ')                     AS PermissionTypes
FROM Roles r
JOIN Applications a      ON r.ApplicationID = a.ApplicationID
JOIN RolePermissions rp  ON r.RoleID = rp.RoleID
JOIN Permissions p       ON rp.PermissionID = p.PermissionID
GROUP BY r.RoleID, r.RoleName, a.AppName, a.RiskLevel
ORDER BY PermissionCount DESC;
