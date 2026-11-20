-- A34Build DB (MySQL 8.0+ / InnoDB / utf8mb4) - E24-Class 5, Group 5
-- File 05: User Queries (Multi-Table Joins, Grouping & Filtering)

USE A34Build_DB;

-- Query 5.1: High-Salary Employee Workload by Department
-- List employees with Salary >= 15,000,000 VND and total logged hours > 0, sorted by hours descending.
SELECT 
    e.EmpID,
    CONCAT(e.FirstName, ' ', e.LastName) AS FullName,
    d.DeptName,
    e.Salary,
    COUNT(w.TaskID) AS TotalTasks,
    SUM(w.HoursLogged) AS TotalHoursLogged
FROM EMPLOYEE e
INNER JOIN DEPARTMENT d ON e.DeptID = d.DeptID
INNER JOIN WORKS_ON_TASK w ON e.EmpID = w.EmpID
WHERE e.Salary >= 15000000
GROUP BY e.EmpID, e.FirstName, e.LastName, d.DeptName, e.Salary
HAVING TotalHoursLogged > 0
ORDER BY TotalHoursLogged DESC;

-- Query 5.2: Active/Planning Projects & Site Count by Client
-- List non-cancelled projects with EstimatedBudget > 30B VND and >= 1 site, sorted by budget descending.
SELECT 
    p.ProjectID,
    p.ProjectName,
    p.Status,
    c.ClientName,
    p.EstimatedBudget,
    COUNT(ps.SiteID) AS TotalSites
FROM PROJECT p
INNER JOIN CLIENT c ON p.ClientID = c.ClientID
INNER JOIN PROJECT_SITE ps ON p.ProjectID = ps.ProjectID
WHERE p.Status <> 'Cancelled'
  AND p.EstimatedBudget > 30000000000
GROUP BY p.ProjectID, p.ProjectName, p.Status, c.ClientName, p.EstimatedBudget
HAVING TotalSites >= 1
ORDER BY p.EstimatedBudget DESC;
