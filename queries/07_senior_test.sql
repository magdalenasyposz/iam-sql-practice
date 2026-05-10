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


-- A2.
-- Find all applications that are either Critical risk OR are privileged (IsPrivileged = 1).
-- Show app name, type, risk level and owner.
-- Order by risk level descending.

-- YOUR ANSWER:


-- A3.
-- How many employees are in each employment type (Permanent, Contractor, Intern)?
-- Show the count and what percentage of the total workforce each type represents.
-- Round the percentage to 1 decimal place.

-- YOUR ANSWER:


-- A4.
-- Find all access requests that were approved,
-- showing the employee username, role name, who approved it,
-- and how many days it took to approve (RequestedAt to ResolvedAt).
-- Order by days taken descending.

-- YOUR ANSWER:


-- ============================================================
-- SECTION B: JOINS (Questions 5-7)
-- ============================================================

-- B5.
-- Show the full access map for the IAM department only:
-- employee full name, application name, role name, and whether the role is privileged.
-- Include only active role assignments.

-- YOUR ANSWER:


-- B6.
-- Find all employees who have access to MORE THAN ONE application.
-- Show their username, department, and the count of distinct applications they have access to.
-- Order by application count descending.

-- YOUR ANSWER:


-- B7.
-- List every SoD conflict rule, showing:
-- the two conflicting role names, the applications they belong to,
-- the conflict reason, and severity.
-- Order by severity (Critical first).

-- YOUR ANSWER:


-- ============================================================
-- SECTION C: SUBQUERIES & CTEs (Questions 8-10)
-- ============================================================

-- C8.
-- Using a subquery, find all employees who have been assigned
-- at least one privileged role on a Critical risk application.
-- Show username, full name, and employment type.

-- YOUR ANSWER:


-- C9.
-- Write a CTE that calculates a risk score for each application:
--   +3 points for each privileged role
--   +1 point for each non-privileged role
--   +2 points for each user with active access
-- Show application name, risk level, and total score.
-- Order by score descending.

-- YOUR ANSWER:


-- C10.
-- Using CTEs, produce an "orphaned access" report:
-- terminated employees who still have active role assignments,
-- showing how many days have passed since their termination,
-- what roles they still hold, and flag any privileged access as URGENT.

-- YOUR ANSWER:


-- ============================================================
-- SECTION D: WINDOW FUNCTIONS (Questions 11-13)
-- ============================================================

-- D11.
-- For each department, rank employees by their number of active role assignments.
-- Show department name, username, role count, and their rank within the department.
-- Employees with the same role count should share a rank.

-- YOUR ANSWER:


-- D12.
-- Show each access request alongside the PREVIOUS request made by the same employee
-- (previous request date and its status).
-- Include employees who only have one request (previous values will be NULL).

-- YOUR ANSWER:


-- D13.
-- Divide all active employees into 3 risk tiers based on their total number of active roles:
-- Tier 1 = highest access, Tier 3 = lowest access.
-- Show username, employment type, role count, and tier.

-- YOUR ANSWER:


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
