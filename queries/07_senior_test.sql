-- ============================================================
-- Module 7: Senior SQL Test
-- Instructions:
--   - Write your answers directly below each question
--   - Do not look at previous modules while answering
--   - Time yourself — aim for 60 minutes total
--   - Run each query to verify it works before submitting
-- ============================================================
USE IAMPractice;
GO

-- ============================================================
-- SECTION A: BASIC (Questions 1-4)
-- ============================================================

-- A1.
-- List all active permanent employees hired before 2021,
-- showing their username, full name, job title and department name.
-- Order by department name, then by hire date oldest first.

-- YOUR ANSWER:
SELECT e.Username,
       e.FirstName + ' ' + e.LastName AS FullName,
       e.JobTitle,
       d.DepartmentName,
       e.StartDate
FROM Employees e
JOIN Departments d ON e.DepartmentID = d.DepartmentID
WHERE e.Status = 'Active'
  AND e.EmploymentType = 'Permanent'
  AND e.StartDate < '2021-01-01'
ORDER BY d.DepartmentName, e.StartDate ASC;

-- A2.
-- Find all applications that are either Critical risk OR are privileged (IsPrivileged = 1).
-- Show app name, type, risk level and owner.
-- Order by risk level descending.

-- YOUR ANSWER:
SELECT AppName, AppType, RiskLevel, Owner
FROM Applications
WHERE RiskLevel = 'Critical'
   OR IsPrivileged = 1
ORDER BY RiskLevel DESC;

-- A3.
-- How many employees are in each employment type (Permanent, Contractor, Intern)?
-- Show the count and what percentage of the total workforce each type represents.
-- Round the percentage to 1 decimal place.

-- YOUR ANSWER:
Select EmploymentType,
       COUNT(*) AS EmployeeCount,
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Employees), 1) AS PercentageOfWorkforce
FROM Employees
GROUP BY EmploymentType;    

-- A4.
-- Find all access requests that were approved,
-- showing the employee username, role name, who approved it,
-- and how many days it took to approve (RequestedAt to ResolvedAt).
-- Order by days taken descending.

-- YOUR ANSWER:
SELECT e.Username, r.RoleName, ar.Status, ar.ApprovedBy, DATEDIFF(day, ar.RequestedAt, ar.resolvedat) as DaysWait
FROM AccessRequests ar
JOIN employees e ON ar.EmployeeID = e.EmployeeID
JOIN roles r on ar.RoleID = r.RoleID
WHERE ar.Status = 'Approved'
ORDER BY DATEDIFF(day, ar.RequestedAt, ar.resolvedat) DESC;

-- ============================================================
-- SECTION B: JOINS (Questions 5-7)
-- ============================================================

-- B5.
-- Show the full access map for the IAM department only:
-- employee full name, application name, role name, and whether the role is privileged.
-- Include only active role assignments.

-- YOUR ANSWER:
SELECT e.FirstName + ' ' + e.LastName AS FullName,
app.AppName, 
r.RoleName,
r.IsPrivileged 
FROM Employees e
JOIN Departments d ON e.DepartmentID = d.DepartmentID
JOIN UserRoles ur ON e.EmployeeID = ur.EmployeeID
JOIN Roles r ON ur.RoleID = r.RoleID 
JOIN Applications app ON r.ApplicationID = app.ApplicationID
WHERE d.DepartmentName = 'Identity & Access Management'
AND ur.IsActive = 1;

-- B6.
-- Find all employees who have access to MORE THAN ONE application.
-- Show their username, department, and the count of distinct applications they have access to.
-- Order by application count descending.

-- YOUR ANSWER:

