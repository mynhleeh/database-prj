-- A34Build DB (MySQL 8.0+ / InnoDB / utf8mb4) - E24-Class 5, Group 5
-- File 06: Business Rule Verification & Trigger Tests (Rules 1-7, pairs with File 02)
-- Usage: Run SELECT checks together; run invalid INSERT/UPDATE checks individually (expect Error 1644 / SQLSTATE 45000).

USE A34Build_DB;

-- Rule 1: Phase budget total <= Project EstimatedBudget
SELECT 
    p.ProjectID,
    p.ProjectName,
    p.EstimatedBudget,
    COALESCE(SUM(pp.PhaseBudget), 0.00) AS TotalPhaseBudget,
    (p.EstimatedBudget - COALESCE(SUM(pp.PhaseBudget), 0.00)) AS RemainingBudget,
    CASE 
        WHEN COALESCE(SUM(pp.PhaseBudget), 0.00) <= p.EstimatedBudget THEN 'PASS'
        ELSE 'VIOLATION'
    END AS Rule1_Status
FROM PROJECT p
LEFT JOIN PROJECT_PHASE pp ON p.ProjectID = pp.ProjectID
GROUP BY p.ProjectID, p.ProjectName, p.EstimatedBudget
ORDER BY p.ProjectID;

INSERT INTO PROJECT_PHASE (ProjectID, PhaseNumber, PhaseName, PhaseBudget, StartDate, ScheduledEndDate, Status)
VALUES ('PRJ001', 4, 'Test Invalid Phase Budget Overrun', 30000000000.00, '2025-07-01', '2025-09-30', 'Pending');

UPDATE PROJECT_PHASE
SET PhaseBudget = 70000000000.00
WHERE ProjectID = 'PRJ001' AND PhaseNumber = 3;


-- Rule 2: Non-overlapping equipment deployment intervals
SELECT 
    ed1.EquipmentID,
    ed1.SiteID AS Site1,
    ed1.DeploymentStartDate AS Start1,
    ed1.DeploymentEndDate AS End1,
    ed2.SiteID AS Site2,
    ed2.DeploymentStartDate AS Start2,
    ed2.DeploymentEndDate AS End2
FROM EQUIPMENT_DEPLOYMENT ed1
JOIN EQUIPMENT_DEPLOYMENT ed2
    ON ed1.EquipmentID = ed2.EquipmentID
   AND ed1.DeploymentStartDate < ed2.DeploymentStartDate
   AND ed1.DeploymentEndDate >= ed2.DeploymentStartDate;

INSERT INTO EQUIPMENT_DEPLOYMENT (EquipmentID, DeploymentStartDate, DeploymentEndDate, OperatingHours, SiteID, OperatorEmpID)
VALUES ('EQP001', '2024-03-01', '2024-03-15', 50.00, 'SITE02', 'EMP010');

UPDATE EQUIPMENT_DEPLOYMENT
SET DeploymentEndDate = '2024-07-15'
WHERE EquipmentID = 'EQP001' AND DeploymentStartDate = '2024-01-10';


-- Rule 3: Operator certification must match equipment category
SELECT 
    ed.EquipmentID,
    eq.EquipmentName,
    eq.Category AS RequiredCategory,
    ed.DeploymentStartDate,
    ed.OperatorEmpID,
    CONCAT(e.FirstName, ' ', e.LastName) AS OperatorName,
    GROUP_CONCAT(ec.Certification SEPARATOR '; ') AS OperatorCertifications,
    CASE 
        WHEN EXISTS (
            SELECT 1
            FROM EMPLOYEE_CERTIFICATION ec2
            WHERE ec2.EmpID = ed.OperatorEmpID
              AND (ec2.Certification LIKE CONCAT('%', eq.Category, '%')
                   OR ec2.Certification LIKE '%Heavy Equipment%'
                   OR ec2.Certification LIKE '%Master Operator%')
        ) THEN 'PASS'
        ELSE 'VIOLATION'
    END AS Rule3_Status
