-- ============================================================
-- Module 4: Subqueries & CTEs
-- Topics: subqueries (WHERE/FROM/SELECT), WITH (CTE), EXISTS, NOT EXISTS
-- ============================================================

-- 1. Subquery in WHERE: employees who have access to Critical applications
SELECT Username, FirstName, LastName, JobTitle
FROM Employees
WHERE EmployeeID IN (
    SELECT DISTINCT ur.EmployeeID
    FROM UserRoles ur
    JOIN Roles r        ON ur.RoleID = r.RoleID
    JOIN Applications a ON r.ApplicationID = a.ApplicationID
    WHERE a.RiskLevel = 'Critical'
      AND ur.IsActive = 1
)
ORDER BY LastName;

-- 2. NOT EXISTS: employees who have NEVER had an access request
SELECT e.Username, e.FirstName, e.LastName, e.EmploymentType
FROM Employees e
WHERE NOT EXISTS (
    SELECT 1 FROM AccessRequests ar
    WHERE ar.EmployeeID = e.EmployeeID
)
ORDER BY e.Username;

-- 3. Subquery in FROM: average roles per employee, then find above-average users
SELECT Username, FirstName, LastName, TotalRoles
FROM (
    SELECT e.EmployeeID, e.Username, e.FirstName, e.LastName,
           COUNT(ur.RoleID) AS TotalRoles
    FROM Employees e
    JOIN UserRoles ur ON e.EmployeeID = ur.EmployeeID AND ur.IsActive = 1
    GROUP BY e.EmployeeID, e.Username, e.FirstName, e.LastName
) AS RoleCounts
WHERE TotalRoles > (
    SELECT AVG(CAST(RoleCount AS FLOAT))
    FROM (
        SELECT COUNT(RoleID) AS RoleCount
        FROM UserRoles
        WHERE IsActive = 1
        GROUP BY EmployeeID
    ) AS Avg_sub
)
ORDER BY TotalRoles DESC;

-- 4. CTE: Identify SoD violations — users who hold two conflicting roles simultaneously
WITH ConflictingAssignments AS (
    SELECT ur1.EmployeeID,
           sod.RoleID_A,
           sod.RoleID_B,
           sod.ConflictReason,
           sod.Severity
    FROM SoDConflicts sod
    JOIN UserRoles ur1 ON sod.RoleID_A = ur1.RoleID AND ur1.IsActive = 1
    JOIN UserRoles ur2 ON sod.RoleID_B = ur2.RoleID AND ur2.IsActive = 1
                      AND ur1.EmployeeID = ur2.EmployeeID
)
SELECT e.Username,
       e.FirstName + ' ' + e.LastName AS FullName,
       d.DepartmentName,
       ra.RoleName AS Role_A,
       rb.RoleName AS Role_B,
       ca.ConflictReason,
       ca.Severity
FROM ConflictingAssignments ca
JOIN Employees e  ON ca.EmployeeID = e.EmployeeID
JOIN Departments d ON e.DepartmentID = d.DepartmentID
JOIN Roles ra     ON ca.RoleID_A = ra.RoleID
JOIN Roles rb     ON ca.RoleID_B = rb.RoleID
ORDER BY ca.Severity DESC;

-- 5. CTE: Orphaned access report — terminated employees with active access
WITH OrphanedAccess AS (
    SELECT e.EmployeeID, e.Username,
           e.FirstName + ' ' + e.LastName AS FullName,
           e.EndDate,
           DATEDIFF(DAY, e.EndDate, GETDATE()) AS DaysSinceTermination,
           r.RoleName,
           a.AppName,
           a.RiskLevel,
           r.IsPrivileged
    FROM Employees e
    JOIN UserRoles ur    ON e.EmployeeID = ur.EmployeeID AND ur.IsActive = 1
    JOIN Roles r         ON ur.RoleID = r.RoleID
    JOIN Applications a  ON r.ApplicationID = a.ApplicationID
    WHERE e.Status = 'Terminated'
)
SELECT *,
       CASE
           WHEN IsPrivileged = 1 THEN 'URGENT - Privileged orphaned access'
           WHEN RiskLevel = 'Critical' THEN 'HIGH - Critical app access'
           ELSE 'MEDIUM - Standard access'
       END AS Priority
FROM OrphanedAccess
ORDER BY IsPrivileged DESC, RiskLevel DESC;

-- 6. Chained CTEs: contractor over-provisioning report
WITH ContractorRoles AS (
    SELECT e.EmployeeID, e.Username, r.RoleName, r.IsPrivileged,
           a.AppName, a.RiskLevel
    FROM Employees e
    JOIN UserRoles ur   ON e.EmployeeID = ur.EmployeeID AND ur.IsActive = 1
    JOIN Roles r        ON ur.RoleID = r.RoleID
    JOIN Applications a ON r.ApplicationID = a.ApplicationID
    WHERE e.EmploymentType IN ('Contractor', 'Intern')
),
PrivilegedContractors AS (
    SELECT EmployeeID, Username,
           COUNT(*) AS PrivilegedRoleCount,
           STRING_AGG(RoleName + ' (' + AppName + ')', '; ') AS PrivilegedRoles
    FROM ContractorRoles
    WHERE IsPrivileged = 1
    GROUP BY EmployeeID, Username
)
SELECT pc.Username,
       pc.PrivilegedRoleCount,
       pc.PrivilegedRoles,
       'Contractor/Intern with privileged access - review required' AS Finding
FROM PrivilegedContractors pc
ORDER BY pc.PrivilegedRoleCount DESC;