SELECT e.Username, d.DepartmentName, COUNT(DISTINCT app.ApplicationID) AS AppAmount 
FROM Employees e
JOIN Departments d ON e.DepartmentID = d.DepartmentID 
JOIN UserRoles ur ON e.EmployeeID = ur.EmployeeID AND ur.IsActive = 1
JOIN Roles r on ur.RoleID = r.RoleID
JOIN Applications app on r.ApplicationID = app.ApplicationID
GROUP BY e.EmployeeID, e.Username, d.DepartmentName
HAVING COUNT(DISTINCT app.ApplicationID) > 1 
ORDER BY AppAmount DESC;




-- B7.
-- List every SoD conflict rule, showing:
-- the two conflicting role names, the applications they belong to,
-- the conflict reason, and severity.
-- Order by severity (Critical first).

-- YOUR ANSWER:

SELECT ra.RoleName AS Role_A, rb.RoleName as Role_B,
app.AppName as AppA, appb.AppName as Appb, sod.ConflictReason, sod.Severity
FROM SoDConflicts sod 
JOIN roles ra ON sod.RoleID_A = ra.RoleID
JOIN roles rb ON sod.RoleID_B = rb.RoleID
JOIN Applications app on ra.ApplicationID = app.ApplicationID 
JOIN Applications appb on rb.ApplicationID = appb.ApplicationID
ORDER BY CASE Severity
    WHEN 'Critical' THEN 1 
    WHEN 'High' then 2 
    when 'medium' then 3 
    when 'low' then 4 
end;



-- ============================================================
-- SECTION C: SUBQUERIES & CTEs (Questions 8-10)
-- ============================================================

-- C8.
-- Using a subquery, find all employees who have been assigned
-- at least one privileged role on a Critical risk application.
-- Show username, full name, and employment type.

-- YOUR ANSWER:
SELECT e.Username, e.FirstName + ' ' + e.LastName AS FullName, e.EmploymentType
FROM Employees e 
WHERE e.EmployeeID IN (
    select ur.EmployeeID
    FROM UserRoles ur
    JOIN Roles r on ur.RoleID = r.RoleID
    JOIN Applications app ON r.ApplicationID = app.ApplicationID
    where r.IsPrivileged = 1
    AND app.RiskLevel = 'Critical'
    AND ur.IsActive = 1
);

-- YOUR ANSWER v2 - its shorter:
SELECT e.Username, e.FirstName + ' ' + e.LastName AS FullName, e.EmploymentType
FROM Employees e 
JOIN UserRoles ur ON e.EmployeeID = ur.EmployeeID AND ur.IsActive = 1
JOIN Roles r ON ur.RoleID = r.RoleID
JOIN Applications app ON r.ApplicationID = app.ApplicationID
WHERE r.IsPrivileged = 1 AND app.RiskLevel = 'Critical';

-- C9.
-- Write a CTE that calculates a risk score for each application:
--   +3 points for each privileged role
--   +1 point for each non-privileged role
--   +2 points for each user with active access
-- Show application name, risk level, and total score.
-- Order by score descending.

-- YOUR ANSWER:
WITH AppRiskScore AS (
    SELECT app.ApplicationID, app.AppName, app.RiskLevel, 
    SUM(CASE WHEN r.IsPrivileged = 1 THEN 3 ELSE 1 END) AS RoleScore,
    COUNT(DISTINCT CASE WHEN ur.IsActive = 1 THEN 1 END) * 2 AS UserScore
    FROM Applications app
    JOIN roles r on app.ApplicationID = r.ApplicationID
    LEFT JOIN UserRoles ur ON r.RoleID = ur.RoleID
    GROUP BY app.ApplicationID, app.AppName, app.RiskLevel
)
SELECT AppName, RiskLevel, RoleScore + UserScore AS TotalScore
FROM AppRiskScore
ORDER BY TotalScore Desc; 

-- C10.
-- Using CTEs, produce an "orphaned access" report:
-- terminated employees who still have active role assignments,
-- showing how many days have passed since their termination,
-- what roles they still hold, and flag any privileged access as URGENT.

