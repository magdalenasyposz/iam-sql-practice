-- ============================================================
-- Module 5: Window Functions
-- Topics: ROW_NUMBER, RANK, DENSE_RANK, LAG, LEAD, PARTITION BY,
--         running totals, moving averages
-- ============================================================

-- 1. ROW_NUMBER: Rank employees by number of roles, per department
SELECT e.Username,
       e.FirstName + ' ' + e.LastName AS FullName,
       d.DepartmentName,
       COUNT(ur.RoleID) AS TotalRoles,
       ROW_NUMBER() OVER (
           PARTITION BY d.DepartmentID
           ORDER BY COUNT(ur.RoleID) DESC
       ) AS RankInDepartment
FROM Employees e
JOIN Departments d ON e.DepartmentID = d.DepartmentID
LEFT JOIN UserRoles ur ON e.EmployeeID = ur.EmployeeID AND ur.IsActive = 1
GROUP BY e.EmployeeID, e.Username, e.FirstName, e.LastName,
         d.DepartmentID, d.DepartmentName
ORDER BY d.DepartmentName, RankInDepartment;

-- 2. RANK vs DENSE_RANK: Role assignment ranking across all employees
SELECT e.Username,
       COUNT(ur.RoleID) AS TotalRoles,
       RANK() OVER (ORDER BY COUNT(ur.RoleID) DESC)        AS RankWithGaps,
       DENSE_RANK() OVER (ORDER BY COUNT(ur.RoleID) DESC)  AS DenseRank
FROM Employees e
LEFT JOIN UserRoles ur ON e.EmployeeID = ur.EmployeeID AND ur.IsActive = 1
GROUP BY e.EmployeeID, e.Username
ORDER BY TotalRoles DESC;

-- 3. LAG/LEAD: Audit log — time between consecutive events per employee
SELECT e.Username,
       al.EventType,
       al.ApplicationID,
       al.Outcome,
       al.EventTimestamp,
       LAG(al.EventTimestamp)  OVER (PARTITION BY al.EmployeeID ORDER BY al.EventTimestamp) AS PreviousEvent,
       LEAD(al.EventTimestamp) OVER (PARTITION BY al.EmployeeID ORDER BY al.EventTimestamp) AS NextEvent,
       DATEDIFF(MINUTE,
           LAG(al.EventTimestamp) OVER (PARTITION BY al.EmployeeID ORDER BY al.EventTimestamp),
           al.EventTimestamp
       ) AS MinutesSincePreviousEvent
FROM AuditLog al
LEFT JOIN Employees e ON al.EmployeeID = e.EmployeeID
ORDER BY al.EmployeeID, al.EventTimestamp;

-- 4. Running total of access requests over time (cumulative)
SELECT RequestedAt,
       RequestType,
       Status,
       COUNT(*) OVER (
           ORDER BY RequestedAt
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS CumulativeRequests,
       COUNT(*) OVER (
           PARTITION BY Status
           ORDER BY RequestedAt
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS CumulativeByStatus
FROM AccessRequests
ORDER BY RequestedAt;

-- 5. NTILE: Bucket employees into quartiles by access breadth (for risk tiering)
WITH RoleCount AS (
    SELECT e.EmployeeID, e.Username,
           e.FirstName + ' ' + e.LastName AS FullName,
           e.EmploymentType,
           COUNT(ur.RoleID) AS TotalRoles
    FROM Employees e
    LEFT JOIN UserRoles ur ON e.EmployeeID = ur.EmployeeID AND ur.IsActive = 1
    GROUP BY e.EmployeeID, e.Username, e.FirstName, e.LastName, e.EmploymentType
)
SELECT Username, FullName, EmploymentType, TotalRoles,
       NTILE(4) OVER (ORDER BY TotalRoles DESC) AS AccessRiskQuartile,
       CASE NTILE(4) OVER (ORDER BY TotalRoles DESC)
           WHEN 1 THEN 'High Risk - Broad Access'
           WHEN 2 THEN 'Medium-High Risk'
           WHEN 3 THEN 'Medium-Low Risk'
           WHEN 4 THEN 'Low Risk - Minimal Access'
       END AS RiskTier
FROM RoleCount
ORDER BY TotalRoles DESC;

-- 6. FIRST_VALUE / LAST_VALUE: For each app, show the first and latest user to get access
SELECT DISTINCT
       a.AppName,
       FIRST_VALUE(e.Username) OVER (
           PARTITION BY r.ApplicationID
           ORDER BY ur.AssignedAt
       ) AS FirstUserGranted,
       FIRST_VALUE(ur.AssignedAt) OVER (
           PARTITION BY r.ApplicationID
           ORDER BY ur.AssignedAt
       ) AS FirstGrantDate,
       LAST_VALUE(e.Username) OVER (
           PARTITION BY r.ApplicationID
           ORDER BY ur.AssignedAt
           ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
       ) AS LastUserGranted
FROM UserRoles ur
JOIN Roles r        ON ur.RoleID = r.RoleID
JOIN Applications a ON r.ApplicationID = a.ApplicationID
JOIN Employees e    ON ur.EmployeeID = e.EmployeeID
ORDER BY a.AppName;