FROM EQUIPMENT_DEPLOYMENT ed
JOIN EQUIPMENT eq ON ed.EquipmentID = eq.EquipmentID
JOIN EMPLOYEE e ON ed.OperatorEmpID = e.EmpID
LEFT JOIN EMPLOYEE_CERTIFICATION ec ON e.EmpID = ec.EmpID
GROUP BY ed.EquipmentID, eq.EquipmentName, eq.Category, ed.DeploymentStartDate, ed.OperatorEmpID, e.FirstName, e.LastName;

INSERT INTO EQUIPMENT_DEPLOYMENT (EquipmentID, DeploymentStartDate, DeploymentEndDate, OperatingHours, SiteID, OperatorEmpID)
VALUES ('EQP002', '2025-01-05', '2025-01-20', 40.00, 'SITE01', 'EMP014');

UPDATE EQUIPMENT_DEPLOYMENT
SET OperatorEmpID = 'EMP014'
WHERE EquipmentID = 'EQP003' AND DeploymentStartDate = '2024-04-15';


-- Rule 4: Max 12.00 logged hours per employee per day
SELECT 
    w.EmpID,
    CONCAT(e.FirstName, ' ', e.LastName) AS EmployeeName,
    w.AssignedDate,
    SUM(w.HoursLogged) AS TotalDailyHours,
    CASE 
        WHEN SUM(w.HoursLogged) <= 12.00 THEN 'PASS'
        ELSE 'VIOLATION'
    END AS Rule4_Status
FROM WORKS_ON_TASK w
JOIN EMPLOYEE e ON w.EmpID = e.EmpID
GROUP BY w.EmpID, e.FirstName, e.LastName, w.AssignedDate
ORDER BY w.AssignedDate, TotalDailyHours DESC;

INSERT INTO WORKS_ON_TASK (EmpID, TaskID, HoursLogged, RoleDescription, AssignedDate)
VALUES ('EMP008', 'TSK102', 5.00, 'Overtime Work', '2024-10-15');

UPDATE WORKS_ON_TASK
SET HoursLogged = 12.50
WHERE EmpID = 'EMP008' AND TaskID = 'TSK103';


-- Rule 5: Acyclic task precedence DAG on PRECEDES
WITH RECURSIVE TaskPaths AS (
    SELECT 
        PredecessorTaskID AS StartTask,
        SuccessorTaskID AS CurrentTask,
        CAST(CONCAT(PredecessorTaskID, ' -> ', SuccessorTaskID) AS CHAR(500)) AS DependencyPath,
        1 AS Depth,
        (PredecessorTaskID = SuccessorTaskID) AS HasCycle
    FROM PRECEDES
    UNION ALL
    SELECT 
        tp.StartTask,
        p.SuccessorTaskID,
        CONCAT(tp.DependencyPath, ' -> ', p.SuccessorTaskID),
        tp.Depth + 1,
        (p.SuccessorTaskID = tp.StartTask)
    FROM TaskPaths tp
    JOIN PRECEDES p ON tp.CurrentTask = p.PredecessorTaskID
    WHERE tp.HasCycle = 0 AND tp.Depth < 20
)
SELECT StartTask, CurrentTask, Depth, DependencyPath, HasCycle
FROM TaskPaths
ORDER BY StartTask, Depth;

INSERT INTO PRECEDES (PredecessorTaskID, SuccessorTaskID)
VALUES ('TSK101', 'TSK101');

INSERT INTO PRECEDES (PredecessorTaskID, SuccessorTaskID)
VALUES ('TSK103', 'TSK101');


-- Rule 6: Prevent stock overdraft & auto-update inventory
SELECT 
    si.SiteID,
    ps.SiteName,
    si.MaterialID,
    m.MaterialName,
    m.Unit,
    si.CurrentStockQuantity,
    si.MinStock,
    si.ReorderQuantity
FROM SITE_INVENTORY si
JOIN PROJECT_SITE ps ON si.SiteID = ps.SiteID
JOIN MATERIAL m ON si.MaterialID = m.MaterialID
ORDER BY si.SiteID, si.MaterialID;

INSERT INTO MATERIAL_USAGE (TaskID, MaterialID, SiteID, UsageDate, UsedQuantity)
VALUES ('TSK103', 'MAT001', 'SITE01', '2024-11-15', 9999.00);

INSERT INTO MATERIAL_USAGE (TaskID, MaterialID, SiteID, UsageDate, UsedQuantity)
VALUES ('TSK103', 'MAT002', 'SITE01', '2024-11-15', 5.00);

SELECT CurrentStockQuantity AS StockBeforeUsage
FROM SITE_INVENTORY WHERE SiteID = 'SITE01' AND MaterialID = 'MAT001';

INSERT INTO MATERIAL_USAGE (TaskID, MaterialID, SiteID, UsageDate, UsedQuantity)
VALUES ('TSK103', 'MAT001', 'SITE01', '2024-11-15', 10.00);

SELECT CurrentStockQuantity AS StockAfterUsage
FROM SITE_INVENTORY WHERE SiteID = 'SITE01' AND MaterialID = 'MAT001';

DELETE FROM MATERIAL_USAGE
WHERE TaskID = 'TSK103' AND MaterialID = 'MAT001' AND SiteID = 'SITE01' AND UsageDate = '2024-11-15';
UPDATE SITE_INVENTORY
SET CurrentStockQuantity = CurrentStockQuantity + 10.00
WHERE SiteID = 'SITE01' AND MaterialID = 'MAT001';

SELECT CurrentStockQuantity AS StockBeforeDelivery
FROM SITE_INVENTORY WHERE SiteID = 'SITE01' AND MaterialID = 'MAT001';

INSERT INTO DELIVERY_DISPATCH (DeliveryCode, DeliveryDate, DeliveredQuantity, Status, MaterialID, SiteID, ReceivedByEmpID, PO_ID)
VALUES ('DEL-TEST-001', '2024-11-16', 50.00, 'Received', 'MAT001', 'SITE01', 'EMP013', 'PO2024-001');

SELECT CurrentStockQuantity AS StockAfterDelivery
FROM SITE_INVENTORY WHERE SiteID = 'SITE01' AND MaterialID = 'MAT001';

DELETE FROM DELIVERY_DISPATCH WHERE DeliveryCode = 'DEL-TEST-001';
UPDATE SITE_INVENTORY
SET CurrentStockQuantity = CurrentStockQuantity - 50.00
WHERE SiteID = 'SITE01' AND MaterialID = 'MAT001';


-- Rule 7: At most one Active project per director
SELECT 
    p.DirectorEmpID,
    CONCAT(e.FirstName, ' ', e.LastName) AS DirectorName,
    SUM(CASE WHEN p.Status = 'Active' THEN 1 ELSE 0 END) AS ActiveProjectCount,
    COUNT(*) AS TotalProjectsAssigned,
    GROUP_CONCAT(CONCAT(p.ProjectID, ' (', p.Status, ')') SEPARATOR ', ') AS ProjectList,
    CASE 
        WHEN SUM(CASE WHEN p.Status = 'Active' THEN 1 ELSE 0 END) <= 1 THEN 'PASS'
        ELSE 'VIOLATION'
    END AS Rule7_Status
FROM PROJECT p
JOIN EMPLOYEE e ON p.DirectorEmpID = e.EmpID
GROUP BY p.DirectorEmpID, e.FirstName, e.LastName;

INSERT INTO PROJECT (
    ProjectID, ProjectName, ContractNumber, EstimatedBudget, ActualCost,
    StartDate, ScheduledEndDate, ActualEndDate, Status, ClientID, DeptID, DirectorEmpID
)
VALUES (
    'PRJ999', 'Test Duplicate Active Project', 'HD-TEST-999', 50000000000.00, 0.00,
    '2025-01-01', '2026-01-01', NULL, 'Active', 'CLI01', 'DEP03', 'EMP003'
);

UPDATE PROJECT
SET DirectorEmpID = 'EMP003', Status = 'Active'
WHERE ProjectID = 'PRJ003';
