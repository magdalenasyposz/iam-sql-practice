-- ============================================================
-- Module 1: Basic Queries
-- Topics: SELECT, WHERE, ORDER BY, LIKE, IN, BETWEEN, IS NULL
-- ============================================================

-- 1. List all active employees
SELECT EmployeeID, Username, FirstName, LastName, JobTitle, StartDate
FROM Employees
WHERE Status = 'Active'
ORDER BY LastName, FirstName;

-- 2. Find all contractors and interns (non-permanent staff)
SELECT Username, FirstName, LastName, EmploymentType, Status
FROM Employees
WHERE EmploymentType IN ('Contractor', 'Intern');

-- 3. Find employees hired between 2020 and 2022
SELECT Username, FirstName, LastName, StartDate, JobTitle
FROM Employees
WHERE StartDate BETWEEN '2020-01-01' AND '2022-12-31'
ORDER BY StartDate;

-- 4. List all Critical and High risk applications
SELECT AppName, AppType, RiskLevel, IsPrivileged
FROM Applications
WHERE RiskLevel IN ('Critical', 'High')
ORDER BY RiskLevel, AppName;

-- 5. Find all privileged roles (IsPrivileged = 1)
SELECT r.RoleName, r.Description, a.AppName, a.RiskLevel
FROM Roles r
JOIN Applications a ON r.ApplicationID = a.ApplicationID
WHERE r.IsPrivileged = 1
ORDER BY a.RiskLevel DESC, r.RoleName;

-- 6. Find terminated employees who still have active role assignments
--    (Classic IAM finding: leaver access not revoked)
SELECT e.Username, e.FirstName, e.LastName, e.Status, e.EndDate,
       r.RoleName, a.AppName
FROM Employees e
JOIN UserRoles ur ON e.EmployeeID = ur.EmployeeID
JOIN Roles r      ON ur.RoleID = r.RoleID
JOIN Applications a ON r.ApplicationID = a.ApplicationID
WHERE e.Status = 'Terminated'
  AND ur.IsActive = 1
ORDER BY e.Username;

-- 7. Find access requests that are still pending for more than 3 days
SELECT ar.RequestID, e.Username, r.RoleName, ar.RequestType,
       ar.RequestedBy, ar.Status,
       DATEDIFF(DAY, ar.RequestedAt, GETDATE()) AS DaysPending,
       ar.BusinessJustification
FROM AccessRequests ar
JOIN Employees e ON ar.EmployeeID = e.EmployeeID
JOIN Roles r     ON ar.RoleID = r.RoleID
WHERE ar.Status = 'Pending'
  AND DATEDIFF(DAY, ar.RequestedAt, GETDATE()) > 3
ORDER BY DaysPending DESC;

-- 8. Search for audit events involving failed/denied access
SELECT al.AuditID, e.Username, a.AppName,
       al.EventType, al.Outcome, al.IPAddress,
       al.EventTimestamp, al.Details
FROM AuditLog al
LEFT JOIN Employees e   ON al.EmployeeID = al.EmployeeID
LEFT JOIN Applications a ON al.ApplicationID = a.ApplicationID
WHERE al.Outcome IN ('Failure', 'Warning')
ORDER BY al.EventTimestamp DESC;