-- YOUR ANSWER:
WITH OrpAcc AS (
    select e.username, r.RoleName, e.status, ur.IsActive, e.StartDate, e.EndDate, r.IsPrivileged
    FROM Employees e
    JOIN UserRoles ur ON e.EmployeeID = ur.EmployeeID
    JOIN Roles r ON ur.RoleID = r.RoleID
    WHERE e.Status = 'Terminated' AND ur.IsActive = 1
)
SELECT Username, RoleName, status, IsActive, DATEDIFF(day, EndDate, GETDATE()) AS SinceTermination, 
CASE WHEN IsPrivileged = 1 THEN 'Urgent' ELSE 'Review' END AS Flag
FROM OrpAcc;

-- ============================================================
-- SECTION D: WINDOW FUNCTIONS (Questions 11-13)
-- ============================================================

-- D11.
-- For each department, rank employees by their number of active role assignments.
-- Show department name, username, role count, and their rank within the department.
-- Employees with the same role count should share a rank.

-- YOUR ANSWER:
WITH RoleCounts AS (
    SELECT e.EmployeeID, e.Username, d.DepartmentName, COUNT(ur.RoleID) AS ActiveRoleCount
    FROM Employees e
    JOIN Departments d ON e.DepartmentID = d.DepartmentID
    LEFT JOIN UserRoles ur ON e.EmployeeID = ur.EmployeeID AND ur.IsActive = 1 
    GROUP BY e.EmployeeID, e.Username, d.DepartmentName

)
SELECT DepartmentName, Username, ActiveRoleCount, DENSE_RANK() OVER (PARTITION BY DepartmentName ORDER BY ActiveRoleCount DESC) AS RankInDept
FROM "RoleCounts"
ORDER BY DepartmentName, RankInDept;



-- D12.
-- Show each access request alongside the PREVIOUS request made by the same employee
-- (previous request date and its status).
-- Include employees who only have one request (previous values will be NULL).

-- YOUR ANSWER:

SELECT e.username, 
LAG(ar.RequestedAt) OVER(PARTITION BY e.EmployeeID ORDER BY ar.requestedAt) AS PreviousReq, 
LAG(ar.status) OVER (PARTITION BY e.EmployeeID ORDER BY ar.requestedAt),
ar.RequestedAt, ar.Status
FROM Employees e 
JOIN AccessRequests ar ON ar.EmployeeID = e.EmployeeID 
ORDER BY e.Username, ar.RequestedAt

-- D13.
-- Divide all active employees into 3 risk tiers based on their total number of active roles:
-- Tier 1 = highest access, Tier 3 = lowest access.
-- Show username, employment type, role count, and tier.

-- YOUR ANSWER:
WITH ActRolesCount AS (
    SELECT e.Username, COUNT(ur.UserRoleID) AS RolesCount
    FROM Employees e 
    JOIN UserRoles ur ON ur.EmployeeID = e.EmployeeID
    WHERE ur.IsActive = 1
    GROUP BY e.username
)
SELECT Username, RolesCount
FROM ActRolesCount

-- ============================================================
-- SECTION E: ADVANCED IAM (Questions 14-15)
-- ============================================================

-- E14.
-- Write a single query that produces a complete access certification report
-- for ALL contractor and intern employees only, showing:
-- username, full name, app name, role name, risk level, assigned date,
-- and a certification decision:
--   'REVOKE'  if the employee is terminated
--   'URGENT REVIEW' if the role is privileged on a Critical app
--   'REVIEW'  if the role is privileged OR the app is High risk
--   'CERTIFY' otherwise

-- YOUR ANSWER:



-- E15.
-- Identify all Segregation of Duties violations currently active in the system.
-- For each violation show:
-- the employee, their department, both conflicting roles,
-- the severity, and how long ago (in days) the SECOND (most recent) conflicting
-- role was assigned — this tells you how long the violation has been active.
-- Order by severity, then by days active descending.

-- YOUR ANSWER:
