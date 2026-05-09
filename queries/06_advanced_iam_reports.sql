-- ============================================================
-- Module 6: Advanced IAM Reports
-- Real-world IAM analyst queries: access certification, risk scoring,
-- privilege creep detection, self-approval detection
-- ============================================================

-- 1. ACCESS CERTIFICATION REPORT
--    Full snapshot of who has what — for quarterly review
SELECT
    e.Username,
    e.FirstName + ' ' + e.LastName      AS FullName,
    e.EmploymentType,
    e.Status                             AS EmployeeStatus,
    d.DepartmentName,
    a.AppName,
    a.RiskLevel,
    r.RoleName,
    r.IsPrivileged,
    ur.AssignedAt,
    ur.AssignedBy,
    ur.ExpiresAt,
    CASE
        WHEN e.Status = 'Terminated'     THEN 'REVOKE - Terminated employee'
        WHEN ur.ExpiresAt < GETDATE()    THEN 'REVOKE - Expired access'
        WHEN e.EmploymentType = 'Contractor' AND r.IsPrivileged = 1
                                         THEN 'REVIEW - Contractor with privileged access'
        WHEN e.EmploymentType = 'Intern' AND a.RiskLevel IN ('High','Critical')
                                         THEN 'REVIEW - Intern on high-risk system'
        ELSE 'CERTIFY'
    END AS CertificationDecision
FROM Employees e
JOIN Departments d   ON e.DepartmentID = d.DepartmentID
JOIN UserRoles ur    ON e.EmployeeID = ur.EmployeeID AND ur.IsActive = 1
JOIN Roles r         ON ur.RoleID = r.RoleID
JOIN Applications a  ON r.ApplicationID = a.ApplicationID
ORDER BY CertificationDecision, a.RiskLevel DESC, e.Username;

-- 2. PRIVILEGE CREEP DETECTION
--    Users whose access has grown over time without a recent review
WITH UserAccessScore AS (
    SELECT e.EmployeeID, e.Username,
           e.EmploymentType,
           COUNT(ur.RoleID)                      AS TotalRoles,
           SUM(r.IsPrivileged)                   AS PrivilegedRoles,
           SUM(CASE WHEN a.RiskLevel = 'Critical' THEN 3
                    WHEN a.RiskLevel = 'High'     THEN 2
                    WHEN a.RiskLevel = 'Medium'   THEN 1
                    ELSE 0 END)                   AS RiskScore,
           MAX(ur.AssignedAt)                    AS LastAccessGranted
    FROM Employees e
    JOIN UserRoles ur    ON e.EmployeeID = ur.EmployeeID AND ur.IsActive = 1
    JOIN Roles r         ON ur.RoleID = r.RoleID
    JOIN Applications a  ON r.ApplicationID = a.ApplicationID
    WHERE e.Status = 'Active'
    GROUP BY e.EmployeeID, e.Username, e.EmploymentType
)
SELECT Username, EmploymentType, TotalRoles, PrivilegedRoles, RiskScore,
       LastAccessGranted,
       CASE
           WHEN RiskScore >= 10 THEN 'CRITICAL - Immediate review'
           WHEN RiskScore >= 6  THEN 'HIGH - Review within 7 days'
           WHEN RiskScore >= 3  THEN 'MEDIUM - Review within 30 days'
           ELSE                      'LOW - Standard review cycle'
       END AS ReviewPriority
FROM UserAccessScore
ORDER BY RiskScore DESC;

-- 3. SELF-APPROVAL DETECTION
--    Access requests where RequestedBy = ApprovedBy (control violation)
SELECT ar.RequestID,
       e.Username,
       e.FirstName + ' ' + e.LastName AS FullName,
       r.RoleName,
       a.AppName,
       a.RiskLevel,
       ar.RequestedBy,
       ar.ApprovedBy,
       ar.RequestedAt,
       ar.BusinessJustification,
       'FINDING: Self-approved access request' AS Finding
FROM AccessRequests ar
JOIN Employees e ON ar.EmployeeID = e.EmployeeID
JOIN Roles r     ON ar.RoleID = r.RoleID
JOIN Applications a ON r.ApplicationID = a.ApplicationID
WHERE ar.ApprovedBy IS NOT NULL
  AND ar.RequestedBy = ar.ApprovedBy
ORDER BY a.RiskLevel DESC;

-- 4. SEGREGATION OF DUTIES VIOLATION REPORT
WITH SoDViolations AS (
    SELECT
        e.EmployeeID,
        e.Username,
        e.FirstName + ' ' + e.LastName AS FullName,
        d.DepartmentName,
        ra.RoleName  AS ConflictingRole_A,
        rb.RoleName  AS ConflictingRole_B,
        sod.ConflictReason,
        sod.Severity,
        ur1.AssignedAt AS Role_A_Granted,
        ur2.AssignedAt AS Role_B_Granted
    FROM SoDConflicts sod
    JOIN UserRoles ur1 ON sod.RoleID_A = ur1.RoleID AND ur1.IsActive = 1
    JOIN UserRoles ur2 ON sod.RoleID_B = ur2.RoleID AND ur2.IsActive = 1
                      AND ur1.EmployeeID = ur2.EmployeeID
    JOIN Employees e   ON ur1.EmployeeID = e.EmployeeID
    JOIN Departments d ON e.DepartmentID = d.DepartmentID
    JOIN Roles ra      ON sod.RoleID_A = ra.RoleID
    JOIN Roles rb      ON sod.RoleID_B = rb.RoleID
)
SELECT *, 'ACTION REQUIRED: SoD violation must be remediated' AS Action
FROM SoDViolations
ORDER BY Severity DESC, Username;

-- 5. EXTERNAL IP LOGIN DETECTION
--    Logins from non-corporate IP ranges (simple check: not starting with 10.)
SELECT e.Username,
       e.FirstName + ' ' + e.LastName AS FullName,
       e.Status AS EmployeeStatus,
       a.AppName,
       al.EventType,
       al.Outcome,
       al.IPAddress,
       al.EventTimestamp,
       al.Details,
       CASE
           WHEN e.Status = 'Terminated' THEN 'CRITICAL - Terminated employee login'
           ELSE 'HIGH - External IP access'
       END AS AlertLevel
FROM AuditLog al
JOIN Employees e    ON al.EmployeeID = e.EmployeeID
JOIN Applications a ON al.ApplicationID = a.ApplicationID
WHERE al.IPAddress NOT LIKE '10.%'
  AND al.EventType = 'Login'
  AND al.Outcome = 'Success'
ORDER BY AlertLevel, al.EventTimestamp DESC;

-- 6. JOINER/MOVER/LEAVER ACCESS LIFECYCLE SUMMARY
--    Overview of access provisioning hygiene
SELECT
    'Joiners (last 90 days)'            AS Category,
    COUNT(DISTINCT e.EmployeeID)        AS EmployeeCount,
    AVG(CAST(DATEDIFF(DAY, e.StartDate, ur.AssignedAt) AS FLOAT)) AS AvgDaysToProvision
FROM Employees e
JOIN UserRoles ur ON e.EmployeeID = ur.EmployeeID
WHERE e.StartDate >= DATEADD(DAY, -90, GETDATE())

UNION ALL

SELECT
    'Leavers with active access'        AS Category,
    COUNT(DISTINCT e.EmployeeID)        AS EmployeeCount,
    AVG(CAST(DATEDIFF(DAY, e.EndDate, GETDATE()) AS FLOAT)) AS AvgDaysToDeprovision
FROM Employees e
JOIN UserRoles ur ON e.EmployeeID = ur.EmployeeID AND ur.IsActive = 1
WHERE e.Status = 'Terminated'

UNION ALL

SELECT
    'Pending access requests > 5 days' AS Category,
    COUNT(*)                            AS EmployeeCount,
    AVG(CAST(DATEDIFF(DAY, RequestedAt, GETDATE()) AS FLOAT)) AS AvgDaysPending
FROM AccessRequests
WHERE Status = 'Pending'
  AND DATEDIFF(DAY, RequestedAt, GETDATE()) > 5;
